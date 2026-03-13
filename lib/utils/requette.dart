import 'package:get/get.dart';
import 'connexion.dart';

class Requette extends GetConnect {
  Future<Response> getEs(String path) async {
    print(":: ${Connexion.lien}$path");
    return get(
      "${Connexion.lien}$path",
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );
  }

  //
  Future<Response> postEs(String path, var data) async {
    return post(
      "${Connexion.lien}$path",
      data,
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );
  }

//
  Future<Response> putEs(String path, var data) async {
    return put(
      "${Connexion.lien}$path",
      data,
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );
  }

//
  Future<Response> deleteEs(String path) async {
    return delete(
      "${Connexion.lien}$path",
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/json; charset=utf-8"
      },
    );
  }
//
}
