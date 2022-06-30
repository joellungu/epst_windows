import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:get/get.dart';

class SendFileController extends GetxController {
  //
  SendFile sendFile = SendFile();
  postMag(String id,String type, String path) async {
    Response rep = await sendFile.postMag(id,type,path);
    if(rep.isOk){
      Get.back();
      Get.snackbar("Success", "Envoyé avec success");
    }else{
      Get.back();
      Get.snackbar("Erreur", "Erreur code: ${rep.statusCode}");
    }
  }
  //
  postMag1(Map<String,dynamic> mag) async {
    Response rep = await sendFile.postMag1(mag);
    if(rep.isOk){
      //Get.back();
      print("Envoyé avec success:  ${rep.statusCode}");
      Get.snackbar("Success", "Envoyé avec success:  ${rep.statusCode}");
    }else{
      //Get.back();
      print("Envoyé avec erreur:  ${rep.statusCode}");
      Get.snackbar("Erreur", "Erreur code: ${rep.statusCode}");
    }
  }
}

class SendFile extends GetConnect {

  Future<Response> postMag(String id,String type, String path) async {
    Uint8List f = File(path).readAsBytesSync();
    return post("${Connexion.lien}piecejointe/$id/$type", f);
  }
  //
  Future<Response> postMag1(Map<String,dynamic> mag) async {
    return post("${Connexion.lien}client/multipart1", jsonEncode(mag));
  }

}