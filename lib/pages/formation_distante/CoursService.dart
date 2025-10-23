import 'dart:convert';
import 'package:epst_windows_app/pages/formation_distante/Cours.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:http/http.dart' as http;

class CoursService {
  static String baseUrl = '${Connexion.lien}cours';

  static Future<List<Cours>> getCoursByClasse(int cls, String categorie) async {
    try {
      //print("jsonList::: ${cls.runtimeType} ${categorie.runtimeType} ");
      // final uri = Uri.parse("$baseUrl/allcours").replace(queryParameters: {
      //   'cls': cls,
      //   'categorie': categorie,
      //   'typeFormation': 'Professeur'
      // });

      final response = await http.get(Uri.parse(
          "$baseUrl/allcours?idClasse=$cls&categorie=$categorie&typeFormation=Professeur"));

      // print("Erreur du à 1 : $cls");
      // print("Erreur du à 2 : $categorie");

      if (response.statusCode == 200 || response.statusCode == 201) {
        //
        final List<dynamic> jsonList = json.decode(response.body);
        print("jsonList : $jsonList");
        return jsonList.map((json) => Cours.fromJson(json)).toList();
      } else {
        return [];
        //throw Exception('Erreur lors du chargement des cours');
      }
    } catch (e) {
      print("Erreur du à : $e");
      return [];
      //throw Exception('Erreur de connexion: $e');
    }
  }
}
