import 'dart:convert';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScormProgressionProfesseursPage extends StatefulWidget {
  const ScormProgressionProfesseursPage({Key? key}) : super(key: key);

  @override
  State<ScormProgressionProfesseursPage> createState() =>
      _ScormProgressionProfesseursPageState();
}

class _ScormProgressionProfesseursPageState
    extends State<ScormProgressionProfesseursPage> {
  late Future<List<_TeacherProgress>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<_TeacherProgress>> _load() async {
    final responses = await Future.wait([
      http.get(
        Uri.parse('${Connexion.lien}scorm-progressions'),
        headers: const {'Accept': 'application/json'},
      ),
      http.get(
        Uri.parse('${Connexion.lien}agent/all'),
        headers: const {'Accept': 'application/json'},
      ),
    ]);

    final progressResponse = responses[0];
    if (progressResponse.statusCode != 200 &&
        progressResponse.statusCode != 201) {
      throw Exception('Erreur serveur ${progressResponse.statusCode}');
    }

    final agentsByKey = _agentsByKey(responses[1]);
    final decoded = jsonDecode(progressResponse.body);
    if (decoded is! List) return [];

    final groups = <String, _TeacherProgress>{};
    for (final item in decoded.whereType<Map>()) {
      final row = Map<String, dynamic>.from(item);
      final numeroIdentifiant = _firstText([
        row['numeroIdentifiant'],
        row['matricule'],
      ]);
      final cle = _firstText([row['cle'], numeroIdentifiant]);
      if (numeroIdentifiant.isEmpty && cle.isEmpty) continue;

      final teacherKey = '$numeroIdentifiant::$cle';
      final agent = agentsByKey[numeroIdentifiant] ?? agentsByKey[cle];
      final teacher = groups.putIfAbsent(
        teacherKey,
        () => _TeacherProgress(
          key: teacherKey,
          numeroIdentifiant: numeroIdentifiant,
          cle: cle,
          nomComplet: _teacherName(agent, numeroIdentifiant, cle),
        ),
      );

      teacher.totalSynchronisations++;
      final courseId = _firstText([row['courseId']]);
      if (courseId.isEmpty) continue;

      final courseKey = '$teacherKey::$courseId';
      final existing = teacher.coursesByKey[courseKey];
      if (existing == null ||
          _dateValue(row['synchronizedAt']).compareTo(
                _dateValue(existing.derniereSynchronisation),
              ) >
              0) {
        final latest = _CourseProgress.from(row);
        latest.totalSynchronisations = existing?.totalSynchronisations ?? 0;
        teacher.coursesByKey[courseKey] = latest;
      }
      teacher.coursesByKey[courseKey]!.totalSynchronisations++;
    }

    final teachers = groups.values.where((teacher) {
      return teacher.coursesByKey.isNotEmpty;
    }).toList();
    teachers.sort((a, b) {
      final sync = _dateValue(b.derniereSynchronisation).compareTo(
        _dateValue(a.derniereSynchronisation),
      );
      if (sync != 0) return sync;
      return a.nomComplet.toLowerCase().compareTo(b.nomComplet.toLowerCase());
    });
    return teachers;
  }

  Map<String, Map<String, dynamic>> _agentsByKey(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) return {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return {};
      final agents = <String, Map<String, dynamic>>{};
      for (final item in decoded.whereType<Map>()) {
        final agent = Map<String, dynamic>.from(item);
        for (final key in [
          agent['matricule'],
          agent['numeroIdentifiant'],
          agent['cle'],
          agent['id'],
        ]) {
          final text = _firstText([key]);
          if (text.isNotEmpty) agents[text] = agent;
        }
      }
      return agents;
    } catch (_) {
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FB),
      child: Column(
        children: [
          _header(),
          Expanded(
            child: FutureBuilder<List<_TeacherProgress>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                }

                final teachers = _filter(snapshot.data ?? []);
                if (teachers.isEmpty) {
                  return const Center(
                    child: Text('Aucune progression SCORM synchronisee.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  itemCount: teachers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return _teacherCard(teachers[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_outlined,
              color: Color(0xFF1D4ED8),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Progression des professeurs',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          SizedBox(
            width: 320,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un professeur ou un cours',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _teacherCard(_TeacherProgress teacher) {
    final percent = teacher.averagePercent.clamp(0, 100);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Row(
          children: [
            Expanded(
              child: Text(
                teacher.nomComplet,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${percent.round()}%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: percent / 100,
                  backgroundColor: const Color(0xFFE5EAF2),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(Icons.menu_book_outlined,
                      '${teacher.courses.length} cours lus'),
                  _chip(Icons.sync,
                      '${teacher.totalSynchronisations} synchronisations'),
                  if (teacher.numeroIdentifiant.isNotEmpty)
                    _chip(Icons.badge_outlined, teacher.numeroIdentifiant),
                  if (teacher.derniereSynchronisation.isNotEmpty)
                    _chip(Icons.schedule, teacher.derniereSynchronisation),
                ],
              ),
            ],
          ),
        ),
        children: teacher.courses.map(_courseTile).toList(),
      ),
    );
  }

  Widget _courseTile(_CourseProgress course) {
    final percent = course.progressPercent.clamp(0, 100);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text('${percent.round()}%'),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6,
              value: percent / 100,
              backgroundColor: const Color(0xFFE5EAF2),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.flag_outlined, course.status),
              if (course.score.isNotEmpty)
                _chip(Icons.emoji_events_outlined, 'Score ${course.score}'),
              if (course.lessonLocation.isNotEmpty)
                _chip(
                    Icons.bookmark_border, 'Position ${course.lessonLocation}'),
              _chip(Icons.sync, '${course.totalSynchronisations} sync'),
              if (course.derniereSynchronisation.isNotEmpty)
                _chip(Icons.schedule, course.derniereSynchronisation),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF475569)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  List<_TeacherProgress> _filter(List<_TeacherProgress> teachers) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return teachers;
    return teachers.where((teacher) {
      return teacher.nomComplet.toLowerCase().contains(query) ||
          teacher.numeroIdentifiant.toLowerCase().contains(query) ||
          teacher.courses.any(
            (course) => course.title.toLowerCase().contains(query),
          );
    }).toList();
  }
}

