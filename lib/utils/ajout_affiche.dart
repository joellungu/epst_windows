import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:epst_windows_app/main.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

import 'connexion.dart';

class Ajouter extends StatefulWidget {
  int? type;

  Ajouter(this.type);

  @override
  State<StatefulWidget> createState() {
    return _Ajouter();
  }
}

class _Ajouter extends State<Ajouter> {
  TextEditingController nom_c = TextEditingController(); //libelle
  TextEditingController description_c = TextEditingController(); //libelle
  TextEditingController fichierController = TextEditingController(); //libelle
  File? file;

  //
  importerPdf() async {
    //fichierController

    //
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    //
    if (result != null) {
      file = File(result.files.single.path!);
      fichierController.text = result.files.single.path!;
    } else {
      // User canceled the picker
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 100, right: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          //
          TextField(
            controller: nom_c,
            decoration: InputDecoration(
              label: const Text("Nom du magasin"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          //
          TextField(
            maxLines: 15,
            controller: description_c,
            decoration: InputDecoration(
              hintText: "Descriptions",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          //
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: TextField(
                      enabled: false,
                      controller: fichierController,
                      decoration: InputDecoration(
                        label: const Text("Fichier"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: importerPdf,
                  icon: Icon(Icons.import_export),
                ),
              ],
            ),
          ),
          //
          ElevatedButton(
            onPressed: () {
              //
              //Enregistrement utilisateur...
              Connexion.saveMagasin({
                //"id": 1,
                "date": "${DateTime.now()}",
                "libelle": nom_c.text,
                "description": description_c.text,
                "piecejointe": file!.readAsBytesSync(),
                "type": 1
              });
            },
            child: const Center(
              child: Text("Envoyer"),
            ),
          ),
        ],
      ),
    );
  }
}

class Affiche extends StatefulWidget {
  Affiche(this.id);
  int? id;

  @override
  State<StatefulWidget> createState() {
    return _Affiche();
  }
}

class _Affiche extends State<Affiche> {
  //
  final app = Alfred();
  //
  Future<Widget> vueFichier() async {
    Map<String, dynamic> mag = await Connexion.getMagasin(widget.id!);
    //
    try {
      //
      return Afficheur();
    } catch (e) {
      print("erreur du à: $e");
      return Container(
        color: Colors.teal,
      );
    }
    //print(mag["id"]);http://localhost:6565/index.html
    return Container(
      color: Colors.teal,
    );
  }

  Future startServer() async {
    //
    Map<String, dynamic> mag = await Connexion.getMagasin(widget.id!);
    //
    app.get('/pdfobject.js', (req, res) => File('assets/pdfobject.js'));
    app.get('/in.pdf', (req, res) => mag["piecejointe"]);
    app.get('/index.html', (req, res) {
      res.headers.contentType = ContentType.html;
      return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      .pdfobject-container { height: 30rem; border: 1rem solid rgba(0,0,0,.1); }
    </style>
    <title>Document</title>
</head>
<body>
    <div id="example1"></div>
    <script src="http://localhost:6565/pdfobject.js"></script>
    <script>PDFObject.embed("http://localhost:6565/in.pdf", "#example1");</script>
</body>
</html>
""";
    });

    await app.listen(6565);
  }

  @override
  void initState() {
    //
    startServer();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    //
    app.close();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: vueFichier(),
        builder: (context, t) {
          if (t.hasData) {
            return t.data as Widget;
          } else if (t.hasError) {
            return Center(
              child: Container(
                alignment: Alignment.center,
                child: Text("Probème de connexion"),
                height: 51,
                width: 250,
              ),
            );
          }
          return Center(
            child: Container(
              child: LinearProgressIndicator(),
              height: 2,
              width: 200,
            ),
          );
        },
      ),
    );
  }
}

class Afficheur extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Afficheur();
  }
}

class _Afficheur extends State<Afficheur> {
  final _controller = WebviewController();
  final _textController = TextEditingController();
  bool _isWebviewSuspended = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Optionally initialize the webview environment using
    // a custom user data directory
    // and/or a custom browser executable directory
    // and/or custom chromium command line flags
    //await WebviewController.initializeEnvironment(
    //    additionalArguments: '--show-fps-counter');

    try {
      await _controller.initialize();
      _controller.url.listen((url) {
        _textController.text = url;
      });

      await _controller.setBackgroundColor(Colors.transparent);
      await _controller.setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
      await _controller.loadUrl('http://localhost:6565/index.html');

      if (!mounted) return;
      setState(() {});
      // ignore: nullable_type_in_catch_clause
    } on Exception catch (e) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: $e'),
                      Text('Message: ${e.toString()}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  Widget compositeView() {
    if (!_controller.value.isInitialized) {
      return const Text(
        'Not Initialized',
        style: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            /*
            Card(
              elevation: 0,
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'URL',
                    contentPadding: EdgeInsets.all(10.0),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        _controller.reload();
                      },
                    )),
                textAlignVertical: TextAlignVertical.center,
                controller: _textController,
                onSubmitted: (val) {
                  _controller.loadUrl(val);
                },
              ),
            ),
            */
            Expanded(
                child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Stack(
                      children: [
                        Webview(
                          _controller,
                          permissionRequested: _onPermissionRequested,
                        ),
                        StreamBuilder<LoadingState>(
                            stream: _controller.loadingState,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data == LoadingState.loading) {
                                return LinearProgressIndicator();
                              } else {
                                return SizedBox();
                              }
                            }),
                      ],
                    ))),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      floatingActionButton: FloatingActionButton(
        tooltip: _isWebviewSuspended ? 'Resume webview' : 'Suspend webview',
        onPressed: () async {
          if (_isWebviewSuspended) {
            await _controller.resume();
          } else {
            await _controller.suspend();
          }
          setState(() {
            _isWebviewSuspended = !_isWebviewSuspended;
          });
        },
        child: Icon(_isWebviewSuspended ? Icons.play_arrow : Icons.pause),
      ),
      
      appBar: AppBar(
        title: StreamBuilder<String>(
          stream: _controller.title,
          builder: (context, snapshot) {
            return Text(snapshot.hasData
                ? snapshot.data!
                : 'WebView (Windows) Example');
          },
        ),
      ),
      */
      body: Center(
        child: compositeView(),
      ),
    );
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      String url, WebviewPermissionKind kind, bool isUserInitiated) async {
    final decision = await showDialog<WebviewPermissionDecision>(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('WebView permission requested'),
        content: Text('WebView has requested permission \'$kind\''),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.deny),
            child: const Text('Deny'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, WebviewPermissionDecision.allow),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return decision ?? WebviewPermissionDecision.none;
  }
}
