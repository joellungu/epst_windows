import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 300,
          width: 300,
          alignment: Alignment.center,
          child: Image.asset(
            "assets/EPST APP.png",
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
