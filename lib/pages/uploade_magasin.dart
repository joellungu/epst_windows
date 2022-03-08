import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UploadMagasin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UploadMagasin();
  }
}

class _UploadMagasin extends State<UploadMagasin> {
  Widget? vue;

  @override
  void initState() {
    //
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
          width: 350,
          //color: Colors.grey.shade700,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  child: ListView(
                    children: List.generate(
                      12,
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
                                vue = detailsVue();
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
                              "Gratuité de l'enseignement",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              "12/12/2022",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 10),
                            ),
                            trailing: Text("..."),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  //
                  setState(() {
                    vue = Ajouter();
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

  Widget detailsVue() {
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
                'Libellé',
              ),
              subtitle: Text(
                '...',
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
                '...',
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
                '...',
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
                '...',
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
                '...',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Ajouter extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Ajouter();
  }
}

class _Ajouter extends State<Ajouter> {
  TextEditingController fichierController = TextEditingController();
  //
  importerPdf() async {
    //fichierController

    //
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    //
    if (result != null) {
      File file = File(result.files.single.path!);
      fichierController.text = result.files.single.path!;
    } else {
      // User canceled the picker
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 100, right: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //
          TextField(
            decoration: InputDecoration(
              label: const Text("Nom du magasin"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          //
          TextField(
            maxLines: 15,
            decoration: InputDecoration(
              hintText: "Descriptions",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          //
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: TextField(
                      enabled: false,
                      controller: fichierController,
                      decoration: InputDecoration(
                        label: const Text("Fichier"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: importerPdf,
                  icon: Icon(Icons.import_export),
                ),
              ],
            ),
          ),
          //
          ElevatedButton(
            onPressed: () {
              //
            },
            child: const Center(
              child: Text("Envoyer"),
            ),
          ),
        ],
      ),
    );
  }
}
