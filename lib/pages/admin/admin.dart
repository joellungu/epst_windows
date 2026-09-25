import 'package:epst_windows_app/pages/admin/liste_utilisateur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'nouvel_utilisateur.dart';

class Admin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _Admin();
  }
}

class _Admin extends State<Admin> {
  Widget? vue;

  bool ajouterAgent = false;
  bool listeAgent = false;

  @override
  void initState() {
    vue = _buildBienvenue();
    super.initState();
  }

  Widget _buildBienvenue() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.admin_panel_settings_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            "Administration",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Sélectionnez une action à gauche pour gérer les agents.",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required String titre,
    required String sousTitre,
    required IconData icone,
    required bool actif,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: actif ? Colors.green.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: actif ? Colors.green.shade700 : Colors.grey.shade200,
          width: actif ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          child: Icon(
            icone,
            color: actif ? Colors.green.shade700 : Colors.grey.shade700,
          ),
          decoration: BoxDecoration(
            color: actif ? Colors.green.shade100 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        title: Text(
          titre,
          style: TextStyle(
            color: Colors.black,
            fontWeight: actif ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          sousTitre,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
            fontSize: 10,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: actif ? Colors.green.shade700 : Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 400,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 10, top: 4),
                child: Text(
                  "Administration des agents",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              _buildNavTile(
                titre: "Ajouter nouvel utilisateur",
                sousTitre: "Créer un compte agent",
                icone: CupertinoIcons.person_add,
                actif: ajouterAgent,
                onTap: () {
                  setState(() {
                    vue = NouvelUtilisateur();
                    ajouterAgent = true;
                    listeAgent = false;
                  });
                },
              ),
              _buildNavTile(
                titre: "Liste des utilisateurs",
                sousTitre: "Rechercher, filtrer et gérer les agents",
                icone: CupertinoIcons.person_2,
                actif: listeAgent,
                onTap: () {
                  setState(() {
                    vue = ListUtilisateur();
                    listeAgent = true;
                    ajouterAgent = false;
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: vue!,
        )
      ],
    );
  }
}
