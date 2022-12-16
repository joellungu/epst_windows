import 'dart:io';
import 'package:epst_windows_app/main.dart';
import 'package:epst_windows_app/pages/archive.dart';
import 'package:epst_windows_app/pages/chat.dart';
import 'package:epst_windows_app/pages/document_officiel/arretes_ministeriel.dart';
import 'package:epst_windows_app/pages/document_officiel/message_phonique.dart';
import 'package:epst_windows_app/pages/document_officiel/notes_circulaires.dart';
import 'package:epst_windows_app/pages/document_officiel/notifications_arretes.dart';
import 'package:epst_windows_app/pages/plainte/plainte.dart';
import 'package:epst_windows_app/pages/profile/profile.dart';
import 'package:epst_windows_app/pages/sms_compagne.dart';
import 'package:epst_windows_app/pages/plainte/uploade_reformes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:split_view/split_view.dart';
import 'admin/admin.dart';
import 'cours/cours.dart';
import 'document_officiel/secretaria_general.dart';
import 'load_mag/uploade_magasin.dart';
import 'mutuelle/mutuelle.dart';

class Accueil extends StatefulWidget {
  Map<String, dynamic> u;
  Accueil(this.u);
  //
  @override
  State<StatefulWidget> createState() {
    return _Accueil();
  }
}

class _Accueil extends State<Accueil> {
  Widget? aff;
  String titre = "Accueil";
  List<Map<String, dynamic>> options = [];

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
    role = widget.u['role'];
    //
    nomC = "${widget.u['postnom']} ${widget.u['prenom']}";
    options = [
      if (widget.u['role'] == 0 || widget.u['role'] == 1)
        {"nom": "Upload magasin", "icon": Icons.book_online},
      if (widget.u['role'] == 0 || widget.u['role'] == 1)
        {"nom": "Upload réformes", "icon": Icons.edit},
      //
      if (widget.u['role'] == 0 || widget.u['role'] == 1)
        {"nom": "Arretés ministeriels", "icon": Icons.dock_sharp},
      if (widget.u['role'] == 0 || widget.u['role'] == 1)
        {"nom": "Notification arretés", "icon": Icons.notifications},
      if (widget.u['role'] == 0 || widget.u['role'] == 1)
        {"nom": "Notes circulaires", "icon": Icons.note_alt},
      if (widget.u['role'] == 0 || widget.u['role'] == 1)
        {"nom": "Message phonique", "icon": Icons.keyboard_voice},
      if (widget.u['role'] == 0 || widget.u['role'] == 1)
        {"nom": "Secretaria général", "icon": Icons.density_small_outlined},
      //
      if (widget.u['role'] == 0 || widget.u['role'] == 1)
        {"nom": "Upload formation EPST", "icon": Icons.insert_chart},
      if (widget.u['role'] == 0 || widget.u['role'] == 4)
        {"nom": "Chat avec public", "icon": Icons.chat_bubble},
      if (widget.u['role'] == 0 ||
          widget.u['role'] == 2 ||
          widget.u['role'] == 3)
        {"nom": "MGP plainte orientation", "icon": Icons.checklist_outlined},
      if (widget.u['role'] == 0 || widget.u['role'] == 5)
        {"nom": "SMS compagne", "icon": Icons.sms_outlined},
      {"nom": "Profile", "icon": Icons.person},
      if (widget.u['role'] == 0) {"nom": "Chat archive", "icon": Icons.archive},
      //{"nom": "Parametres", "icon": Icons.settings},
      if (widget.u['role'] == 0) {"nom": "Admin", "icon": Icons.dashboard},
      if (widget.u['role'] == 0) {"nom": "Cours en ligne", "icon": Icons.tv},
      if (widget.u['role'] == 0 || widget.u['role'] == 6)
        {"nom": "Mutuelle", "icon": Icons.people},
      {"nom": "Quitter", "icon": Icons.power_settings_new} //
    ];
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
                        title: Text("${widget.u['nom']}"),
                        subtitle: Text(
                            "${widget.u['postnom']} ${widget.u['prenom']}"),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Agent EPST"),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.u['email']}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                if (options[index]["nom"] == "Upload magasin") {
                                  setState(() {
                                    aff = UploadMagasin();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "Upload réformes") {
                                  //
                                  setState(() {
                                    aff = UploadReformes();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "Chat avec public") {
                                  //
                                  setState(() {
                                    aff = Chat(
                                      u: widget.u,
                                    );
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "Cours en ligne") {
                                  //
                                  setState(() {
                                    aff = UploadCours();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "MGP plainte orientation") {
                                  //SmsCompagne
                                  setState(() {
                                    aff = Plainte(widget.u['role']);
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "Chat archive") {
                                  //
                                  setState(() {
                                    aff = Archive(
                                        "${widget.u['postnom']} ${widget.u['prenom']}");
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "SMS compagne") {
                                  //
                                  setState(() {
                                    aff = SmsCompagne();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] == "Admin") {
                                  //Admin
                                  setState(() {
                                    aff = Admin();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] == "Profile") {
                                  setState(() {
                                    aff = Profile(widget.u);
                                  });
                                  Navigator.of(context)
                                      .pop(); ////////////////////////////////////////////////
                                } else if (options[index]["nom"] ==
                                    "Arretés ministeriels") {
                                  setState(() {
                                    aff = ArretesMinisteriel();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "Notification arretés") {
                                  setState(() {
                                    aff = NotificationsArretes();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "Notes circulaires") {
                                  setState(() {
                                    aff = NotesCirculaire();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "Message phonique") {
                                  setState(() {
                                    aff = MessagePhonique();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "Secretaria général") {
                                  //
                                  setState(() {
                                    aff = SecretariaGeneral();
                                  });
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] ==
                                    "Mutuelle") {
                                  //
                                  setState(() {
                                    aff = Mutuelle(widget.u);
                                  }); //Mutuelle
                                  Navigator.of(context).pop();
                                } else if (options[index]["nom"] == "Quitter") {
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
