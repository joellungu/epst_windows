import 'dart:convert';

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
          "${Connexion.lien}coure/all",
        ),
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json; charset=utf-8"
        });

    if (rep.statusCode == 200 || rep.statusCode == 201) {
      listeDeClasse.value = jsonDecode(rep.body);
      //print(listeDeClasse);
      change(listeDeClasse, status: RxStatus.success());
    } else {
      change([], status: RxStatus.empty());
    }
  }

  addClasse(Map classe) async {
    //Response rep = await requette.postE("coure/ajouter", jsonEncode(classe));
    http.Response rep = await http.post(
        Uri.parse(
          "${Connexion.lien}coure/ajouter",
        ),
        body: jsonEncode(classe),
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json; charset=utf-8"
        });
    if (rep.statusCode == 200 || rep.statusCode == 201) {
      listeDeClasse.value = jsonDecode(rep.body);
      change(listeDeClasse, status: RxStatus.success());
      Get.back();
      Get.snackbar("Ajouter", "Nouvelle classe ajouté");
    } else {
      change(listeDeClasse, status: RxStatus.empty());
      Get.back();
      Get.snackbar("Problème", "Code: ${rep.statusCode}");
      print("body: ${rep.body}");
    }
  }

  addMatiere(String idclasse, Map matiere) async {
    //Response rep = await requette.postE(
    //  "classe/addmatiere/$idclasse", jsonEncode(matiere));
    http.Response rep = await http.post(
        Uri.parse(
          "${Connexion.lien}classe/addmatiere/$idclasse",
        ),
        body: jsonEncode(matiere),
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json; charset=utf-8"
        });

    if (rep.statusCode == 200 || rep.statusCode == 201) {
      listeDeClasse = jsonDecode(rep.body);
      change(listeDeClasse, status: RxStatus.success());
    } else {
      change([], status: RxStatus.empty());
    }
  }

  addVideoEtQues(String idmatiere, var video) async {
    //Response rep = await requette.postE("classe/addvideo/$idmatiere", video);
    http.Response rep = await http.post(
        Uri.parse(
          "${Connexion.lien}classe/addvideo/$idmatiere",
        ),
        body: video,
        headers: {
          "Accept": "*/*",
          "Content-Type": "application/json; charset=utf-8"
        });
    if (rep.statusCode == 200 || rep.statusCode == 201) {
      listeDeClasse = jsonDecode(rep.body);
      change(listeDeClasse, status: RxStatus.success());
    } else {
      change([], status: RxStatus.empty());
    }
  }
  //
}
