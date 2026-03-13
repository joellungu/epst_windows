import 'package:epst_windows_app/pages/demande_documents/demande_documents_controller.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailsDiplome extends StatelessWidget {
  //
  Map e;
  //
  DemandeDocumentsController demandeDocumentsController = Get.find();
  //
  List types = [
    "Validé", //1
    "Refusé", //2
    "En attente", //3
  ];
  //
  TextEditingController raisonController = TextEditingController();
  //
  RxInt type = 1.obs;
  //
  DetailsDiplome(this.e);
  //
  @override
  Widget build(BuildContext context) {
    //
    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                child: e['type'] == 2
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "id: ${e['id']}",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.centerLeft,
                          //   child: Text(
                          //     "documenrDemandecode: ${e['documenrDemandecode']}",
                          //     style: TextStyle(
                          //         color: Colors.black,
                          //         fontSize: 17,
                          //         fontWeight: FontWeight.normal),
                          //   ),
                          // ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "document Demande: ${e['documenrDemande']}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "date demande: ${e['datedemande']}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FutureBuilder(
                              future: getStatus("${e['id']}"),
                              builder: (context, t) {
                                if (t.hasData) {
                                  Map v = t.data as Map;
                                  print("Valider ou: $v");
                                  //show.value = v['valider'];
                                  //setState((){});
                                  return SizedBox(
                                    height: 100,
                                    child: Column(
                                      children: [
                                        v['valider'] == 1
                                            ? const Column(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Validation: Validé",
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Passez à l'imprimerie de Kinshasa",
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : v['valider'] == 2
                                                ? Column(
                                                    children: [
                                                      const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Validation: Refusé",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Raison: ${v['raison']}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : v['valider'] == 3
                                                    ? const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Validation: Expiré",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      )
                                                    : const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Validation: En attente",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  );
                                  //return
                                } else if (t.hasError) {
                                  return const Text("...");
                                }

                                return Container(
                                  height: 50,
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "id: ${e['id']}",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Nom: ${e['nom']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Postnom: ${e['postnom']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Prenom: ${e['prenom']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "sexe: ${e['sexe']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "lieuNaissance: ${e['lieuNaissance']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "dateNaissance: ${e['dateNaissance']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "telephone: ${e['telephone']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "nompere: ${e['nompere']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "nommere: ${e['nommere']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "adresse: ${e['adresse']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              )),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "province Origine: ${e['provinceOrigine']}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              )),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "ecole: ${e['ecole']}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "province Ecole: ${e['provinceEcole']}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "province Educationnel: ${e['provinceEducationnel']}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "option: ${e['option']}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "annee: ${e['annee']}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          //${e['documenrDemande']} du ${e['datedemande']
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "document Demande: ${e['documenrDemande']}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "date demande: ${e['datedemande']}",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "document Demande: ${e['documenrDemande']}",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FutureBuilder(
                              future: getStatus("${e['id']}"),
                              builder: (context, t) {
                                if (t.hasData) {
                                  Map v = t.data as Map;
                                  print("Valider ou: $v");
                                  //show.value = v['valider'];
                                  //setState((){});
                                  return SizedBox(
                                    height: 100,
                                    child: Column(
                                      children: [
                                        v['valider'] == 1
                                            ? const Column(
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Validation: Validé",
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "Passez à l'imprimerie de Kinshasa",
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : v['valider'] == 2
                                                ? Column(
                                                    children: [
                                                      const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Validation: Refusé",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Raison: ${v['raison']}",
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 15),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                : v['valider'] == 3
                                                    ? const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Validation: Expiré",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      )
                                                    : const Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Validation: En attente",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  );
                                  //return
                                } else if (t.hasError) {
                                  return const Text("...");
                                }

                                return Container(
                                  height: 50,
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    height: 250,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(
                            "${Connexion.lien}documentscolaire/piecejointe/${e['id']}"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 7,
                child: TextField(
                  controller: raisonController,
                  decoration: const InputDecoration(
                    labelText: "Raison",
                    //hintText: "Raison",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: type.value,
                        underline: const SizedBox(),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.black),
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
                              value: index + 1,
                              child: Text(
                                types[index],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () async {
                      //
                      Get.dialog(
                        Center(
                          child: Center(
                            child: Container(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      );
                      bool v = await demandeDocumentsController.setUpdate(
                          raisonController.text, type.value, e['id']);
                      //
                      if (v) {
                        Get.back();
                        demandeDocumentsController
                            .getAllDemande(e['provinceEcole']);
                      }
                      //types[type]
                      //
                    },
                    child: const Text(
                      "Traiter",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

//
Requette requete = Requette();
//
Future<Map> getStatus(String id) async {
  Response response = await requete.getEs("documentscolaire/$id");
  print("documentscolaire/$id");
  if (response.statusCode == 200 || response.statusCode == 201) {
    print("le status: ${response.body}");
    return response.body;
  } else {
    print("-----------------------------");
    print("erreur du à&: ${response.statusCode}");
    print("erreur du à: ${response.body}");
    return {"valider": 0};
  }
}
