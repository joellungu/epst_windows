import 'dart:async';
import 'dart:io';

import 'package:epst_windows_app/pages/secretariat/secretariat_controller.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as t;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

//
RxList departements = [].obs;
//

class UpdateOffice extends StatefulWidget {
  Map e;
  UpdateOffice(this.e, {required Key key}) {
    print(e);
  }
  //
  @override
  State<StatefulWidget> createState() {
    //
    return _UpdateOffice();
  }
}

class _UpdateOffice extends State<UpdateOffice> {
  //
  SecretariatController secretariatController = Get.find();
  //

  t.QuillController _controllerHis = t.QuillController.basic();
  t.QuillController _controllerArr = t.QuillController.basic();
  t.QuillController _controllerAtt = t.QuillController.basic();
  t.QuillController _controllerRea = t.QuillController.basic();
  //t.QuillController _controller = t.QuillController.basic();
  //
  TextEditingController responsable = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController telephone = TextEditingController();
  TextEditingController titre = TextEditingController();
  TextEditingController sigle = TextEditingController();
  TextEditingController adresse = TextEditingController();
  //
  final cont = t.QuillController(
    document: t.Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );
  //
  @override
  void initState() {
    titre.text = widget.e['denomition'] ?? "";
    sigle.text = widget.e['sigle'] ?? "";
    adresse.text = widget.e['adresse'] ?? "";
    telephone.text = widget.e['telephone'] ?? "";
    email.text = widget.e['email'] ?? "";
    responsable.text = widget.e['responsable'] ?? "";
    //
    if (widget.e['arretes'] != null) {
      _controllerArr.document.insert(0, widget.e['arretes']['text'] ?? "");
    }
    //
    departements.value = widget.e['departement'] ?? [];
    //"attributionMission":
    _controllerAtt.document.insert(0, widget.e['historique'] ?? "");
    //"historique":
    _controllerHis.document.insert(0, widget.e['historique'] ?? "");
    //"realisation":
    _controllerRea.document.insert(0, widget.e['realisation'] ?? "");
    //.replaced(TextRange.empty, widget.e['realisation'] ?? "");
    //.copyWith(text: widget.e['realisation'] ?? "")
    print("data: ${titre.text} : ${widget.e['denomition']}");
    print("data: ${email.text} : ${widget.e['email']}");
    print("data: ${telephone.text} : ${widget.e['telephone']}");
    //
    super.initState();
    //
  }
  //

