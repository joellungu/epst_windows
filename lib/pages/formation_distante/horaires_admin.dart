import 'package:epst_windows_app/pages/formation_distante/Classe.dart';
import 'package:epst_windows_app/pages/formation_distante/ClasseService.dart';
import 'package:epst_windows_app/pages/formation_distante/Cours.dart';
import 'package:epst_windows_app/pages/formation_distante/CoursService.dart';
import 'package:epst_windows_app/pages/formation_distante/OnlineScheduleService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'inspecteur_cours_provider.dart';
import 'inspecteur_cours_service.dart';

class HorairesAdminScreen extends StatefulWidget {
  final Map user;
  final List<String>? classFilter;
  final String? initialClassId;

  const HorairesAdminScreen(
    this.user, {
    Key? key,
    this.classFilter,
    this.initialClassId,
  }) : super(key: key);

  @override
  State<HorairesAdminScreen> createState() => _HorairesAdminScreenState();
}

class _HorairesAdminScreenState extends State<HorairesAdminScreen> {
  final TextEditingController _titleController = TextEditingController();
  final DateFormat _formatter = DateFormat('dd/MM/yyyy HH:mm');

  List<Classe> _classes = [];
  Classe? _selectedClasse;
  String _audience = 'STUDENT';
  DateTime? _startsAt;
  DateTime? _endsAt;

  List<Map<String, dynamic>> _schedules = [];
  bool _loadingClasses = false;
  bool _loadingSchedules = false;

  List<Cours> _coursesEleve = [];
  List<Cours> _coursesProf = [];
  bool _loadingCourses = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _loadingClasses = true);
    try {
      var classes = await ClasseService.getAllClasses();
      if (widget.classFilter != null && widget.classFilter!.isNotEmpty) {
        classes = classes
            .where((c) => widget.classFilter!.contains(c.id))
            .toList();
      }
      setState(() => _classes = classes);
      if (_selectedClasse == null && _classes.isNotEmpty) {
        final initial = widget.initialClassId == null
            ? null
            : _classes.firstWhere(
                (c) => c.id == widget.initialClassId,
                orElse: () => _classes.first,
              );
        _selectedClasse = initial ?? _classes.first;
        _loadSchedules();
        _loadCourses();
      }
    } finally {
      setState(() => _loadingClasses = false);
    }
  }

  Future<void> _loadSchedules() async {
    if (_selectedClasse == null) return;
    setState(() => _loadingSchedules = true);
    try {
      final items = await OnlineScheduleService.getByClass(
        _selectedClasse!.id,
        audience: _audience,
      );
      setState(() => _schedules = items);
    } catch (_) {
      setState(() => _schedules = []);
    } finally {
      setState(() => _loadingSchedules = false);
    }
  }

  Future<void> _loadCourses() async {
    if (_selectedClasse == null) return;
    setState(() {
      _loadingCourses = true;
      _coursesEleve = [];
      _coursesProf = [];
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
      setState(() {
        _coursesEleve = eleves;
        _coursesProf = profs;
      });
    } catch (_) {
      setState(() {
        _coursesEleve = [];
        _coursesProf = [];
      });
    } finally {
      setState(() => _loadingCourses = false);
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startsAt = dt;
      } else {
        _endsAt = dt;
      }
    });
  }

  Future<void> _createSchedule() async {
    if (_selectedClasse == null || _startsAt == null || _endsAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez selectionner la classe et les dates')),
      );
      return;
    }

    final title = _titleController.text.isEmpty ? 'Cours' : _titleController.text;
    final typeFormation = _audience == 'STUDENT' ? 'Eleve' : 'Professeur';

    try {
      await OnlineScheduleService.create(
        classId: _selectedClasse!.id,
        title: title,
        audience: _audience,
        startsAt: _startsAt!.toIso8601String(),
        endsAt: _endsAt!.toIso8601String(),
        createdByMatricule: widget.user['matricule']?.toString(),
      );

      // Creer automatiquement le cours si absent
      final existing = (typeFormation == 'Eleve' ? _coursesEleve : _coursesProf)
          .any((c) => c.cours.toLowerCase() == title.toLowerCase());
      if (!existing) {
        await CoursService.createCourseForSchedule(
          idClasse: _selectedClasse!.id,
          cycle: _selectedClasse!.cycle,
          title: title,
          typeFormation: typeFormation,
        );
      }

      _titleController.clear();
      await _loadSchedules();
      await _loadCourses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horaire cree avec succes')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _deleteSchedule(Map<String, dynamic> item) async {
    final id = item['id'];
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'horaire'),
        content: const Text('Voulez-vous supprimer cet horaire ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await OnlineScheduleService.delete(id);
      await _loadSchedules();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horaire supprime')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Widget _buildCoursesRow(String title, List<Cours> courses) {
    if (courses.isEmpty) {
      return const Text('Aucun cours');
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: courses.map((c) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blueGrey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            c.cours,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyCourse = _coursesEleve.isNotEmpty || _coursesProf.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Horaires des cours')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _loadingClasses
                      ? const LinearProgressIndicator()
                      : DropdownButtonFormField<Classe>(
                          value: _selectedClasse,
                          decoration: const InputDecoration(labelText: 'Classe'),
                          items: _classes
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.label.isNotEmpty ? c.label : c.id),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedClasse = value);
                            _loadSchedules();
                            _loadCourses();
                          },
                        ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: _audience,
                    decoration: const InputDecoration(labelText: 'Audience'),
                    items: const [
                      DropdownMenuItem(value: 'STUDENT', child: Text('Eleves')),
                      DropdownMenuItem(
                          value: 'TEACHER', child: Text('Enseignants')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _audience = value);
                      _loadSchedules();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Nom du cours'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDateTime(isStart: true),
                    child: Text(
                      _startsAt == null
                          ? 'Debut'
                          : _formatter.format(_startsAt!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDateTime(isStart: false),
                    child: Text(
                      _endsAt == null ? 'Fin' : _formatter.format(_endsAt!),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _createSchedule,
                  child: const Text('Creer'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Cours de la classe',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Colors.blueGrey.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _loadingCourses
                    ? const Center(child: CircularProgressIndicator())
                    : (!hasAnyCourse
                        ? const Center(
                            child: Text('Aucun cours pour cette classe'),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Eleves',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 6),
                              _buildCoursesRow('Cours Eleves', _coursesEleve),
                              const SizedBox(height: 12),
                              Text(
                                'Enseignants',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 6),
                              _buildCoursesRow('Cours Enseignants', _coursesProf),
                            ],
                          )),
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Expanded(
              child: _loadingSchedules
                  ? const Center(child: CircularProgressIndicator())
                  : _schedules.isEmpty
                      ? const Center(child: Text('Aucun horaire enregistre'))
                      : ListView.builder(
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final item = _schedules[index];
                            return Card(
                              child: ListTile(
                                title: Text(item['title'] ?? 'Cours'),
                                subtitle: Text(
                                  '${item['startsAt']} - ${item['endsAt']}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(item['audience'] ?? ''),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      tooltip: 'Supprimer',
                                      onPressed: () => _deleteSchedule(item),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}



