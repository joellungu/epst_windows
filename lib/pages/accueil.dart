import 'dart:io';

import 'package:epst_windows_app/pages/chat.dart';
import 'package:epst_windows_app/pages/plainte/plainte.dart';
import 'package:epst_windows_app/pages/sms_compagne.dart';
import 'package:epst_windows_app/pages/uploade_reformes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:split_view/split_view.dart';

import 'admin/admin.dart';
import 'uploade_magasin.dart';

class Accueil extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Accueil();
  }
}

class _Accueil extends State<Accueil> {
  Widget? aff;
  String titre = "Accueil";
  List<Map<String, dynamic>> options = [
    {"nom": "Upload magasin", "icon": Icons.book_online},
    {"nom": "Upload réformes", "icon": Icons.edit},
    {"nom": "Upload structures EPST", "icon": Icons.insert_chart},
    {"nom": "Chat avec public", "icon": Icons.chat_bubble},
    {"nom": "MGP plainte orientation", "icon": Icons.checklist_outlined},
    {"nom": "SMS compagne", "icon": Icons.sms_outlined},
    {"nom": "Profile", "icon": Icons.person},
    {"nom": "Plainte & archive", "icon": Icons.archive},
    {"nom": "Parametres", "icon": Icons.settings},
    {"nom": "Admin", "icon": Icons.dashboard},
    {"nom": "Quitter", "icon": Icons.power_settings_new}
  ];

  @override
  void initState() {
    aff = Center(
      child: Container(
        height: 300,
        width: 300,
        alignment: Alignment.center,
        child: Image.asset(
          "assets/EPST APP.png",
          fit: BoxFit.fill,
        ),
      ),
    );
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titre),
        centerTitle: false,
      ),
      drawer: Drawer(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 150,
                child: DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ListTile(
                        leading: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          child: Icon(
                            CupertinoIcons.person,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        title: Text("Mokpongbo"),
                        subtitle: Text("Lungu Joel"),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Agent EPST"),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  controller: ScrollController(),
                  children: List.generate(
                    options.length,
                    (index) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 3,
                            height: 50,
                            color: Colors.green,
                          ),
                          Expanded(
                            flex: 1,
                            child: ListTile(
                              onTap: () {
                                titre = options[index]["nom"];
                                //
                                if (index == 0) {
                                  setState(() {
                                    aff = UploadMagasin();
                                  });
                                  Navigator.of(context).pop();
                                } else if (index == 1) {
                                  //
                                  setState(() {
                                    aff = UploadReformes();
                                  });
                                  Navigator.of(context).pop();
                                } else if (index == 3) {
                                  //
                                  setState(() {
                                    aff = Chat();
                                  });
                                  Navigator.of(context).pop();
                                } else if (index == 4) {
                                  //SmsCompagne
                                  setState(() {
                                    aff = Plainte();
                                  });
                                  Navigator.of(context).pop();
                                } else if (index == 5) {
                                  //
                                  setState(() {
                                    aff = SmsCompagne();
                                  });
                                  Navigator.of(context).pop();
                                } else if (index == 9) {
                                  //Admin
                                  setState(() {
                                    aff = Admin();
                                  });
                                  Navigator.of(context).pop();
                                } else if (index == 10) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Quitter"),
                                        content: const Text(
                                            "Voulez-vous vraiment quitter l'applicaton ?"),
                                        actions: [
                                          IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon: Icon(Icons.close),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              exit(0);
                                            },
                                            icon: Icon(Icons.check),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              leading: Icon(options[index]["icon"]),
                              title: Text(options[index]["nom"]),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: aff,
    );
  }
}

/*
viewMode: SplitViewMode.Vertical,
        indicator: SplitIndicator(viewMode: SplitViewMode.Vertical),
        activeIndicator: SplitIndicator(
          viewMode: SplitViewMode.Vertical,
          isActive: true,
        ),
        controller: SplitViewController(limits: [null, WeightLimit(max: 0.5)]),
        onWeightChanged: (w) => print("Vertical $w"),
*/