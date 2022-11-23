import 'dart:async';
import 'dart:convert';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MutuelleController extends GetxController with StateMixin<List> {

  Requette requette = Requette();
  
  getAllDemande() async {
    change([],status: RxStatus.loading());
    //
    http.Response rep = await http.get(Uri.parse("${Connexion.lien}mutuelle/all/demande"));
    //await requette.getE("mutuelle/all/demande");
      if(rep.statusCode == 200 || rep.statusCode == 201){
        print(rep.statusCode);
        //print(rep.body);
        change(jsonDecode(rep.body),status: RxStatus.success());
      }else{
        print(rep.statusCode);
        print(rep.body);
        change([],status: RxStatus.empty());
      }
      //
  }
  //
  setStatus(int t, String id) async {
    change([],status: RxStatus.loading());
    //
    http.Response rep = await http.get(Uri.parse("${Connexion.lien}mutuelle/update/$id/$t"));
    //await requette.getE("mutuelle/all/demande");
    if(rep.statusCode == 200 || rep.statusCode == 201){
      getAllDemande();
    }else{
      getAllDemande();
    }
    //
  }
}