class _TeacherProgress {
  final String key;
  final String numeroIdentifiant;
  final String cle;
  final String nomComplet;
  final Map<String, _CourseProgress> coursesByKey = {};
  int totalSynchronisations = 0;

  _TeacherProgress({
    required this.key,
    required this.numeroIdentifiant,
    required this.cle,
    required this.nomComplet,
  });

  List<_CourseProgress> get courses {
    final list = coursesByKey.values.toList();
    list.sort((a, b) => _dateValue(b.derniereSynchronisation).compareTo(
          _dateValue(a.derniereSynchronisation),
        ));
    return list;
  }

  double get averagePercent {
    if (coursesByKey.isEmpty) return 0;
    final total = coursesByKey.values.fold<double>(
      0,
      (sum, course) => sum + course.progressPercent,
    );
    return total / coursesByKey.length;
  }

  String get derniereSynchronisation {
    if (coursesByKey.isEmpty) return '';
    return courses.first.derniereSynchronisation;
  }
}

class _CourseProgress {
  final String courseId;
  final String title;
  final String status;
  final double progressPercent;
  final String score;
  final String lessonLocation;
  int totalSynchronisations;
  final String derniereSynchronisation;

  _CourseProgress({
    required this.courseId,
    required this.title,
    required this.status,
    required this.progressPercent,
    required this.score,
    required this.lessonLocation,
    required this.totalSynchronisations,
    required this.derniereSynchronisation,
  });

  factory _CourseProgress.from(Map<String, dynamic> row) {
    final courseId = _firstText([row['courseId']]);
    return _CourseProgress(
      courseId: courseId,
      title: _firstText([row['courseTitle'], 'Cours $courseId']),
      status: _firstText([row['lessonStatus'], 'Statut inconnu']),
      progressPercent: _asDouble(row['progressPercent']),
      score: _firstText([row['scoreRaw']]),
      lessonLocation: _firstText([row['lessonLocation']]),
      totalSynchronisations: _asInt(row['totalSynchronisations']),
      derniereSynchronisation: _firstText([
        row['synchronizedAt'],
        row['derniereSynchronisation'],
      ]),
    );
  }
}

String _teacherName(
  Map<String, dynamic>? agent,
  String numeroIdentifiant,
  String cle,
) {
  if (agent != null) {
    final names = [
      _firstText([agent['nom']]),
      _firstText([agent['postnom']]),
      _firstText([agent['prenom']]),
    ].where((text) => text.isNotEmpty).join(' ');
    if (names.isNotEmpty) return names;
  }
  return _firstText([numeroIdentifiant, cle, 'Professeur']);
}

String _firstText(List<Object?> values) {
  for (final value in values) {
    final text = '${value ?? ''}'.trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  return '';
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? '0'}'.replaceAll(',', '.')) ?? 0;
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? '0'}') ?? 0;
}

DateTime _dateValue(Object? value) {
  return DateTime.tryParse(_firstText([value])) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
