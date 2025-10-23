import 'package:epst_windows_app/pages/cours/cours_categorie_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'nouveau_cours.dart';

class CoursCategorie extends GetView<CoursCategorieController> {
  Map classe;
  String typeFormation;
  //
  CoursCategorie(this.classe, this.typeFormation) {
    controller.getAllClasse(
        classe['id'] ?? 0, classe['categorie'] ?? 0, typeFormation);
  }
  //
  RxString cs = "".obs;
  //
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: controller.obx(
          (s) {
            //
            return Column(
              children: [
                Container(
                  height: 50,
                  child: TextField(
                    //controller: nom,
                    onChanged: (t) {
                      cs.value = t;
                    },
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
                ),
                Expanded(
                  flex: 1,
                  child: Obx(
                    () => ListView(
                      padding: EdgeInsets.all(10),
                      children: List.generate(s!.length, (index) {
                        //
                        Map cours = s[index];
                        //
                        print('Cours: $cours');
                        //
                        if ("${cours['cours']}"
                            .toLowerCase()
                            .contains(cs.value.toLowerCase())) {
                          return ListTile(
                            leading: Container(
                              height: 50,
                              width: 50,
                              alignment: Alignment.center,
                              child: Icon(Icons.menu_book),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            title: Text("Cours: ${cours['cours']}"),
                            subtitle: Text(
                                "Branche: ${cours['banche']} / Notion: ${cours['notion']}"),
                            onTap: () {
                              //vue.value = CoursCategorie(classe);
                              //ix.value = index;
                            },
                            trailing: IconButton(
                              onPressed: () async {
                                //
                                controller.deleteCours(
                                  {
                                    "id": cours['id'],
                                    "cls": classe['cls'],
                                    "categorie": classe['categorie'],
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.shade700,
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                    ),
                  ),
                ),
              ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          //
          Get.to(NouveauCours(classe, typeFormation));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
