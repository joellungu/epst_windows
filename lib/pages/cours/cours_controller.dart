import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CoursController extends GetxController with StateMixin<List> {
  RxList listeDeClasse = [].obs;
  Requette requette = Requette();

  getAllClasse() async {
    //Response rep = await requette.getE("coure/all");
    http.Response rep = await http.get(
        Uri.parse(
          "${Connexion.lien}classes",
        ),
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json; charset=utf-8"
        });

    if (rep.statusCode == 200 || rep.statusCode == 201) {
      listeDeClasse.value = jsonDecode(rep.body);
      //print(listeDeClasse);
      print("rep: ${rep.body}");
      print("rep: ${rep.statusCode}");
      change(listeDeClasse, status: RxStatus.success());
    } else {
      print("rep: ${rep.body}");
      print("rep: ${rep.statusCode}");
      change([], status: RxStatus.empty());
    }
  }

  addClasse(Map classe) async {
    //Response rep = await requette.postE("coure/ajouter", jsonEncode(classe));
    http.Response rep = await http.post(
        Uri.parse(
          "${Connexion.lien}classe",
        ),
        body: jsonEncode(classe),
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json; charset=utf-8"
        });
    if (rep.statusCode == 200 || rep.statusCode == 201) {
      //listeDeClasse.value = jsonDecode(rep.body);
      //change(listeDeClasse, status: RxStatus.success());
      getAllClasse();
      Get.back();
      Get.snackbar("Ajouter", "Nouvelle classe ajouté");
    } else {
      //change(listeDeClasse, status: RxStatus.empty());
      Get.back();
      Get.snackbar("Problème", "Code: ${rep.statusCode}");
      print("body: ${rep.body}");
    }
  }

  //
  deleteClasse(int id) async {
    //Response rep = await requette.getE("coure/all");
    http.Response rep = await http.delete(
      Uri.parse(
        "${Connexion.lien}classe?id=$id",
      ),
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );

    if (rep.statusCode == 200 || rep.statusCode == 201) {
      //listeDeClasse.value = jsonDecode(rep.body);
      //print(listeDeClasse);
      print("rep: ${rep.body}");
      print("rep: ${rep.statusCode}");
      Get.snackbar(
        "Succès",
        "La classe a été supprimé",
        backgroundColor: Colors.green,
      );
      getAllClasse();
      //change(listeDeClasse, status: RxStatus.success());
    } else {
      print("rep: ${rep.body}");
      print("rep: ${rep.statusCode}");
      Get.snackbar(
        "Succès",
        "La classe n'a été supprimé",
        backgroundColor: Colors.red,
      );
      getAllClasse();
      //change([], status: RxStatus.empty());
    }
  }
}
