import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:native_pdf_renderer/native_pdf_renderer.dart';

import 'connexion.dart';


class Ajouter extends StatefulWidget {
  int? type;

  Ajouter(this.type);

  @override
  State<StatefulWidget> createState() {
    return _Ajouter();
  }
}

class _Ajouter extends State<Ajouter> {
  TextEditingController nom_c = TextEditingController(); //libelle
  TextEditingController description_c = TextEditingController(); //libelle
  TextEditingController fichierController = TextEditingController(); //libelle
  File? file;

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
      file = File(result.files.single.path!);
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
            controller: nom_c,
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
            controller: description_c,
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
              //Enregistrement utilisateur...
              Connexion.saveMagasin({
                //"id": 1,
                "date": "${DateTime.now()}",
                "libelle": nom_c.text,
                "description": description_c.text,
                "piecejointe": file!.readAsBytesSync(),
                "type":1
              });
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

class Affiche extends StatefulWidget {

  Affiche(this.id);
  int? id;

  @override
  State<StatefulWidget> createState() {
    return _Affiche();
  }
}

class _Affiche extends State<Affiche>{


  Future<Widget> vueFichier() async {

    Map<String,dynamic> mag = await Connexion.getMagasin(widget.id!);
    //
    try {
      final document = await PdfDocument.openAsset('assets/sample.pdf');
      final page = await document.getPage(1);
      final pageImage = await page.render(width: page.width, height: page.height);
      await page.close();
      return Center(
        child: Image(
          image: MemoryImage(pageImage!.bytes),
        ),
      );
    }catch(e){
      print("erreur du à: $e");
    }
    print(mag["id"]);
    return Container(
      color: Colors.teal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: vueFichier(),
        builder: (context, t){
          if(t.hasData){
            return t.data as Widget;
          }else if(t.hasError){
            return Center(
              child: Container(
                alignment: Alignment.center,
                child: Text("Probème de connexion"),
                height: 51,width: 250,
              ),
            );
          }
          return Center(
            child: Container(child: LinearProgressIndicator(),height: 2,width: 200,),
          );
        },
      ),
    );
  }

}
