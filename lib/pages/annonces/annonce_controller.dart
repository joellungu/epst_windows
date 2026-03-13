import 'package:epst_windows_app/utils/requette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnonceController extends GetxController with StateMixin<List> {
  //
  Requette requette = Requette();
  //
  getAllAnnonces() async {
    //
    change([], status: RxStatus.loading());
    //
    Response response = await requette.getEs("annonce/all");
    //
    if (response.isOk) {
      change(response.body, status: RxStatus.success());
    } else {
      change([], status: RxStatus.empty());
    }
  }

  //
  supprimerAnnonces(String id) async {
    //
    change([], status: RxStatus.loading());
    //
    Response response = await requette.deleteEs("annonce?id=$id");
    //
    if (response.isOk) {
      Get.back();
      getAllAnnonces();
    } else {
      //
      Get.back();
      Get.snackbar("Oups", "Nous navons pas pu supprimer ça.");
    }
  }

  //
  Future<String> saveAnnonce(Map a) async {
    //
    //change([], status: RxStatus.loading());
    //
    Response response = await requette.postEs("annonce", a);
    //
    if (response.isOk) {
      Get.back();
      //getAllAnnonces();
      //change(response.body, status: RxStatus.success());
      return response.body;
    } else {
      Get.back();
      Get.snackbar(
        "Erreur",
        "Un problème est survenu lors de l'envoi au serveur.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return "0";
      //change([], status: RxStatus.empty());
    }
  }
}
