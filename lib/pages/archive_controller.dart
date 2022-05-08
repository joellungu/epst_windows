import 'package:epst_windows_app/utils/connexion.dart';
import 'package:get/get.dart';

class ArchiveController extends GetxController {
  //
  RxList listeConvArchive = [].obs;
  //
  RxList conversation = [].obs;
  //
  var load1 = false.obs;
  //
  var load2 = false.obs;
  //
  getListeConv1(String matricule, String d) async {
    listeConvArchive.value.clear();
    listeConvArchive.value = await Connexion.getArchive1(matricule, d);
  }

  //
  getListeConv2(String matricule, String d, String h) async {
    conversation.value.clear();
    conversation.value = await Connexion.getArchive2(matricule, d, h);
  }
}
