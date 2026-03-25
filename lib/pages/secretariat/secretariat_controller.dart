import 'dart:convert';
import 'dart:io';

import 'package:epst_windows_app/utils/requette.dart';
import 'package:get/get.dart';

class SecretariatController extends GetxController with StateMixin<List> {
  //
  Requette requete = Requette();
  //
  Future<void> saveS(
    Map s, {
    File? photoProfil,
    File? photoArrete,
    List<Map<String, dynamic>> departementPhotos = const [],
  }) async {
    Response response = await requete.postEs("secretariat", s);
    if (response.isOk) {
      final data = response.body;
      final id = data != null ? data["id"] : null;
      if (id != null) {
        if (photoProfil != null) {
          await requete.uploadFile("secretariat/$id/photoProfil", photoProfil);
        }
        if (photoArrete != null) {
          await requete.uploadFile("secretariat/$id/arrete/photo", photoArrete);
        }
        final List? createdDeps = data != null ? data["departements"] : null;
        int i = 0;
        for (final dp in departementPhotos) {
          dynamic depId = dp["id"];
          if (depId == null && createdDeps != null && i < createdDeps.length) {
            depId = createdDeps[i]["id"];
          }
          final File? file = dp["file"];
          if (depId != null && file != null) {
            await requete.uploadFile(
                "secretariat/departement/$depId/photo", file);
          }
          i++;
        }
      }
      Get.back();
      allSecretariats();
      Get.snackbar("Succes", "Enregistrement effectué");
    } else {
      print("rep er: ${response.statusCode}");
      print("rep er: ${response.body}");
      Get.back();
      Get.snackbar("Erreur", "Enregistrement non effectué");
    }
  }

  Future<void> updateS(
    Map s, {
    File? photoProfil,
    File? photoArrete,
    List<Map<String, dynamic>> departementPhotos = const [],
  }) async {
    final id = s["id"];
    Response response = await requete.putEs("secretariat/$id", s);
    if (response.isOk) {
      if (id != null) {
        if (photoProfil != null) {
          await requete.uploadFile("secretariat/$id/photoProfil", photoProfil);
        }
        if (photoArrete != null) {
          await requete.uploadFile("secretariat/$id/arrete/photo", photoArrete);
        }
        final data = response.body;
        final List? updatedDeps = data != null ? data["departements"] : null;
        int i = 0;
        for (final dp in departementPhotos) {
          dynamic depId = dp["id"];
          if (depId == null && updatedDeps != null && i < updatedDeps.length) {
            depId = updatedDeps[i]["id"];
          }
          final File? file = dp["file"];
          if (depId != null && file != null) {
            await requete.uploadFile(
                "secretariat/departement/$depId/photo", file);
          }
          i++;
        }
      }
      Get.back();
      allSecretariats();
      Get.snackbar("Succes", "Mise Ã  jour effectuÃ©e");
    } else {
      print("rep er: ${response.statusCode}");
      print("rep er: ${response.body}");
      Get.back();
      Get.snackbar("Erreur", "Mise Ã  jour non effectuÃ©e");
    }
  }

  Future<void> saveFull(
    Map s, {
    File? photoProfil,
    File? photoArrete,
    List<File?> departementPhotos = const [],
    void Function(int sent, int total)? onProgress,
  }) async {
    final files = <dynamic>[];
    files.add(requete.jsonPart("payload", jsonEncode(s)));
    if (photoProfil != null) {
      files.add(await requete.filePart("photoProfil", photoProfil));
    }
    if (photoArrete != null) {
      files.add(await requete.filePart("photoArrete", photoArrete));
    }
    final List<int> depIndexes = [];
    for (int i = 0; i < departementPhotos.length; i++) {
      final f = departementPhotos[i];
      if (f != null) {
        depIndexes.add(i);
        files.add(await requete.filePart("departementPhoto", f));
      }
    }

    Response response = await requete.sendMultipartWithProgress(
      "POST",
      "secretariat/full",
      fields: {
        "departementIndexCsv": depIndexes.join(","),
      },
      files: List.from(files),
      onProgress: onProgress,
    );
    if (response.isOk) {
      Get.back();
      allSecretariats();
      Get.snackbar("Succes", "Enregistrement effectuÃ©");
    } else {
      print("saveFull status: ${response.statusCode}");
      print("saveFull body: ${response.body}");
      print("saveFull bodyString: ${response.bodyString}");
      print("saveFull headers: ${response.headers}");
      Get.back();
      Get.snackbar("Erreur", "Enregistrement non effectuÃ©");
    }
  }

  Future<void> updateFull(
    Map s, {
    File? photoProfil,
    File? photoArrete,
    List<File?> departementPhotos = const [],
    void Function(int sent, int total)? onProgress,
  }) async {
    final id = s["id"];
    final files = <dynamic>[];
    files.add(requete.jsonPart("payload", jsonEncode(s)));
    if (photoProfil != null) {
      files.add(await requete.filePart("photoProfil", photoProfil));
    }
    if (photoArrete != null) {
      files.add(await requete.filePart("photoArrete", photoArrete));
    }
    final List<int> depIndexes = [];
    for (int i = 0; i < departementPhotos.length; i++) {
      final f = departementPhotos[i];
      if (f != null) {
        depIndexes.add(i);
        files.add(await requete.filePart("departementPhoto", f));
      }
    }

    Response response = await requete.sendMultipartWithProgress(
      "PUT",
      "secretariat/$id/full",
      fields: {
        "departementIndexCsv": depIndexes.join(","),
      },
      files: List.from(files),
      onProgress: onProgress,
    );
    if (response.isOk) {
      Get.back();
      allSecretariats();
      Get.snackbar("Succes", "Mise Ã  jour effectuÃ©e");
    } else {
      print("updateFull status: ${response.statusCode}");
      print("updateFull body: ${response.body}");
      print("updateFull bodyString: ${response.bodyString}");
      print("updateFull headers: ${response.headers}");
      Get.back();
      Get.snackbar("Erreur", "Mise Ã  jour non effectuÃ©e");
    }
  }

  //
  allSecretariats() async {
    //
    change([], status: RxStatus.loading());
    //
    Response response = await requete.getEs("secretariat/all");
    if (response.isOk) {
      //
      change(response.body, status: RxStatus.success());
      //
      //return response.body;
    } else {
      //
      change([], status: RxStatus.empty());
      //
    }
  }

  //
  supprimerS(String id) async {
    //change([], status: RxStatus.loading());
    Response response = await requete.deleteEs("secretariat/$id");
    if (response.isOk) {
      print(response.statusCode);
      print(response.body);
      allSecretariats();
    } else {
      print(response.statusCode);
      print(response.body);
    }
  }

  //
  Future<Map> getSecretarial(String id) async {
    //change([], status: RxStatus.loading());
    Response response = await requete.getEs("secretariat/detail?id=$id");
    if (response.isOk) {
      print(response.statusCode);
      print(response.body);
      return response.body;
    } else {
      print(response.statusCode);
      print(response.body);
      return {};
    }
  }
  //
}
