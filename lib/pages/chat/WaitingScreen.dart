import 'dart:async';
import 'package:epst_windows_app/pages/chat/ApiService.dart';
import 'package:epst_windows_app/pages/chat/ChatScreen.dart';
import 'package:epst_windows_app/pages/chat/Conversation.dart';
import 'package:flutter/material.dart';

class WaitingScreen extends StatefulWidget {
  @override
  _WaitingScreenState createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  final TextEditingController _nameController = TextEditingController();
  Conversation? _conversation;
  bool _isWaiting = false;
  int index = 0;
  Timer? tt;

  void _startConversation() async {
    if (_nameController.text.isEmpty) return;

    setState(() {
      _isWaiting = true;
      index++;
    });

    try {
      //
      final conversation = await ApiService().startConversation(
        _nameController.text,
      );
      setState(() {
        _conversation = conversation;
      });
      //
      print("conversation: $conversation");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       "${conversation.clientId} - ${conversation.status} - ${conversation.agentMatricule}",
      //     ),
      //   ),
      // );

      // Polling pour vérifier si un agent a rejoint
      _checkConversationStatus();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      setState(() {
        _isWaiting = false;
      });
    }
  }

  void _checkConversationStatus() async {
    tt = Timer.periodic(const Duration(seconds: 5), (t) async {
      //
      index++;
      _conversation = await ApiService().checkConversation(_conversation?.id!);

      // while (_conversation != null &&
      //     _conversation!.status == ConversationStatus.PENDING) {
      //   await Future.delayed(Duration(seconds: 2));
      //   // Implémenter la vérification du statut
      // }

      if (_conversation?.status == ConversationStatus.ACTIVE) {
        t.cancel();
        tt!.cancel();
        //
        setState(() {
          _isWaiting = false;
        });
        //
        Timer(const Duration(milliseconds: 100), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(conversation: _conversation!),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support Client')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!_isWaiting) ...[
              Text(
                'Bienvenue au support client',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Votre nom',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startConversation,
                child: Text('Démarrer la conversation'),
              ),
            ] else ...[
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('En attente d\'un agent... $index'),
              Text('Votre position dans la file: 1'),
            ],
          ],
        ),
      ),
    );
  }
}
