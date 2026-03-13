import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'annonce_controller.dart';

final dio = Dio();

class Annonces extends GetView<AnnonceController> {
  //
  RxString path = "".obs;
  //
  RxString percentage = "".obs;
  RxDouble pr = 0.0.obs;
  //
  Annonces() {
    //
    controller.getAllAnnonces();
  }
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: controller.obx(
        (s) {
          List annonces = s!;
          return GridView.count(
            crossAxisCount: 4,
            childAspectRatio: 0.7,
            children: List.generate(annonces.length, (a) {
              //

              //
              return Card(
                elevation: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                "${Connexion.lien}annonce/image?id=${annonces[a]}"),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      onPressed: () async {
                        //
                        Get.dialog(
                          Center(
                            child: Container(
                              height: 40,
                              width: 40,
                              child: const CircularProgressIndicator(),
                            ),
                          ),
                        );
                        //
                        controller.supprimerAnnonces("${annonces[a]}");
                        //
                      },
                      child: const Text(
                        "Supprimer",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              );
            }),
          );
        },
        onEmpty: Container(),
        onLoading: Center(
          child: Container(
            height: 40,
            width: 40,
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: false,
            type: FileType.custom,
            allowedExtensions: ['png', 'PNG', 'jpeg', 'JPEG', 'jpg', 'JPG'],
          );

          if (result == null) {
            return;
          }

          final File? file = File(result.paths[0]!);
          if (file != null) {
            //_handleLostFiles(files);
            //
            Get.dialog(
              Center(
                child: Card(
                  elevation: 1,
                  child: Container(
                    height: 400,
                    width: 300,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(
                                  File(result.paths[0]!),
                                ),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            //
                            Get.back();
                          },
                          child: const Text(
                            "Annuler",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () async {
                            //
                            Get.back();
                            //
                            Get.dialog(
                              Center(
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  child: const CircularProgressIndicator(),
                                ),
                              ),
                            );
                            //
                            var r = Random();
                            Map a = {
                              "nom":
                                  "${r.nextInt(9)}-${r.nextInt(9)}-${r.nextInt(9)}-${r.nextInt(9)}-${r.nextInt(9)}-${r.nextInt(9)}-${r.nextInt(9)}-${r.nextInt(9)}-${r.nextInt(9)}",
                              "image": null,
                            };
                            //

                            String id = await controller.saveAnnonce(a);
                            if (id == "0") {
                              Get.snackbar("Oups",
                                  "Erreur lors de l'envoie au serveur.");
                            } else {
                              //
                              Get.dialog(
                                Center(
                                  child: Container(
                                    height: 50,
                                    width: 360,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.all(5),
                                      height: 35,
                                      width: double.maxFinite,
                                      child: Obx(
                                        () => LinearPercentIndicator(
                                          width: 350,
                                          lineHeight: 20.0,
                                          percent: pr / 100,
                                          center: Text(
                                            "${pr.value} %",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          backgroundColor: Colors.grey.shade400,
                                          progressColor: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              //
                              send(id, file.readAsBytesSync());
                            }
                          },
                          child: const Text(
                            "Ajouter",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            //_handleError(response.exception);
            //
            Get.dialog(
              Center(
                child: Card(
                  elevation: 1,
                  child: Container(
                    height: 120,
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text("Une erreur c'est produit"),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                          ),
                          onPressed: () {
                            //
                            Get.back();
                            //
                          },
                          child: const Text(
                            "Annuler",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  //
  send(String id, Uint8List media) async {
    var res = await dio.put(
      "${Connexion.lien}annonce?id=$id",
      data: media,
      options: Options(headers: {"Content-Type": "application/octet-stream"}),
      onSendProgress: (int sent, int total) {
        percentage.value = (sent / total * 100).toStringAsFixed(2);
        pr.value = double.parse(percentage.value);
        print("::::::::: $percentage ");
        /*
                                      progress = "$sent" +
                                      " Bytes of " "$total Bytes - " +
                                      percentage +
                                      " % uploaded";
                                    */
        print("::::::::: $sent"
                " Bytes of "
                "$total Bytes - " +
            percentage.value +
            " % uploaded");
        //update the progress
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      print(res.toString());
      //print response from server
      Get.back();
      Get.snackbar("Succès", "Enregistrement éfféctué");
      controller.getAllAnnonces();
    } else {
      Get.back();
      Get.snackbar("Oups", "Impossible d'enregistrer maintenant");
      print("Error during connection to server.");
    }
  }
}
