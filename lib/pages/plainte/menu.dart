import 'dart:io';

import 'package:epst_windows_app/pages/plainte/details.dart';
import 'package:epst_windows_app/pages/plainte/plainte.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';

class MenuGauche extends StatefulWidget {
  State state;
  int? role;

  MenuGauche(this.state, this.role);
  @override
  State<StatefulWidget> createState() {
    return _MenuGauche();
  }
}

class _MenuGauche extends State<MenuGauche> with TickerProviderStateMixin {
  //
  late TabController controller;

  List angles = ["Nouvelles", "Traités"];
  Widget? vue;
  //

  //
  Future<Widget> getPlainte0() async {
    print("cool");
    //
    List<Map<String, dynamic>> liste = [];
    // = await Connexion.liste_plainte("0");
    if (widget.role == 2) {
      liste = await Connexion.liste_plainte("0");
    } else {
      liste = await Connexion.liste_plainte("1");
    }
    //print(liste);

    return Container(
      width: 400,
      child: ListView(
        padding: EdgeInsets.all(10),
        children: List.generate(liste.length, (index) {
          List tiquets = [
            "Gratuité de l'enseignement",
            "Violences basées sur le genre",
            "Autres...",
          ];
          //print(liste[index]["id_tiquet"].runtimeType);
          //print("le tiquet:------------------${tiquets[int.parse(liste[index]["id_tiquet"])] ?? "Pas cool"}");
          //liste[index];
          print(liste[index]["id_tiquet"].runtimeType);
          if(liste[index]["id_tiquet"] != "1"){
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            child: ListTile(
              onTap: () {
                //
                //load();
                //
                setState(() {
                  //widget.state.setState(() {
                  vue = Container();
                  vue = Details(
                    liste[index],
                    key: UniqueKey(),
                    state: this,
                  );
                  print(liste[index]["id_tiquet"]);
                  //});
                });
              },
              leading: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: Icon(
                  CupertinoIcons.person,
                  color: Colors.grey.shade700,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              title: Text(
                "${tiquets[int.parse(liste[index]["id_tiquet"])]}",
                style: TextStyle(
                  //color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              subtitle: Text(
                "${liste[index]['envoyeur']} / ${liste[index]['telephone']}",
                //"Mokpongb lungu joel / 0815454789",
                style: TextStyle(
                  //color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              trailing: Text("${liste[index]['date']}"),
            ),
          );}else{return Container();}
        }),
      ),
    );
  }

  //
  Future<Widget> getPlainte1() async {
    //
    List<Map<String, dynamic>> liste = [];
    // = await Connexion.liste_plainte("0");
    if (widget.role == 2) {
      liste = await Connexion.liste_plainte("2");
    }
    //print(liste);

    return Container(
      width: 400,
      child: ListView(
        padding: EdgeInsets.all(10),
        children: List.generate(liste.length, (index) {
          List tiquets = [
            "Gratuité de l'enseignement",
            "Violences basées sur le genre",
            "Autres...",
          ];
          //print(liste[index]["id_tiquet"].runtimeType);
          //print("le tiquet:------------------${tiquets[int.parse(liste[index]["id_tiquet"])] ?? "Pas cool"}");

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            child: ListTile(
              onTap: () {
                //
                //load();
                //
                setState(() {
                  //widget.state.setState(() {
                  vue = Container();
                  vue = Details(
                    liste[index],
                    key: UniqueKey(),
                    state: this,
                  );
                  print(liste[index]["id_tiquet"]);
                  //});
                });
              },
              leading: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: Icon(
                  CupertinoIcons.person,
                  color: Colors.grey.shade700,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              title: Text(
                "${tiquets[int.parse(liste[index]["id_tiquet"])]}",
                style: TextStyle(
                  //color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              subtitle: Text(
                "${liste[index]['envoyeur']} / ${liste[index]['telephone']}",
                //"Mokpongb lungu joel / 0815454789",
                style: TextStyle(
                  //color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              trailing: Text("${liste[index]['date']}"),
            ),
          );
        }),
      ),
    );
  }

  //
  load() async {
    try {
      if (Platform.isWindows) {
        var shell = Shell();
        //yt1s.io-LibGDX Scene2D -- UI, Widgets and Skins-(1080p).mp4
        //Start chrome C:/Users/Public/Documents/LE_MAGAZINE_DE_L_EPST_4_01.12.2021.pdf
        //await shell.run(
        //  """Start chrome C:/Users/Public/Documents/yt1s.io-LibGDX.mp4""");
        // C:\Users\Public\Documents\LE_MAGAZINE_DE_L'EPST_4_01.12.2021.pdf
      }
    } on ProcessException catch (e) {
      print(e.message);
    }
    //result?.exitCode == 0;
  }

  @override
  void initState() {
    //
    vue = Container();
    //
    controller = TabController(length: angles.length, vsync: this);
    //
    super.initState();
    //
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 400,
          child: Column(
            //backgroundColor: Colors.teal.shade400,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 50,
                      child: TabBar(
                        isScrollable: false,
                        controller: controller,
                        indicatorWeight: 1,
                        //indicator: BoxDecoration(),
                        indicatorColor: Colors.black,
                        labelColor: Colors.black,
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.white10,
                        ),
                        tabs: List.generate(angles.length, (index) {
                          return Tab(
                            text: angles[index],
                          );
                        }),
                      ),
                    ),
                  ),
                  widget.role == 2 || widget.role == 3
                      ? Container(
                          height: 50,
                          width: 50,
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Material(
                                      color: Colors.grey.shade300,
                                      child: Recherche(),
                                    );
                                  });
                            },
                          ),
                        )
                      : Container(),
                ],
              ),
              Expanded(
                flex: 1,
                child: TabBarView(
                  controller: controller,
                  children: [
                    FutureBuilder(
                        future: getPlainte0(),
                        builder: (context, t) {
                          if (t.hasData) {
                            return t.data as Widget;
                          } else if (t.hasError) {
                            return Container();
                          }
                          return Center(
                            child: Container(
                              height: 2,
                              width: 70,
                              alignment: Alignment.center,
                              child: const LinearProgressIndicator(),
                            ),
                          );
                        }),
                    FutureBuilder(
                      future: getPlainte1(),
                      builder: (context, t) {
                        if (t.hasData) {
                          return t.data as Widget;
                        } else if (t.hasError) {
                          return Container();
                        }
                        return Center(
                          child: Container(
                            height: 2,
                            width: 70,
                            alignment: Alignment.center,
                            child: const LinearProgressIndicator(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(child: vue!),
      ],
    );
  }
}

class Recherche extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Recherche();
  }
}

class _Recherche extends State<Recherche> {
  Widget? vue;
  //TextEditingController text = TextEditingController();
  String textRecherche = "";
  //17520194514hxetqmo
  Future<Widget> getPlainte0() async {
    //
    List<Map<String, dynamic>> liste =
        await Connexion.liste_plainteRec(textRecherche);
    //print(liste);

    return Container(
      width: 400,
      child: ListView(
        padding: EdgeInsets.all(10),
        children: List.generate(liste.length, (index) {
          List tiquets = [
            "Gratuité de l'enseignement",
            "Violences basées sur le genre",
            "Autres...",
          ];
          //print(liste[index]["id_tiquet"].runtimeType);
          //print("le tiquet:------------------${tiquets[int.parse(liste[index]["id_tiquet"])] ?? "Pas cool"}");

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            child: ListTile(
              onTap: () {
                //
                //load();
                //
                setState(() {
                  //widget.state.setState(() {
                  vue = Container();
                  vue = Details(
                    liste[index],
                    key: UniqueKey(),
                  );
                  print(liste[index]["id_tiquet"]);
                  //});
                });
              },
              leading: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: Icon(
                  CupertinoIcons.person,
                  color: Colors.grey.shade700,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              title: Text(
                "${tiquets[int.parse(liste[index]["id_tiquet"])]}",
                style: TextStyle(
                  //color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              subtitle: Text(
                "${liste[index]['envoyeur']} / ${liste[index]['telephone']}",
                //"Mokpongb lungu joel / 0815454789",
                style: TextStyle(
                  //color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              trailing: Text("${liste[index]['date']}"),
            ),
          );
        }),
      ),
    );
  }

  @override
  void initState() {
    vue = Container();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 400,
          height: 870.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      color: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close))
                ],
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
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value) {
                            setState(() {
                              textRecherche = value;
                            });
                            print("$value");
                          },
                          decoration: const InputDecoration(
                            hintText: "Recherche par référence",
                            border: InputBorder.none,
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
                child: FutureBuilder(
                  future: getPlainte0(),
                  builder: (context, t) {
                    if (t.hasData) {
                      return t.data as Widget;
                    } else if (t.hasError) {
                      return Container();
                    }
                    return Center(
                      child: Container(
                        height: 2,
                        width: 70,
                        alignment: Alignment.center,
                        child: const LinearProgressIndicator(),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: vue!,
        )
      ],
    );
  }
}
