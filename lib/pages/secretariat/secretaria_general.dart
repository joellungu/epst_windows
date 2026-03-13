import 'dart:async';
import 'dart:io';

import 'package:epst_windows_app/pages/controllers/plainte_controller.dart';
import 'package:epst_windows_app/pages/secretariat/secretariat_controller.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/ajout_affiche.dart';
import 'nouvelle_office.dart';
import 'update_office.dart';

class SecretariaGeneral extends GetView<SecretariatController> {
  Rx vue = Rx<Widget>(Container());
  Rx vue2 = Rx<Widget>(Container());
  //
  RxString text = "".obs;
  //
  RxInt choix = 0.obs;
  //

  Future<void> loadMagasin() async {
    plainteController.reload.value = true;
    plainteController.listePieceJointe.value.clear();
    plainteController.listePieceJointe.value = await Connexion.liste_magasin(7);
    plainteController.reload.value = false;
  }

  PlainteController plainteController = Get.find();

  SecretariaGeneral() {
    controller.allSecretariats();
    //
    //vue.value = Container();
    //
    //vue2.value = Container();
    //
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 350,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          //color: Colors.grey.shade700,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 10,
              ),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                child: Container(
                  height: 40,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          onChanged: (t) {
                            //
                            text.value = t;
                          },
                          decoration: InputDecoration(
                            hintText: "Recherche",
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: controller.obx(
                  (state) {
                    List l = state!;
                    return ListView(
                      children: List.generate(
                        l.length,
                        (index) {
                          //print("map: ${l[index]}");
                          return "${l[index]["denomition"]}"
                                  .toLowerCase()
                                  .contains(text.value.toLowerCase())
                              ? Obx(
                                  () => Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: choix.value != index
                                            ? Colors.grey.shade200
                                            : Colors.blue.shade200,
                                      ),
                                    ),
                                    child: ListTile(
                                      onTap: () async {
                                        //
                                        Get.dialog(
                                          Center(
                                            child: Container(
                                              alignment: Alignment.center,
                                              color: Colors.white,
                                              height: 100,
                                              width: 100,
                                              child: const SizedBox(
                                                height: 35,
                                                width: 35,
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                        );
                                        //
                                        Map e = await controller.getSecretarial(
                                            "${l[index]['id']}");
                                        //
                                        Get.back();
                                        //
                                        choix.value = index;
                                        //
                                        vue.value = Container();
                                        //
                                        Timer(const Duration(seconds: 1), () {
                                          //
                                          vue.value = UpdateOffice(
                                            e,
                                            key: UniqueKey(),
                                          );
                                        });
                                        //
                                        // setState(() {
                                        //   vue2 = Affiche(
                                        //       UniqueKey(),
                                        //       plainteController.listePieceJointe
                                        //           .value[index]["id"]);
                                        //   //
                                        //   vue = detailsVue(plainteController
                                        //       .listePieceJointe.value[index]);
                                        //
                                        //});
                                      },
                                      leading: Container(
                                        height: 40,
                                        width: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Icon(
                                          CupertinoIcons.list_dash,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      title: Text(
                                        l[index]["denomition"],
                                        style: TextStyle(
                                          //color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      subtitle: Text(
                                        l[index]["sigle"],
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 10,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          //
                                          await controller
                                              .supprimerS("${l[index]["id"]}");
                                          //
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : Container();
                        },
                      ),
                    );
                  },
                  onEmpty: Container(),
                  onLoading: const Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    //
                    Get.to(NouvelleOffice());
                  },
                  child: const Center(
                    child: Text("Ajouter"),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Obx(
            () =>
                //color: Colors.grey.shade500,
                vue.value,
          ),
        )
      ],
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
                      '...',
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
                      '...',
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      'Date mise en ligne',
                    ),
                    subtitle: Text(
                      '...',
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
                      '...',
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
                      '...',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Obx(
              () => vue2.value,
            ),
          )
        ],
      ),
    );
  }
}
