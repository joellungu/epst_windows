import 'package:epst_windows_app/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RechercheAntenne extends SearchDelegate {
  //List<String> liste_annee = [];
  int a = 1900;

  RechercheAntenne() {
    print(liste_antennes.length);
    // for (int i = 0; i < liste_ecoles.length; i++) {
    //   liste_annee.add(liste_ecoles[i]);
    //   a++;
    // }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Map> matchQuery = [];
    for (var annee in liste_antennes) {
      if (annee["antenne"].toLowerCase().contains(query.toLowerCase())) {
        //var result = matchQuery[]
        matchQuery.add(annee);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        Map result = matchQuery[index];
        return ListTile(
          title: Text(
            "${result["antenne"]} (${result["code"]})",
            style: const TextStyle(
              fontSize: 13,
            ),
          ), //
          onTap: () {
            //
            antenne.value = result;
            //ecole1.value = result;
            //ecole2.value = result;
            //print("salut: ${ecole.value}");
            Get.back();
            //
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map> matchQuery = [];
    for (var annee in liste_antennes) {
      if (annee["antenne"].toLowerCase().contains(query.toLowerCase())) {
        //var result = matchQuery[]
        matchQuery.add(annee);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        Map result = matchQuery[index];
        return ListTile(
          title: Text(
            "${result["antenne"]} (${result["code"]})",
            style: const TextStyle(
              fontSize: 13,
            ),
          ), //
          onTap: () {
            //
            antenne.value = result;
            // ecole1.value = result;
            // ecole2.value = result;
            //print("salut: ${ecole.value}");
            Get.back();
            //
          },
        );
      },
    );
  }
}

class RechercheEcole2 extends SearchDelegate {
  //List<String> liste_annee = [];
  int a = 1900;

  RechercheEcole() {
    print(liste_antennes.length);
    // for (int i = 0; i < liste_ecoles.length; i++) {
    //   liste_annee.add(liste_ecoles[i]);
    //   a++;
    // }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = "";
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Map> matchQuery = [];
    for (var annee in liste_antennes) {
      if (annee["antenne"].toLowerCase().contains(query.toLowerCase())) {
        //var result = matchQuery[]
        matchQuery.add(annee);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        Map result = matchQuery[index];
        return ListTile(
          title: Text(
            "${result["antenne"]} (${result["code"]})",
            style: const TextStyle(
              fontSize: 13,
            ),
          ), //
          onTap: () {
            //
            antenne.value = result;
            //ecole1.value = result;
            //ecole2.value = result;
            print("salut");
            Get.back();
            //
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Map> matchQuery = [];
    for (var annee in liste_antennes) {
      if (annee["antenne"].toLowerCase().contains(query.toLowerCase())) {
        //var result = matchQuery[]
        matchQuery.add(annee);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        Map result = matchQuery[index];
        return ListTile(
          title: Text(
            "${result["antenne"]} (${result["code"]})",
            style: const TextStyle(
              fontSize: 13,
            ),
          ), //
          onTap: () {
            //
            antenne.value = result;
            //ecole1.value = result;
            //ecole2.value = result;
            print("salut");
            Get.back();
            //
          },
        );
      },
    );
  }
}
