import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SmsCompagne extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SmsCompagne();
  }
}

class _SmsCompagne extends State<SmsCompagne> {
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
                              "Scolarisation des filles",
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
                  child: Text("Nouvelle compagne"),
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

  //
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
                'Date de fin',
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
                'Nombre de personne chez Vodacom',
              ),
              subtitle: Text(
                '1.000.000',
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'Nombre de personne  chez Orange',
              ),
              subtitle: Text(
                '1.000.000',
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'Nombre de personne  chez Airtel',
              ),
              subtitle: Text(
                '1.000.000',
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'Nombre de personne  chez Africell',
              ),
              subtitle: Text(
                '1.000.000',
              ),
            ),
          ),
          Container(
            height: 50,
            child: ListTile(
              onTap: () {},
              title: Text(
                'Nombre de personne atteint',
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
  bool v1 = false;
  bool v2 = false;
  bool v3 = false;
  bool v4 = false;
  //
  int c1 = 0;
  int c2 = 0;
  int c3 = 0;
  int c4 = 0;
  //
  var listeProvinceV = [];
  var listeProvinceO = [];
  var listeProvinceA = [];
  var listeProvinceAr = [];

  //
  List listeProvince = [
    "Bas-Uele",
    "Équateur",
    "Haut-Katanga",
    "Haut-Lomami",
    "Haut-Uele",
    "Ituri",
    "Kasaï",
    "Kasaï central",
    "Kasaï oriental",
    "Kinshasa",
    "Kongo-Central",
    "Kwango",
    "Kwilu",
    "Lomami",
    "Lualaba",
    "Mai-Ndombe",
    "Maniema",
    "Mongala",
    "Nord-Kivu",
    "Nord-Ubangi",
    "Sankuru",
    "Sud-Kivu",
    "Sud-Ubangi",
    "Tanganyika",
    "Tshopo",
    "Tshuapa",
  ];
  //
  double valeurW = 160;
//

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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            //SizedBox(height: 5,),
            TextField(
              maxLines: 5,
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
              width: MediaQuery.of(context).size.width,
              //color: Colors.grey.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //
                  Expanded(
                      flex: 2,
                      child: CheckboxListTile(
                        value: v1,
                        title: Text("Vodacom"),
                        onChanged: (c) {
                          setState(() {
                            v1 = c!;
                          });
                        },
                      )),
                  Expanded(
                    flex: 2,
                    child: CheckboxListTile(
                      value: v2,
                      title: Text("Orange"),
                      onChanged: (c) {
                        setState(() {
                          v2 = c!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CheckboxListTile(
                      value: v3,
                      title: Text("Airtel"),
                      onChanged: (c) {
                        setState(() {
                          v3 = c!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: CheckboxListTile(
                      value: v4,
                      title: Text("Africell"),
                      onChanged: (c) {
                        setState(() {
                          v4 = c!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //
                  v1 ? Container(
                      width: valeurW,
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<int>(
                                value: c1,
                                onChanged: (value) {
                                  c1 = value as int;
                                  setState(() {
                                    listeProvinceV.add(listeProvince[c1]);
                                  });
                                },
                                items: List.generate(
                                  listeProvince.length,
                                      (index) {
                                    return DropdownMenuItem(
                                      value: index,
                                      child: Text(listeProvince[index]),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 150,
                            child: SingleChildScrollView(
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //controller: ScrollController(),
                                children: List.generate(listeProvinceV.length, (index) => ListTile(
                                  title: Text(listeProvinceV[index]),
                                  trailing: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        listeProvinceV.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                )),
                              ),
                            ),
                          )
                        ],
                      )
                  ) : Container(width: valeurW,),
                  SizedBox(width: 10,),
                  v2 ? Container(
                      width: valeurW,
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<int>(
                                value: c2,
                                onChanged: (value) {
                                  c2 = value as int;
                                  setState(() {
                                    listeProvinceO.add(listeProvince[c2]);
                                  });
                                },
                                items: List.generate(
                                  listeProvince.length,
                                      (index) {
                                    return DropdownMenuItem(
                                      value: index,
                                      child: Text(listeProvince[index]),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 150,
                            child: SingleChildScrollView(
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //controller: ScrollController(),
                                children: List.generate(listeProvinceO.length, (index) => ListTile(
                                  title: Text(listeProvinceO[index]),
                                  trailing: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        listeProvinceO.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                )),
                              ),
                            ),
                          )
                        ],
                      )
                  ) : Container(width: valeurW,),
                  SizedBox(width: 10,),
                  v3 ? Container(
                      width: valeurW,
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<int>(
                                value: c3,
                                onChanged: (value) {
                                  c3 = value as int;
                                  setState(() {
                                    listeProvinceA.add(listeProvince[c3]);
                                  });
                                },
                                items: List.generate(
                                  listeProvince.length,
                                      (index) {
                                    return DropdownMenuItem(
                                      value: index,
                                      child: Text(listeProvince[index]),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 150,
                            child: SingleChildScrollView(
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //controller: ScrollController(),
                                children: List.generate(listeProvinceA.length, (index) => ListTile(
                                  title: Text(listeProvinceA[index]),
                                  trailing: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        listeProvinceA.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                )),
                              ),
                            ),
                          )
                        ],
                      )
                  ) : Container(width: valeurW,),
                  SizedBox(width: 10,),
                  v4 ? Container(
                      width: valeurW,
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<int>(
                                value: c4,
                                onChanged: (value) {
                                  c4 = value as int;
                                  setState(() {
                                    listeProvinceAr.add(listeProvince[c4]);
                                  });
                                },
                                items: List.generate(
                                  listeProvince.length,
                                      (index) {
                                    return DropdownMenuItem(
                                      value: index,
                                      child: Text(listeProvince[index]),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 150,
                            child: SingleChildScrollView(
                              child: Column(
                                //mainAxisAlignment: MainAxisAlignment.center,
                                //controller: ScrollController(),
                                children: List.generate(listeProvinceAr.length, (index) => ListTile(
                                  title: Text(listeProvinceAr[index]),
                                  trailing: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        listeProvinceAr.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.delete),
                                  ),
                                )),
                              ),
                            ),
                          )
                        ],
                      )
                  ) : Container(width: valeurW,),
                  SizedBox(width: 10,),
                ],
              ),
            ),
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
