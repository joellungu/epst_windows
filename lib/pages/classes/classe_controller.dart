import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' hide Response;

class ClasseController extends GetxController {
  Requette requette = Requette();

  Future<List> getClasses() async {
    Response<dynamic> response = await requette.getEs(
      'classes',
    );
    if (response.isOk) {
      print('Classes récupérées avec succès');
      return response.body;
    } else {
      print(
        'Erreur lors de la récupération des classes: ${response.statusText}',
      );
      return Future.value([]);
    }
  }

  supprimerClasse({
    required String id,
  }) async {
    await requette.deleteEs(
      'classes/$id',
    );
  }

  Future<List> resetFiltres({
    required String niveau,
    required String cycle,
    String? section,
  }) async {
    Response<dynamic> response = await requette.getEs(
      'classes/search?niveau=$niveau&cycle=$cycle${section != null ? '&section=$section' : ''}',
    );
    if (response.isOk) {
      print('Classes r�cup�r�es avec succ�s');
      return response.body;
    } else {
      print(
        'Erreur lors de la r�cup�ration des classes: ${response.statusText}',
      );
      return Future.value([]);
    }
  }

  Future<Map<String, dynamic>> ajouterClasse({
    required String cle,
    required String nom,
    required String niveau,
    required String cycle,
    String? section,
    String? option,
    int? code,
    String? dateEnregistrement,
    String? updatedAt,
    String? anneescolaire,
  }) async {
    final payload = <String, dynamic>{
      'cle': cle,
      'nom': nom,
      'niveau': niveau,
      'cycle': cycle,
      'section': section,
      'option': option,
      'code': code,
      'dateEnregistrement': dateEnregistrement,
      'updatedAt': updatedAt,
      'anneescolaire': anneescolaire,
    }..removeWhere((_, value) => value == null);

    Response<dynamic> response = await requette.postEs(
      'classes',
      payload,
    );
    if (response.isOk) {
      getClasses();
      print('Classe ajout�e avec succ�s');
      return Future.value({'success': true, 'data': response.body});
    } else {
      print("Erreur lors de l'ajout de la classe: ${response.statusText}");
      return Future.value({
        'success': false,
        'data':
            '${response.statusCode} ${response.statusText} ${response.body}',
      });
    }
  }
}
