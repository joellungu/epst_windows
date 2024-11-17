import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import 'detail_ecole.dart';
import 'ecole_controller.dart';
import 'nouvelle_ecole.dart';

class Ecole extends GetView<EcoleController> {
  Ecole() {
    controller.getAllEcoles();
  }
  @override
  Widget build(BuildContext context) {
    //
    RxString text = "".obs;
    //
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          height: Get.size.height,
          width: 350,
          child: controller.obx(
            (state) {
              RxList ecoles = RxList(state!);
              //
              return Column(
                children: [
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: TextField(
                      onChanged: (t) {
                        text.value = t;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Obx(
                      () => ListView(
                        children: List.generate(ecoles.length, (index) {
                          Map ecole = ecoles[index];
                          if (ecole["nom"].contains(text)) {
                            return ListTile(
                              onTap: () {
                                Get.to(DetailEcole(ecole));
                              },
                              title: Text(
                                "${ecole['nom']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "${ecole['province']} || ${ecole['provinceEducationnelle']}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        }),
                      ),
                    ),
                  ),
                ],
              );
            },
            onEmpty: Center(
              child: Container(
                height: 200,
                width: 300,
                alignment: Alignment.center,
                child: const Text(""),
              ),
            ),
            onLoading: const Center(
              child: SizedBox(
                height: 40,
                width: 40,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          //
          Get.to(NouvelleEcole());
          //
        },
      ),
    );
  }
}
