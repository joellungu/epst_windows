import 'dart:convert';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:http/http.dart' as http;

class OnlineScheduleService {
  static String baseUrl = '${Connexion.lien}online/schedules';

  static Future<List<Map<String, dynamic>>> getByClass(
    String classId, {
    String? audience,
  }) async {
    final query = audience != null ? '?audience=$audience' : '';
    final response = await http.get(Uri.parse('$baseUrl/class/$classId$query'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('Erreur lors du chargement des horaires');
  }

  static Future<Map<String, dynamic>> create({
    required String classId,
    required String title,
    required String audience,
    required String startsAt,
    required String endsAt,
    String? createdByMatricule,
  }) async {
    final payload = {
      'classId': classId,
      'title': title,
      'audience': audience,
      'startsAt': startsAt,
      'endsAt': endsAt,
      'createdByMatricule': createdByMatricule,
    }..removeWhere((key, value) => value == null || value.toString().isEmpty);

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(response.body));
    }

    throw Exception('Erreur lors de la creation: ${response.body}');
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    }
    throw Exception('Erreur lors de la suppression: ${response.body}');
  }
}
