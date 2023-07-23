import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';

class ParametreController extends GetxController {
  Requette requete = Requette();

  Future<double> setTaux(double taux) async {
    Response rep = await requete.deleteEs("paiement/devise");
    if (rep.isOk) {
      Map e = {
        "devise": "USD",
        "taux": taux,
      };
      print("Suppression effectué");
      Response rep2 = await requete.postEs("paiement/devise", e);
      if (rep2.isOk) {
        print("ajoue effectué effectué");
        print(rep2.body);
        //
        return rep2.body;
      } else {
        print(rep2.body);
        //
        return 1;
      }
      //
      return rep.body;
    } else {
      print(rep.body);
      //
      return 1;
    }
  }

  Future<double> getTaux() async {
    Response rep = await requete.getEs("paiement/devise");
    if (rep.isOk) {
      print(rep.body);
      //
      return rep.body;
    } else {
      print(rep.body);
      //
      return 1;
    }
  }
}
