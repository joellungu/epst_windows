import 'package:epst_windows_app/pages/controllers/plainte_controller.dart';
import 'package:epst_windows_app/pages/load_mag/update_controller.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/ajout_affiche.dart';
import 'cours_categorie.dart';
import 'cours_controller.dart';

class UploadCours extends GetView<CoursController> {
  UploadCours() {
    initState();
  }
  //
  RxInt typeFormation = 0.obs;

  Rx<Widget> vue = Rx(Container());
  Widget? vue2;
  //
  TextEditingController nom = TextEditingController();
  //
  RxInt classe = 1.obs;
  Map classeMap = {};
  //
  RxInt categorie = 1.obs;

  RxString id = "".obs;
  RxInt ix = RxInt(-1);
  //CoursController coursController = Get.find();

  void initState() {
    //
    controller.getAllClasse();
    //
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 350,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.white,
                ),
              ),
            ),
            //color: Colors.grey.shade700,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //
                Container(
                  height: 50,
                  child: Obx(
                    () => Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //
                            typeFormation.value = 0;
                            vue.value = CoursCategorie(
                                classeMap,
                                typeFormation.value == 0
                                    ? "Eleve"
                                    : "Professeur");
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(1)),
                            backgroundColor: typeFormation.value == 0
                                ? Colors.blue
                                : Colors.grey.shade400,
                          ),
                          child: const Text("Elèves"),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            //
                            typeFormation.value = 1;
                            vue.value = CoursCategorie(
                                classeMap,
                                typeFormation.value == 1
                                    ? "Eleve"
                                    : "Professeur");
                            //Map classe = listeClasses[idx];
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(1)),
                            backgroundColor: typeFormation.value == 1
                                ? Colors.blue
                                : Colors.grey.shade400,
                          ),
                          child: const Text("Professeur"),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: controller.obx(
                    (s) {
                      //
                      List listeClasses = s as List;
                      //
                      return ListView(
                        padding: const EdgeInsets.all(10),
                        children: List.generate(listeClasses.length, (index) {
                          //
                          Map classe = listeClasses[index];
                          classeMap = classe;
                          //
                          return Obx(
                            () => ListTile(
                              tileColor: ix.value == index
                                  ? Colors.blue.shade200
                                  : Colors.white,
                              leading: Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.center,
                                child: Icon(Icons.school),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              title: Text("${classe['cls']}"),
                              subtitle: Text("${classe['categorie']}"),
                              onTap: () {
                                vue.value = CoursCategorie(
                                    classe,
                                    typeFormation.value == 0
                                        ? "Eleve"
                                        : "Professeur");
                                ix.value = index;
                              },
                              trailing: IconButton(
                                onPressed: () async {
                                  //
                                  controller.deleteClasse(classe['id']);
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                    onEmpty: Container(),
                    onLoading: Center(
                      child: Container(
                        height: 30,
                        width: 30,
                        child: const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                    //
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Nouvelle classe"),
                          content: Container(
                            height: 300,
                            width: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextField(
                                  controller: nom,
                                  decoration: InputDecoration(
                                    hintText: "Nom",
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
                                  child: DropdownButtonHideUnderline(
                                    child: Obx(
                                      () => DropdownButton<int>(
                                        //onTap: () {},
                                        value: categorie.value,
                                        items: const [
                                          /**
                                           * "Primaire",
                                            "Secondaire",
                                            "FOAD Maternel",
                                            "FOAD Primaire",
                                            "Education de base",
                                            "FOAD Secondaire",
                                            "FOAD Technique",
                                            "Education de base"
                                           */
                                          DropdownMenuItem(
                                            child: Text("Primaire"),
                                            value: 1,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("Education de base"),
                                            value: 2,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("Secondaire"),
                                            value: 3,
                                          ),
                                          //
                                          DropdownMenuItem(
                                            child: Text("FOAD Maternel"),
                                            value: 4,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("FOAD Primaire"),
                                            value: 5,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("FOAD Secondaire"),
                                            value: 6,
                                          ),
                                          DropdownMenuItem(
                                            child: Text("FOAD Technique"),
                                            value: 7,
                                          ),
                                        ],
                                        onChanged: (int? value) {
                                          categorie.value = value!;
                                        },
                                        elevation: 1,
                                        isExpanded: true,
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
                                  child: DropdownButtonHideUnderline(
                                    child: Obx(
                                      () => DropdownButton<int>(
                                        //onTap: () {},
                                        value: classe.value,
                                        items: List.generate(8, (index) {
                                          return DropdownMenuItem(
                                            child: Text("${index + 1}"),
                                            value: index + 1,
                                          );
                                        }),
                                        onChanged: (int? value) {
                                          classe.value = value!;
                                        },
                                        elevation: 1,
                                        isExpanded: true,
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (nom.text.isNotEmpty) {
                                      //
                                      controller.addClasse(
                                        {
                                          "nom": nom.text,
                                          "categorie": [
                                            "Primaire",
                                            "Secondaire",
                                            "FOAD Maternel",
                                            "FOAD Primaire",
                                            "Education de base",
                                            "FOAD Secondaire",
                                            "FOAD Technique",
                                          ][categorie.value - 1],
                                          "cls": classe.value,
                                        },
                                      );
                                      //
                                    }
                                  },
                                  child: const Text("Ajouter"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                    //
                  },
                  child: Center(
                    child: Text(
                      "Ajouter un classe",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 1,
            child: Obx(
              () => Container(
                child: vue.value,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget detailsVue(Map<String, dynamic> mag) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 350,
            child: ListView(
              //primary: false,
              controller: ScrollController(),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
              ),
              children: [
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      'Libellé',
                    ),
                    subtitle: Text(
                      '${mag['']}',
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      'Description',
                    ),
                    subtitle: Text(
                      '${mag['']}',
                    ),
                  ),
                ),
                /*
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      'Date mise en ligne',
                    ),
                    subtitle: Text(
                      '${mag['']}',
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      'Utilisateur uploader',
                    ),
                    subtitle: Text(
                      '${mag['']}',
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      'Piece jointe',
                    ),
                    subtitle: Text(
                      '${mag['']}',
                    ),
                  ),
                ),
              */
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: vue2!,
          )
        ],
      ),
    );
  }
}


//

