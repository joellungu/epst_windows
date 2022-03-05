import 'package:flutter/cupertino.dart';
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
                children: List.generate(10, (index) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        child: Icon(
                          CupertinoIcons.person,
                          color: Colors.grey.shade700,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      title: Text(
                        "Gratuité de l'enseignement",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        "Mokpongb lungu joel / 0815454789",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      trailing: Text("12/12/2022"),
                    ),
                  );
                }),
              ),
              ListView(
                padding: EdgeInsets.all(10),
                children: List.generate(10, (index) {
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                            right: 10,
                          ),
                          child: Icon(
                            CupertinoIcons.person,
                            color: Colors.grey.shade700,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      text: "Gratuité de l'enseignement\n",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.normal,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: index % 2 == 1
                                              ? "Classé"
                                              : "En traitement",
                                          style: TextStyle(
                                            color: Colors.green.shade300,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mokpongb lungu joel / 0815454789",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        Text("12/12/2022")
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        )
      ],
    );
  }
}
