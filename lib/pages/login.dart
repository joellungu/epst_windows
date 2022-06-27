import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:epst_windows_app/pages/accueil.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'archive_controller.dart';
import 'controllers/plainte_controller.dart';
import 'load_mag/update_controller.dart';

class Login extends StatefulWidget {
  PlainteController plainteController = Get.put(PlainteController());
  //
  ArchiveController archiveController = Get.put(ArchiveController());
  //
  UpdateController updateController = Get.put(UpdateController());
  //
  @override
  State<StatefulWidget> createState() {
    return _Login();
  }
}

class _Login extends State<Login> {
  bool obs = true;

  TextEditingController matriculeC = TextEditingController();
  TextEditingController mdpC = TextEditingController();

  //

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: Row(
        children: [
          Expanded(
            child: Container(
              child: Center(
                child: Container(
                  height: 300,
                  width: 300,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/EPST APP.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 300,
            //height: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  //dashboard_outlined
                  CupertinoIcons.person,
                  //CupertinoIcons.house,
                  //color: Colors.green.shade300,
                  size: MediaQuery.of(context).size.width / 9,
                  //color: Colors.green,
                ),
                const Text(
                  "Connexion",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          " Maricule",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: matriculeC,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    CupertinoIcons.person,
                                    color: Colors.blue,
                                  ),
                                  hintText: "Maricule",
                                  label: Text("Maricule"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Mot de passe",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: mdpC,
                                keyboardType: TextInputType.emailAddress,
                                obscureText: obs,
                                style: const TextStyle(
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                    color: Colors.blue,
                                  ),
                                  hintText: "Mot de passe",
                                  label: Text("Mot de passe"),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  obs ? obs = false : obs = true;
                                });
                              },
                              icon: Icon(Icons.remove_red_eye_outlined),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {
                    var connectivityResult =
                        await (Connectivity().checkConnectivity());
                    if (connectivityResult == ConnectivityResult.mobile ||
                        connectivityResult == ConnectivityResult.wifi) {
                      //
                      if (matriculeC.text.isEmpty || mdpC.text.isEmpty) {
                        //
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Erreur"),
                              content: const Text(
                                  "Veuillez saisire vos identifiants"),
                              actions: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.check),
                                )
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Material(
                              color: Colors.transparent,
                              child: LoaderU(
                                matriculeC.text,
                                mdpC.text,
                                (() {
                                  setState(() {
                                    matriculeC.clear();
                                    mdpC..clear();
                                  });
                                }),
                              ),
                            );
                          },
                        );
                      }
                    } else {
                      //
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Erreur"),
                            content: const Text(
                                "Vous n'etes pas connecté à internet!"),
                            actions: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.check),
                              )
                            ],
                          );
                        },
                      );
                    }
                  },
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                      //backgroundColor:
                      //  MaterialStateProperty.all(Colors.blue.shade900),
                      ),
                  child: SizedBox(
                    height: 45,
                    //width: 220,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        //Icon(Icons.add_box_outlined),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Connexion",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 100),
          )
        ],
      ),
    );
  }
}

//
class LoaderU extends StatefulWidget {
  String matricule;
  String mdp;

  VoidCallback? cl;
  LoaderU(this.matricule, this.mdp, this.cl);
  //
  @override
  State<StatefulWidget> createState() {
    return _LoaderU();
  }
}

class _LoaderU extends State<LoaderU> {
  //
  Widget resultat(Map<String, dynamic> rep) {
    Timer(Duration(seconds: 3), () {
      if (rep["matricule"] == null) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Accueil(rep),
          ),
        );
      }
    });
    return Center(
        child: Container(
      height: 75,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(
        rep["matricule"] == null
            ? "Votre mot de passe ou matricule n'est pas correcte"
            : "Authentification reussit!",
        textAlign: TextAlign.center,
      ),
    ));
  }

  //
  Future<Widget> send() async {
    //print("mon usr:   ${widget.utilisateur}");
    Map<String, dynamic> c =
        await Connexion.utilisateur_login(widget.matricule, widget.mdp);
    widget.cl!();
    return resultat(c);
  }

  //
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 500,
        width: 300,
        alignment: Alignment.center,
        child: FutureBuilder(
          future: send(),
          builder: (context, s) {
            if (s.hasData) {
              return s.data as Widget;
            } else if (s.hasError) {
              return Container(
                color: Colors.amber,
              );
            }
            return Center(
              child: Container(
                height: 40,
                width: 40,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
      ),
    );
  }
}
