import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'cours_categorie_controller.dart';
import 'package:dio/dio.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:percent_indicator/percent_indicator.dart';

final dio = Dio();

class NouveauCours extends StatelessWidget {
  Map classe;
  NouveauCours(this.classe, this.typeFormation);

  RxString fichier = "".obs;
  String fichierPath = "";
  String typeFormation;
  TextEditingController cours = TextEditingController();
  TextEditingController branche = TextEditingController();
  TextEditingController notion = TextEditingController();
  TextEditingController chapitre = TextEditingController();
  CoursCategorieController coursCategorieController = Get.find();
  RxString percentage = "".obs;
  RxDouble pr = 0.0.obs;

  @override
  Widget build(BuildContext context) {
    final classeTitle =
        "${classe['niveau']} ${classe['cycle']} ${classe['section'] ?? ''}"
            .trim();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(classeTitle),
        centerTitle: false,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EAF2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.upload_file_outlined,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Enregistrer un cours",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              "$typeFormation / $classeTitle",
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _textField(
                    controller: cours,
                    label: "Cours",
                    icon: Icons.menu_book_outlined,
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: branche,
                    label: "Branche",
                    icon: Icons.account_tree_outlined,
                  ),
                  const SizedBox(height: 14),
                  _textField(
                    controller: notion,
                    label: "Notion",
                    icon: Icons.lightbulb_outline,
                  ),
                  const SizedBox(height: 18),
                  _filePicker(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _saveCourse();
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text(
                        "Enregistrer",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
        ),
      ),
    );
  }

  Widget _filePicker() {
    return Obx(
      () => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null) {
            fichier.value = result.files.single.name;
            fichierPath = result.files.single.path!;
          }
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD8E0EC)),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.attach_file,
                  color: Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fichier.value.isEmpty
                          ? "Selectionner un fichier"
                          : fichier.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      "PDF, video, audio ou autre support du cours",
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCourse() async {
    if (cours.text.trim().isEmpty || fichierPath.isEmpty) {
      Get.snackbar(
        "Information manquante",
        "Veuillez renseigner le cours et selectionner un fichier.",
      );
      return;
    }

    Map c = {
      "cours": cours.text.toLowerCase(),
      "propriete": typeFormation,
      "banche": branche.text,
      "notion": notion.text,
      "chapitre": 0,
      "type": fichier.value.split(".").last.toLowerCase(),
      "idClasse": classe['id'],
      "cycle": classe['cycle'],
    };

    Get.dialog(
      const Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(),
        ),
      ),
    );

    String id = await coursCategorieController.addCours(c);
    if (id == "0") {
      Get.back();
      Get.snackbar("Oups", "Impossible de creer le cours maintenant !");
    } else {
      Get.back();
      Get.dialog(
        Center(
          child: Container(
            height: 58,
            width: 390,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Obx(
              () => LinearPercentIndicator(
                width: 350,
                lineHeight: 20.0,
                percent: pr / 100,
                center: Text(
                  "${pr.value} %",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                barRadius: const Radius.circular(10),
                backgroundColor: const Color(0xFFE5EAF2),
                progressColor: const Color(0xFF1D4ED8),
              ),
            ),
          ),
        ),
      );
      send(id, File(fichierPath).readAsBytesSync());
    }
  }

  send(String id, Uint8List media) async {
    var res = await dio.post(
      "${Connexion.lien}cours/media?id=$id",
      data: media,
      options: Options(headers: {"Content-Type": "application/octet-stream"}),
      onSendProgress: (int sent, int total) {
        percentage.value = (sent / total * 100).toStringAsFixed(2);
        pr.value = double.parse(percentage.value);
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      Get.back();
      Get.snackbar("Succes", "Enregistrement effectue");
      coursCategorieController.getAllClasse(classe['id'], typeFormation);
    } else {
      Get.back();
      Get.snackbar("Oups", "Impossible d'enregistrer maintenant");
    }
  }
}
