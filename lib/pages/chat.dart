import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';

class Chat extends StatefulWidget {
  String? titre;

  Chat({this.titre});
  @override
  State<StatefulWidget> createState() {
    return _Chat();
  }
}

class _Chat extends State<Chat> {
  bool start = false;

  List<Map<String, dynamic>> liste_utilisateur = [
    {"nom": "Mokpongbo Lungu Joel", "status": "en communication"},
    {"nom": "Mokpongbo Lungu Joel", "status": "Fini"},
    {"nom": "Mokpongbo Lungu Joel", "status": "en attente"},
    {"nom": "Landu nephtalie", "status": "en attente"},
    {"nom": "Landu nephtalie", "status": "en communication"},
    {"nom": "Landu nephtalie", "status": "Fini"},
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 5), () {
      setState(() {
        start = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey.shade300,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              child: Icon(
                CupertinoIcons.person,
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text("Agent DGC/EPST"),
          ],
        ),
      ),
      */
      body: start
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 400,
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: List.generate(liste_utilisateur.length, (index) {
                      return ListTile(
                        leading: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          child: Icon(
                            CupertinoIcons.person,
                            color: Colors.grey.shade300,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        title: Text(liste_utilisateur[index]["nom"]),
                        trailing: liste_utilisateur[index]["status"] == "Fini"
                            ? Text(
                                liste_utilisateur[index]["status"],
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 10,
                                ),
                              )
                            : Container(
                                width: 150,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: Text(
                                        liste_utilisateur[index]["status"],
                                        style: TextStyle(
                                          color: liste_utilisateur[index]
                                                      ["status"] ==
                                                  "en attente"
                                              ? Colors.blue
                                              : Colors.green,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: liste_utilisateur[index]
                                                  ["status"] ==
                                              "en attente"
                                          ? Icon(Icons.subdirectory_arrow_left)
                                          : Icon(Icons.phone),
                                    )
                                  ],
                                ),
                              ),
                      );
                    }),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10, top: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ticquet: Gratuité"),
                            Text("Mokpongbo Lungu joel"),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: ListView(
                          children: [
                            smsMessage(true),
                            smsMessage(true),
                            smsMessage(false),
                            smsMessage(true),
                            smsMessage(false),
                            smsMessage(false),
                            smsMessage(true),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        child: SafeArea(
                          child: Row(
                            children: [
                              Icon(
                                Icons.mic,
                                color: Colors.green.shade300,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  //height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.attach_file,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.send,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 150,
                                height: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  "Fin de la conversation",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade700,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          : Center(
              child: Container(
                height: 100,
                //width: 200,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 5,
                      width: 100,
                      alignment: Alignment.center,
                      child: LinearProgressIndicator(),
                    ),
                    Text(
                        "Etablissement de la communication avec un agent de la DGC")
                  ],
                ),
              ),
            ),
    );
  }

  Widget smsMessage(bool t) {
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
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
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
            "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat",
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }
}
