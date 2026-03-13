import 'package:epst_windows_app/pages/formation_distante/Classe.dart';
import 'package:epst_windows_app/pages/formation_distante/ClasseService.dart';
import 'package:epst_windows_app/pages/formation_distante/Cours.dart';
import 'package:epst_windows_app/pages/formation_distante/CoursService.dart';
import 'package:epst_windows_app/pages/formation_distante/OnlineScheduleService.dart';
import 'package:epst_windows_app/pages/formation_distante/inspecteur_cours.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'inspecteur_cours_provider.dart';

class InspecteurCoursFormScreen extends StatefulWidget {
  final InspecteurCours? inspecteurCours;
  final int? fixedInspecteurId;
  final String typeFormation;
  final bool embedded;
  final VoidCallback? onSaved;

  const InspecteurCoursFormScreen({
    this.inspecteurCours,
    this.fixedInspecteurId,
    this.typeFormation = 'Professeur',
    this.embedded = false,
    this.onSaved,
  });

  @override
  State<InspecteurCoursFormScreen> createState() =>
      _InspecteurCoursFormScreenState();
}

class _InspecteurCoursFormScreenState extends State<InspecteurCoursFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idInspecteurController = TextEditingController();

  // Lists pour les selections
  List<Classe> _classes = [];
  List<Cours> _coursesEleve = [];
  List<Cours> _coursesProf = [];

  // Elements selectionnes
  Classe? _selectedClasse;
  List<Cours> _selectedCours = [];

  // Etats de chargement
  bool _isLoadingClasses = false;
  bool _isLoadingCours = false;
  String _errorMessage = '';

  final Map<String, bool> _scheduleByClasse = {};

  @override
  void initState() {
    super.initState();
    if (widget.fixedInspecteurId != null) {
      _idInspecteurController.text = widget.fixedInspecteurId.toString();
    } else if (widget.inspecteurCours != null) {
      _idInspecteurController.text =
          widget.inspecteurCours!.idInspecteur.toString();
    }
    _loadClasses();
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  Future<void> _loadClasses() async {
    _safeSetState(() {
      _isLoadingClasses = true;
      _errorMessage = '';
    });

    try {
      final classes = await ClasseService.getAllClasses();
      _safeSetState(() {
        _classes = classes;
      });
      _loadScheduleFlags();
    } catch (e) {
      _safeSetState(() {
        _errorMessage = 'Erreur lors du chargement des classes: $e';
      });
    } finally {
      _safeSetState(() {
        _isLoadingClasses = false;
      });
    }
  }

  Future<void> _loadScheduleFlags() async {
    for (final classe in _classes) {
      if (!mounted) return;
      if (_scheduleByClasse.containsKey(classe.id)) continue;
      try {
        final student = await OnlineScheduleService.getByClass(
          classe.id,
          audience: 'STUDENT',
        );
        if (!mounted) return;
        if (student.isNotEmpty) {
          _scheduleByClasse[classe.id] = true;
          if (mounted) setState(() {});
          continue;
        }
        final teacher = await OnlineScheduleService.getByClass(
          classe.id,
          audience: 'TEACHER',
        );
        if (!mounted) return;
        _scheduleByClasse[classe.id] = teacher.isNotEmpty;
        if (mounted) setState(() {});
      } catch (_) {
        if (!mounted) return;
        _scheduleByClasse[classe.id] = false;
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _loadCours() async {
    if (_selectedClasse == null) return;

    _safeSetState(() {
      _isLoadingCours = true;
      _coursesEleve = [];
      _coursesProf = [];
      _selectedCours = [];
    });

    try {
      final eleves = await CoursService.getCoursByClasse(
        _selectedClasse!.id,
        'Eleve',
      );
      final profs = await CoursService.getCoursByClasse(
        _selectedClasse!.id,
        'Professeur',
      );
      _safeSetState(() {
        _coursesEleve = eleves;
        _coursesProf = profs;
      });
    } catch (e) {
      _safeSetState(() {
        _errorMessage = 'Erreur lors du chargement des cours: $e';
      });
    } finally {
      _safeSetState(() {
        _isLoadingCours = false;
      });
    }
  }

  void _onClasseSelected(Classe? classe) {
    _safeSetState(() {
      _selectedClasse = classe;
      _selectedCours = [];
    });

    if (classe != null) {
      _loadCours();
    }
  }

  void _onCoursSelected(Cours? cours, bool selected) {
    _safeSetState(() {
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
          const SnackBar(content: Text('Veuillez selectionner une classe')),
        );
        return;
      }

      if (_selectedCours.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Veuillez selectionner au moins un cours')),
        );
        return;
      }

      // Recuperer les IDs de la classe et des cours selectionnes
      final classeId = _selectedClasse!.id;
      final coursIds = _selectedCours.map((cours) => cours.id).toList();

      final inspecteurCours = InspecteurCours(
        id: widget.inspecteurCours?.id,
        idInspecteur: int.parse(_idInspecteurController.text),
        cours: coursIds,
        classe: [classeId], // On stocke l'ID de la classe selectionnee
      );

      final provider =
          Provider.of<InspecteurCoursProvider>(context, listen: false);
      final isNew =
          widget.inspecteurCours == null || widget.inspecteurCours!.id == null;
      final success = isNew
          ? await provider.createInspecteurCours(inspecteurCours)
          : await provider.updateInspecteurCours(
              widget.inspecteurCours!.id!, inspecteurCours);

      if (!mounted) return;
      if (success) {
        if (widget.embedded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Affectation enregistree')),
          );
          widget.onSaved?.call();
        } else {
          Navigator.pop(context);
        }
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

  List<Widget> _buildFormFields() {
    return [
      _buildIdInspecteurField(),
      const SizedBox(height: 20),
      _buildClasseSelection(),
      const SizedBox(height: 20),
      if (_selectedClasse != null) _buildCoursSelection(),
      const SizedBox(height: 24),
      _buildSubmitButton(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    final form = Form(
      key: _formKey,
      child: widget.embedded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildFormFields(),
            )
          : ListView(
              children: _buildFormFields(),
            ),
    );

    if (widget.embedded) {
      return form;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.inspecteurCours == null
            ? 'Nouvel Inspecteur Cours'
            : 'Modifier Inspecteur Cours'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: form,
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
            child: const Text('Reessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildIdInspecteurField() {
    return TextFormField(
      controller: _idInspecteurController,
      enabled: widget.fixedInspecteurId == null,
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
              'Selection de la Classe *',
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
                isExpanded: true,
                items: _classes.map((classe) {
                  final hasSchedule = _scheduleByClasse[classe.id] == true;
                  return DropdownMenuItem<Classe>(
                    value: classe,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: Text(
                            '${classe.cycle} (${classe.section} - ${classe.niveau})',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasSchedule) const SizedBox(width: 8),
                        if (hasSchedule)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Horaire',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: _onClasseSelected,
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez selectionner une classe';
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
    final isEleve = widget.typeFormation == 'Eleve';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selection des Cours * (${_selectedCours.length} selectionnes)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_isLoadingCours)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cours Eleves',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  _buildCoursList(
                    _coursesEleve,
                    selectable: isEleve,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cours Enseignants',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  _buildCoursList(
                    _coursesProf,
                    selectable: !isEleve,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursList(List<Cours> list, {required bool selectable}) {
    if (list.isEmpty) {
      return const Text('Aucun cours');
    }
    return Column(
      children: list.map((cours) {
        if (!selectable) {
          return ListTile(
            dense: true,
            title: Text(cours.cours),
            leading: const Icon(Icons.lock, size: 18),
          );
        }
        final isSelected = _selectedCours.any((c) => c.id == cours.id);
        return CheckboxListTile(
          dense: true,
          title: Text(cours.cours),
          value: isSelected,
          onChanged: (selected) {
            _onCoursSelected(cours, selected ?? false);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text(
        'Valider',
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

