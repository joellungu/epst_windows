import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/ajout_affiche.dart';

class UploadMagasin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UploadMagasin();
  }
}

class _UploadMagasin extends State<UploadMagasin> {
  Widget? vue;
  Widget? vue2;

  Future<Widget> loadMagasin() async {
    List<Map<String, dynamic>> liste = await Connexion.liste_magasin(1);
    print("longueur  ___  $liste");
    return ListView(
      children: List.generate(
        liste.length,
        (index) {
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
                setState(() {
                  vue2 = Affiche(liste[index]["id"]);
                  //
                  vue = detailsVue(liste[index]);

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
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              title: Text(
                liste[index]["libelle"],
                style: TextStyle(
                  //color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              subtitle: Text(
                liste[index]["date"],
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 10,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  //
                  setState(() {
                    Connexion.supprimer_magasin(liste[index]["id"]);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
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
              const SizedBox(
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
                          decoration: InputDecoration(
                            hintText: "Recherche des magasins en ligne.",
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
                  future: loadMagasin(),
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
              ElevatedButton(
                onPressed: () async {
                  //
                  setState(() {
                    vue = Ajouter(1);
                  });
                },
                child: Center(
                  child: Text("Ajouter magasin"),
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
    print(mag);
    //
    //
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
                      mag["libelle"],
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
                      mag["description"],
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      'Date mise en ligne',
                    ),
                    subtitle: Text(
                      mag["date"],
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      '...',
                    ),
                    subtitle: Text(
                      "...",
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      '...',
                    ),
                    subtitle: Text(
                      '...',
                    ),
                  ),
                ),
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

