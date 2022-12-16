import 'dart:async';
import 'dart:convert';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InspecteurController extends GetxController with StateMixin<List> {
  Requette requette = Requette();

  Future<List> getAllDemandeByMatricule(String matricule) async {
    //
    http.Response rep = await http.get(Uri.parse(
        "${Connexion.lien}mutuelle/all/demandebymatricule?matricule=$matricule"));
    //await requette.getE("mutuelle/all/demande");
    if (rep.statusCode == 200 || rep.statusCode == 201) {
      print(rep.statusCode);
      print(rep.body);
      //print(rep.body);
      //change(jsonDecode(rep.body), status: RxStatus.success());
      return jsonDecode(rep.body);
    } else {
      print(rep.statusCode);
      print(rep.body);
      return [];
    }
    //
  }
  //

  getAllDemande(String province, String district) async {
    change([], status: RxStatus.loading());
    //
    http.Response rep = await http.get(Uri.parse(
        "${Connexion.lien}mutuelle/all/demande?province=$province&district=$district"));
    //await requette.getE("mutuelle/all/demande");
    if (rep.statusCode == 200 || rep.statusCode == 201) {
      print(rep.statusCode);
      print(rep.body);
      //print(rep.body);
      change(jsonDecode(rep.body), status: RxStatus.success());
    } else {
      print(rep.statusCode);
      print(rep.body);
      change([], status: RxStatus.empty());
    }
    //
  }

  //
  setStatus(int t, String id, String province, String district) async {
    change([], status: RxStatus.loading());
    //
    http.Response rep =
        await http.get(Uri.parse("${Connexion.lien}mutuelle/update/$id/$t"));
    //await requette.getE("mutuelle/all/demande");
    if (rep.statusCode == 200 || rep.statusCode == 201) {
      getAllDemande(province, district);
    } else {
      getAllDemande(province, district);
    }
    //
  }
}
