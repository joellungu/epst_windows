import 'package:epst_windows_app/pages/formation_distante/InspecteurCoursScreen.dart';
import 'package:epst_windows_app/pages/formation_distante/details_inspecteur.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormationDistante extends StatelessWidget {
  //
  Rx<Widget> vue = Rx(Container());
  //
  Requette requette = Requette();
  //
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  height: 50,
                ),
                FutureBuilder(
                    future: getAllInspecteurs(),
                    builder: (c, t) {
                      //
                      if (t.hasData) {
                        //
                        List list1 = t.data as List;
                        //
                        List liste = list1
                            .where(
                              (e) => e['role'] == 15,
                            )
                            .toList();
                        //
                        return Expanded(
                          flex: 9,
                          child: ListView(
                            children: List.generate(liste.length, (a) {
                              //
                              Map ag = liste[a];
                              //
                              return ListTile(
                                onTap: () {
                                  //
                                  print("Agent: $ag");
                                  //vue.value = DetailsInspecteur();
                                  //
                                  vue.value = InspecteurCoursScreen(ag['id']);
                                },
                                leading: Icon(Icons.person),
                                title: Text(
                                    "${ag['nom']} ${ag['postnom']} ${ag['prenom']}"),
                                subtitle:
                                    Text("${ag['numero']} / ${ag['province']}"),
                                trailing: Icon(Icons.arrow_forward_ios),
                              );
                            }),
                          ),
                        );
                      } else if (t.hasError) {
                        //
                        print("Le data: ${t.error}");
                        //
                        return Container();
                      }

                      return const Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    })
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: Obx(() => vue.value),
          ),
        ],
      ),
    );
  }

  //
  Future<List> getAllInspecteurs() async {
    //
    List<Map<String, dynamic>> liste = await Connexion.liste_utilisateur();
    //Response response = await requette.get("");
    //
    return liste;
  }
}
