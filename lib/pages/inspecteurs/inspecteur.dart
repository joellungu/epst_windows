import 'dart:async';
import 'dart:io';

import 'package:epst_windows_app/pages/mutuelle/mutuelle_recherche.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'inspecteur_controller.dart';

class Inspecteur extends GetView<InspecteurController> {
  //
  RxMap infos = RxMap();
  Map us = {};
  //
  String tempDirectory = "";
  Timer? t;
  //"Kinshasa","KINSHASA-MONT AMBA"
  String? province = "Kinshasa", district = "KINSHASA-MONT AMBA";
  //
  TextEditingController recherche_matricule = TextEditingController();
  //
  Inspecteur(this.us) {
    province = us["province"] ?? '';
    district = us["district"] ?? '';
    controller.getAllDemande(province!, district!);
    //
    t = Timer.periodic(Duration(minutes: 1), (timer) {
      controller.getAllDemande(province!, district!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.all(10),
            child: controller.obx((state) {
              List l = state!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          flex: 6,
                          child: TextField(
                            controller: recherche_matricule,
                            decoration: InputDecoration(
                              hintText: "Matricule",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              if (recherche_matricule.text.isNotEmpty) {
                                Get.to(MutuelleRecherche(
                                    recherche_matricule.text));
                              }
                            },
                            child: const Text("Recherche"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: List.generate(l.length, (index) {
                        Map d = l[index];
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: ListTile(
                            onTap: () async {
                              //
                              infos.value = d;
                              //
                            },
                            leading: Container(
                              height: 40,
                              width: 40,
                              alignment: Alignment.center,
                              child: Icon(
                                CupertinoIcons.paperclip,
                                color: Colors.blue,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            title: Text(
                              "${d['nom']} ${d['postnom']} ${d['prenom']}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              "${d['direction']} / ${d['beneficiaire']}",
                              //"Mokpongb lungu joel / 0815454789",
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            trailing: Text("${d['jour'] ?? ''}"),
                          ),
                        );
                      }),
                    ),
                  )
                ],
              );
            }),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
              child: Obx(
                () => infos['nom'] != null
                    ? ListView(
                        controller: ScrollController(),
                        children: [
                          ListTile(
                            title: Text("Nom"),
                            subtitle: Text("${infos['nom'] ?? ''}"),
                          ),
                          ListTile(
                            title: Text("Postnom"),
                            subtitle: Text("${infos['postnom'] ?? ''}"),
                          ),
                          ListTile(
                            title: Text("Prenom"),
                            subtitle: Text("${infos['prenom'] ?? ''}"),
                          ),
                          ListTile(
                            title: Text("Matricule"),
                            subtitle: Text("${infos['matricule'] ?? ''}"),
                          ),
                          ListTile(
                            title: Text("Direction"),
                            subtitle: Text("${infos['direction'] ?? ''}"),
                          ),
                          ListTile(
                            title: Text("Service"),
                            subtitle: Text("${infos['services'] ?? ''}"),
                          ),
                          ListTile(
                            title: Text("Beneficiaire"),
                            subtitle: Text("${infos['beneficiaire'] ?? ''}"),
                          ),
                          ListTile(
                            title: Text("Note"),
                            subtitle: Text("${infos['notes'] ?? ''}"),
                          ),
                          ListTile(
                            title: Text("Status"),
                            subtitle: Text(
                                "${infos['valider'] == 0 ? 'Non validé' : 'Validé'}"),
                          ),
                          ListTile(
                            title: Text("Date"),
                            subtitle: Text("${infos['jour'] ?? ''}"),
                          ),
                        ],
                      )
                    : Container(),
              )),
        ),
        Expanded(
          flex: 4,
          child: Obx(
            () => Container(
              padding: EdgeInsets.all(20),
              child: infos.value['ext1'] != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 250,
                          width: 300,
                          child: Image.network(
                              "${Connexion.lien}mutuelle/carte/${infos['id']}"),
                        ),
                        infos.value['services'] != "Demande consulation"
                            ? SizedBox(
                                height: 250,
                                width: 300,
                                child: Image.network(
                                    "${Connexion.lien}mutuelle/piecejointe/${infos['id']}"),
                              )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.setStatus(1, "${infos['id']}",
                                        province!, district!);
                                  },
                                  child: Text("Accepter"),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: ElevatedButton(
                                  onPressed: () {
                                    controller.setStatus(2, "${infos['id']}",
                                        province!, district!);
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.red)),
                                  child: Text(
                                    "Annuler",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  : Text(""),
            ),
          ),
        )
      ],
    );
  }
}
