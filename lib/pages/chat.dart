import 'dart:async';
import 'dart:convert';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

var channel;
List<String> listeConSave = [];
List<Widget> listeConv = [];
//
Widget? chatt;
Widget? listChatt;
String nomDe = "";
//

class Chat extends StatefulWidget {
  String? titre;
  Map<String, dynamic>? u = {};

  Chat({this.titre, this.u});
  @override
  State<StatefulWidget> createState() {
    return _Chat();
  }
}

class _Chat extends State<Chat> {
  List listeUsers = [];

  TextEditingController chatCont = TextEditingController();
  DateTime dateTime = DateTime.now();
  String date = "";
  String heure = "";

  late Timer timer;

  @override
  void initState() {
    //
    date =
        "${dateTime.day}-${dateTime.month}-${dateTime.year}"; //${dateTime.hour}
    heure = "${dateTime.hour}-${dateTime.minute}";
    //
    super.initState();
    //${widget.u!['postnom']} ${widget.u!['prenom']}
    //http://localhost:8080/
    //ws://epstapp.herokuapp.com
    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://localhost:8080/chat/${widget.u!['postnom']} ${widget.u!['prenom']}/admin'),
    );
    //
    channel.stream.listen((message) {
      //channel.sink.add('received!');
      print("La reponse du serveur: $message");
      //listeConSave.add("$message\n");//
      //channel.sink.close();
      //Utf8Decoder().convert("${e["username"]}".codeUnits
      Map<String, dynamic> map = jsonDecode(message);
      //Utf8Decoder().convert("${}".codeUnits)
      //String idsession = map["idsession"] ?? map["requete"];
      if (map["liste"] != null) {
        listeUsers = map["liste"];
      }
      //
      String idSessionHote = map["idSessionHote"] ?? "";
      //
      String contenu = map["content"] ?? "";
      String hostId = map["hostId"] ?? "";
      String clientId = map["clientId"] ?? "";
      String from = map["from"] ?? "";

      setState(() {
        if (map["liste"] != null) {
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
                    listeConSave = [];
                    //,${widget.u!['postnom']} ${widget.u!['prenom']}
                    //chatt = ChatStart(channel); //
                    //Map<String, dynamic> catt =
                    //  jsonDecode((snapshot.data) as String);
                    channel.sink.add(
                        """{"from":"${widget.u!['postnom']} ${widget.u!['prenom']}","to":"hote",
                        "content":"Bonjour, je suis ${widget.u!['postnom']} ${widget.u!['prenom']} agent du ministère de l'EPST à la DGC, comment puis-je vous aider ?",
                            "hostId":"${e["hostId"]}","clientId":"${e["clientId"]}","close":false,"all":false,"visible":"non","conversation": true,"matricule":"${widget.u!['matricule']}","date":"$date","heure":"$heure"}""");
                    chatt = Container();
                    nomDe = Utf8Decoder().convert("${e["username"]}".codeUnits);
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
                          e['visible'] == "oui" ? "En-attente" : "",
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
                        child: e['visible'] == "oui"
                            ? Icon(Icons.subdirectory_arrow_left)
                            : Icon(Icons.phone),
                      )
                    ],
                  ),
                ),
              );
            }),
          );
        } else if (map["conversation"] != true ||
            map["concloseversation"] == true) {
          print("efface tout!");
          //listeConSave
          // Connexion.saveArchive({
          //   "date_save": "${DateTime.now()}",
          //   "nom_agent": "${widget.u!['postnom']} ${widget.u!['prenom']}",
          //   "nom_client": nomDe,
          //   "conversation": jsonEncode(listeConSave),
          // });

          listeConSave.clear();
          //
          listeConv.clear();
          listeConv.forEach((element) {
            bool v = listeConv.remove(element);
            v ? print("Effectué") : print("Pas éffectué");
          });
          chatt = Container();
        } else {
          listeConSave.add(contenu + "\n");
          contenu != "" ? listeConv.add(smsMessage(false, contenu)) : print("");
          //listeConv.add(smsMessage(false, contenu));
          chatt = ChattConv(
            idSessionHote,
            listeConv,
            hostId,
            clientId,
            from,
            "${widget.u!['matricule']}",
            user: "${widget.u!['postnom']} ${widget.u!['prenom']}",
          );
        }
      });
    });
    //
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      //
      //setState(() {
      channel.sink.add(
          '{"from":"","to":"","content":"","hostId":"","clientId":"","close":false,"all":true,"visible":"","conversation": false,"matricule":"${widget.u!['matricule']}","date":"$date","heure":"$heure"}');
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
                      Text(""),
                      Text("$nomDe"),
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
  String? hostId, clientId, from;
  String? user;
  String? matricule;

  ChattConv(this.idSessionHote, this.listeConv, this.hostId, this.clientId,
      this.from, this.matricule,
      {this.user});

  @override
  State<StatefulWidget> createState() {
    return _ChattConv();
  }
}

class _ChattConv extends State<ChattConv> {
  TextEditingController chatCont = TextEditingController();
  //
  DateTime dateTime = DateTime.now();
  String date = "";
  String heure = "";

  @override
  void initState() {
    //
    date = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
    heure = "${dateTime.hour}:${dateTime.minute}";

    //${dateTime.hour}
    //
    super.initState();
  }

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
                            print(
                                """{"from":"${widget.user}","to":"hote","content":"${chatCont.text}","hostId":"${widget.hostId}","clientId":"${widget.clientId}","close":false,"all":false,"visible":"non","conversation": true}""");
                            //
                            setState(() {
                              widget.listeConv!
                                  .add(smsMessage(true, chatCont.text));
                              channel.sink.add(
                                  """{"from":"${widget.user}","to":"hote","content":"${chatCont.text}","hostId":"${widget.hostId}","clientId":"${widget.clientId}","close":false,"all":false,"visible":"non","conversation": true,"matricule":"${widget.matricule}","date":"$date","heure":"$heure"}""");
                              chatCont.clear();
                            });
                          },
                          icon: Icon(
                            Icons.send,
                            color: Colors.blue.shade400,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            channel.sink.add(
                                """{"from":"${widget.user}","to":"hote","content":"${chatCont.text}","hostId":"${widget.hostId}","clientId":"${widget.clientId}","close":true,"all":false,"visible":"non","conversation": false,"matricule":"${widget.matricule}","date":"$date","heure":"$heure"}""");
                            ////////////////////////////////////////////////////
                            print("efface tout!");
                            //listeConSave

                            listeConSave = [];
                            //
                            listeConv = [];
                            listeConv.forEach((element) {
                              bool v = listeConv.remove(element);
                              v ? print("Effectué") : print("Pas éffectué");
                            });
                            chatt = Container();
                          },
                          child: Container(
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
//
