import 'package:get/get.dart';
import 'connexion.dart';

class Requette extends GetConnect {
  Future<Response> getE(String path) async {
    print(":: ${Connexion.lien}$path");
    return get("${Connexion.lien}$path");
  }
  //
  Future<Response> postE(String path, String data) async {
    return post("${Connexion.lien}$path", data);
  }
//
  Future<Response> putE(String path, String data) async {
    return put("${Connexion.lien}$path", data);
  }
//
  Future<Response> deleteE(String path) async {
    return delete("${Connexion.lien}$path");
  }
//

}