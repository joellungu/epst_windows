import 'package:flutter/material.dart';

class MenuGauche extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MenuGauche();
  }
}

class _MenuGauche extends State<MenuGauche> with TickerProviderStateMixin {
  //
  late TabController controller;

  List angles = ["Nouvelles", "Traités"];
  //

  @override
  void initState() {
    //
    controller = TabController(length: angles.length, vsync: this);
    //
    super.initState();
    //
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      //backgroundColor: Colors.teal.shade400,
      children: [
        Container(
          height: 50,
          child: TabBar(
            isScrollable: false,
            controller: controller,
            indicatorWeight: 1,
            //indicator: BoxDecoration(),
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.white10,
            ),
            tabs: List.generate(angles.length, (index) {
              return Tab(
                text: angles[index],
              );
            }),
          ),
        ),
        Expanded(
          flex: 1,
          child: TabBarView(
            controller: controller,
            children: [
              ListView(
                padding: EdgeInsets.all(10),
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.dashboard_customize_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.folder,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Fichier",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.map_outlined,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Centre",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.payment,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Paiement",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
