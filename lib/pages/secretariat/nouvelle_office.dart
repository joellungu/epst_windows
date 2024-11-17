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
                    child: details(),
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

/**
 * In ex nisi nostrud exercitation magna sunt laboris excepteur. Anim nostrud ad amet id. Id exercitation occaecat incididunt qui in est deserunt ea excepteur. Occaecat tempor qui ad culpa culpa labore eu aliquip irure eiusmod velit sit exercitation. Anim in elit magna duis duis ipsum Lorem quis ut duis consequat officia. Enim duis ipsum id eiusmod do dolore adipisicing. Fugiat non et ipsum est ex laboris veniam ut id laborum occaecat labore.

Esse minim consectetur sit proident nostrud exercitation excepteur magna adipisicing do mollit. Fugiat incididunt Lorem tempor ut ad nostrud adipisicing aute aliquip magna aute consectetur ea. Voluptate cillum eu aute enim dolor nostrud exercitation sunt cillum laboris deserunt ad et. Culpa do elit culpa pariatur cillum sit duis reprehenderit quis sit. Enim enim sunt incididunt Lorem proident magna incididunt esse.

Cillum proident aliqua cupidatat nulla ea cillum dolor nulla ipsum in proident. Cillum nostrud sit velit duis nisi labore occaecat Lorem veniam proident eiusmod. Officia labore officia culpa irure magna anim mollit tempor ullamco.

Elit id ad eiusmod qui eiusmod sunt qui minim voluptate do. Esse adipisicing nisi nulla irure exercitation quis enim est officia id pariatur et. Laboris adipisicing aliquip velit qui enim. Aliqua consequat ex non irure pariatur aliquip laboris occaecat aliquip aliquip ad et. Officia do exercitation ipsum elit aliqua ea nulla est officia. Culpa occaecat nostrud exercitation aliqua officia.

Fugiat aliquip consequat dolore culpa irure amet. Sunt non voluptate sint ipsum cillum aliquip qui. Mollit ad sit exercitation ex nulla exercitation dolore qui ad. Sunt minim occaecat aute laboris occaecat Lorem exercitation ex. Elit laborum nulla est non esse aliquip non in excepteur Lorem deserunt consectetur do tempor. Est pariatur voluptate ut exercitation incididunt pariatur ullamco mollit nisi et. Aliqua aute sunt sit deserunt magna incididunt fugiat sunt.

Do tempor aute velit mollit aliqua culpa nisi sit mollit. Fugiat enim amet esse velit duis velit cupidatat Lorem ut quis ea nulla velit. Adipisicing quis nostrud est voluptate duis eiusmod. Eiusmod esse velit excepteur reprehenderit cillum excepteur consequat labore Lorem nisi laborum occaecat. Proident magna tempor mollit do ad consequat quis est ex cillum non consectetur mollit.

Tempor ad minim voluptate laboris fugiat adipisicing mollit enim incididunt. Eu nulla duis culpa fugiat. Cillum ullamco fugiat dolore adipisicing qui occaecat minim id.

Anim Lorem incididunt aute elit sit sunt sit proident dolore duis. Eiusmod aute duis reprehenderit aute sit veniam aliqua cupidatat sit ut consectetur sunt. Sit eu veniam aute occaecat ipsum et dolore ipsum. Consectetur ad aliquip commodo proident qui pariatur amet elit. Aute veniam occaecat voluptate ipsum sit in Lorem sit mollit adipisicing. Eiusmod duis ea reprehenderit veniam commodo ex sunt. Amet aliquip in minim laboris incididunt ad.

Sunt nulla duis nostrud amet do. Officia qui qui qui exercitation culpa ut enim. Aute enim et do aute quis mollit excepteur quis cillum eiusmod dolore. Adipisicing eiusmod cupidatat eu commodo nostrud cupidatat enim. Nisi laborum aliquip adipisicing aliquip irure ex. Consectetur ad laboris sint pariatur incididunt quis et quis quis ea commodo dolor. Non enim excepteur commodo nostrud cillum sint adipisicing id voluptate reprehenderit dolor cillum exercitation.

Cillum mollit ea occaecat nisi officia tempor reprehenderit dolor mollit eu veniam. Enim ea sunt adipisicing mollit in mollit occaecat nulla enim commodo ullamco. Eiusmod mollit ullamco excepteur reprehenderit ipsum cillum ipsum nisi. Dolor culpa amet anim esse eiusmod. Deserunt officia occaecat quis tempor aliqua sit. Anim laborum aute esse veniam reprehenderit deserunt proident proident. Anim enim aliquip consequat et dolore duis ea amet in.
 */