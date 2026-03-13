import 'dart:convert';
import 'package:epst_windows_app/pages/formation_distante/Cours.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:http/http.dart' as http;

class CoursService {
  static String baseUrl = '${Connexion.lien}cours';

  static Future<List<Cours>> getCoursByClasse(
    String idClasse,
    String typeFormation,
  ) async {
    try {
      print("$baseUrl/allcours?idClasse=$idClasse&typeFormation=$typeFormation");

      final response = await http.get(
        Uri.parse(
          "$baseUrl/allcours?idClasse=$idClasse&typeFormation=$typeFormation",
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> jsonList = json.decode(response.body);
        print("jsonList : $jsonList");
        return jsonList.map((json) => Cours.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("Erreur du : $e");
      return [];
    }
  }

  static Future<bool> createCourseForSchedule({
    required String idClasse,
    required String cycle,
    required String title,
    required String typeFormation,
  }) async {
    try {
      final payload = {
        'cours': title.toLowerCase(),
        'propriete': typeFormation,
        'banche': '',
        'notion': '',
        'chapitre': 0,
        'type': 'horaire',
        'idClasse': idClasse,
        'cycle': cycle,
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Erreur creation cours: $e');
      return false;
    }
  }
}
