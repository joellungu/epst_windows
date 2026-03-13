import 'dart:async';
import 'dart:io';

import 'package:epst_windows_app/pages/secretariat/secretariat_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as t;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

//
RxList departements = [].obs;
//

class NouvelleOffice extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //
    return _NouvelleOffice();
  }
}

class _NouvelleOffice extends State<NouvelleOffice> {
  //
  SecretariatController secretariatController = Get.find();
  //
  t.QuillController _controllerHis = t.QuillController.basic();
  t.QuillController _controllerArr = t.QuillController.basic();
  t.QuillController _controllerAtt = t.QuillController.basic();
  t.QuillController _controllerRea = t.QuillController.basic();
  //
  TextEditingController responsable = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController telephone = TextEditingController();
  TextEditingController titre = TextEditingController();
  TextEditingController sigle = TextEditingController();
  TextEditingController adresse = TextEditingController();
  //

  //
  XFile? img1;
  //
  String ext1 = "png";
  //
  RxInt i = 0.obs;
  //
  final cont = t.QuillController(
    document: t.Document(),
    selection: const TextSelection.collapsed(offset: 0),
  );
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
                color: Colors.white,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        onPressed: () {
                          //
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const Expanded(
                      flex: 9,
                      child: TabBar(
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
                    )
                  ],
                )),
            Expanded(
              flex: 1,
              child: TabBarView(
                children: <Widget>[
                  SingleChildScrollView(
                    child: Center(
                      child: details(),
                    ),
                  ),
                  Column(
                    children: [
                      t.QuillSimpleToolbar(
                        controller: _controllerHis,
                        // configurations: t.QuillSimpleToolbarConfigurations(
                        //   controller: _controllerHis,
                        //   sharedConfigurations:
                        //       const t.QuillSharedConfigurations(
                        //     locale: Locale('fr'),
                        //   ),
                        // ),
                      ),
                      Expanded(
                        child: t.QuillEditor.basic(
                          controller: _controllerHis,
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
                      //       // child: t.QuillEditor.basic(
                      //       //   //controller: _controllerHis,
                      //       //   //readOnly: false,
                      //       //   configurations:
                      //       //       QuillEditorConfigurations(), // true for view only mode
                      //       // ),
                      //       ),
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
                                    Expanded(
                                      flex: 3,
                                      child: Image.memory(d["photo"]),
                                    ),
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
                      t.QuillSimpleToolbar(
                        controller: _controllerArr,
                      ),
                      Expanded(
                        child: t.QuillEditor.basic(
                          controller: _controllerArr,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      t.QuillSimpleToolbar(
                        controller: _controllerAtt,
                      ),
                      Expanded(
                        child: t.QuillEditor.basic(
                          controller: _controllerAtt,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      t.QuillSimpleToolbar(
                        controller: _controllerRea,
                      ),
                      Expanded(
                        child: t.QuillEditor.basic(
                          controller: _controllerRea,
                        ),
                      )
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
                    "denomition": titre.text,
                    "sigle": sigle.text,
                    "adresse": adresse.text,
                    "telephone": telephone.text,
                    "email": email.text,
                    "photo": File(img1!.path).readAsBytesSync(),
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
                  //print("s: $s");
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
                  secretariatController.saveS(s);
                  //
                },
                child: const Center(
                  child: Text("Enregistrer"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget details() {
    return SizedBox(
      width: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
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
                      image:
                          DecorationImage(image: FileImage(File(img1!.path)))),
                  //child: Image.file(File(img!.path)),
                )
              : Container()),
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
