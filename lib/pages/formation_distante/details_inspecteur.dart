import 'package:flutter/material.dart';

class DetailsInspecteur extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              const Text("Cours"),
              Expanded(
                flex: 9,
                child: ListView(),
              ),
              ElevatedButton(
                  onPressed: () {
                    //
                  },
                  child: const Text("Ajouter"))
            ],
          ),
        ),
        Container(
          color: Colors.black,
          height: 600,
          width: 1,
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              const Text(
                "Classe",
                style: TextStyle(),
              ),
              Expanded(
                flex: 9,
                child: ListView(),
              ),
              ElevatedButton(
                  onPressed: () {
                    //
                  },
                  child: const Text("Ajouter"))
            ],
          ),
        ),
      ],
    );
  }
  //
}
