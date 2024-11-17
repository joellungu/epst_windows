import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main.dart';
import 'pages/annonces/annonce_controller.dart';
import 'pages/cours/cours_categorie_controller.dart';
import 'pages/cours/cours_controller.dart';
import 'pages/ecoles/ecole_controller.dart';
import 'pages/login.dart';
import 'package:flutter/services.dart';
import 'pages/ministre/ministre_controller.dart';
import 'pages/mutuelle/mutuelle_controller.dart';
import 'pages/parametre/parametre_controller.dart';
import 'pages/secretariat/secretariat_controller.dart';

class Splash extends StatelessWidget {
  Splash() {
    //
    CoursController coursController = Get.put(CoursController());
    //
    MutuelleController mutuelleController = Get.put(MutuelleController());
    //
    MinistreController ministreController = Get.put(MinistreController());
    //
    ParametreController parametreController = Get.put(ParametreController());
    //
    EcoleController ecoleController = Get.put(EcoleController());
    //
    AnnonceController annonceController = Get.put(AnnonceController());
    //
    SecretariatController secretariatController =
        Get.put(SecretariatController());
    //
    CoursCategorieController coursCategorieController =
        Get.put(CoursCategorieController());
    //
    load();
    //
    Timer(Duration(seconds: 5), () {
      Get.off(Login());
    });
  }
  //
  load() async {
    var a = await rootBundle.loadString("assets/antenne.txt");
    List la = a.split('\n');
    int x = 0;
    for (String e in la) {
      //print("la valeur: $e");
      //t++;
      if (e.split(';').length > 2) {
        liste_antennes.add({
          "antenne": e.split(';')[1],
          "code": e.split(';')[2],
          "province": e.split(';')[3]
        });
      }
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
    );
  }
}
