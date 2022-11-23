import 'dart:io';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:path_provider_windows/path_provider_windows.dart';
import 'mutuelle_controller.dart';

class Mutuelle extends GetView<MutuelleController> {
  RxMap infos = RxMap();
  String tempDirectory = "";
  Mutuelle(){
    controller.getAllDemande();
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
              return ListView(
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
              );
            }),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 10, left: 40,right: 40),
            child: Obx(()=> infos['nom'] != null ? ListView(
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
                  subtitle: Text("${infos['valider'] == 0 ? 'Non validé':'Validé'}"),
                ),
                ListTile(
                  title: Text("Date"),
                  subtitle: Text("${infos['jour'] ?? ''}"),
                ),
              ],):Container(),
            )
          ),
        ),
        Expanded(
            flex: 4,
            child: Obx(()=> Container(
              padding: EdgeInsets.all(20),
              child: infos.value['ext'] != null ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 300,
                      child: ExtendedImage.network(
                          "${Connexion.lien}mutuelle/carte/${infos['id']}"
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            child: ElevatedButton(
                              onPressed: (){
                                controller.setStatus(1,"${infos['id']}");
                              },
                              child: Text("Accepter"),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          flex: 4,
                          child: Container(
                            child: ElevatedButton(
                              onPressed: (){
                                controller.setStatus(2,"${infos['id']}");
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.red)
                              ),
                              child: Text("Annuler", style: TextStyle(color: Colors.white,),),
                            ),
                          ),
                        ),

                      ],
                    )
                  ],
                ):
              Text("Image")
            ),
          ),
        )
      ],
    );
  }

}