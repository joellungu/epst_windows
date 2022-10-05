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
  @override
  void dispose() {
    //
    archiveController.listeConvArchive.value = [];
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
                          flex: 5,
                          child: TextField(
                            controller: textMatricule,
                            decoration: InputDecoration(hintText: "Matricule"),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          flex: 4,
                          child: TextField(
                            controller: textDate,
                            decoration: InputDecoration(hintText: "Date"),
                          ),
                        ),

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
                                    print("${archiveController.listeConvArchive.value[index]['hostIdt']}");
                                    archiveController.getListeConv2(
                                        "${archiveController.listeConvArchive.value[index]['hostIdt']}"
                                    );
                                  },
                                  leading: Icon(Icons.messenger_outline),
                                  title: Text("${archiveController.listeConvArchive.value[index]['fromt']} avec ${widget.nomAgent}"),

                                  subtitle: Text(
                                    "${archiveController.listeConvArchive.value[index]['datet']}  ${archiveController.listeConvArchive.value[index]['heuret']}",
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
        SizedBox(
          width: 50,
        ),
        Expanded(
          flex: 5,
          child: Obx(
            (() => ListView(
                  controller: ScrollController(),
                  children: List.generate(
                      archiveController.conversation.value.length, (index) {
                    if (archiveController.conversation.value[index]["tot"] ==
                        "hote") {
                      return smsMessage(
                        false,
                        archiveController.conversation.value[index]["contentt"],
                        context,
                      );
                    } else {
                      return smsMessage(
                        true,
                        archiveController.conversation.value[index]["contentt"],
                        context,
                      );
                    }
                  }),
                )),
          ),
        )
      ],
    );
  }

  Widget smsMessage(bool t, String contenu, BuildContext context) {
    if (t) {
      return ChatBubble(
        clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
        alignment: Alignment.topRight,
        margin: EdgeInsets.only(top: 20),
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
        backGroundColor: Color(0xffE7E7ED),
        margin: EdgeInsets.only(top: 20),
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
