import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:get/get.dart';

import 'archive_controller.dart';

class Archive extends StatefulWidget {
  Archive(this.nomAgent);
  String nomAgent;
  @override
  State<StatefulWidget> createState() {
    return _Archive();
  }
}

class _Archive extends State<Archive> {
  //

  ArchiveController archiveController = Get.find();
  //
  TextEditingController? textMatricule = TextEditingController();
  TextEditingController? textDate = TextEditingController();
  TextEditingController? textHeure = TextEditingController();
  //
  RxString client = "".obs;

  //
  @override
  void dispose() {
    //
    archiveController.listeConvArchive.value = [];
    archiveController.conversation.value.clear();
    //
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: textMatricule,
                            decoration: InputDecoration(hintText: "Matricule"),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            flex: 7,
                            child: ElevatedButton(
                              onPressed: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(3000),
                                ).then((value) {
                                  DateTime dt = value!;
                                  //
                                  archiveController.listeConvArchive.value
                                      .clear();
                                  archiveController.conversation.value.clear();
                                  //
                                  archiveController.getListeConv1(
                                      textMatricule!.text,
                                      "${dt.day}-${dt.month}-${dt.year}");
                                  print(
                                      "la date: ${textMatricule!.text} -- ${dt.day}-${dt.month}-${dt.year}");
                                });
                              },
                              child: Text("Date de la conversation"),
                            )
                            /*
                          TextField(
                            controller: textDate,
                            decoration: InputDecoration(hintText: "Date"),
                          ),
                          */
                            ),
                        /*
                        IconButton(
                          onPressed: () {
                            //
                            archiveController.listeConvArchive.value.clear();
                            //
                            archiveController.getListeConv1(
                                textMatricule!.text, textDate!.text);
                          },
                          icon: const Icon(
                            Icons.search,
                          ),
                        )
                        */
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Obx(
                    (() => ListView(
                          controller: ScrollController(),
                          children: List.generate(
                            archiveController.listeConvArchive.value.length,
                            (index) {
                              if (archiveController
                                      .listeConvArchive.value[index]["tot"] !=
                                  "hote") {
                                return ListTile(
                                  onTap: () {
                                    client.value =
                                        "${archiveController.listeConvArchive.value[index]['from_']}";
                                    print(
                                        "${archiveController.listeConvArchive.value[index]['hostId_']}");
                                    archiveController.getListeConv2(
                                        "${archiveController.listeConvArchive.value[index]['hostId_']}");
                                  },
                                  leading: Icon(Icons.messenger_outline),
                                  title: Text(
                                    "${archiveController.listeConvArchive.value[index]['from_']} avec ${widget.nomAgent}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${archiveController.listeConvArchive.value[index]['date_']}  ${archiveController.listeConvArchive.value[index]['heure_']}",
                                    style: TextStyle(
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                );
                              }
                              {
                                return Container();
                              }
                            },
                          ),
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 50,
        ),
        Expanded(
          flex: 5,
          child: Column(children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(client.value),
              ),
            ),
            Expanded(
              flex: 1,
              child: Obx(
                (() => ListView(
                      controller: ScrollController(),
                      children: List.generate(
                          archiveController.conversation.value.length, (index) {
                        if (archiveController.conversation.value[index]
                                ["to_"] ==
                            "hote") {
                          return smsMessage(
                            false,
                            archiveController.conversation.value[index]
                                ["content_"],
                            context,
                          );
                        } else {
                          return smsMessage(
                            true,
                            archiveController.conversation.value[index]
                                ["content_"],
                            context,
                          );
                        }
                      }),
                    )),
              ),
            ),
          ]),
        )
      ],
    );
  }

  Widget smsMessage(bool t, String contenu, BuildContext context) {
    if (t) {
      return ChatBubble(
        clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
        alignment: Alignment.topRight,
        margin: const EdgeInsets.only(top: 20),
        backGroundColor: Colors.blue,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            contenu,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return ChatBubble(
        clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
        backGroundColor: const Color(0xffE7E7ED),
        margin: const EdgeInsets.only(top: 20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Text(
            contenu,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }
}
