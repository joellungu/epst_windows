import 'package:dio/dio.dart';
import 'package:epst_windows_app/pages/chat/Conversation.dart';
import 'package:epst_windows_app/pages/chat/Message.dart';
import 'package:epst_windows_app/pages/chat/SendMessageRequest.dart';
import 'package:epst_windows_app/utils/connexion.dart';

class ApiService {
  static String baseUrl = Connexion.lien; // 'http://192.168.1.68:8080';

  final Dio _dio = Dio();

  // Mobile: Démarrer une conversation
  Future<Conversation> startConversation(String clientName) async {
    final response = await _dio.post(
      '$baseUrl/conversations/start',
      data: {'clientName': clientName},
    );
    return Conversation.fromJson(response.data);
  }

  // Mobile: Démarrer une conversation
  Future<Conversation> checkConversation(int? id) async {
    final response = await _dio.get('$baseUrl/conversations/check/$id');
    return Conversation.fromJson(response.data);
  }

  // Desktop: Récupérer les conversations en attente
  Future<List<Conversation>> getPendingConversations() async {
    final response = await _dio.get('$baseUrl/conversations/pending');
    return (response.data as List)
        .map((json) => Conversation.fromJson(json))
        .toList();
  }

  // Desktop: Assigner un agent
  Future<Conversation> assignAgent(int conversationId, String matricule) async {
    final response = await _dio.put(
      '$baseUrl/conversations/$conversationId/assign/$matricule',
    );
    return Conversation.fromJson(response.data);
  }

  // Récupérer les messages d'une conversation
  Future<List<Message>> getMessages(int conversationId) async {
    final response = await _dio.get(
      '$baseUrl/messages/conversation/$conversationId',
    );
    return (response.data as List)
        .map((json) => Message.fromJson(json))
        .toList();
  }

  // Envoyer un message
  Future<Message> sendMessage(SendMessageRequest request) async {
    final response = await _dio.post(
      '$baseUrl/messages/send',
      data: request.toJson(),
    );
    return Message.fromJson(response.data);
  }

  // fermer la conversation
  Future<Message> fermerMessage(SendMessageRequest request) async {
    final response = await _dio.post(
      '$baseUrl/messages/fermer',
      data: request.toJson(),
    );
    return Message.fromJson(response.data);
  }

  // Vérifier le statut d'une conversation
  Future<Conversation> getConversation(int conversationId) async {
    final response = await _dio.get('$baseUrl/conversations/$conversationId');
    return Conversation.fromJson(response.data);
  }
}
