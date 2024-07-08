import 'dart:async';
//import 'package:desktop_window/desktop_window.dart';
//import 'package:dart_vlc/dart_vlc.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:epst_windows_app/pages/controllers/plainte_controller.dart';
import 'package:epst_windows_app/pages/ministre/ministre_controller.dart';
import 'package:epst_windows_app/pages/mutuelle/mutuelle_controller.dart';
import 'package:epst_windows_app/splash.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

import 'pages/accueil.dart';
import 'pages/cours/cours_controller.dart';
import 'pages/load_mag/update_controller.dart';
import 'pages/login.dart';
import 'pages/mutuelle/mutuelle_controller.dart';
import 'utils/theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();
String? tempDirectory = 'Unknown';
int role = 0;
String nomC = "";
//
List liste_antennes = [];
//
RxString annee = "".obs;
//
RxMap antenne = {"antenne": "", "province": ""}.obs;
//

void main() {
  //
  WidgetsFlutterBinding.ensureInitialized();
  //
  //DartVLC.initialize();
  //

  initDirectories();
  //
  //testWindowFunctions();
  //
  runApp(
    Epst(
      vue: Splash(),
    ),
  );
  //
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

class Epst extends StatelessWidget {
  //

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
