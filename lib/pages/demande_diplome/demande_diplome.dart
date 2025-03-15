import 'package:epst_windows_app/pages/demande_diplome/demande_diplome_controller.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'details_diplome.dart';

class DemandeDiplomes extends GetView<DemandeDiplomesController> {
  //
  Map user;
  //
  DemandeDiplomes(this.user) {
    //
    controller.getAllDemande();
  }
  //
  List types = [
    "Diplôme d'etat",
    "Diplôme d'aptitude profesionnel",
    "Brevet professionnel",
    "Attestation reussite (EXETAT)",
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 8,
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
                            const SizedBox(
                              width: 10,
                            ),
                            IconButton(
                              onPressed: () {
                                //
                                //
                              },
                              icon: const Icon(Icons.search),
                            ),
                          ],
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
                                print(
                                    ':::: ${demande['documenrDemande'].toLowerCase()} == ${types[type.value].toLowerCase()} :: ${demande['documenrDemande'].toLowerCase().contains(types[type.value].toLowerCase())}');
                                //
                                if (demande['documenrDemande']
                                    .toLowerCase()
                                    .contains(
                                        types[type.value].toLowerCase())) {
                                  //
                                  return ListTile(
                                    onTap: () {
                                      //
                                      vue.value = Center(
                                        child: DetailsDiplome(demande),
                                      );
                                    },
                                    title: Text("${demande['matricule']}"),
                                    subtitle: Text("${demande['annee']}"),
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
