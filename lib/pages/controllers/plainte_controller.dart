import 'package:epst_windows_app/utils/connexion.dart';
import 'package:get/get.dart';

class PlainteController extends GetxController {
  RxList listePieceJointe = [].obs;
  var reload = true.obs;
  //
  void reloads(int t) async {
    reload.value = true;
    listePieceJointe.value = await Connexion.liste_magasin(t);
    reload.value = false;
  }
}
