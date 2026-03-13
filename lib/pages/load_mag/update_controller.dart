import 'dart:convert';

import 'package:epst_windows_app/utils/utils.dart';
import 'package:get/get.dart';

class UpdateController extends GetxController {
  UpdateConnexion updateConnexion = UpdateConnexion();
  RxList listeEls = RxList();
  RxBool load = true.obs;
  getMags(String type) async {
    Response rep = await updateConnexion.getMags(type);
    if(rep.isOk){
      listeEls = rep.body;
    }
  }
  postMag(Map<String,dynamic> u) async {
    Response rep = await updateConnexion.postMag(u);
    if(rep.isOk){
      Get.back();
      Get.snackbar("SUCCES", "Votre magasin a bien été ajouté");
    }else{
      Get.back();
      Get.snackbar("ERREUR", "Votre magasin n'a bien été ajouté");
    }
  }
}

class UpdateConnexion extends GetConnect {
  Future<Response> getMags(String type) async => get("${Utils.lien}/magasin/all/$type");
  //
  Future<Response> getMag(String id) async => get("${Utils.lien}/magasin/$id");
  //
  Future<Response> postMag(Map<String,dynamic> u) => post("${Utils.lien}/magasin", jsonEncode(u));
  //

}