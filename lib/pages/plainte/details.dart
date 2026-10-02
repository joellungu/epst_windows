import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:epst_windows_app/main.dart';
import 'package:epst_windows_app/pages/controllers/plainte_controller.dart';
import 'package:epst_windows_app/pages/plainte/menu.dart';
import 'package:epst_windows_app/pages/plainte/plainte.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:process_run/shell.dart';
import 'package:video_player/video_player.dart';

class Details extends StatefulWidget {
  Map<String, dynamic> element = {};
  State? state;
  //static Widget? details;
  Details(this.element, {Key? key, this.state}) : super(key: key);
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
  TextEditingController nomC = TextEditingController();
  TextEditingController postnomC = TextEditingController();
  TextEditingController prenomC = TextEditingController();
  TextEditingController sexeC = TextEditingController();
  TextEditingController etablissementC = TextEditingController();
  TextEditingController profilC = TextEditingController();
  TextEditingController provinceEducationC = TextEditingController();
  TextEditingController latitudeC = TextEditingController();
  TextEditingController longitudeC = TextEditingController();
  //
  PlainteController plainteController = Get.find();
  //
  List liste = ["Video", "Image", "Document"];
  List<Map<String, dynamic>> listePiecejointe = [];

  @override
  void initState() {
    //Plainte.details = Container();
    print("le contenu: ${widget.element}");
    //
    messageC.text = widget.element["message"] ?? "";
    deC.text = widget.element["envoyeur"] ?? "";
    telephoneC.text = widget.element["telephone"] ?? "";
    emailC.text = widget.element["email"] ?? "";
    aC.text = widget.element["destinateur"] ?? "";
    provinceC.text = widget.element["province"] ?? "";
    id_tiquetC.text = "${widget.element["id_tiquet"] ?? ""}";
    referenceC.text = widget.element["reference"] ?? "";
    //
    nomC.text = widget.element["nom"] ?? "";
    postnomC.text = widget.element["postnom"] ?? "";
    prenomC.text = widget.element["prenom"] ?? "";
    sexeC.text = widget.element["sexe"] ?? "";
    etablissementC.text = widget.element["etablissement"] ?? "";
    profilC.text = widget.element["profil"] ?? "";
    provinceEducationC.text = widget.element["province_education"] ?? "";
    final lat = widget.element["latitude"];
    final lon = widget.element["longitude"];
    latitudeC.text = (lat == null || lat == 0) ? "" : "$lat";
    longitudeC.text = (lon == null || lon == 0) ? "" : "$lon";
    //
    recuper_et_ecrire();

    //
    var c = utf8.decode(messageC.text.codeUnits);
    print("le message :${c.characters}");
    //
    super.initState();
  }

  recuper_et_ecrire() async {
    print("(((((((((((())))))): ${widget.element}");
    plainteController.listePieceJointe.value.clear();
    plainteController.listePieceJointe.value =
        await Connexion.liste_piecejointe(
            "${widget.element["piecejointe_id"]}");
    plainteController.listePieceJointe.value.forEach((piece) {
      listePiecejointe
          .add({"extention": "${piece['type']}", "id": "${piece['id']}"});
      File('$tempDirectory\\${piece['id']}.${piece['type']}')
          .writeAsBytes(base64Decode(piece['donne']));
      print("truc__________________________________${{
        "extention": "${piece['type']}",
        "id": "${piece['id']}"
      }}");
    });

