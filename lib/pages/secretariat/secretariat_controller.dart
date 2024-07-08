import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';

class SecretariatController extends GetxController with StateMixin<List> {
  //
  Requette requete = Requette();
  //
  Future<void> saveS(Map s) async {
    Response response = await requete.postEs("secretariat", s);
    if (response.isOk) {
      //
      print("rep ok: ${response.statusCode}");
      print("rep ok: ${response.body}");
      Get.back();
      allSecretariats();
      Get.snackbar("Succes", "Enregistrement éffectué");
    } else {
      //
      print("rep er: ${response.statusCode}");
      print("rep er: ${response.body}");
      Get.back();
      Get.snackbar("Erreur", "Enregistrement non éffectué");
    }
  }

  Future<void> updateS(Map s) async {
    Response response = await requete.putEs("secretariat", s);
    if (response.isOk) {
      //
      print("rep ok: ${response.statusCode}");
      print("rep ok: ${response.body}");

      Get.back();
      allSecretariats();
      Get.snackbar("Succes", "Enregistrement éffectué");
    } else {
      //
      print("rep er: ${response.statusCode}");
      print("rep er: ${response.body}");
      Get.back();
      Get.snackbar("Erreur", "Enregistrement non éffectué");
    }
  }

  //
  allSecretariats() async {
    //
    change([], status: RxStatus.loading());
    //
    Response response = await requete.getEs("secretariat/all");
    if (response.isOk) {
      //
      change(response.body, status: RxStatus.success());
      //
      //return response.body;
    } else {
      //
      change([], status: RxStatus.empty());
      //
    }
  }

  //
  supprimerS(String id) async {
    //change([], status: RxStatus.loading());
    Response response = await requete.deleteEs("secretariat/$id");
    if (response.isOk) {
      print(response.statusCode);
      print(response.body);
      allSecretariats();
    } else {
      print(response.statusCode);
      print(response.body);
    }
  }

  //
  Future<Map> getSecretarial(String id) async {
    //change([], status: RxStatus.loading());
    Response response = await requete.getEs("secretariat/$id");
    if (response.isOk) {
      print(response.statusCode);
      print(response.body);
      return response.body;
    } else {
      print(response.statusCode);
      print(response.body);
      return {};
    }
  }
  //
}
