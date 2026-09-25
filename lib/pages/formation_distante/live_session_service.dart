import 'dart:convert';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:http/http.dart' as http;

/// Service Admin pour piloter les sessions live / vidéo streaming.
/// S'appuie sur les endpoints Quarkus :
/// POST /online/sessions/start, GET /online/sessions/live,
/// GET /online/sessions/recent, GET /online/sessions/{id}/participants,
/// POST /online/sessions/end, POST /online/sessions/teacher/access,
/// POST /online/sessions/student/access
class LiveSessionService {
  static String get _base => '${Connexion.lien}online/sessions';

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  static Future<List<Map<String, dynamic>>> listLive() async {
    final response = await http.get(
      Uri.parse('$_base/live'),
      headers: _headers,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    }
    throw Exception('Erreur chargement lives (${response.statusCode})');
  }

  static Future<List<Map<String, dynamic>>> listRecent({
    int limit = 100,
  }) async {
    final response = await http.get(
      Uri.parse('$_base/recent?limit=$limit'),
      headers: _headers,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    }
    throw Exception('Erreur historique lives (${response.statusCode})');
  }

  static Future<List<Map<String, dynamic>>> participants(int sessionId) async {
    final response = await http.get(
      Uri.parse('$_base/$sessionId/participants'),
      headers: _headers,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    }
    throw Exception('Erreur participants (${response.statusCode})');
  }

  /// Démarre une session live.
  /// hostRole: INSPECTOR_STUDENT (19), INSPECTOR_TEACHER (20),
  /// INSPECTOR_STREAMING (21 - vidéo streaming, audience libre).
  static Future<Map<String, dynamic>> start({
    required String classId,
    List<String>? classIds,
    required String title,
    required String hostMatricule,
    required String hostRole,
    String? audience,
    int maxParticipants = 100,
    bool recordingEnabled = false,
  }) async {
    final payload = {
      'classId': classId,
      if (classIds != null && classIds.isNotEmpty) 'classIds': classIds,
      'title': title,
      'hostMatricule': hostMatricule,
      'hostRole': hostRole,
      if (audience != null && audience.isNotEmpty) 'audience': audience,
      'maxParticipants': maxParticipants,
      'recordingEnabled': recordingEnabled,
    };
    final response = await http.post(
      Uri.parse('$_base/start'),
      headers: _headers,
      body: json.encode(payload),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(response.body));
    }
    throw Exception(
      'Demarrage impossible (${response.statusCode}): ${response.body}',
    );
  }

  static Future<void> end({
    required int sessionId,
    required String endedByMatricule,
    String endedByRole = 'ADMIN',
  }) async {
    final response = await http.post(
      Uri.parse('$_base/end'),
      headers: _headers,
      body: json.encode({
        'sessionId': sessionId,
        'endedByMatricule': endedByMatricule,
        'endedByRole': endedByRole,
      }),
    );
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      return;
    }
    throw Exception('Arret impossible (${response.statusCode})');
  }

  static String audienceLabel(String? audience) {
    switch ((audience ?? '').toUpperCase()) {
      case 'STUDENT':
        return 'Eleves';
      case 'TEACHER':
        return 'Enseignants';
      case 'BOTH':
        return 'Tous';
      default:
        return audience ?? '-';
    }
  }
}
