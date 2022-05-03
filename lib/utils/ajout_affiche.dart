import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:alfred/alfred.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:epst_windows_app/main.dart';
import 'package:epst_windows_app/pages/controllers/plainte_controller.dart';
import 'package:epst_windows_app/pages/uploade_magasin.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:process_run/shell.dart';
import 'package:webview_windows/webview_windows.dart';
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
  importerFile() async {
    //fichierController

    //
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      //allowedExtensions: ['pdf'],
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
                  onPressed: importerFile,
                  icon: Icon(Icons.import_export),
                ),
              ],
            ),
          ),
          //
          ElevatedButton(
            onPressed: () {
              if (nom_c.text.isEmpty) {
                messageErreur("Erreur", "Champ titre vide");
              } else if (description_c.text.isEmpty) {
                messageErreur("Erreur", "Champ description vide");
              } else if (file!.path.isEmpty) {
                messageErreur("Erreur", "Pas de fichier associé");
              } else {
                List l = fichierController.text.split(".");
                //
                //Enregistrement utilisateur...
                showDialog(
                  context: context,
                  builder: (context) {
                    return Material(
                      color: Colors.white,
                      child: LoaderU({
                        //"id": 1,
                        "date": "${DateTime.now()}",
                        "libelle": nom_c.text,
                        "description": description_c.text,
                        //"piecejointe": File(file!.path).readAsBytesSync(),//file!.path,
                        "types": widget.type,
                        "extention": l.last,
                      }, file!.path, widget.type!),
                    );
                  },
                );
              }
            },
            child: const Center(
              child: Text("Envoyer"),
            ),
          ),
        ],
      ),
    );
  }

  messageErreur(String titre, String message) {
    //GetSnackBar(title: titre, message: message);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titre),
          content: Text(message),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.close,
              ),
            )
          ],
        );
      },
    );
  }
}

class LoaderU extends StatefulWidget {
  Map<String, dynamic> utilisateur;
  String? path;
  late int type;
  LoaderU(this.utilisateur, this.path, this.type);
  //
  @override
  State<StatefulWidget> createState() {
    return _LoaderU();
  }
}

class _LoaderU extends State<LoaderU> {
  //
  PlainteController plainteController = Get.find();
  //
  Widget resultat(String message) {
    //
    //if (mounted) {
    //UploadMagasin.magState.setState(() {});
    //}
    //
    Timer(const Duration(seconds: 2), () {
      //
      Navigator.of(context).pop();
      //
      plainteController.reloads(widget.type);
    });
    return Center(
      child: Container(
        height: 200,
        width: 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            "Ce libelle existe déjà" == message
                ? Icon(
                    Icons.close,
                    size: 150,
                    color: Colors.red.shade700,
                  )
                : const Icon(
                    Icons.check_circle_outline,
                    size: 150,
                    color: Colors.green,
                  ),
            Text(message)
          ],
        ),
      ),
    );
  }

  //
  Future<Widget> send() async {
    String c = await Connexion.saveMagasin(widget.utilisateur);
    //print(widget.utilisateur);
    Connexion.majMag(c, widget.path!);
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
            alignment: Alignment.center,
            child: Text("Erreur du à: ${s.error}"),
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

////////////////////////////////////////////////////////////////////////////////

class Affiche extends StatefulWidget {
  Affiche(this.id);
  int? id;

  @override
  State<StatefulWidget> createState() {
    return _Affiche();
  }
}

class _Affiche extends State<Affiche> {
  //
  final app = Alfred();
  bool vue = false;
  Map<String, dynamic> mag = {};
  //
  recuper_et_ecrire() async {
    mag = await Connexion.getMagasin(widget.id!);
    File('$tempDirectory/${mag['id']}.${mag['extention']}')
        .writeAsBytes(base64Decode(mag['piecejointe']));
    setState(() {
      vue = true;
    });
  }
  //

  @override
  void initState() {
    //
    recuper_et_ecrire();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: vue
          ? Center(
              child: ListTile(
              onTap: () async {
                var shell = Shell();
                //yt1s.io-LibGDX Scene2D -- UI, Widgets and Skins-(1080p).mp4
                //Start chrome C:/Users/Public/Documents/LE_MAGAZINE_DE_L_EPST_4_01.12.2021.pdf
                if ([
                  "MP4",
                  "MOV",
                  "WMV",
                  "AVI",
                  "AVCHD",
                  "FLV",
                  "F4V",
                  "SWF",
                  "MKV",
                  "MPEG-2"
                ].contains("${mag['extention']}".toUpperCase())) {
                  //
                  Player player = Player(id: 7);
                  player.add(Media.file(
                      File("$tempDirectory/${mag['id']}.${mag['extention']}")));
                  /*
                player.open(
                  Media.file(File('$tempDirectory/${mag['id']}.${mag['extention']}')),
                  autoStart: true, // default
                );
                */
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Material(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                        onTap: () {
                                          player.dispose();
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.black,
                                          ),
                                        ))
                                  ]),
                              Expanded(
                                  child: Container(
                                //color: Colors.yellow,
                                padding: EdgeInsets.all(50),
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 2,
                                  child: Video(
                                    key: UniqueKey(),
                                    player: player,
                                    //height: 2920.0,
                                    //width: 1080.0,
                                    scale: 1.0,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                    // default
                                    showControls: true,
                                    playlistLength: 0, // default
                                  ),
                                ),
                              ))
                            ],
                          ),
                        );
                      });
                } else if ([
                  "tif",
                  "tiff",
                  "bmp",
                  "jpg",
                  "jpeg",
                  "gif",
                  "png",
                  "eps",
                  "raw",
                  "cr2",
                  "nef",
                  "orf",
                  "sr2"
                ].contains("${mag['extention']}".toLowerCase())) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Material(
                        color: Colors.transparent,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                    onTap: () {
                                      //player.dispose();
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                      ),
                                    ))
                              ],
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(200),
                                child: ExtendedImage.file(
                                  File(
                                    "$tempDirectory/${mag['id']}.${mag['extention']}",
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  await shell.run(
                      """Start chrome $tempDirectory/${mag['id']}.${mag['types']}""");
                }
                //await shell
                //  .run("""Start chrome $tempDirectory/${mag['id']}.${mag['types']}""");
              },
              leading: Icon(
                [
                  "MP4",
                  "MOV",
                  "WMV",
                  "AVI",
                  "AVCHD",
                  "FLV",
                  "F4V",
                  "SWF",
                  "MKV",
                  "MPEG-2"
                ].contains('${mag["extention"]}'.toUpperCase())
                    ? Icons.play_arrow_outlined
                    : Icons.file_download_done,
                color: Colors.black,
              ),
              title: Text(
                "${mag["libelle"]}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text("${mag["libelle"]}"),
            ))
          : Center(
              child: Container(
                alignment: Alignment.center,
                height: 5,
                width: 100,
                child: LinearProgressIndicator(),
              ),
            ),
    );
  }
}
