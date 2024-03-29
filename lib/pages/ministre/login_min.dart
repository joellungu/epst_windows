import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:epst_windows_app/pages/ministre/ministre.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginMin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginMin();
  }
}

class _LoginMin extends State<LoginMin> {
  //
  bool obs = true;

  TextEditingController matriculeC = TextEditingController();
  TextEditingController mdpC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              child: Center(
                child: Container(
                  height: 300,
                  width: 300,
                  alignment: Alignment.center,
                  child: Image.asset(
                    "assets/EPST APP.png",
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 300,
            //height: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  //dashboard_outlined
                  CupertinoIcons.person,
                  //CupertinoIcons.house,
                  //color: Colors.green.shade300,
                  size: MediaQuery.of(context).size.width / 9,
                  //color: Colors.green,
                ),
                const Text(
                  "Connexion",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          " Matricule",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(),
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: matriculeC,
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
                                  hintText: "Maricule",
                                  label: Text("Maricule"),
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
                Container(
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Mot de passe",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        height: 55,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: mdpC,
                                keyboardType: TextInputType.emailAddress,
                                obscureText: obs,
                                style: const TextStyle(
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    top: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                    color: Colors.blue,
                                  ),
                                  hintText: "Mot de passe",
                                  label: Text("Mot de passe"),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  obs ? obs = false : obs = true;
                                });
                              },
                              icon: Icon(Icons.remove_red_eye_outlined),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () async {
                    var connectivityResult =
                        await (Connectivity().checkConnectivity());
                    if (connectivityResult == ConnectivityResult.mobile ||
                        connectivityResult == ConnectivityResult.wifi ||
                        true) {
                      //
                      if (matriculeC.text.isEmpty || mdpC.text.isEmpty) {
                        //

                        //
                      } else {
                        Get.off(Ministre());
                      }
                    } else {
                      //
                    }
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
                          "Connexion",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 100),
          )
        ],
      ),
    );
  }
}
