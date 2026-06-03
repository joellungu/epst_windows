import 'dart:convert';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ScormProgressionCoursPage extends StatefulWidget {
  final Map cours;

  const ScormProgressionCoursPage({Key? key, required this.cours})
      : super(key: key);

  @override
  State<ScormProgressionCoursPage> createState() =>
      _ScormProgressionCoursPageState();
}

class _ScormProgressionCoursPageState extends State<ScormProgressionCoursPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final courseId = '${widget.cours['id']}';
    final response = await http.get(
      Uri.parse('${Connexion.lien}scorm-progressions/course-details/$courseId'),
      headers: const {'Accept': 'application/json'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur serveur ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = '${widget.cours['cours'] ?? 'Cours SCORM'}';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Progression - $title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () => setState(() => _future = _load()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return const Center(
              child: Text('Aucune progression synchronisee pour ce cours.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final row = rows[index];
              final percent = _asDouble(row['progressPercent']).clamp(0, 100);
              final teacher = _firstText([
                row['nomComplet'],
                row['numeroIdentifiant'],
                row['cle'],
              ]);
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5EAF2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            teacher.isEmpty ? 'Enseignant' : teacher,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${percent.round()}%',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: percent / 100,
                        backgroundColor: const Color(0xFFE5EAF2),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(
                            Icons.flag_outlined,
                            _firstText(
                                [row['lessonStatus'], 'Statut inconnu'])),
                        if (_firstText([row['scoreRaw']]).isNotEmpty)
                          _chip(Icons.emoji_events_outlined,
                              'Score ${row['scoreRaw']}'),
                        if (_firstText([row['lessonLocation']]).isNotEmpty)
                          _chip(Icons.bookmark_border,
                              'Position ${row['lessonLocation']}'),
                        _chip(Icons.sync,
                            '${row['totalSynchronisations'] ?? 0} sync'),
                        if (_firstText([row['derniereSynchronisation']])
                            .isNotEmpty)
                          _chip(Icons.schedule,
                              '${row['derniereSynchronisation']}'),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
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

  String _firstText(List<Object?> values) {
    for (final value in values) {
      final text = '${value ?? ''}'.trim();
      if (text.isNotEmpty && text != 'null') return text;
    }
    return '';
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? '0'}') ?? 0;
  }
}
