import 'dart:convert';

import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';

class CoursController extends GetxController with StateMixin<List>{
  RxList listeDeClasse = [].obs;
  Requette requette = Requette();

  getAllClasse() async {
    Response rep = await requette.getE("coure/all");
    if(rep.isOk){
      listeDeClasse.value = rep.body;
      //print(listeDeClasse);
      change(listeDeClasse,status: RxStatus.success());
    }else{
      change([],status: RxStatus.empty());
    }
  }

  addClasse(Map classe) async {
    Response rep = await requette.postE("coure/ajouter", jsonEncode(classe));
    if(rep.isOk){
      listeDeClasse.value = rep.body;
      change(listeDeClasse,status: RxStatus.success());
      Get.back();
      Get.snackbar("Ajouter", "Nouvelle classe ajouté");
    }else{
      change(listeDeClasse,status: RxStatus.empty());
      Get.back();
      Get.snackbar("Problème", "Code: ${rep.statusCode}");
      print("body: ${rep.body}");
    }
  }

  addMatiere(String idclasse, Map matiere) async {
    Response rep = await requette.postE("classe/addmatiere/$idclasse", jsonEncode(matiere));
    if(rep.isOk){
      listeDeClasse = rep.body;
      change(listeDeClasse,status: RxStatus.success());
    }else{
      change([],status: RxStatus.empty());
    }
  }

  addVideoEtQues(String idmatiere, var video) async {
    Response rep = await requette.postE("classe/addvideo/$idmatiere", video);
    if(rep.isOk){
      listeDeClasse = rep.body;
      change(listeDeClasse,status: RxStatus.success());
    }else{
      change([],status: RxStatus.empty());
    }
  }
  //
}