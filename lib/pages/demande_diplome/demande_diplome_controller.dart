import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';

class DemandeDiplomesController extends GetxController with StateMixin<List> {
  //
  Requette requete = Requette();
  getAllDemande() async {
    //
    change([], status: RxStatus.loading());
    //
    Response response = await requete.getEs("diplome/all/demandeencour");
    //
    if (response.isOk) {
      //
      change(response.body, status: RxStatus.success());
    } else {
      //
      change([], status: RxStatus.empty());
    }
  }

  //
  Future<bool> setUpdate(String raison, int status, int id) async {
    //
    //change([], status: RxStatus.loading());
    //
    Response response =
        await requete.getEs("documentscolaire/update/$id/$status");
    //
    if (response.isOk) {
      //
      return true;
      //change(response.body, status: RxStatus.success());
    } else {
      //
      return true;
      //change([], status: RxStatus.empty());
    }
  }
}
