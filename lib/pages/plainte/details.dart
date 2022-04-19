import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:epst_windows_app/main.dart';
import 'package:epst_windows_app/pages/plainte/menu.dart';
import 'package:epst_windows_app/pages/plainte/plainte.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';

class Details extends StatefulWidget {
  Map<String, dynamic> element = {};
  //static Widget? details;
  Details(
    this.element, {
    Key? key,
  }) : super(key: key);
  //____________________
  @override
  State<StatefulWidget> createState() {
    return _Details();
  }
}

class _Details extends State<Details> {
  //
  TextEditingController deC = TextEditingController();
  TextEditingController telephoneC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController aC = TextEditingController();
  TextEditingController messageC = TextEditingController();
  TextEditingController provinceC = TextEditingController();
  TextEditingController id_tiquetC = TextEditingController();
  TextEditingController referenceC = TextEditingController();

  List liste = ["Video", "Image", "Document"];
  List<Map<String, dynamic>> listePiecejointe = [];

  @override
  void initState() {
    //Plainte.details = Container();
    print("le contenu: ${widget.element}");
    //
    messageC.text = widget.element["message"];
    deC.text = widget.element["envoyeur"];
    telephoneC.text = widget.element["telephone"];
    emailC.text = widget.element["email"];
    aC.text = widget.element["destinateur"];
    messageC.text = widget.element["message"];
    provinceC.text = widget.element["province"];
    id_tiquetC.text = widget.element["id_tiquet"];
    referenceC.text = widget.element["reference"];
    //
    if (mounted) {
      recuper_et_ecrire();
    }
    //
    print("le message :${messageC.text}");
    //
    super.initState();
  }

  recuper_et_ecrire() async {
    List<Map<String, dynamic>> liste =
        await Connexion.liste_piecejointe(widget.element["piecejointe_id"]);
    liste.forEach((piece) {
      listePiecejointe
          .add({"type": "${piece['type']}", "id": "${piece['id']}"});
      //File('$tempDirectory/${piece['id']}.${piece['type']}')
      //  .writeAsBytes(base64Decode(piece['donne']));
    });
    //Timer(Duration(seconds: 1), () {
    setState(() {});
    //});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          width: 400,
          child: ListView(
            controller: ScrollController(),
            children: [
              TextField(
                controller: deC,
                enabled: false,
                decoration: InputDecoration(
                  //prefixIcon: Text("De:"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  label: Text("De:"),
                  //prefixText: "De: "
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: aC,
                enabled: false,
                decoration: InputDecoration(
                  //prefixIcon: Text("De:"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  label: Text("À:"),
                  //prefixText: "De: "
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: telephoneC,
                enabled: false,
                decoration: InputDecoration(
                    //prefixIcon: Text("Téléphone:"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    label: Text("Téléphone:")
                    //prefixText: "De: "
                    ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: emailC,
                enabled: false,
                decoration: InputDecoration(
                  //prefixIcon: Text("Email:"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  label: Text("Email:"),
                  //prefixText: "De: "
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: provinceC,
                enabled: false,
                decoration: InputDecoration(
                  //prefixIcon: Text("Email:"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  label: Text("Province"),
                  //prefixText: "De: "
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: id_tiquetC,
                enabled: false,
                decoration: InputDecoration(
                  //prefixIcon: Text("Email:"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  label: Text("Tiquet"),
                  //prefixText: "De: "
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: referenceC,
                enabled: false,
                decoration: InputDecoration(
                  //prefixIcon: Text("Email:"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                  label: Text("reférence"),
                  //prefixText: "De: "
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(messageC.text),
              SizedBox(
                height: 20,
              ),
            ],
          ),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    controller: ScrollController(),
                    children: List.generate(listePiecejointe.length, (index) {
                      String ty = listePiecejointe[index]["type"];
                      String id = listePiecejointe[index]["id"];

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: ListTile(
                          onTap: () async {
                            //
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
                            ].contains(ty.toUpperCase())) {
                              //
                              Player player = Player(id: 69420 + index);
                              /*
                              player.open(
                                Media.file(File('$tempDirectory/$id.$ty')),
                                autoStart: true, // default
                              );
                              */
                              //
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Material(
                                      color: Colors.transparent,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
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
                                                            BorderRadius
                                                                .circular(25)),
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
                                            padding: EdgeInsets.all(50),
                                            child: Video(
                                              key: UniqueKey(),
                                              player: player,
                                              //height: 2920.0,
                                              //width: 1080.0,
                                              scale: 1.0,
                                              fit: BoxFit.contain,
                                              filterQuality: FilterQuality.high,
                                              showControls: true,
                                              playlistLength: 0, // default
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
                            ].contains(ty.toLowerCase())) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Material(
                                      color: Colors.transparent,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
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
                                                            BorderRadius
                                                                .circular(25)),
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
                                            child: ExtendedImage.asset(
                                                "$tempDirectory/$id.$ty"),
                                          ))
                                        ],
                                      ),
                                    );
                                  });
                            } else {
                              await shell.run(
                                  """Start chrome $tempDirectory/$id.$ty""");
                            }
                          },
                          leading: Container(
                            height: 40,
                            width: 40,
                            alignment: Alignment.center,
                            child: Icon(
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
                              ].contains(ty.toUpperCase())
                                  ? CupertinoIcons.play
                                  : [
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
                                    ].contains(ty.toLowerCase())
                                      ? CupertinoIcons.photo
                                      : CupertinoIcons.doc_fill,
                              color: Colors.grey.shade700,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          title: Text(
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
                            ].contains(ty.toUpperCase())
                                ? "Video"
                                : [
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
                                  ].contains(ty.toLowerCase())
                                    ? "Image"
                                    : "Document",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            "${listePiecejointe[index]["id"]}",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          trailing: Text("$tempDirectory"),
                        ),
                      );
                    }),
                  ),
                ),
                Container(
                  height: 50,
                  width: 300,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 40,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Traiter",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              onSelected: (t) {
                                //
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: () {},
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Classer",
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                  value: 1,
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    //
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Envoyer",
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
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
                                        "Avis",
                                        style: TextStyle(
                                          color: Colors.black,
                                        ),
                                      )
                                    ],
                                  ),
                                  value: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
