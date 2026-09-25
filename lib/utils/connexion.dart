import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:epst_windows_app/pages/plainte/plainte.dart';
import 'package:http/http.dart' as http;

class Connexion {
  //
  // static var lien = 'http://localhost:8080/';
  // static var ws = 'localhost:8080/';
  //
  static var lien = 'https://educ-app-serveur-43d00822f87c.herokuapp.com/';
  static var lien2 = 'https://smartkelasi-7109ee9b9b9b.herokuapp.com/';
  static var ws = 'educ-app-serveur-43d00822f87c.herokuapp.com/';
  //
  //static var lien = 'http://192.168.1.110:8080/';
  //static var ws = '192.168.1.110:8080/';
  //
  //static var lien = 'http://localhost:8080/';
  //static var ws = 'localhost:8080/';
  //
  //static var lien = 'http://45.90.220.130:8080/';
  //static var ws = '45.90.220.130:8080/';
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
    return "Enregistrement éffectuté";
    //return "${response.body}";
  }

  //
  static Future<Map<String, dynamic>> utilisateur_login(
      String matricule, String mdp) async {
    final mat = matricule.trim();
    final pass = mdp;

    if (mat.isEmpty || pass.isEmpty) {
      return {
        "ok": false,
        "message": "Veuillez saisir votre matricule et votre mot de passe."
      };
    }

    try {
      var url = Uri.parse(lien + "agent/login");
      var response = await http
          .post(
            url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json; charset=utf-8",
            },
            body: json.encode({"matricule": mat, "mdp": pass}),
          )
          .timeout(const Duration(seconds: 30));

      print("status: ${response.statusCode}");
      print("rep: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          return {"ok": true, "user": decoded};
        }
        return {
          "ok": false,
          "message": "Réponse inattendue du serveur. Veuillez réessayer."
        };
      }

      // Le serveur déployé ne connaît pas encore le nouveau POST /agent/login :
      // on retombe sur l'ancien GET /agent/login/{matricule}/{mdp}.
      if (response.statusCode == 404 || response.statusCode == 405) {
        return _loginAncienEndpoint(mat, pass);
      }

      return {
        "ok": false,
        "message":
            _messageErreurServeur(response.statusCode, response.bodyBytes)
      };
    } on TimeoutException {
      return {
        "ok": false,
        "message":
            "Délai de connexion dépassé. Vérifiez votre connexion internet puis réessayez."
      };
    } on SocketException {
      return {
        "ok": false,
        "message":
            "Impossible de joindre le serveur. Vérifiez votre connexion internet puis réessayez."
      };
    } on http.ClientException {
      return {
        "ok": false,
        "message":
            "Impossible de joindre le serveur. Vérifiez votre connexion internet puis réessayez."
      };
    } on FormatException {
      return {
        "ok": false,
        "message": "Réponse illisible du serveur. Veuillez réessayer."
      };
    } catch (e) {
      print("Erreur de connexion: $e");
      return {
        "ok": false,
        "message": "Une erreur inattendue est survenue. Veuillez réessayer."
      };
    }
  }

  static Future<Map<String, dynamic>> _loginAncienEndpoint(
      String mat, String pass) async {
    try {
      final url = Uri.parse(lien +
          "agent/login/${Uri.encodeComponent(mat)}/${Uri.encodeComponent(pass)}");
      final response = await http.get(
        url,
        headers: {"Accept": "application/json"},
      ).timeout(const Duration(seconds: 30));

      print("ancien endpoint status: ${response.statusCode}");
      print("ancien endpoint rep: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is Map<String, dynamic>) {
          final user = Map<String, dynamic>.from(decoded);
          if ("${user["id_statut"]}" == "0") {
            return {
              "ok": false,
              "message":
                  "Votre compte est désactivé. Veuillez contacter l'administrateur."
            };
          }
          if (user["matricule"] == null) {
            return {
              "ok": false,
              "message": "Matricule ou mot de passe incorrect."
            };
          }
          return {"ok": true, "user": user};
        }
      }
      return {
        "ok": false,
        "message": "Matricule ou mot de passe incorrect."
      };
    } on TimeoutException {
      return {
        "ok": false,
        "message":
            "Délai de connexion dépassé. Vérifiez votre connexion internet puis réessayez."
      };
    } on SocketException {
      return {
        "ok": false,
        "message":
            "Impossible de joindre le serveur. Vérifiez votre connexion internet puis réessayez."
      };
    } catch (e) {
      print("Erreur ancien endpoint: $e");
      return {
        "ok": false,
        "message": "Matricule ou mot de passe incorrect."
      };
    }
  }

  static String _messageErreurServeur(int statusCode, List<int> bodyBytes) {
    switch (statusCode) {
      case 400:
        return "Requête invalide. Veuillez vérifier vos informations.";
      case 401:
        return "Matricule ou mot de passe incorrect.";
      case 403:
        return "Votre compte est désactivé. Veuillez contacter l'administrateur.";
      case 404:
        return "Service introuvable. Contactez l'administrateur.";
      case 500:
      case 502:
      case 503:
        return "Le serveur rencontre un problème. Veuillez réessayer plus tard.";
      default:
        break;
    }
    try {
      final dynamic decoded = jsonDecode(utf8.decode(bodyBytes));
      if (decoded is Map<String, dynamic> && decoded["message"] != null) {
        return "${decoded["message"]}";
      }
    } catch (_) {}
    return "Connexion impossible (erreur $statusCode). Veuillez réessayer.";
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
    var url = Uri.parse("${lien}agent/all");
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
    //Map<String, dynamic> m = jsonDecode(response.body);
    //
    //print("${m['status']}");
    //print(m['status'].runtimeType);
    print("______________________");

    return "Cool ok!";
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
    print(mag);
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
      body: json.encode(mag),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    var m = response.body;
    //
    print("$m");
    //print(m['status'].runtimeType);
    print("______________________");
    Plainte.plainteState.setState(() {});

    return "${response.statusCode}";
  }

  //
  static Future<List<Map<String, dynamic>>> liste_magasin(int type) async {
    List<Map<String, dynamic>> liste = [];
    //
    print(lien + "magasin/all/$type");
    //
    var url = Uri.parse(lien + "magasin/all/$type");
    var response = await http.get(url, headers: {
      "Accept": "application/json, text/plain;charset=UTF-8",
      "Content-type": "application/json; charset=utf-8"
    });
    //String.fromCharCodes(charCodes)
    print("la reponse: ${response.body}");
    //
    List rep_liste = json.decode(response.body); //utf8.decode(
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
    if (response.statusCode == 200 || response.statusCode == 201) {
      //
      print("status:: ${response.statusCode}");
      print("rep:: ${response.body}");
      try {
        List rep_liste = json.decode(response.body);
        //print(rep_liste);
        rep_liste.forEach((element) {
          Map<String, dynamic> e = element;
          print("________les plaintes: $e");
          liste.add(e);
        });
      } catch (e) {
        print("$e");
      }
      print(liste.length);
      return liste;
    } else {
      print("status:: ${response.statusCode}");
      print("rep:: ${response.body}");
      return [];
    }
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
    print("(((((((((((())))))): ${response.body}");
    //
    try {
      List rep_liste = json.decode(response.body);
      //print(rep_liste);
      rep_liste.forEach((element) {
        Map<String, dynamic> e = element;
        print("________0000000 les plaintes: ${e['piecejointe_id']}");
        liste.add(e);
      });
    } catch (e) {
      print("erreur: $e");
    }

    return liste;
  }

  //__________________________
  static Future<int> majMag(String id, String ext, String path) async {
    try {
      var url = Uri.parse(lien + "client/multipart/$id");
      //
      Uint8List f = File(path).readAsBytesSync();
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/octet-stream", //"application/json",
        },
        body: f, //
      );
      print("le code: ${response.statusCode}");
      return response.statusCode;
    } catch (e) {
      print(e);
      return 0;
    }
    /*
    //return response.statusCode;
    var request = http.MultipartRequest('POST', Uri.parse(lien + "client/multipart1/$id/$ext"));
    request.files.add(http.MultipartFile('image',
        File(path).readAsBytes().asStream(), File(path).lengthSync(),
        filename: path.split("/").last));
    var res = await request.send();
    print("la reponse::: $res");
    */
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
      print(t);
      //t = f.reversed.toList();
    }
    //
    return t;
  }

  static Future<List> getArchive2(String matricule) async {
    List<dynamic> t = [];
    //
    var url = Uri.parse(lien + "archive/conv/$matricule");
    var response = await http.get(url);
    print(response.body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      print(response.body);
      var f = jsonDecode(response.body);
      t = f; //.reversed.toList()
    }
    //
    return t;
  }
}
//
