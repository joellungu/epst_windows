import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chat extends StatefulWidget {
  String? titre;
  String? nom;

  Chat({this.titre, this.nom});
  @override
  State<StatefulWidget> createState() {
    return _Chat();
  }
}

class _Chat extends State<Chat> {
  var _channel;

  List<Widget> listeConv = [];

  TextEditingController chatCont = TextEditingController();

  @override
  void initState() {
    //
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/chat/0'),
    );
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
      body: StreamBuilder(
        stream: _channel.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print("t'est quoi?: ${snapshot.data}");
            if (snapshot.hasData == null) {
              return Text("${snapshot.data}");
            } else {
              //Je pourais repondre parce que j'aurai toujours sont id donc (to)
              Map<String, dynamic> chatt =
                  jsonDecode((snapshot.data) as String);
              String commande = chatt["requete"];
              String to_ = chatt["idSessionHote"];
              String contenu = chatt["contenu"];

              print(chatt);
              //
              if (commande == "start") {
                listeConv.add(smsMessage(true, contenu));
                return Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ListView(
                        children: List.generate(
                          listeConv.length,
                          (index) {
                            return listeConv[index];
                          },
                        ),
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
                                        controller: chatCont,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        //
                                        await _channel.sink.add(
                                            '{"from":"...","to":"$to_","content":"${chatCont.text}"');
                                      },
                                      icon: Icon(
                                        Icons.send,
                                        color: Colors.blue.shade400,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                );
              } else {
                return const Center(
                  child: Text("Mauvaise commande"),
                );
              }
              //return Listage(jsonDecode((snapshot.data) as String));
            }

            //
          } else {
            return Center(
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
            );
          }
        },
      ),
    );
  }

  Widget smsMessage(bool t, String contenu) {
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
