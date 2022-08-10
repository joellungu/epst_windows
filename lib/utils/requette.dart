import 'package:epst_windows_app/utils/utils.dart';
import 'package:get/get.dart';

class Requette extends GetConnect {
  Future<Response> getE(String path) async {
    return get("${Utils.lien}$path");
  }
  //
  Future<Response> postE(String path, String data) async {
    return post("${Utils.lien}$path", data);
  }
//
  Future<Response> putE(String path, String data) async {
    return put("${Utils.lien}$path", data);
  }
//
  Future<Response> deleteE(String path) async {
    return delete("${Utils.lien}$path");
  }
//

}