import 'dart:async';
import 'dart:convert';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

var channel;
List<String> listeConSave = [];
RxList<Widget> listeConv = RxList<Widget>();
RxMap<String, dynamic> map = RxMap();
String clientId = "";
String hostId = "";
//
Rx<Widget> vue = Rx<Widget>(Container());
Widget? listChatt;
String nomDe = "";
//
RxMap chatListner = {}.obs;

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
  RxList listeUsers = [].obs;

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
    //pepiteapp.herokuapp.com
    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://${Connexion.ws}/chat/${widget.u!['postnom']} ${widget.u!['prenom']}/admin'),
    );
    //app-02b35183-fec6-4c4b-99d9-fca268735259.cleverapps.io
    //${Connexion.ws}
    channel.stream.listen((message) {
      //channel.sink.add('received!');
      //listeConSave.add("$message\n");//
      //channel.sink.close();
      //Utf8Decoder().convert("${e["username"]}".codeUnits
      var encoded = utf8.encode(message);
      var decoded = utf8.decode(encoded);
      print(":: $decoded");
      map.value = jsonDecode(decoded);
      //Utf8Decoder().convert("${}".codeUnits)
      //String idsession = map["idsession"] ?? map["requete"];

      setState(() {
        if (map["liste"] != null) {
          listeUsers.value = map["liste"];
        } else if (map["conversation_"] != true || map["close_"] == true) {
          //print("efface tout!");
          listeConSave.clear();
          //
          listeConv.clear();
          // listeConv.forEach((element) {
          //   bool v = listeConv.remove(element);
          //   v ? print("Effectué") : print("Pas éffectué");
          // });
          //
          Get.back();
          //chatt = Container();
        } else {
          String contenu = map["content_"] ?? "";
          //contenu != "" ?
          listeConv.add(smsMessage(false, contenu));
          // : print("");
        }
      });
    });
    //
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      //
      //setState(() {
      channel.sink.add(
          '{"from_":"","to_":"","content_":"","hostId_":"","clientId_":"","close_":false,"all_":true,"visible_":"","conversation_": false,"matricule_":"${widget.u!['matricule']}","date_":"$date","heure_":"$heure"}');
      print("cool");
      //});
    });

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 400,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade200,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Demandeurs en attente"),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Obx(() {
                    return ListView(
                      controller: ScrollController(),
                      children: List.generate(listeUsers.length, (index) {
                        //
                        Map<String, dynamic> e = listeUsers[index];
                        print("::: $e");
                        //
                        return ListTile(
                          onTap: () {
                            //ChatStart()
                            setState(() {
                              listeConSave = [];
                              //

                              //
                              String idSessionHote = map["idSessionHote"] ?? "";
                              //

                              String hostId = "${e["hostId_"]}";
                              String clientId = "${e["clientId_"]}";
                              String from = map["from_"] ?? "";
                              //
                              channel.sink.add(
                                  """{"from_":"${widget.u!['postnom']} ${widget.u!['prenom']}","to_":"hote",
                        "content_":"Bonjour, je suis ${widget.u!['postnom']} ${widget.u!['prenom']} agent du ministère de l'EPST à la DGC, comment puis-je vous aider ?",
                            "hostId_":"${e["hostId_"]}","clientId_":"${e["clientId_"]}","close_":false,"all_":false,"visible_":"non","conversation_": true,"matricule_":"${widget.u!['matricule']}","date_":"$date","heure_":"$heure"}""");
                              //chatt = Container();
                              var encoded = utf8.encode("${e["username_"]}");
                              var decoded = utf8.decode(encoded);
                              nomDe = decoded.replaceAll("%20", " ");
                              //Utf8Decoder().convert("${e["username"]}".codeUnits);

                              //
                              listeConv.clear();
                              //
                              listeConv.add(smsMessage(true,
                                  "Bonjour, je suis ${widget.u!['postnom']} ${widget.u!['prenom']} agent du ministère de l'EPST à la DGC, comment puis-je vous aider ?"));

                              vue.value = ChattServ(
                                {
                                  "idSessionHote": idSessionHote,
                                  "listeConv": listeConv,
                                  "hostId": hostId,
                                  "clientId": clientId,
                                  "from": from,
                                  "matricule": "${widget.u!['matricule']}",
                                  "user":
                                      "${widget.u!['postnom']} ${widget.u!['prenom']}",
                                },
                              );
                              // chatListner.value = {
                              //   "idSessionHote": idSessionHote,
                              //   "listeConv": listeConv,
                              //   "hostId": hostId,
                              //   "clientId": clientId,
                              //   "from": from,
                              //   "matricule": "${widget.u!['matricule']}",
                              //   "user": "${widget.u!['postnom']} ${widget.u!['prenom']}",
                              // };
                              //
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
                          title:
                              Text("${e["username_"]}".replaceAll("%20", " ")),
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
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Obx(() => vue.value),
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

// class ChattConv extends StatefulWidget {
//   List? listeConv;
//   String? idSessionHote;
//   String? hostId, clientId, from;
//   String? user;
//   String? matricule;
//   ChattConv(this.idSessionHote, this.listeConv, this.hostId, this.clientId,
//       this.from, this.matricule,
//       {this.user});
//   @override
//   State<StatefulWidget> createState() {
//     return _ChattConv();
//   }
// }
// class _ChattConv extends State<ChattConv> {
//   TextEditingController chatCont = TextEditingController();
//   //
//   DateTime dateTime = DateTime.now();
//   String date = "";
//   String heure = "";
//   @override
//   void initState() {
//     //
//     date = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
//     heure = "${dateTime.hour}:${dateTime.minute}";
//     //${dateTime.hour}
//     //
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           flex: 1,
//           child: ListView(
//             children: List.generate(
//               widget.listeConv!.length,
//               (index) {
//                 return widget.listeConv![index];
//               },
//             ),
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 10,
//           ),
//           decoration: BoxDecoration(
//             color: Colors.transparent,
//           ),
//           child: SafeArea(
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.mic,
//                   color: Colors.green.shade300,
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Expanded(
//                   child: Container(
//                     //height: 50,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       children: [
//                         IconButton(
//                           onPressed: () {},
//                           icon: Icon(
//                             Icons.attach_file,
//                             color: Colors.blue.shade400,
//                           ),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Expanded(
//                           flex: 1,
//                           child: TextField(
//                             controller: chatCont,
//                             decoration: InputDecoration(
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () async {
//                             print(
//                                 """{"from_":"${widget.user}","to_":"hote_","content_":"${chatCont.text}","hostId_":"${widget.hostId}","clientId_":"${widget.clientId}","close_":false,"all_":false,"visible_":"non","conversation_": true}""");
//                             //
//                             setState(() {
//                               widget.listeConv!
//                                   .add(smsMessage(true, chatCont.text));
//                               channel.sink.add(
//                                   """{"from_":"${widget.user}","to_":"hote","content_":"${chatCont.text}","hostId_":"${widget.hostId}","clientId_":"${widget.clientId}","close_":false,"all_":false,"visible_":"non","conversation_": true,"matricule_":"${widget.matricule}","date_":"$date","heure_":"$heure"}""");
//                               chatCont.clear();
//                             });
//                           },
//                           icon: Icon(
//                             Icons.send,
//                             color: Colors.blue.shade400,
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             channel.sink.add(
//                                 """{"from_":"${widget.user}","to_":"hote","content_":"${chatCont.text}","hostId_":"${widget.hostId}","clientId_":"${widget.clientId}","close_":true,"all_":false,"visible_":"non","conversation_": false,"matricule_":"${widget.matricule}","date_":"$date","heure_":"$heure"}""");
//                             ////////////////////////////////////////////////////
//                             print("efface tout!");
//                             //listeConSave
//                             listeConSave = [];
//                             //
//                             listeConv = [];
//                             listeConv.forEach((element) {
//                               bool v = listeConv.remove(element);
//                               v ? print("Effectué") : print("Pas éffectué");
//                             });
//                             chatt = Container();
//                           },
//                           child: Container(
//                             width: 150,
//                             height: 40,
//                             alignment: Alignment.center,
//                             child: const Text(
//                               "Fin de la conversation",
//                               style: TextStyle(
//                                 color: Colors.white,
//                               ),
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.red.shade700,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         )
//       ],
//     );
//   }

//   Widget smsMessage(bool t, String contenu) {
//     if (t) {
//       return ChatBubble(
//         clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
//         alignment: Alignment.topRight,
//         margin: EdgeInsets.only(top: 20),
//         backGroundColor: Colors.blue,
//         child: Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.7,
//           ),
//           child: Text(
//             contenu,
//             style: TextStyle(color: Colors.white),
//           ),
//         ),
//       );
//     } else {
//       return ChatBubble(
//         clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
//         backGroundColor: Color(0xffE7E7ED),
//         margin: const EdgeInsets.only(top: 20),
//         child: Container(
//           constraints: BoxConstraints(
//             maxWidth: MediaQuery.of(context).size.width * 0.7,
//           ),
//           child: Text(
//             contenu,
//             style: TextStyle(color: Colors.black),
//           ),
//         ),
//       );
//     }
//   }
// }

//

class ChattServ extends GetView {
  TextEditingController chatCont = TextEditingController();
  //
  DateTime dateTime = DateTime.now();
  String date = "";
  String heure = "";

  Map e = {};

  ChattServ(this.e) {
    print('Premier appel de e: $e');
    /**
     * {
        "idSessionHote": idSessionHote,
        "listeConv": listeConv,
        "hostId": hostId,
        "clientId": clientId,
        "from": from,
        "matricule": "${widget.u!['matricule']}",
        "user": "${widget.u!['postnom']} ${widget.u!['prenom']}",
      }
     */
    //
    print(chatListner);
    //
    date = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
    heure = "${dateTime.hour}:${dateTime.minute}";
    //
    //${dateTime.hour}
    //
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(10),
            child: IconButton(
              onPressed: () {
                //
                DateTime dateTime = DateTime.now();
                String date = "";
                String heure = "";
                //
                date = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
                heure = "${dateTime.hour}:${dateTime.minute}";
                //
                channel!.sink.add(
                    """{"from_":"${e['user']}","to_":"","content_":"","hostId_":"${e['hostId']}","clientId_":"${e['clientId']}","close_":false,"all_":false,"visible_":"non","conversation_": true,"matricule_":"${e['matricule']}","date_":"$date","heure_":"$heure"}""");

                Get.back();
                listeConv.clear();
                //
              },
              icon: Icon(Icons.close, color: Colors.black),
            ),
          ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const SizedBox(
                    width: 40,
                  ),
                  Expanded(
                    child: Container(
                      //height: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const SizedBox(
                            width: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: chatCont,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    print("e: $e");
                                    print(
                                        """{"from_":"${e['user']}","to_":"hote_","content_":"${chatCont.text}","hostId_":"${e['hostId']}","clientId_":"${e['clientId']}","close_":false,"all_":false,"visible_":"non","conversation_": true,"matricule_":"${e['matricule']}","date_":"$date","heure_":"$heure"}""");
                                    //
                                    //setState(() {
                                    //List l = chatListner['listeConv'];
                                    listeConv
                                        .add(smsMessage(true, chatCont.text));
                                    //chatListner['listeConv'] = l;
                                    channel.sink.add(
                                        """{"from_":"${e['user']}","to_":"hote","content_":"${chatCont.text}","hostId_":"${e['hostId']}","clientId_":"${e['clientId']}","close_":false,"all_":false,"visible_":"non","conversation_": true,"matricule_":"${e['matricule']}","date_":"$date","heure_":"$heure"}""");
                                    chatCont.clear();
                                    //});
                                  },
                                  icon: Icon(
                                    Icons.send,
                                    color: Colors.blue.shade400,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          /*
                          IconButton(
                            onPressed: () async {
                              print(
                                  """{"from_":"${chatListner['user']}","to_":"hote_","content_":"${chatCont.text}","hostId_":"${chatListner['hostId']}","clientId_":"${chatListner['clientId']}","close_":false,"all_":false,"visible_":"non","conversation_": true}""");
                              //
                              //setState(() {
                              List l = chatListner['listeConv'];
                              l.add(smsMessage(true, chatCont.text));
                              chatListner['listeConv'] = l;
                              channel.sink.add(
                                  """{"from_":"${chatListner['user']}","to_":"hote","content_":"${chatCont.text}","hostId_":"${chatListner['hostId']}","clientId_":"${chatListner['clientId']}","close_":false,"all_":false,"visible_":"non","conversation_": true,"matricule_":"${chatListner['matricule']}","date_":"$date","heure_":"$heure"}""");
                              chatCont.clear();
                              //});
                            },
                            icon: Icon(
                              Icons.send,
                              color: Colors.blue.shade400,
                            ),
                          ),
                          */
                          InkWell(
                            onTap: () {
                              channel.sink.add(
                                  """{"from_":"${e['user']}","to_":"hote","content_":"${chatCont.text}","hostId_":"${e['hostId']}","clientId_":"${e['clientId']}","close_":true,"all_":false,"visible_":"non","conversation_": false,"matricule_":"${e['matricule']}","date_":"$date","heure_":"$heure"}""");
                              ////////////////////////////////////////////////////
                              print("efface tout!");
                              //listeConSave

                              listeConSave = [];
                              //
                              listeConv.value = [];
                              listeConv.forEach((element) {
                                bool v = listeConv.remove(element);
                                v ? print("Effectué") : print("Pas éffectué");
                              });
                            },
                            child: Container(
                              width: 150,
                              height: 40,
                              alignment: Alignment.center,
                              child: const Text(
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
      ),
    );
  }

  Widget smsMessage(bool t, String contenu) {
    if (t) {
      return ChatBubble(
        clipper: ChatBubbleClipper1(type: BubbleType.sendBubble),
        alignment: Alignment.topRight,
        margin: const EdgeInsets.only(top: 20),
        backGroundColor: Colors.blue,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Get.size.width * 0.7,
          ),
          child: Text(
            contenu,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return ChatBubble(
        clipper: ChatBubbleClipper1(type: BubbleType.receiverBubble),
        backGroundColor: Color(0xffE7E7ED),
        margin: const EdgeInsets.only(top: 20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: Get.size.width * 0.7,
          ),
          child: Text(
            contenu,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      );
    }
  }
}
//
