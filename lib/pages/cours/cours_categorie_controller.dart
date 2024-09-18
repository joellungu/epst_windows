import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CoursCategorieController extends GetxController with StateMixin<List> {
  RxList listeDeClasse = [].obs;
  Requette requette = Requette();

  getAllClasse(int cls, String categorie, String typeFormation) async {
    categorie = categorie.toLowerCase();
    //Response rep = await requette.getE("coure/all");
    change([], status: RxStatus.loading());
    //
    print("cls: $cls, categorie: $categorie");
    http.Response rep = await http.get(
      Uri.parse(
        "${Connexion.lien}cours/allcours?cls=$cls&categorie=$categorie&typeFormation=$typeFormation",
      ),
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );

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

  Future<String> addCours(Map c) async {
    //Response rep = await requette.postE("coure/ajouter", jsonEncode(classe));
    print("Envois...");
    http.Response rep = await http.post(
        Uri.parse(
          "${Connexion.lien}cours",
        ),
        body: jsonEncode(c),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json"
        });
    //charset=utf-8
    if (rep.statusCode == 200 || rep.statusCode == 201) {
      //listeDeClasse.value = jsonDecode(rep.body);
      //change(listeDeClasse, status: RxStatus.success());
      //Get.back();
      return rep.body;
      //Get.snackbar("Ajouter", "Nouvelle classe ajouté");
    } else {
      //change(listeDeClasse, status: RxStatus.empty());
      //Get.back();
      print("Problème Code: ${rep.statusCode}");
      print("Problème Code: ${rep.statusCode}");
      Get.snackbar("Problème", "Code: ${rep.statusCode}");
      print("body: ${rep.body}");
      return "0";
    }
  }

//
  deleteCours(Map cours) async {
    //Response rep = await requette.getE("coure/all");
    http.Response rep = await http.delete(
      Uri.parse(
        "${Connexion.lien}cours?id=${cours['id']}",
      ),
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );

    if (rep.statusCode == 200 ||
        rep.statusCode == 201 ||
        rep.statusCode == 204) {
      //listeDeClasse.value = jsonDecode(rep.body);
      //print(listeDeClasse);
      print("rep: ${rep.body}");
      print("rep: ${rep.statusCode}");
      Get.snackbar(
        "Succès",
        "Le cours a été supprimé",
        backgroundColor: Colors.green,
      );
      getAllClasse(cours['cls'], cours['categorie'], cours['propriete']);
      //change(listeDeClasse, status: RxStatus.success());
    } else {
      print("rep: ${rep.body}");
      print("rep: ${rep.statusCode}");
      Get.snackbar(
        "Succès",
        "Le cours n'a été supprimé",
        backgroundColor: Colors.red,
      );
      getAllClasse(cours['cls'], cours['categorie'], cours['propriete']);
      //change([], status: RxStatus.empty());
    }
  }
}