  @override
  Widget build(BuildContext context) {
    //
    return DefaultTabController(
      initialIndex: 0,
      length: 6,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Colors.black,
              height: 60,
              child: const TabBar(
                labelStyle: TextStyle(
                  color: Colors.black,
                ),
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.edit),
                    text: "Détails",
                  ),
                  Tab(
                    icon: Icon(Icons.history),
                    text: "Historique",
                  ),
                  Tab(
                    icon: Icon(Icons.business),
                    text: "Département",
                  ),
                  Tab(
                    icon: Icon(Icons.format_align_justify_sharp),
                    text: "Arreté",
                  ),
                  Tab(
                    icon: Icon(Icons.attribution),
                    text: "Attribution et mission",
                  ),
                  Tab(
                    icon: Icon(Icons.control_point),
                    text: "Realisation",
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                children: <Widget>[
                  Center(
                    child: details(
                      responsable.text,
                      telephone.text,
                      email.text,
                    ),
                  ),
                  Column(
                    children: [
                      t.QuillToolbar.simple(
                        configurations: t.QuillSimpleToolbarConfigurations(
                          controller: _controllerHis,
                          sharedConfigurations:
                              const t.QuillSharedConfigurations(
                            locale: Locale('fr'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: t.QuillEditor.basic(
                          configurations: t.QuillEditorConfigurations(
                            controller: _controllerHis,
                            //readOnly: false,
                            sharedConfigurations:
                                const t.QuillSharedConfigurations(
                              locale: Locale('fr'),
                            ),
                          ),
                        ),
                      )
                      // t.QuillToolbar.basic(
                      //   controller: _controllerHis,
                      //   showDirection: true,
                      //   showSmallButton: true,
                      //   showAlignmentButtons: true,
                      // ),
                      // Expanded(
                      //   child: Container(
                      //     child: t.QuillEditor.basic(
                      //       controller: _controllerHis,
                      //       readOnly: false, // true for view only mode
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  Scaffold(
                    body: Obx(
                      () => ListView(
                        padding: const EdgeInsets.all(20),
                        children: List.generate(
                          departements.length,
                          (index) {
                            //departements
                            Map d = departements[index];
                            return Card(
                              elevation: 0,
                              child: SizedBox(
                                height: 150,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    d["photo"] != null
                                        ? Expanded(
                                            flex: 3,
                                            child: Image.network(
                                                "${Connexion.lien}secretariat/photo/${widget.e["id"]}/$index"),
                                          )
                                        : Container(),
                                    Expanded(
                                      flex: 6,
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${d["responsable"]}",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text.rich(
                                                TextSpan(
                                                  text: "Departement: ",
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          "${d["departement"]}",
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      child: IconButton(
                                        onPressed: () {
                                          //
                                          departements.removeAt(index);
                                          //
                                        },
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () {
                        //
                        Get.dialog(
                          Material(
                              color: Colors.transparent,
                              child: AjouterDepartement()),
                        );
                      },
                      backgroundColor: Colors.black,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      t.QuillToolbar.simple(
                        configurations: t.QuillSimpleToolbarConfigurations(
                          controller: _controllerArr,
                          sharedConfigurations:
                              const t.QuillSharedConfigurations(
                            locale: Locale('fr'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: t.QuillEditor.basic(
                          configurations: t.QuillEditorConfigurations(
                            controller: _controllerArr,
                            //readOnly: false,
                            sharedConfigurations:
                                const t.QuillSharedConfigurations(
                              locale: Locale('fr'),
                            ),
                          ),
                        ),
                      )
                      // t.QuillToolbar.basic(
                      //   controller: _controllerArr,
                      //   showDirection: true,
                      //   showSmallButton: true,
                      //   showAlignmentButtons: true,
                      // ),
                      // Expanded(
                      //   child: Container(
                      //     child: t.QuillEditor.basic(
                      //       controller: _controllerArr,
                      //       readOnly: false, // true for view only mode
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  Column(
                    children: [
                      t.QuillToolbar.simple(
                        configurations: t.QuillSimpleToolbarConfigurations(
                          controller: _controllerAtt,
                          sharedConfigurations:
                              const t.QuillSharedConfigurations(
                            locale: Locale('fr'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: t.QuillEditor.basic(
                          configurations: t.QuillEditorConfigurations(
                            controller: _controllerAtt,
                            //readOnly: false,
                            sharedConfigurations:
                                const t.QuillSharedConfigurations(
                              locale: Locale('fr'),
                            ),
                          ),
                        ),
                      )
                      // t.QuillToolbar.basic(
                      //   controller: _controllerAtt,
                      //   showDirection: true,
                      //   showSmallButton: true,
                      //   showAlignmentButtons: true,
                      // ),
                      // Expanded(
                      //   child: Container(
                      //     child: t.QuillEditor.basic(
                      //       controller: _controllerAtt,
                      //       readOnly: false, // true for view only mode
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  Column(
                    children: [
                      t.QuillToolbar.simple(
                        configurations: t.QuillSimpleToolbarConfigurations(
                          controller: _controllerRea,
                          sharedConfigurations:
                              const t.QuillSharedConfigurations(
                            locale: Locale('fr'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: t.QuillEditor.basic(
                          configurations: t.QuillEditorConfigurations(
                            controller: _controllerRea,
                            //readOnly: false,
                            sharedConfigurations:
                                const t.QuillSharedConfigurations(
                              locale: Locale('fr'),
                            ),
                          ),
                        ),
                      )
                      // t.QuillToolbar.basic(
                      //   controller: _controllerRea,
                      //   showDirection: true,
                      //   showSmallButton: true,
                      //   showAlignmentButtons: true,
                      // ),
                      // Expanded(
                      //   child: Container(
                      //     child: t.QuillEditor.basic(
                      //       controller: _controllerRea,

                      //       readOnly: false, // true for view only mode
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () async {
                  //
                  Map s = {
                    "id": widget.e['id'],
                    "denomition": titre.text,
                    "sigle": sigle.text,
                    "adresse": adresse.text,
                    "telephone": telephone.text,
                    "email": email.text,
                    "responsable": responsable.text,
                    "maps": "",
                    "departement": departements,
                    "arretes": {
                      "photo": "",
                      "text": _controllerArr.document.toPlainText(),
                    },
                    "attributionMission": _controllerAtt.document.toPlainText(),
                    "historique": _controllerHis.document.toPlainText(),
                    "realisation": _controllerRea.document.toPlainText(),
                  };
                  //
                  print("s: $s");
                  //
                  Get.dialog(
                    const Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                  //
                  secretariatController.updateS(s);
                  //
                },
                child: const Center(
                  child: Text("Mettre à jour"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget details(String resp, String tel, String em) {
    responsable.text = resp;
    telephone.text = tel;
    email.text = em;

    return SizedBox(
      width: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Inforamtions lié au DCS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: responsable,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person),
              label: Text("Responsable"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: email,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.email),
              label: Text("Email officiel"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: telephone,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.phone_android),
              label: Text("Téléphone officiel"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Inforamtions lié à la direction",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: titre,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit),
              label: Text("Titre"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: sigle,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.edit),
              label: Text("Sigle"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: adresse,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.location_on),
              label: Text("Adresse physique"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              //
            },
            child: const Text("Carte map"),
          ),
        ],
      ),
    );
  }
}

class DetailsResponsable extends StatefulWidget {
  String resp;
  String tel;
  String em;

  DetailsResponsable(this.resp, this.tel, this.em);
  @override
  State<StatefulWidget> createState() {
    //
    return _DetailsResponsable();
  }
}

class _DetailsResponsable extends State<DetailsResponsable> {
  @override
  Widget build(BuildContext context) {
    //
    throw UnimplementedError();
  }
}

class AjouterDepartement extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AjouterDepartement();
  }
}

class _AjouterDepartement extends State<AjouterDepartement> {
  //
  XFile? img1;
  //
  String ext1 = "png";
  //
  RxInt i = 0.obs;
  //
  TextEditingController nomChef = TextEditingController();
  TextEditingController departement = TextEditingController();
  //
  @override
  Widget build(BuildContext context) {
    //
    return Center(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        height: 500,
        width: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      //showDialog(context: context, builder: builder);
                      final ImagePicker _picker = ImagePicker();
                      // Pick an image
                      img1 = await _picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 75,
                        maxWidth: 500,
                        maxHeight: 500,
                      );
                      if (img1 != null) {
                        ext1 = img1!.name.split(".").last;
                        //
                        i = 1.obs;
                        print("ext ${img1!.name}".split(".").last);
                        // Capture a photo
                        Timer(const Duration(seconds: 1), () {
                          setState(() {
                            //
                          });
                        });
                      }
                    },
                    icon: const Icon(Icons.file_present),
                    label: const Text("Joindre la photo"),
                  ),
                ),
              ],
            ),
            Obx(() => i.value != 0
                ? Container(
                    height: Get.size.height / 4,
                    width: Get.size.width / 1.1,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(File(img1!.path)))),
                    //child: Image.file(File(img!.path)),
                  )
                : Container()),
            TextField(
              controller: nomChef,
              decoration: InputDecoration(
                label: Text("Nom du chef de departement"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: departement,
              decoration: InputDecoration(
                label: Text("Departement"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                departements.add(
                  {
                    "responsable": nomChef.text,
                    "departement": departement.text,
                    "photo": File(img1!.path).readAsBytesSync(),
                  },
                );
                //
                Get.back();
                //
              },
              child: Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }
}
