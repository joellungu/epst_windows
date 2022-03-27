import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

var channel;

class Chat extends StatefulWidget {
  String? titre;

  Chat({this.titre});
  @override
  State<StatefulWidget> createState() {
    return _Chat();
  }
}

class _Chat extends State<Chat> {
  Widget? chatt;
  Widget? listChatt;
  List<Widget> listeConv = [];
  List listeUsers = [];

  TextEditingController chatCont = TextEditingController();

  late Timer timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //
    channel = WebSocketChannel.connect(
      Uri.parse('ws://localhost:8080/chat/0'),
    );
    //
    channel.stream.listen((message) {
      //channel.sink.add('received!');
      print("La reponse du serveur: $message");
      //channel.sink.close();
      Map<String, dynamic> map = jsonDecode((message) as String);
      String idsession = map["idsession"] ?? map["requete"];
      if (map["liste"] != null) {
        listeUsers = map["liste"];
      }
      //
      String idSessionHote = map["idSessionHote"] ?? "";
      //
      String contenu = map["contenu"] ?? "";
      setState(() {
        if (idsession != "start") {
          listChatt = ListView(
            controller: ScrollController(),
            children: List.generate(listeUsers.length, (index) {
              //
              Map<String, dynamic> e = listeUsers[index];
              //
              return ListTile(
                onTap: () {
                  //ChatStart()
                  setState(() {
                    //chatt = ChatStart(channel); //
                    //Map<String, dynamic> catt =
                    //  jsonDecode((snapshot.data) as String);
                    channel.sink.add(
                        '{"from":"0","to":"system","content":"communique,$idsession,${e['sessionId']}"}');
                  });
                },
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
                title: Text(e["username"]),
                trailing: Container(
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Text(
                          e['statut'],
                          style: TextStyle(
                            color: e['statut'] == "en-attente"
                                ? Colors.blue
                                : Colors.green,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: e['statut'] == "en-attente"
                            ? Icon(Icons.subdirectory_arrow_left)
                            : Icon(Icons.phone),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        } else {
          contenu != "" ? listeConv.add(smsMessage(false, contenu)) : print("");
          //listeConv.add(smsMessage(false, contenu));
          chatt = chatt = ChattConv(idSessionHote, listeConv);
        }
      });
    });
    //
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      //
      //setState(() {
      channel.sink.add('{"from":"0","to":"system","content":"getall"}');
      print("cool");
      //});
    });

    chatt = Container();
    listChatt = Container(
      child: Center(child: Text("Demande de connection vide!")),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    //
    super.dispose();
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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 400,
            child: listChatt!,
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
                Expanded(flex: 1, child: chatt!),
              ],
            ),
          )
        ],
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

class ChattConv extends StatefulWidget {
  List? listeConv;
  String? idSessionHote;

  ChattConv(this.idSessionHote, this.listeConv);

  @override
  State<StatefulWidget> createState() {
    return _ChattConv();
  }
}

class _ChattConv extends State<ChattConv> {
  TextEditingController chatCont = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: ListView(
            children: List.generate(
              widget.listeConv!.length,
              (index) {
                return widget.listeConv![index];
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
                            setState(() {
                              widget.listeConv!
                                  .add(smsMessage(true, chatCont.text));
                              channel.sink.add(
                                  """{"from":"...","to":"${widget.idSessionHote}","content":"${chatCont.text}" }""");
                              chatCont.clear();
                            });
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.blue.shade400,
                          ),
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


/*

*/