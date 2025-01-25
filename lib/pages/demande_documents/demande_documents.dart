import 'package:epst_windows_app/utils/requette.dart';
import 'package:flutter/material.dart';
import 'demande_documents_controller.dart';
import 'package:get/get.dart';

import 'details_demande.dart';

class DemandeDocuments extends GetView<DemandeDocumentsController> {
  //
  Map user;
  //
  DemandeDocuments(this.user) {
    //
    controller.getAllDemande(user['province']);
  }
  //
  List types = [
    "Diplôme d'etat",
    "Diplôme d'aptitude profesionnel",
    "Brevet professionnel",
    "Certificat d'étude primaire",
    "Note d'acquis de droit",
    "Attestation reussite (EXETAT)",
    "Attestation de N.D.D",
    "Releve de côtes"
  ];
  //
  RxInt type = 0.obs;
  //
  Rx<Widget> vue = Rx(Container());
  //
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: controller.obx(
              (state) {
                //
                List demandes = state!;
                //
                RxString text = "".obs;
                //
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        height: 70,
                        child: Card(
                          elevation: 0,
                          margin: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Text(
                                  "  Doc demandé:",
                                  style: TextStyle(fontSize: 10),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Obx(
                                    () => DropdownButtonHideUnderline(
                                      child: DropdownButton<int>(
                                        value: type.value,
                                        underline: const SizedBox(),
                                        style: const TextStyle(
                                            fontSize: 10, color: Colors.black),
                                        isExpanded: true,
                                        // decoration: const InputDecoration(

                                        //   border: OutlineInputBorder(
                                        //     gapPadding: 0,

                                        //     borderSide: BorderSide(
                                        //       color: Colors.white,
                                        //       width: 0,
                                        //     ),
                                        //   ),
                                        // ),

                                        onChanged: (value) {
                                          type.value = value as int;
                                          print("le id: $type");
                                        },
                                        items: List.generate(
                                          types.length,
                                          (index) {
                                            return DropdownMenuItem(
                                              value: index,
                                              child: Text(
                                                types[index],
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(5),
                        child: TextField(
                          onChanged: (t) {
                            //nom,postnom,prenom,matricule,
                            text.value = t;
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Obx(
                          () => ListView(
                            children: List.generate(
                              demandes.length,
                              (d) {
                                //
                                Map demande = demandes[d];
                                debugPrint("Demande: $demande");
                                //
                                if (demande['nom']
                                        .toLowerCase()
                                        .contains(text.value.toLowerCase()) ||
                                    demande['postnom']
                                        .toLowerCase()
                                        .contains(text.value.toLowerCase()) ||
                                    demande['prenom']
                                        .toLowerCase()
                                        .contains(text.value.toLowerCase()) ||
                                    demande['matricule']
                                        .toLowerCase()
                                        .contains(text.value.toLowerCase())) {
                                  //
                                  return ListTile(
                                    onTap: () {
                                      //
                                      vue.value = Center(
                                        child: DetailsDemande(demande),
                                      );
                                    },
                                    title:
                                        Text("${demande['documenrDemande']}"),
                                    subtitle: Text("${demande['datedemande']}"),
                                  );
                                } else {
                                  //
                                  return Container();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              onEmpty: Container(),
              onLoading: Center(
                child: Container(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Obx(() => vue.value),
            ),
          ),
        ],
      ),
    );
  }

  //
}
