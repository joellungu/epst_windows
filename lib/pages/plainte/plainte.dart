import 'package:epst_windows_app/pages/plainte/menu.dart';
import 'package:flutter/material.dart';

class Plainte extends StatefulWidget {
  static Widget? details;
  static late State plainteState;
  int? role;
  Plainte(this.role);
  @override
  State<StatefulWidget> createState() {
    return _Plainte();
  }
}

class _Plainte extends State<Plainte> {
  @override
  void initState() {
    Plainte.details = Container();
    //
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Plainte.plainteState = this;
    return MenuGauche(this, widget.role);
    /*
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          //width: 400,
          child: ,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        /*
        Expanded(
          flex: 1,
          child: Container(
            child: Plainte.details,
          ),
        )
        */
      ],
    );
    */
  }
}
