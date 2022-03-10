import 'dart:convert';

import 'package:http/http.dart' as http;

class Connexion {
  //
  static var lien = 'http://localhost:8080/';
  //
  static Future<String> enregistrement(Map<String, dynamic> utilisateur) async {
    //
    print("utilisateur: ${json.encode(utilisateur)}");
    //
    var url = Uri.parse(lien + "agent");
    //
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(utilisateur),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    //print(response);
    return "";
    //return "${response.body}";
  }

  static Future<String> update_utilisateur(Map<String, dynamic> m) async {
    int t = 0;
    //
    var url = Uri.parse(lien + "agent");
    var response = await http.put(
      url,
      headers: {
        "Content-Type":"application/json"
      },
      body: jsonEncode(m),);
    //Map<String, dynamic> l = jsonDecode(response.body);
    //t = response.statusCode;
    //
    print("_______________: ${response.body}");
    print("_______________: ${json.encode(m)}");
    print("_______________: ${response.statusCode}");
    //
    return "";
  }

  static Future<int> supprimer_utilisateur(int id) async {
    int t = 0;
    //
    var url = Uri.parse(lien + "agent/$id");
    var response = await http.delete(url);
    t = response.statusCode;
    //
    return t;
  }
  
  static Future<List<Map<String, dynamic>>> liste_utilisateur() async {
    List<Map<String, dynamic>> liste = [];
    //
    var url = Uri.parse(lien + "agent/all");
    var response = await http.get(url);
    //
    List rep_liste = json.decode(response.body);
    print(rep_liste);
    rep_liste.forEach((element) {
      Map<String, dynamic> e = element;
      print("________les utilisateurs: $e");
      liste.add(e);
    });

    return liste;
  }
  //__________________________

  static Future<String> saveMagasin(Map<String, dynamic> mag) async {
    //
    var url = Uri.parse(lien + "magasin");
    //
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(mag),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    //
    return "";
  }

  //
  static Future<List<Map<String, dynamic>>> liste_magasin(int type) async {
    List<Map<String, dynamic>> liste = [];
    //
    var url = Uri.parse(lien + "magasin/all/$type");
    var response = await http.get(url);
    //
    List rep_liste = json.decode(response.body);
    rep_liste.forEach((element) {
      Map<String, dynamic> e = element;
      liste.add(e);
    });

    return liste;
  }

  //
  static Future<int> supprimer_magasin(int id) async {
    int t = 0;
    //
    var url = Uri.parse(lien + "magasin/$id");
    var response = await http.delete(url);
    t = response.statusCode;
    //
    return t;
  }
  //
  static Future<Map<String, dynamic>> getMagasin(int id) async {
    Map<String, dynamic> t = {};
    //
    var url = Uri.parse(lien + "magasin/$id");
    var response = await http.get(url);
    t = jsonDecode(response.body);
    //
    return t;
  }


}
