import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'cours_categorie_controller.dart';
import 'package:dio/dio.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:percent_indicator/percent_indicator.dart';

final dio = Dio();

class NouveauCours extends StatelessWidget {
  //
  Map classe;
  NouveauCours(this.classe, this.typeFormation);
  //
  RxString fichier = "".obs;
  String fichierPath = "";
  //
  String typeFormation;
  //
  TextEditingController cours = TextEditingController();
  TextEditingController branche = TextEditingController();
  TextEditingController notion = TextEditingController();
  TextEditingController chapitre = TextEditingController();
  //TextEditingController cours = TextEditingController();
  //
  CoursCategorieController coursCategorieController = Get.find();
  //
  //
  RxString percentage = "".obs;
  RxDouble pr = 0.0.obs;
  //
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${classe['cls']} ${classe['categorie']}"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextField(
                controller: cours,
                decoration: InputDecoration(
                  hintText: "Cours",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: branche,
                decoration: InputDecoration(
                  hintText: "Branche",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: notion,
                decoration: InputDecoration(
                  hintText: "Notion",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 9,
                      child: Obx(
                        () => Text(fichier.value),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        //
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();

                        if (result != null) {
                          //File file = File(result.files.single.path!);
                          fichier.value = result.files.single.name;
                          fichierPath = result.files.single.path!;
                        } else {
                          // User canceled the picker
                        }
                      },
                      icon: Icon(
                        Icons.file_download,
                      ),
                    ),
                  ],
                ),
              ),
              //
              ElevatedButton(
                onPressed: () async {
                  if (true) {
                    //
                    // controller.addClasse(
                    //   {
                    //     "nom": nom.text,
                    //     "categorie": [
                    //       "Maternelle",
                    //       "Primaire",
                    //       "Education de base",
                    //       "Secondaire"
                    //     ][categorie.value - 1],
                    //     "cls": classe.value,
                    //   },
                    // );
                    //
                    /**
                     *
                        public String cours = cours.text;
                        public String propriete;//Eleve ou les enseignants
                        public String banche; // Pour la cas de Francais par ex on a Conjugaison, Grammaire etc
                        public String notion;//
                        public int chapitre;//
                        public int type;// Type de contenue (audio, video, pdf)
                        public int classe; // Ex 1er primaire ...
                        public String categorie;//Maternelle , Education de base et secondaire
                        public byte[] data;
                     */
                    //
                    Map c = {
                      "cours": cours.text.toLowerCase(),
                      "propriete": typeFormation,
                      "banche": branche.text,
                      "notion": notion.text,
                      "chapitre": 0,
                      "type": fichier.value.split(".").last.toLowerCase(),
                      "idClasse": classe['id'],
                      "cls": classe['cls'],
                      "categorie": classe['categorie'],
                      //"data": null,
                    };
                    //
                    //
                    Get.dialog(
                      Center(
                        child: Container(
                          height: 30,
                          width: 30,
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    );
                    //

                    String id = await coursCategorieController.addCours(c);
                    //
                    if (id == "0") {
                      Get.back();
                      Get.snackbar(
                          "Oups", "Impossible de créer le cours maintenant !");
                    } else {
                      Get.back();
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
                      send(id, File(fichierPath).readAsBytesSync());
                    }
                  }
                },
                child: const Text(
                  "Enregistrer",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  send(String id, Uint8List media) async {
    var res = await dio.post(
      "${Connexion.lien}cours/media?id=$id",
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
        print("::::::::: $sent" " Bytes of " "$total Bytes - " +
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
      coursCategorieController.getAllClasse(
          classe['cls'], classe['categorie'], typeFormation);
    } else {
      Get.back();
      Get.snackbar("Oups", "Impossible d'enregistrer maintenant");
      print("Error during connection to server.");
    }
  }
}
