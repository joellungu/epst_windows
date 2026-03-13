import 'dart:async';
import 'package:epst_windows_app/pages/chat/ApiService.dart';
import 'package:epst_windows_app/pages/chat/Conversation.dart';
import 'package:epst_windows_app/pages/chat/Message.dart';
import 'package:epst_windows_app/pages/chat/MessageBubble.dart';
import 'package:epst_windows_app/pages/chat/SendMessageRequest.dart'
    hide MessageType;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgentChatScreen extends StatefulWidget {
  final Conversation conversation;
  final String agentMatricule;

  const AgentChatScreen({
    Key? key,
    required this.conversation,
    required this.agentMatricule,
  }) : super(key: key);

  @override
  _AgentChatScreenState createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
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
      // WebSocket pour nouveaux messages
    });
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
          sender: widget.agentMatricule,
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
        title: Text('Conversation avec ${widget.conversation.clientName}'),
      ),
      body: Column(
        children: [
          // En-tête de conversation
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                CircleAvatar(child: Text(widget.conversation.clientName[0])),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.conversation.clientName),
                    Text('Client ID: ${widget.conversation.clientId}'),
                  ],
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.sender == widget.agentMatricule;
                //
                Timer(const Duration(milliseconds: 100), () {
                  print("Conversation 1: ${message.type}");
                  print("Conversation 2: ${MessageType.TEXT}");
                  print("Conversation 3: ${message.type.runtimeType}");
                  print("Conversation 4: ${MessageType.TEXT.runtimeType}");
                  print(
                    "Conversation 5: ${message.type.name == MessageType.TEXT.name}",
                  );

                  converser.value = message.type.name == MessageType.TEXT.name;
                });

                return MessageBubble(message: message, isMe: isMe);
              },
            ),
          ),

          // Input
          Obx(
            () => Container(
              height: 48,
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
