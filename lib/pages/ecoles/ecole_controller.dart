import 'dart:convert';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EcoleController extends GetxController with StateMixin<List> {
  //
  Requette requette = Requette();
  //

  getAllEcoles() async {
    change([], status: RxStatus.empty());
    Response response = await requette.getEs("ecole/all");
    if (response.isOk) {
      //
      print("les ecoles: ${response.body}");
      //
      change(response.body, status: RxStatus.success());
    } else {
      change([], status: RxStatus.empty());
    }
  }

  //
  Future<void> enregistrer(Map e) async {
    //
    print(e);
    //http.get
    //var rep = await requette.postE("agent", e);
    http.Response rep = await http.post(
      Uri.parse("${Connexion.lien}ecole"),
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
      body: jsonEncode(e),
    );
    print("${Connexion.lien}agent");
    //requette.postE("agent", e);
    if (rep.statusCode == 200 || rep.statusCode == 201) {
      //
      print("code: ${rep.statusCode}");
      print("code: ${rep.body}");
      Get.back();
      Get.snackbar("Reussit", "Enregistrement effectué avec succes");
    } else {
      print("code: ${rep.statusCode}");
      print("code: ${rep.body}");
      Get.back();
      Get.snackbar("Erreur", "Enregistrement n'a pas abouti");
    }
  }
}
