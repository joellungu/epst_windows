import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'parametre_controller.dart';

class Taux extends StatelessWidget {
  Taux() {
    load();
  }
  //
  load() async {
    taux.value = await parametreController.getTaux();
    text.text = "${taux.value}";
  }

  //
  TextEditingController text = TextEditingController();
  //
  RxDouble taux = 0.0.obs;
  //
  ParametreController parametreController = Get.find();
  //
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Taux d'echange",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextField(
              controller: text,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                //
                taux.value =
                    await parametreController.setTaux(double.parse(text.text));
                //
                //taux.value = await utilisateurController.getTaux();
                text.text = "${taux.value}";
                //
              },
              child: const Text("Changer"),
            )
          ],
        ),
      ),
    );
  }
}