    //Timer(Duration(seconds: 1), () {
    //setState(() {});
    //});
  }

  Widget _entete() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.report_problem_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Détails de la plainte",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Informations fournies par le plaignant via MGP",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitre(String titre, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade800),
          const SizedBox(width: 8),
          Text(
            titre,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //
    //recuper_et_ecrire();

    var c = utf8.decode(messageC.text.codeUnits);
    //
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          width: 400,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          child: ListView(
            controller: ScrollController(),
            children: [
              _entete(),
              _sectionTitre("Identité du plaignant", Icons.person_outline),
              _field(nomC, "Nom"),
              _field(postnomC, "Post-nom"),
              _field(prenomC, "Prénom"),
              _field(sexeC, "Sexe"),
              _field(etablissementC, "Établissement"),
              _field(profilC, "Profil du plaignant"),
              const SizedBox(height: 12),
              _sectionTitre("Coordonnées", Icons.contact_phone_outlined),
              _field(telephoneC, "Téléphone"),
              _field(emailC, "Email"),
              const SizedBox(height: 12),
              _sectionTitre("Localisation", Icons.location_on_outlined),
              _field(provinceC, "Province"),
              _field(provinceEducationC, "Province éducation"),
              const SizedBox(height: 12),
              _sectionTitre("Géolocalisation", Icons.my_location),
              _field(latitudeC, "Latitude"),
              _field(longitudeC, "Longitude"),
              const SizedBox(height: 12),
              _sectionTitre("Plainte", Icons.assignment_outlined),
              _field(id_tiquetC, "Thématique"),
              _field(referenceC, "Référence"),
              const SizedBox(height: 15),
              const Text(
                "Message",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text("${c.characters}"),
              ),
              const SizedBox(height: 20),
            ],
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
                  child: Obx(
                    (() => ListView(
                          padding: EdgeInsets.all(10),
                          controller: ScrollController(),
                          children: List.generate(
                              plainteController.listePieceJointe.value.length,
                              (index) {
                            print(
                                "-------------------------------:  ${plainteController.listePieceJointe.value[index]['type']}");
                            print(
                                "-------------------------------:  ${plainteController.listePieceJointe.value[index]['type']}");

                            // ignore: invalid_use_of_protected_member
                            String ty = plainteController
                                .listePieceJointe.value[index]["type"];
                            // ignore: invalid_use_of_protected_member
                            int id = plainteController
                                .listePieceJointe.value[index]["id"];

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
                                    var controller = VideoPlayerController.file(
                                        File("$tempDirectory\\$id.$ty"));
                                    //
                                    // Player player = Player(id: 69420 + index);
                                    // player.open(
                                    //   Media.file(
                                    //     File('$tempDirectory\\$id.$ty'),
                                    //   ),
                                    //   autoStart: true, // default
                                    // );
                                    //
                                    //
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Material(
                                            color: Colors.transparent,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        //player.dispose();
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(25),
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                          Icons.close,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(50),
                                                    child:
                                                        VideoPlayer(controller),
                                                    // child: Video(
                                                    //   key: UniqueKey(),
                                                    //   player: player,
                                                    //   //height: 2920.0,
                                                    //   //width: 1080.0,
                                                    //   scale: 1.0,
                                                    //   fit: BoxFit.contain,
                                                    //   filterQuality:
                                                    //       FilterQuality.high,
                                                    //   showControls: true,
                                                    //   //playlistLength: 0,
                                                    //   //playlistLength: 0,
                                                    //   //default
                                                    // ),
                                                  ),
                                                )
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                        onTap: () {
                                                          //player!.dispose();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          25)),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.black,
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.all(200),
                                                    child: Image.file(
                                                      File(
                                                          "$tempDirectory/$id.$ty"),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        });
                                  } else {
                                    await shell.run(
                                        """Start chrome $tempDirectory\\$id.$ty""");
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
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),

                                subtitle: Text(
                                  "$tempDirectory/$id.$ty",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                //trailing: Text("$tempDirectory/$id.$ty"),
                              ),
                            );
                          }),
                        )),
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
                                if (t == 1) {
                                  var m = widget.element;
                                  m["id_statut"] = 3;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Material(
                                        child: Traitement1(widget.state!, m),
                                      );
                                    },
                                  );
                                } else if (t == 2) {
                                  var m = widget.element;
                                  m["id_statut"] = 1;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Material(
                                        child: Traitement1(widget.state!, m),
                                      );
                                    },
                                  );
                                } else {
                                  var m = widget.element;
                                  m["id_statut"] = 2;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Material(
                                        child: Traitement2(widget.state!, m),
                                      );
                                    },
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                if (role == 2)
                                  PopupMenuItem(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                if (role == 2)
                                  PopupMenuItem(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                if (role == 3)
                                  PopupMenuItem(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Traiter",
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

class Traitement1 extends StatelessWidget {
  TextEditingController note = TextEditingController();
  Map<String, dynamic> mapPlainte = {};
  State state;

  Traitement1(this.state, this.mapPlainte);

  conteAr(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pop();
      Plainte.plainteState.setState(() {});
    });

    return Center(
      child: Container(
        height: 200,
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(
              Icons.check,
              size: 70,
            ),
            Text("La mise à jour éffectué !"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: FutureBuilder(
        future: Connexion.majPlainte(mapPlainte),
        builder: (context, t) {
          if (t.hasData) {
            if (t.data == 201 || t.data == 200) {
              return conteAr(context);
            } else {
              return Center(
                child: Container(
                  height: 200,
                  width: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(
                        Icons.check,
                        size: 70,
                      ),
                      Text("Une erreu s'est produite code: ${t.error}"),
                    ],
                  ),
                ),
              );
            }
          } else if (t.hasError) {
            return Center(
              child: Container(
                height: 200,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.check,
                      size: 70,
                    ),
                    Text("Une erreu s'est produite code: ${t.error}"),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(),
            ),
          );
        },
      )),
    );
  }
}

class Traitement2 extends StatelessWidget {
  TextEditingController note = TextEditingController();
  Map<String, dynamic> mapPlainte = {};
  State state;

  Traitement2(this.state, this.mapPlainte);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SizedBox(
          width: 400,
          height: 600,
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            TextField(
              maxLines: 20,
              controller: note,
              decoration: const InputDecoration(
                label: Text("Une note pour la plainte"),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (note.text.isEmpty) {
                  showDialog(
                      context: context,
                      builder: (c) {
                        return AlertDialog(
                          title: Text("Erreur"),
                          content: Text("Note vide"),
                          actions: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.close),
                            )
                          ],
                        );
                      });
                } else {
                  //
                  Get.dialog(const Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ));
                  //
                  int c = await Connexion.majPlainte(mapPlainte);

                  if (c == 201 || c == 201) {
                    String r = await Connexion.saveNote(
                      {
                        //"id": 1,
                        "nom_admin": nomC,
                        "reference": "${mapPlainte['reference']}",
                        "note": note.text,
                      },
                    );
                    if ("201" == r || "200" == r) {
                      Get.back();
                      Get.back();
                      Get.snackbar(
                        "Succès",
                        "La modification a bien été éffectué",
                        backgroundColor: Colors.grey.shade300,
                      );
                    } else {
                      Get.back();
                      Get.snackbar(
                        "Erreur",
                        "Un problème est survenue lors de la mise ) jour code: $r",
                        backgroundColor: Colors.grey,
                      );
                    }
                  }
                  /*
                   
                  */
                }
              },
              child: Text("Enregistrer"),
            )
          ]),
        ),
      ),
    );
  }
}
