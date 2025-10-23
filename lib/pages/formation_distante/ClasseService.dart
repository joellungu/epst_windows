import 'dart:convert';
import 'package:epst_windows_app/pages/formation_distante/Classe.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:http/http.dart' as http;

class ClasseService {
  static String baseUrl = '${Connexion.lien}classe';

  static Future<List<Classe>> getAllClasses() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print("jsonList: $jsonList");
        return jsonList.map((json) => Classe.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des classes');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}
