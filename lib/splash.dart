import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/cours/cours_controller.dart';
import 'pages/login.dart';
import 'pages/ministre/ministre_controller.dart';
import 'pages/mutuelle/mutuelle_controller.dart';
import 'pages/parametre/parametre_controller.dart';

class Splash extends StatelessWidget {
  Splash() {
    CoursController coursController = Get.put(CoursController());
    MutuelleController mutuelleController = Get.put(MutuelleController());
    MinistreController ministreController = Get.put(MinistreController());
    ParametreController parametreController = Get.put(ParametreController());
    //
    Timer(Duration(seconds: 5), () {
      Get.off(Login());
    });
  }
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
