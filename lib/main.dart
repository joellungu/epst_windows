import 'dart:async';
//import 'package:desktop_window/desktop_window.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:epst_windows_app/pages/controllers/plainte_controller.dart';
import 'package:epst_windows_app/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

import 'pages/accueil.dart';
import 'pages/archive_controller.dart';
import 'pages/load_mag/update_controller.dart';
import 'pages/login.dart';
import 'utils/theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();
String? tempDirectory = 'Unknown';
int role = 0;
String nomC = "";

void main() {
  //
  WidgetsFlutterBinding.ensureInitialized();
  //
  DartVLC.initialize();
  //

  initDirectories();
  //
  testWindowFunctions();
  runApp(
    Epst(
      vue: Splash(),
    ),
  );
  //
  Timer(
    const Duration(seconds: 5),
    () {
      start();
    },
  );
}

//
Future<void> initDirectories() async {
  //String? tempDirectory;
  final PathProviderWindows provider = PathProviderWindows();

  try {
    tempDirectory = await provider.getTemporaryPath();
  } catch (exception) {
    tempDirectory = 'Failed to get temp directory: $exception';
  }
  //
  // setState(() {
  //   _tempDirectory = tempDirectory;
  // });
  //
  //print(
  //  "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ !!!!!!!!!!!!!!!!!!!!!!!! \n$tempDirectory\n$tempDirectory \n++++++++++++++++++++++");
}

Future testWindowFunctions() async {
  Size size = await DesktopWindow.getWindowSize();
  print(
      "_________________________________________________________________ $size");
  await DesktopWindow.setWindowSize(size);

  await DesktopWindow.setMinWindowSize(size);
  await DesktopWindow.setMaxWindowSize(size);

  await DesktopWindow.resetMaxWindowSize();
  await DesktopWindow.toggleFullScreen();
  bool isFullScreen = await DesktopWindow.getFullScreen();
  await DesktopWindow.setFullScreen(true);
  await DesktopWindow.setFullScreen(false);
}

start() async {
  bool deja = false;

  if (deja) {
    /*
    runApp(
      Epst(
        vue: Accueil(),
      ),
    );
    */
  } else {
    runApp(Epst(
      vue: Login(),
    ));
  }
}

class Epst extends StatelessWidget {
  Epst({this.vue});

  Widget? vue;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EPST APP',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeClass.lightTheme,
      themeMode: ThemeMode.system,
      //darkTheme: ThemeClass.darkTheme,
      home: vue,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
