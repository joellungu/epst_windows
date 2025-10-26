import 'dart:async';
import 'package:epst_windows_app/pages/chat/AgentChatScreen.dart';
import 'package:epst_windows_app/pages/chat/ApiService.dart';
import 'package:epst_windows_app/pages/chat/Conversation.dart';
import 'package:epst_windows_app/pages/chat/SendMessageRequest.dart';
import 'package:flutter/material.dart';

class ConversationList extends StatefulWidget {
  final String agentMatricule;
  Map u;

  ConversationList(this.u, {Key? key, required this.agentMatricule})
      : super(key: key);

  @override
  _ConversationListState createState() => _ConversationListState();
}

class _ConversationListState extends State<ConversationList> {
  final ApiService _apiService = ApiService();
  List<Conversation> _pendingConversations = [];
  Conversation? _selectedConversation;

  @override
  void initState() {
    super.initState();
    _loadPendingConversations();
    // Polling pour nouvelles conversations
    _startPolling();
  }

  void _loadPendingConversations() async {
    try {
      final conversations = await _apiService.getPendingConversations();
      setState(() {
        _pendingConversations = conversations;
      });
    } catch (e) {
      print('Erreur chargement conversations: $e');
    }
  }

  void _startPolling() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      _loadPendingConversations();
    });
  }

  void _takeConversation(Conversation conversation) async {
    try {
      final updatedConversation = await _apiService.assignAgent(
        conversation.id!,
        widget.agentMatricule,
      );

      _selectedConversation = updatedConversation;
      _pendingConversations.remove(conversation);

      //
      await _apiService.sendMessage(
        SendMessageRequest(
          conversationId: updatedConversation.id!,
          sender: widget.agentMatricule,
          content:
              "Bonjour, je suis ${widget.u!['postnom']} ${widget.u!['prenom']} agent du ministère de l'EPST à la DGC, comment puis-je vous aider ?",
        ),
      );

      //
      setState(() {});
    } catch (e) {
      print('Erreur prise de conversation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Liste des conversations
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Conversations en attente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _pendingConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _pendingConversations[index];
                    return ListTile(
                      title: Text(conversation.clientName),
                      subtitle: Text(
                        'En attente depuis ${conversation.createdAt}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _takeConversation(conversation),
                        child: Text('Prendre'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Zone de chat
        Expanded(
          flex: 2,
          child: _selectedConversation != null
              ? AgentChatScreen(
                  conversation: _selectedConversation!,
                  agentMatricule: widget.agentMatricule,
                )
              : Center(child: Text('Sélectionnez une conversation')),
        ),
      ],
    );
  }
}
