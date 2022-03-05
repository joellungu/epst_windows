import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'nouvel_utilisateur.dart';

class Admin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Admin();
  }
}

class _Admin extends State<Admin> {
  Widget? vue;

  bool ajouterAgent = false;

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
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: ajouterAgent
                        ? Colors.green.shade700
                        : Colors.grey.shade200,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    //
                    setState(() {
                      vue = NouvelUtilisateur();
                      //
                      ajouterAgent = true;
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
                    "Ajouter nouvel utilisateur",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    "Ajouter nouvel utilisateur",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 10),
                  ),
                  trailing: Text("..."),
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
