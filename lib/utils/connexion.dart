import 'dart:convert';

import 'package:http/http.dart' as http;

class Connexion {
  //
  static var lien = 'http://localhost:9090/';
  //
  static Future<String> enregistrement(Map<String, dynamic> utilisateur) async {
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

  static Future<List<Map<String, dynamic>>> liste_utilisateur() async {
    List<Map<String, dynamic>> liste = [];
    //
    var url = Uri.parse(lien + "agents");
    var response = await http.get(url);
    //
    List rep_liste = json.decode(response.body);
    rep_liste.forEach((element) {
      Map<String, dynamic> e = element;
      liste.add(e);
    });

    return liste;
  }
}
