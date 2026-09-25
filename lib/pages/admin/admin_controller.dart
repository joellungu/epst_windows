import 'dart:async';
import 'dart:convert';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AdminController extends GetxController {
  //
  Requette requette = Requette();
  //
  Future<void> enregistrer(Map e) async {
    //
    print(e);
    try {
      http.Response rep = await http
          .post(
            Uri.parse("${Connexion.lien}agent"),
            headers: {
              "Accept": "*/*",
              "Content-Type": "application/json; charset=utf-8"
            },
            body: jsonEncode(e),
          )
          .timeout(const Duration(seconds: 30));
      print("${Connexion.lien}agent");
      if (rep.statusCode == 200 || rep.statusCode == 201) {
        print("code: ${rep.statusCode}");
        print("code: ${rep.body}");
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        Get.snackbar("Réussite", "Enregistrement effectué avec succès");
      } else {
        print("code: ${rep.statusCode}");
        print("code: ${rep.body}");
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        Get.snackbar("Erreur", "L'enregistrement n'a pas abouti");
      }
    } catch (ex) {
      print("Erreur enregistrement: $ex");
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        "Erreur",
        "Impossible de joindre le serveur. Vérifiez votre connexion internet.",
      );
    }
  }

  //
  //
  Future<void> updateAgent(Map e) async {
    //
    try {
      http.Response rep = await http
          .put(
            Uri.parse("${Connexion.lien}agent"),
            headers: {
              "Accept": "*/*",
              "Content-Type": "application/json; charset=utf-8"
            },
            body: jsonEncode(e),
          )
          .timeout(const Duration(seconds: 30));
      if (rep.statusCode == 200 || rep.statusCode == 201) {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        Get.snackbar("Réussite", "Modifications enregistrées avec succès");
      } else {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        Get.snackbar("Erreur", "La mise à jour n'a pas abouti");
      }
    } catch (ex) {
      print("Erreur mise à jour: $ex");
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      Get.snackbar(
        "Erreur",
        "Impossible de joindre le serveur. Vérifiez votre connexion internet.",
      );
    }
  }
}
