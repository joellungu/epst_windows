import 'package:epst_windows_app/pages/controllers/plainte_controller.dart';
import 'package:epst_windows_app/pages/load_mag/update_controller.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/ajout_affiche.dart';
import 'cours_controller.dart';


class UploadCours extends GetView<CoursController> {

  UploadCours(){
    initState();
  }

  Widget? vue;
  Widget? vue2;
  
  TextEditingController text = TextEditingController();

  RxString id = "".obs;
  //CoursController coursController = Get.find();

  void initState() {
    //
    controller.getAllClasse();
    //
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 0),
        child:Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 350,
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.white,
                  ),
                ),
              ),
              //color: Colors.grey.shade700,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 10,
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      //
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          title: Text("Nouvelle classe"),
                          content: Container(
                            height: 100,
                            width: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextField(
                                  controller: text,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      )
                                    )
                                  ),
                                ),
                                ElevatedButton(onPressed: (){
                                  if(text.text.isNotEmpty){
                                    //
                                    controller.addClasse({"classe":"${text.text}","matiere":{}});
                                    //
                                  }
                                }, child: Text("Ajouter"))
                              ],
                            ),
                          ),
                        );
                      });
                      //
                    },
                    child: Center(
                      child: Text("Ajouter un classe"),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 10,),
            Expanded(
              flex: 1,
              child: Container(
                child: vue,
              ),
            )
          ],
        )
    );
  }

  Widget detailsVue(Map<String, dynamic> mag) {
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
                      '${mag['']}',
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
                      '${mag['']}',
                    ),
                  ),
                ),
                /*
                Container(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: Text(
                      'Date mise en ligne',
                    ),
                    subtitle: Text(
                      '${mag['']}',
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
                      '${mag['']}',
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
                      '${mag['']}',
                    ),
                  ),
                ),
              */
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
class Matieres extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _Matieres();
  }
}

class _Matieres extends State<Matieres> {

  late Widget vue;

  RxString id = "".obs;

  RxList listeMatiere = [
    {"id":"1","matiere":"Mathematique","1":"",}, {"id":"2","matiere":"Français","1":"",}, {"id":"3","matiere":"Anglais","1":"",}, {"id":"4","matiere":"Physique","1":"",},
    {"id":"5","matiere":"Chimie","1":"",}, {"id":"6","matiere":"ECM","1":"",}, {"id":"7","matiere":"Geographie","1":"",}
  ].obs;

  @override
  void initState() {
    vue = Container();
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
       padding: EdgeInsets.only(right: 0),
        child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Obx(()=> ListView(
                          children: List.generate(
                            listeMatiere.length,
                                (index) {
                              return Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: listeMatiere[index]['id'] == id.value ? Colors.blue : Colors.grey.shade200,
                                  ),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    //
                                    setState(() {
                                      id.value = listeMatiere[index]['id'];
                                      vue = VideoCours();
                                      //
                                    });
                                  },
                                  leading: Container(
                                    height: 40,
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      CupertinoIcons.list_dash,
                                      color: listeMatiere[index]['id'] == id.value ? Colors.blue : Colors.grey.shade700,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  title: Text(listeMatiere[index]['matiere'],
                                    style: TextStyle(
                                      //color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      //
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      )
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        //
                        setState(() {
                          //vue = Ajouter(1);
                        });
                      },
                      child: Center(
                        child: Text("Ajouter une matiere"),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                flex: 1,
                child: vue,
              )
            ],
          )
    );
  }

}
//
//
class VideoCours extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _VideoCours();
  }
}

class _VideoCours extends State<VideoCours> {

  late Widget vue;
  //
  RxString id = "".obs;

  RxList listeMatiere = [
    {"id":"1","chapitre":"Chapitre 1","souschapitre":"Notion des ensemble",}, {"id":"2","chapitre":"Chapitre 2","souschapitre":"Notion des ensemble",},
    {"id":"3","chapitre":"Chapitre 3","souschapitre":"Notion des ensemble",}, {"id":"4","chapitre":"Chapitre 4","souschapitre":"Notion des ensemble",},
    {"id":"5","chapitre":"Chapitre 5","souschapitre":"Notion des ensemble",}, {"id":"6","chapitre":"Chapitre 6","souschapitre":"Notion des ensemble",},
    {"id":"7","chapitre":"Chapitre 7","souschapitre":"Notion des ensemble",}
  ].obs;


  @override
  void initState() {
    vue = Container();
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                      flex: 1,
                      child: Obx(()=> ListView(
                        children: List.generate(
                          listeMatiere.length,
                              (index) {
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: listeMatiere[index]['id'] == id.value ? Colors.blue : Colors.grey.shade200,
                                ),
                              ),
                              child: ListTile(
                                onTap: () {
                                  //
                                  setState(() {
                                    id.value = listeMatiere[index]['id'];
                                    vue = VideoCours();
                                    //
                                  });
                                },
                                leading: Container(
                                  height: 40,
                                  width: 40,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    CupertinoIcons.book,
                                    color: listeMatiere[index]['id'] == id.value ? Colors.blue : Colors.grey.shade700,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                title: Text(listeMatiere[index]['chapitre'],
                                  style: TextStyle(
                                    //color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(listeMatiere[index]['souschapitre'],
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    //
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      )
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      //
                      setState(() {
                        //vue = Ajouter(1);
                      });
                    },
                    child: Center(
                      child: Text("Ajouter une video"),
                    ),
                  )
                ],
              ),
            )
          ],
        )
    );
  }
}
//

