import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:epst_windows_app/pages/plainte/plainte.dart';
import 'package:http/http.dart' as http;

class Connexion {
  //
  //static var lien = 'https://epstapp.herokuapp.com/';
  static var lien = 'https://pepiteapp.herokuapp.com/';
  //static var lien = 'http://localhost:8080/';
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

  //
  static Future<Map<String, dynamic>> utilisateur_login(
      String matricule, String mdp) async {
    Map<String, dynamic> t = {};
    //
    var url = Uri.parse(lien + "agent/login/$matricule/$mdp");
    var response = await http.get(url);
    t = jsonDecode(response.body);
    //
    return t;
  }

  static Future<String> update_utilisateur(Map<String, dynamic> m) async {
    int t = 0;
    //
    var url = Uri.parse(lien + "agent");
    var response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(m),
    );
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
    Map<String, dynamic> m = jsonDecode(response.body);
    //
    print("${m['status']}");
    print(m['status'].runtimeType);
    print("______________________");

    return "${m['status']}";
  }

  //
  static Future<String> saveArchive(Map<String, dynamic> mag) async {
    //
    var url = Uri.parse(lien + "Archive/save");
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
    Map<String, dynamic> m = jsonDecode(response.body);
    //
    print("${m['status']}");
    print(m['status'].runtimeType);
    print("______________________");

    return "${m['status']}";
  }

  //
  static Future<int> majPlainte(Map<String, dynamic> mag) async {
    //
    var url = Uri.parse(lien + "plainte");
    //
    var response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(mag),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    Map<String, dynamic> m = jsonDecode(response.body);
    //
    if (response.statusCode == 200 || response.statusCode == 201) {
      //saveNote(note);
    }
    //else {
    return response.statusCode;
    //}
    print("${m['status']}");
    print(m['status'].runtimeType);
    print("______________________");

    //return "${m['status']}";
  }

  //
  static Future<String> saveNote(Map<String, dynamic> mag) async {
    //
    var url = Uri.parse(lien + "note/ajouter");
    //
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: "", //json.encode(mag),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    var m = response.body;
    //
    print("$m");
    //print(m['status'].runtimeType);
    print("______________________");
    Plainte.plainteState.setState(() {});

    return "";
  }

  //
  static Future<List<Map<String, dynamic>>> liste_magasin(int type) async {
    List<Map<String, dynamic>> liste = [];
    //
    var url = Uri.parse(lien + "magasin/all/$type");
    var response = await http.get(url, headers: {
      "Accept": "application/json, text/plain;charset=UTF-8",
      "Content-type": "application/json; charset=utf-8"
    });
    //String.fromCharCodes(charCodes)
    print("la reponse: ${Utf8Decoder().convert(response.body.codeUnits)}");
    //
    List rep_liste = json
        .decode(Utf8Decoder().convert(response.body.codeUnits)); //utf8.decode(
    rep_liste.forEach((element) {
      Map<String, dynamic> e = element;
      liste.add(e);
    });
    //print("-------------: $type");
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

  //____________________________________
  static Future<List<Map<String, dynamic>>> liste_plainte(String statut) async {
    List<Map<String, dynamic>> liste = [];
    //
    var url = Uri.parse(lien + "plainte/all/$statut");
    var response = await http.get(url);
    //
    try {
      List rep_liste = json.decode(response.body);
      //print(rep_liste);
      rep_liste.forEach((element) {
        Map<String, dynamic> e = element;
        //print("________les plaintes: $e");
        liste.add(e);
      });
    } catch (e) {
      print("$e");
    }

    return liste;
  }

  //____________________________________
  static Future<List<Map<String, dynamic>>> liste_plainteRec(
      String reference) async {
    List<Map<String, dynamic>> liste = [];
    //
    var url = Uri.parse(lien + "plainte/reference/$reference");
    var response = await http.get(url);
    //
    try {
      List rep_liste = json.decode(response.body);
      //print(rep_liste);
      rep_liste.forEach((element) {
        Map<String, dynamic> e = element;
        //print("________les plaintes: $e");
        liste.add(e);
      });
    } catch (e) {
      print("$e");
    }

    return liste;
  }

  //__________________________
  static Future<List<Map<String, dynamic>>> liste_piecejointe(
      String piecejointe_id) async {
    List<Map<String, dynamic>> liste = [];
    //
    var url = Uri.parse(lien + "piecejointe/all/$piecejointe_id");
    var response = await http.get(url);
    //
    print("(((((((((((())))))): $piecejointe_id");
    //print("(((((((((((())))))): ${response.body}");
    //
    try {
      List rep_liste = json.decode(response.body);
      //print(rep_liste);
      rep_liste.forEach((element) {
        Map<String, dynamic> e = element;
        print("________les plaintes: ${e['piecejointe_id']}");
        liste.add(e);
      });
    } catch (e) {
      print("erreur: $e");
    }

    return liste;
  }

  //__________________________
  static Future<int> majMag(String id, String path) async {
    var url = Uri.parse(lien + "client/multipart/$id");
    //
    Uint8List f = File(path).readAsBytesSync();
    var response = await http.post(
      url,
      headers: {
        //"Content-Type": "application/json",
      },

      body: f, //
    );
    print('Response status2: ${response.statusCode}');
    //print(response.body);
    //Map<String, dynamic> m = jsonDecode(response.body);
    //
    print("La reponse du serveur est: ${response.statusCode}");
    return response.statusCode;
    //
  }

  static Future<List> getArchive1(String matricule, String date) async {
    List t = [];
    //
    var url = Uri.parse(lien + "archive/a1/$matricule/$date");
    var response = await http.get(url);
    //print(response.body);
    //print(response.statusCode);
    if (response.statusCode == 201 || response.statusCode == 200) {
      //print(response.body);
      t = jsonDecode(response.body);
      //t = f.reversed.toList();
    }
    //
    return t;
  }

  static Future<List> getArchive2(
      String matricule, String date, String heure) async {
    List<dynamic> t = [];
    //
    var url = Uri.parse(lien + "archive/a2/$matricule/$date/$heure");
    var response = await http.get(url);
    print(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      print(response.body);
      var f = jsonDecode(response.body);
      t = f.reversed.toList();
    }
    //
    return t;
  }
}
///
//


