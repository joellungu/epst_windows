import 'package:epst_windows_app/pages/plainte/menu.dart';
import 'package:flutter/material.dart';

class Plainte extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Plainte();
  }
}

class _Plainte extends State<Plainte> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 400,
          child: MenuGauche(),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.green,
          ),
        )
      ],
    );
  }
}
