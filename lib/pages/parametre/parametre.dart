import 'package:epst_windows_app/pages/parametre/taux.dart';
import 'package:flutter/material.dart';

class Parametre extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "Taux", icon: Icon(Icons.flight)),
              Tab(icon: Icon(Icons.directions_transit)),
            ],
          ),
          title: const Text('Parametres'),
        ),
        body: TabBarView(
          children: [
            Taux(),
            const Icon(Icons.directions_transit, size: 350),
          ],
        ),
      ),
    );
  }
}
