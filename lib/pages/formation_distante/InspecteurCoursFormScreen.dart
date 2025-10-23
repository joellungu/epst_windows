import 'package:epst_windows_app/pages/formation_distante/Classe.dart';
import 'package:epst_windows_app/pages/formation_distante/ClasseService.dart';
import 'package:epst_windows_app/pages/formation_distante/Cours.dart';
import 'package:epst_windows_app/pages/formation_distante/CoursService.dart';
import 'package:epst_windows_app/pages/formation_distante/inspecteur_cours.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'inspecteur_cours_provider.dart';

class InspecteurCoursFormScreen extends StatefulWidget {
  final InspecteurCours? inspecteurCours;

  const InspecteurCoursFormScreen({this.inspecteurCours});

  @override
  State<InspecteurCoursFormScreen> createState() =>
      _InspecteurCoursFormScreenState();
}

class _InspecteurCoursFormScreenState extends State<InspecteurCoursFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idInspecteurController = TextEditingController();

  // Lists pour les sélections
  List<Classe> _classes = [];
  List<Cours> _cours = [];

  // Éléments sélectionnés
  Classe? _selectedClasse;
  List<Cours> _selectedCours = [];

  // États de chargement
  bool _isLoadingClasses = false;
  bool _isLoadingCours = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    //
    print("Data: ${widget.inspecteurCours!.idInspecteur.toString()}");
    //
    if (widget.inspecteurCours != null) {
      _idInspecteurController.text =
          widget.inspecteurCours!.idInspecteur.toString();
    }
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoadingClasses = true;
      _errorMessage = '';
    });

    try {
      final classes = await ClasseService.getAllClasses();
      setState(() {
        _classes = classes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des classes: $e';
      });
    } finally {
      setState(() {
        _isLoadingClasses = false;
      });
    }
  }

  Future<void> _loadCours() async {
    if (_selectedClasse == null) return;

    setState(() {
      _isLoadingCours = true;
      _cours = [];
      _selectedCours = [];
    });

    try {
      List<Cours> cours = await CoursService.getCoursByClasse(
        _selectedClasse!.id,
        _selectedClasse!.categorie,
      );
      setState(() {
        _cours = cours;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des cours: $e';
      });
    } finally {
      setState(() {
        _isLoadingCours = false;
      });
    }
  }

  void _onClasseSelected(Classe? classe) {
    setState(() {
      _selectedClasse = classe;
      _selectedCours = [];
    });

    if (classe != null) {
      _loadCours();
    }
  }

  void _onCoursSelected(Cours? cours, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedCours.any((c) => c.id == cours!.id)) {
          _selectedCours.add(cours!);
        }
      } else {
        _selectedCours.removeWhere((c) => c.id == cours!.id);
      }
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedClasse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une classe')),
        );
        return;
      }

      if (_selectedCours.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Veuillez sélectionner au moins un cours')),
        );
        return;
      }

      // Récupérer les IDs de la classe et des cours sélectionnés
      final classeId = _selectedClasse!.id;
      final coursIds = _selectedCours.map((cours) => cours.id).toList();

      final inspecteurCours = InspecteurCours(
        id: widget.inspecteurCours?.id,
        idInspecteur: int.parse(_idInspecteurController.text),
        cours: coursIds,
        classe: [classeId], // On stocke l'ID de la classe sélectionnée
      );

      final provider =
          Provider.of<InspecteurCoursProvider>(context, listen: false);
      final success = widget.inspecteurCours!.id == null
          ? await provider.createInspecteurCours(inspecteurCours)
          : await provider.updateInspecteurCours(
              widget.inspecteurCours!.id!, inspecteurCours);

      if (success && mounted) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.inspecteurCours == null
            ? 'Nouvel Inspecteur Cours'
            : 'Modifier Inspecteur Cours'),
      ),
      body: _errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildIdInspecteurField(),
                    const SizedBox(height: 20),
                    _buildClasseSelection(),
                    const SizedBox(height: 20),
                    if (_selectedClasse != null) _buildCoursSelection(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadClasses,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildIdInspecteurField() {
    return TextFormField(
      controller: _idInspecteurController,
      decoration: const InputDecoration(
        labelText: 'ID Inspecteur *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'L\'ID inspecteur est obligatoire';
        }
        if (int.tryParse(value) == null) {
          return 'Veuillez entrer un nombre valide';
        }
        return null;
      },
    );
  }

  Widget _buildClasseSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélection de la Classe *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_isLoadingClasses)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<Classe>(
                value: _selectedClasse,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Choisir une classe',
                ),
                items: _classes.map((classe) {
                  return DropdownMenuItem<Classe>(
                    value: classe,
                    child: Text(
                        '${classe.nom} (${classe.id} - ${classe.categorie})'),
                  );
                }).toList(),
                onChanged: _onClasseSelected,
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une classe';
                  }
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélection des Cours * (${_selectedCours.length} sélectionnés)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_isLoadingCours)
              const Center(child: CircularProgressIndicator())
            else if (_cours.isEmpty)
              const Text('Aucun cours disponible pour cette classe')
            else
              _buildCoursList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _cours.length,
        itemBuilder: (context, index) {
          final cours = _cours[index];
          final isSelected = _selectedCours.any((c) => c.id == cours.id);

          return CheckboxListTile(
            title: Text(cours.cours),
            value: isSelected,
            onChanged: (selected) {
              _onCoursSelected(cours, selected ?? false);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Enregistrer',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  void dispose() {
    _idInspecteurController.dispose();
    super.dispose();
  }
}
