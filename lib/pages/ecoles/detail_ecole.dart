import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ecole_controller.dart';

class DetailEcole extends StatefulWidget {
  Map detail;
  //
  DetailEcole(this.detail);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailEcole();
  }
}

class _DetailEcole extends State<DetailEcole> {
  //
  EcoleController ecoleController = Get.find();
  //
  List listeProvince = [
    "Bas-Uele",
    "Équateur",
    "Haut-Katanga",
    "Haut-Lomami",
    "Haut-Uele",
    "Ituri",
    "Kasai",
    "Kasai central",
    "Kasai oriental",
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
  //
  List<Map<String, dynamic>> listeDistrict2 = [
    {"p": "BAS-UELE", "d": "BAS-UELE"},
    {"p": "EQUATEUR", "d": "EQUATEUR 1"},
    {"p": "EQUATEUR", "d": "EQUATEUR 2"},
    {"p": "HAUT-KATANGA", "d": "HAUT-KATANGA 1"},
    {"p": "HAUT-KATANGA", "d": "HAUT-KATANGA 2"},
    {"p": "HAUT-LOMAMI", "d": "HAUT-LOMAMI 1"},
    {"p": "HAUT-LOMAMI", "d": "HAUT-LOMAMI 2"},
    {"p": "HAUT-UELE", "d": "HAUT-UELE 1"},
    {"p": "HAUT-UELE", "d": "HAUT-UELE 2"},
    {"p": "ITURI", "d": "ITURI 1"},
    {"p": "ITURI", "d": "ITURI 2"},
    {"p": "ITURI", "d": "ITURI 3"},
    {"p": "KASAI", "d": "KASAI 1"},
    {"p": "KASAI", "d": "KASAI 2"},
    {"p": "KASAI CENTRAL", "d": "KASAI CENTRAL 1"},
    {"p": "KASAI CENTRAL", "d": "KASAI CENTRAL 2"},
    {"p": "KASAI ORIENTAL", "d": "KASAI ORIENTAL 1"},
    {"p": "KASAI ORIENTAL", "d": "KASAI ORIENTAL 2"},
    {"p": "KINSHASA", "d": "KINSHASA-FUNA"},
    {"p": "KINSHASA", "d": "KINSHASA-LUKUNGA"},
    {"p": "KINSHASA", "d": "KINSHASA-MONT AMBA"},
    {"p": "KINSHASA", "d": "KINSHASA-PLATEAU"},
    {"p": "KINSHASA", "d": "KINSHASA-TSHANGU"},
    {"p": "KONGO CENTRAL", "d": "KONGO CENTRAL 1"},
    {"p": "KONGO CENTRAL", "d": "KONGO CENTRAL 2"},
    {"p": "KONGO CENTRAL", "d": "KONGO CENTRAL 3"},
    {"p": "KWANGO", "d": "KWANGO 1"},
    {"p": "KWANGO", "d": "KWANGO 2"},
    {"p": "KWILU", "d": "KWILU 1"},
    {"p": "KWILU", "d": "KWILU 2"},
    {"p": "KWILU", "d": "KWILU 3"},
    {"p": "LOMAMI", "d": "LOMAMI"},
    {"p": "LOMAMI", "d": "LOMAMI 2"},
    {"p": "LUALABA", "d": "LUALABA 1"},
    {"p": "LUALABA", "d": "LUALABA 2"},
    {"p": "MAI-NDOMBE", "d": "MAI-NDOMBE 1"},
    {"p": "MAI-NDOMBE", "d": "MAI-NDOMBE 2"},
    {"p": "MAI-NDOMBE", "d": "MAI-NDOMBE 3"},
    {"p": "MANIEMA", "d": "MANIEMA 1"},
    {"p": "MANIEMA", "d": "MANIEMA 2"},
    {"p": "MONGALA", "d": "MONGALA 1"},
    {"p": "MONGALA", "d": "MONGALA 2"},
    {"p": "NORD-KIVU", "d": "NORD-KIVU 1"},
    {"p": "NORD-KIVU", "d": "NORD-KIVU 2"},
    {"p": "NORD-KIVU", "d": "NORD-KIVU 3"},
    {"p": "NORD-UBANGI", "d": "NORD-UBANGI 1"},
    {"p": "NORD-UBANGI", "d": "NORD-UBANGI 2"},
    {"p": "SANKURU", "d": "SANKURU 1"},
    {"p": "SANKURU", "d": "SANKURU 2"},
    {"p": "SUD KIVU", "d": "SUD KIVU 2"},
    {"p": "SUD KIVU", "d": "SUD-KIVU 1"},
    {"p": "SUD KIVU", "d": "SUD-KIVU 3"},
    {"p": "SUD-UBANGI", "d": "SUD-UBANGI 1"},
    {"p": "SUD-UBANGI", "d": "SUD-UBANGI 2"},
    {"p": "TANGANYIKA", "d": "TANGANYIKA 1"},
    {"p": "TANGANYIKA", "d": "TANGANYIKA 2"},
    {"p": "TSHOPO", "d": "TSHOPO 1"},
    {"p": "TSHOPO", "d": "TSHOPO 2"},
    {"p": "TSHUAPA", "d": "TSHUAPA 1"},
    {"p": "TSHUAPA", "d": "TSHUAPA 2"}
  ];
  //
  int p = 0;
  int d = 0;
  //
  List<String> listeDistrict = [];

  //
  RxString prov = "Kinshasa".obs;
  //
  var nom_e = TextEditingController();
  //
  var province_e = TextEditingController();
  //
  var distrique_e = TextEditingController();
  //
  var provinceEduc_e = TextEditingController();
  //
  var adresse_e = TextEditingController();
  //
  var codeEcole_e = TextEditingController();
  //
  @override
  void initState() {
    //
    super.initState();
    //
    listeDistrict.clear();
    //
    listeDistrict2.forEach((element) {
      if ("${element['p']}".toLowerCase() ==
          ("${listeProvince[0]}".toLowerCase())) {
        listeDistrict.add("${element['d']}");
      }
    });
  }

  //
  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        appBar: AppBar(
          title: const Text("Nouvelle ecole"),
        ),
        body: Center(
          child: SizedBox(
            width: 500,
            height: Get.size.height,
            child: ListView(
              padding: EdgeInsets.only(top: 20),
              children: [
                Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text("Nouvelle ecole"),
                ),
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: nom_e,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    CupertinoIcons.person,
                                    color: Colors.blue,
                                  ),
                                  hintText: "Nom",
                                  label: Text("Nom"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //
                Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: adresse_e,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    CupertinoIcons.location,
                                    color: Colors.blue,
                                  ),
                                  hintText: "Adresse",
                                  label: Text("Adresse"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Code"),
                ),
                const SizedBox(
                  height: 10,
                ),
                //codeEcole
                Container(
                  height: 60,
                  child: TextField(
                    controller: codeEcole_e,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.only(
                        top: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.school,
                        color: Colors.blue,
                      ),
                      hintText: "Code Ecole",
                      label: const Text("Code Ecole"),
                    ),
                  ),
                ),
                //
                const SizedBox(
                  height: 10,
                ),
                Text("Province"),
                SizedBox(
                  height: 10,
                ),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("  Province:"),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<int>(
                              value: p,
                              onChanged: (value) {
                                p = value as int;
                                listeDistrict.clear();
                                setState(() {
                                  listeDistrict2.forEach((element) {
                                    if ("${element['p']}".toLowerCase() ==
                                        ("${listeProvince[p]}".toLowerCase())) {
                                      print("$element");
                                      listeDistrict.add("${element['d']}");
                                    }
                                  });
                                });
                                //value = s;
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
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text("Province éducationnel"),
                SizedBox(
                  height: 10,
                ),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey),
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("  Province éducationnel:"),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 1,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<int>(
                              value: d,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              onChanged: (value) {
                                d = value as int;
                                setState(() {});
                                //value = s;
                              },
                              items: List.generate(
                                listeDistrict.length,
                                (index) {
                                  return DropdownMenuItem(
                                    value: index,
                                    child: Text(listeDistrict[index]),
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                //
                const SizedBox(
                  height: 10,
                ),
                //
                ElevatedButton(
                  onPressed: () {
                    //Enregistrement utilisateur...
                    Get.dialog(const Center(
                      child: SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(),
                      ),
                    ));
                    //
                    Map e = {
                      //"agentId": 1,
                      "nom": nom_e.text,
                      "adresse": adresse_e.text,
                      "codeEcole": codeEcole_e.text,
                      "province": listeProvince[p],
                      "provinceEducationnelle": listeDistrict[d]
                    };
                    ecoleController.enregistrer(e);
                    /*
                showDialog(
                    context: context,
                    builder: (context) {
                      return Material(
                        color: Colors.white,
                        child: LoaderU(
                          {
                            //"agentId": 1,
                            "nom": nom_c.text,
                            "postnom": postnom_c.text,
                            "prenom": prenom_c.text,
                            "date_de_naissance": "$date_de_naissance",
                            "numero": numero_c.text,
                            "email": email_c.text,
                            "adresse": adresse_c.text,
                            "role": a,
                            "matricule": matricule_c.text,
                            "id_statut": "1",
                            "mdp": "epst0000",
                            "province": listeProvince[p],
                            "district": listeDistrict[d]
                          },
                          (() {
                            setState(() {
                              matricule_c.clear();
                              adresse_c.clear();
                              email_c.clear();
                              numero_c.clear();
                              prenom_c.clear();
                              postnom_c.clear();
                              nom_c.clear();
                            });
                          }),
                        ),
                      );
                    });
                */
                  },
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.all(0),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                      //backgroundColor:
                      //  MaterialStateProperty.all(Colors.blue.shade900),
                      ),
                  child: SizedBox(
                    height: 45,
                    //width: 220,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        //Icon(Icons.add_box_outlined),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Enregistrer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
