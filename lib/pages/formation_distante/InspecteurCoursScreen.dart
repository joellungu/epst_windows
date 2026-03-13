import 'dart:convert';

import 'package:epst_windows_app/pages/demande_documents/details_demande.dart';
import 'package:epst_windows_app/pages/formation_distante/InspecteurCoursFormScreen.dart';
import 'package:epst_windows_app/pages/formation_distante/inspecteur_cours.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'inspecteur_cours_provider.dart';

class InspecteurCoursScreen extends StatefulWidget {
  InspecteurCoursScreen(this.idInspecteur, {required this.roleInspecteur});
  final int idInspecteur;
  final int roleInspecteur;

  @override
  State<InspecteurCoursScreen> createState() => _InspecteurCoursScreenState();
}

class _InspecteurCoursScreenState extends State<InspecteurCoursScreen> {
  //
  final int _pageSize = 10;
  final Requette requete = Requette();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<InspecteurCoursProvider>(context, listen: false);
      provider.loadAllInspecteurCours(
          pageIndex: 0,
          pageSize: _pageSize,
          idInspecteur: widget.idInspecteur);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<InspecteurCoursProvider>(
        builder: (context, provider, child) {
          final existing = provider.inspecteurCoursList.isNotEmpty
              ? provider.inspecteurCoursList[0]
              : null;
          final typeFormation =
              widget.roleInspecteur == 19 ? 'Eleve' : 'Professeur';
          return Column(
            children: [
              _buildHeader(),
              _buildHint(),
              _buildStatus(provider),
              Expanded(
                child: provider.isLoading && provider.inspecteurCoursList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: InspecteurCoursFormScreen(
                            inspecteurCours: existing,
                            fixedInspecteurId: widget.idInspecteur,
                            typeFormation: typeFormation,
                            embedded: true,
                            onSaved: _loadData,
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final label = widget.roleInspecteur == 19
        ? "Inspecteur eleves"
        : "Inspecteur enseignants";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 12),
          Text(
            "ID: ${widget.idInspecteur}",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: const [
          Icon(Icons.info_outline, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Selectionnez une classe, choisissez les cours, puis cliquez sur Valider.",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatus(InspecteurCoursProvider provider) {
    final hasAffectation = provider.inspecteurCoursList.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Icon(
            hasAffectation ? Icons.check_circle : Icons.info,
            color: hasAffectation ? Colors.green : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            hasAffectation
                ? 'Affectation existante'
                : 'Aucune affectation pour cet inspecteur',
            style: TextStyle(
              color: hasAffectation ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Rafraichir'),
          )
        ],
      ),
    );
  }
}
