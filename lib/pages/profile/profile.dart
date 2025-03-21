import 'dart:async';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  Map<String, dynamic> agent = {};

  Profile(this.agent);
  @override
  State<StatefulWidget> createState() {
    return _Profile();
  }
}

class _Profile extends State<Profile> {
  //
  TextEditingController nom_c = TextEditingController();
  TextEditingController postnom_c = TextEditingController();
  TextEditingController prenom_c = TextEditingController();
  TextEditingController numero_c = TextEditingController();
  TextEditingController email_c = TextEditingController();
  TextEditingController adresse_c = TextEditingController();
  TextEditingController matricule_c = TextEditingController();
  TextEditingController date_enregistrement_c = TextEditingController();
  TextEditingController mdp = TextEditingController();
  //
  //
  int a = 0;
  var Fichier = "";
  DateTime date_de_naissance = DateTime.now();
  List listeRole = [
    "Administrateur",
    "Uploader",
    "MGP-utilisateur",
    "MGP-admin",
    "Chat-utilisateur",
    "Editeurs SMS"
  ];
  //
  @override
  void initState() {
    //
    nom_c.text = widget.agent["nom"];
    postnom_c.text = widget.agent["postnom"];
    prenom_c.text = widget.agent["prenom"];
    numero_c.text = widget.agent["numero"];
    email_c.text = widget.agent["email"];
    adresse_c.text = widget.agent["adresse"];
    matricule_c.text = widget.agent["matricule"];
    date_enregistrement_c.text = widget.agent["date_de_naissance"];
    mdp.text = widget.agent["mdp"];
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 400,
            padding: const EdgeInsets.all(10),
            child: ListView(
              controller: ScrollController(),
              padding: const EdgeInsets.only(
                top: 10,
              ),
              children: [
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: const Text("Votre profil"),
                ),
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: nom_c,
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
                                  hintText: "Nom",
                                  label: Text("Nom"),
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
                //
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: postnom_c,
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
                                  hintText: "Postnom",
                                  label: Text("Postnom"),
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
                //
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: prenom_c,
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
                                  hintText: "Prenom",
                                  label: Text("Prenom"),
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
                //
                Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Date d'enregistrement",
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
                                enabled: false,
                                controller: date_enregistrement_c,
                                keyboardType: TextInputType.emailAddress,
                                //obscureText: obs,
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
                                    Icons.date_range,
                                    color: Colors.blue,
                                  ),
                                  hintText: "Date de naissance",
                                  //label: Text("Date de naissance"),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  //obs ? obs = false : obs = true;
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2030),
                                  ).then((value) {
                                    date_de_naissance = value!;
                                    date_enregistrement_c.text =
                                        date_de_naissance.toString();
                                    print(value);
                                  });
                                });
                              },
                              icon: Icon(Icons.calendar_today_outlined),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: numero_c,
                                keyboardType: TextInputType.number,
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
                                    CupertinoIcons.phone,
                                    color: Colors.blue,
                                  ),
                                  hintText: "Numéro de téléphone",
                                  label: Text("Numéro de téléphone"),
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
                //
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: email_c,
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
                                    CupertinoIcons.mail,
                                    color: Colors.blue,
                                  ),
                                  hintText: "Email",
                                  label: Text("Email"),
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
                //
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: matricule_c,
                                keyboardType: TextInputType.text,
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
                                    CupertinoIcons.signature,
                                    color: Colors.blue,
                                  ),
                                  hintText: "Matricule",
                                  label: Text("Matricule"),
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
                //
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: adresse_c,
                                keyboardType: TextInputType.text,
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
                                  hintText: "Adresse de residence",
                                  label: Text("Adresse de residence"),
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
                //
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: mdp,
                                keyboardType: TextInputType.text,
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
                                  hintText: "Mot de passe",
                                  label: Text("Mot de passe"),
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
                /*
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Container(
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Role de l'agent",
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
                        /*
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 55,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<int>(
                              value: a,
                              onChanged: (value) {
                                value = a;
                              },
                              items: List.generate(
                                listeProvince.length,
                                (index) {
                                  return DropdownMenuItem(
                                    value: index,
                                    child: Text(listeProvince[index]),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                        */
                      ],
                    ),
                  ),

                ),
                */
                const SizedBox(
                  height: 10,
                ),
                //
                ElevatedButton(
                  onPressed: () {
                    //
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Material(
                            color: Colors.white,
                            child: LoaderU(
                              {
                                "id": widget.agent["id"],
                                "nom": nom_c.text,
                                "postnom": postnom_c.text,
                                "prenom": prenom_c.text,
                                "date_de_naissance": "$date_de_naissance",
                                "numero": numero_c.text,
                                "email": email_c.text,
                                "adresse": adresse_c.text,
                                "role": a,
                                "matricule": matricule_c.text,
                                "id_statut": "1",
                                "mdp": mdp.text,
                              },
                              (() {
                                setState(() {
                                  matricule_c.clear();
                                  adresse_c..clear();
                                  email_c..clear();
                                  numero_c..clear();
                                  prenom_c..clear();
                                  postnom_c..clear();
                                  nom_c..clear();
                                });
                              }),
                            ),
                          );
                        });
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
                          "Enregistrer",
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
class LoaderU extends StatefulWidget {
  Map<String, dynamic>? utilisateur;
  VoidCallback? cl;
  LoaderU(this.utilisateur, this.cl);
  //
  @override
  State<StatefulWidget> createState() {
    return _LoaderU();
  }
}

class _LoaderU extends State<LoaderU> {
  //
  Widget resultat(String message) {
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
    return Center(
      child: Text(message),
    );
  }

  //
  Future<Widget> send() async {
    print("mon usr:   ${widget.utilisateur}");
    String c = await Connexion.update_utilisateur(widget.utilisateur!);
    widget.cl!();
    return resultat(c);
  }

  //
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
    );
  }
}
