import 'package:epst_windows_app/pages/controllers/plainte_controller.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/ajout_affiche.dart';
import 'update_controller.dart';

class UploadMagasin extends StatefulWidget {
  static late State magState;
  @override
  State<StatefulWidget> createState() {
    return _UploadMagasin();
  }
}

class _UploadMagasin extends State<UploadMagasin> {
  Widget? vue;
  Widget? vue2;
  //
  RxString text = "".obs;
  //

  Future<void> loadMagasin() async {
    plainteController.reload.value = true;
    plainteController.listePieceJointe.value.clear();
    plainteController.listePieceJointe.value = await Connexion.liste_magasin(1);
    plainteController.reload.value = false;
  }

  PlainteController plainteController = Get.find();

  @override
  void initState() {
    //
    loadMagasin();
    //
    vue = Container();
    //
    vue2 = Container();
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 350,
          decoration: BoxDecoration(
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
              SizedBox(
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
                          decoration: const InputDecoration(
                            hintText: "Recherche des reformes en ligne.",
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
                child: Obx(
                  () => plainteController.reload.value
                      ? Center(
                          child: Container(
                            height: 2,
                            width: 50,
                            child: LinearProgressIndicator(),
                          ),
                        )
                      : Obx(
                          () => ListView(
                            children: List.generate(
                              plainteController.listePieceJointe.value.length,
                              (index) {
                                return "${plainteController.listePieceJointe.value[index]["libelle"]}"
                                        .toLowerCase()
                                        .contains(text.value.toLowerCase())
                                    ? Card(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: ListTile(
                                          onTap: () {
                                            //
                                            setState(() {
                                              vue2 = Affiche(
                                                  UniqueKey(),
                                                  plainteController
                                                      .listePieceJointe
                                                      .value[index]["id"]);
                                              //
                                              vue = detailsVue(plainteController
                                                  .listePieceJointe
                                                  .value[index]);
                                              //
                                            });
                                          },
                                          leading: Container(
                                            height: 40,
                                            width: 40,
                                            alignment: Alignment.center,
                                            child: Icon(
                                              CupertinoIcons.list_dash,
                                              color: Colors.grey.shade700,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          title: Text(
                                            plainteController.listePieceJointe
                                                .value[index]["libelle"],
                                            style: TextStyle(
                                              //color: Colors.black,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          subtitle: Text(
                                            plainteController.listePieceJointe
                                                .value[index]["dateenligne"],
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 10,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () async {
                                              //
                                              int x = await Connexion
                                                  .supprimer_magasin(
                                                      plainteController
                                                          .listePieceJointe
                                                          .value[index]["id"]);
                                              if (x == 201 || x == 200) {
                                                loadMagasin();
                                              }
                                            },
                                          ),
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                          ),
                        ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  //
                  setState(() {
                    vue = Ajouter(1);
                  });
                },
                child: Center(
                  child: Text("Ajouter magazin"),
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            //color: Colors.grey.shade500,
            child: vue,
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
                      '${mag['libelle']}',
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
                      '${mag['description']}',
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

