import 'dart:async';
import 'package:epst_windows_app/pages/chat/ApiService.dart';
import 'package:epst_windows_app/pages/chat/Conversation.dart';
import 'package:epst_windows_app/pages/chat/Message.dart';
import 'package:epst_windows_app/pages/chat/MessageBubble.dart';
import 'package:epst_windows_app/pages/chat/SendMessageRequest.dart'
    hide MessageType;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> _messages = [];
  final ApiService _apiService = ApiService();
  //
  Timer? tt;
  //
  RxBool converser = true.obs;

  @override
  void initState() {
    super.initState();
    tt = Timer.periodic(const Duration(seconds: 2), (t) async {
      _loadMessages();
    });
    // Démarrer WebSocket pour les nouveaux messages
  }

  void _loadMessages() async {
    try {
      List<Message> messages = await _apiService.getMessages(
        widget.conversation.id!,
      );
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      print('Erreur chargement messages: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Message d'erreur: $e")));
    }
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    try {
      await _apiService.sendMessage(
        SendMessageRequest(
          conversationId: widget.conversation.id!,
          sender: widget.conversation.clientId,
          content: message,
        ),
      );
    } catch (e) {
      print('Erreur envoi message: $e');
    }
  }

  void _fermerMessage() async {
    final message = _messageController.text;
    _messageController.clear();

    try {
      await _apiService.fermerMessage(
        SendMessageRequest(
          conversationId: widget.conversation.id!,
          sender: widget.conversation.clientId,
          content: message,
        ),
      );
    } catch (e) {
      print('Erreur envoi message: $e');
    }
  }

  @override
  void dispose() {
    //
    tt!.cancel();
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conversation avec ${widget.conversation.agentMatricule ?? 'Agent'}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.sender == widget.conversation.clientId;
                // ignore: unrelated_type_equality_checks
                // converser.value = message.type == MessageType.TEXT;
                //
                Timer(const Duration(milliseconds: 100), () {
                  converser.value = message.type.name == MessageType.TEXT.name;
                });

                return MessageBubble(message: message, isMe: isMe);
              },
            ),
          ),
          Obx(
            () => Container(
              height: 65,
              alignment: Alignment.center,
              padding: EdgeInsets.all(8.0),
              child: converser.value
                  ? Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red.shade700),
                          onPressed: _fermerMessage,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Tapez votre message...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                      ],
                    )
                  : Text("La conversation a été fermé."),
            ),
          ),
        ],
      ),
    );
  }
}
