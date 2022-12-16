import 'dart:convert';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'nouvel_utilisateur.dart';
import 'update_agent.dart';

class ListUtilisateur extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListUtilisateur();
  }
}

class _ListUtilisateur extends State<ListUtilisateur> {
  Widget? vue;

  bool ajouterAgent = false;

  Future<Widget> listeAgent() async {
    List<Map<String, dynamic>> liste = await Connexion.liste_utilisateur();
    return ListView(
      padding: EdgeInsets.all(10),
      children: List.generate(liste.length, (index) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color:
                  ajouterAgent ? Colors.green.shade700 : Colors.grey.shade200,
            ),
          ),
          child: ListTile(
            onTap: () {
              //
              setState(() {
                vue = detailsVue(liste[index]);
                //
                ajouterAgent = true;
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
              "${liste[index]['nom']}  ${liste[index]['postnom']}  ${liste[index]['prenom']}",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            subtitle: Text(
              "${[
                "Administrateur",
                "Uploader",
                "MGP-utilisateur",
                "MGP-admin",
                "Chat-utilisateur",
                "Editeurs SMS",
                "Agent mutuelle",
                "Inspecteur",
              ][liste[index]['role']]} / ${liste[index]['numero']}",
              style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.normal,
                  fontSize: 10),
            ),
            trailing: PopupMenuButton(
              icon: Icon(Icons.more_vert),
              onSelected: (t) {
                if (t == 1) {
                  //
                  //
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Material(
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 50,
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: UpdatelUtilisateur(liste[index]),
                            )
                          ],
                        ),
                      );
                    },
                  );
                } else if (t == 2) {
                  //
                  Map<String, dynamic> m = liste[index];
                  m["id_statut"] = liste[index]["id_statut"] == "0" ? "1" : "0";
                  //
                  //print("_______: ${json.encode(m)}");
                  //Navigator.of(context).pop();update_utilisateur
                  setState(() {
                    Connexion.update_utilisateur(m);
                  });
                } else {
                  //Navigator.of(context).pop();
                  setState(() {
                    Connexion.supprimer_utilisateur(liste[index]["id"]);
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Mettre à jour",
                        //style: Theme.of(context).textTheme.bodyText1,
                      )
                    ],
                  ),
                  value: 1,
                ),
                PopupMenuItem(
                  onTap: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        liste[index]["id_statut"] == "0"
                            ? "Desactiver"
                            : "Activer",
                        //style: Theme.of(context).textTheme.bodyText1,
                      )
                    ],
                  ),
                  value: 2,
                ),
                PopupMenuItem(
                  onTap: () {
                    //
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Supprimer",
                        //style: Theme.of(context).textTheme.bodyText1,
                      )
                    ],
                  ),
                  value: 3,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  void initState() {
    vue = Container();
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 400,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          child: FutureBuilder(
            future: listeAgent(),
            builder: (context, t) {
              if (t.hasData) {
                return t.data as Widget;
              } else if (t.hasError) {
                return Center(
                  child: Text("Problème de connexion"),
                );
              }

              return Center(
                child: Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  child: LinearProgressIndicator(),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: vue!,
        )
      ],
    );
  }

  Widget detailsVue(Map<String, dynamic> e) {
    return Scaffold(
      body: ListView(
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
                'Nom',
              ),
              subtitle: Text(
                e["nom"],
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'Postnom',
              ),
              subtitle: Text(
                e["postnom"],
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'Prenom',
              ),
              subtitle: Text(
                e["prenom"],
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                "Date d'enregistrement",
              ),
              subtitle: Text(
                e["date_de_naissance"],
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'Numero',
              ),
              subtitle: Text(
                e["numero"],
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'email',
              ),
              subtitle: Text(
                e["email"],
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'adresse',
              ),
              subtitle: Text(
                e["adresse"],
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'Role',
              ),
              subtitle: Text(
                "${e["role"]}",
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'Matricule',
              ),
              subtitle: Text(
                "${e["matricule"]}",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
