import 'package:flutter/material.dart';

class Barre extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Barre();
  }
}

class _Barre extends State<Barre> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(10, (index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 3,
              color: Colors.green,
            ),
            Expanded(
              flex: 1,
              child: ListTile(
                leading: Icon(Icons.paragliding),
                title: Text("Truc"),
              ),
            )
          ],
        );
      }),
    );
  }
}
