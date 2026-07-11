import 'dart:convert';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const Map<String, List<String>> provincesEducationnellesRdc = {
  'Kinshasa': [
    'Kinshasa Funa',
    'Kinshasa Lukunga',
    'Kinshasa Mont-Amba',
    'Kinshasa Plateau',
    'Kinshasa Tshangu',
  ],
  'Kongo Central': [
    'Kongo Central 1',
    'Kongo Central 2',
    'Kongo Central 3',
  ],
  'Kwango': ['Kwango 1', 'Kwango 2'],
  'Kwilu': ['Kwilu 1', 'Kwilu 2', 'Kwilu 3'],
  'Mai-Ndombe': ['Mai-Ndombe 1', 'Mai-Ndombe 2', 'Mai-Ndombe 3'],
  'Equateur': ['Equateur 1', 'Equateur 2'],
  'Tshuapa': ['Tshuapa 1', 'Tshuapa 2'],
  'Mongala': ['Mongala 1', 'Mongala 2'],
  'Nord-Ubangi': ['Nord-Ubangi 1', 'Nord-Ubangi 2'],
  'Sud-Ubangi': ['Sud-Ubangi 1', 'Sud-Ubangi 2'],
  'Bas-Uele': ['Bas-Uele'],
  'Haut-Uele': ['Haut-Uele 1', 'Haut-Uele 2'],
  'Ituri': ['Ituri 1', 'Ituri 2', 'Ituri 3'],
  'Tshopo': ['Tshopo 1', 'Tshopo 2'],
  'Maniema': ['Maniema 1', 'Maniema 2'],
  'Nord-Kivu': ['Nord-Kivu 1', 'Nord-Kivu 2', 'Nord-Kivu 3'],
  'Sud-Kivu': ['Sud-Kivu 1', 'Sud-Kivu 2', 'Sud-Kivu 3'],
  'Tanganyika': ['Tanganyika 1', 'Tanganyika 2'],
  'Haut-Lomami': ['Haut-Lomami 1', 'Haut-Lomami 2'],
  'Lualaba': ['Lualaba 1', 'Lualaba 2'],
  'Haut-Katanga': ['Haut-Katanga 1', 'Haut-Katanga 2'],
  'Lomami': ['Lomami 1', 'Lomami 2'],
  'Sankuru': ['Sankuru 1', 'Sankuru 2'],
  'Kasai Oriental': ['Kasai Oriental 1', 'Kasai Oriental 2'],
  'Kasai Central': ['Kasai Central 1', 'Kasai Central 2'],
  'Kasai': ['Kasai 1', 'Kasai 2'],
};

class ScormProgressionProfesseursPage extends StatefulWidget {
  const ScormProgressionProfesseursPage({Key? key}) : super(key: key);

  @override
  State<ScormProgressionProfesseursPage> createState() =>
      _ScormProgressionProfesseursPageState();
}

class _ScormProgressionProfesseursPageState
    extends State<ScormProgressionProfesseursPage> {
  // Données chargées en une fois.
  late Future<void> _future;
  final Map<String, _TeacherProgress> _progressByNumero = {};
  final Map<String, _TeacherProgress> _progressByCle = {};
  List<Map<String, dynamic>> _allTeachers = [];
  List<Map<String, dynamic>> _schools = [];

  // Recherche / filtres écoles.
  final TextEditingController _searchSchoolController =
      TextEditingController();
  String _provinceFilter = '';
  String _educationProvinceFilter = '';
  String _subProvinceFilter = '';
  String _networkFilter = '';

  // Sélection.
  Map<String, dynamic>? _selectedSchool;
  String? _selectedTeacherKey;
  final TextEditingController _searchTeacherController =
      TextEditingController();
  String _teacherQuery = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchSchoolController.dispose();
    _searchTeacherController.dispose();
    super.dispose();
  }

  /// Charge en parallèle les progressions SCORM, la liste des enseignants
  /// et la liste des écoles. La jointure école -> enseignant -> progression
  /// se fait côté client.
  Future<void> _load() async {
    final responses = await Future.wait([
      http.get(
        Uri.parse('${Connexion.lien}scorm-progressions'),
        headers: const {'Accept': 'application/json'},
      ),
      http.get(
        Uri.parse('${Connexion.lien2}enseignant'),
        headers: const {'Accept': 'application/json'},
      ),
      http.get(
        Uri.parse('${Connexion.lien2}ecoleinfosservice'),
        headers: const {'Accept': 'application/json'},
      ),
    ]);

    final progressResponse = responses[0];
    if (progressResponse.statusCode != 200 &&
        progressResponse.statusCode != 201) {
      print('Erreur serveur ${progressResponse.statusCode}');
      print('Response body: ${progressResponse.body}');
      throw Exception('Erreur serveur ${progressResponse.statusCode}');
    }

    final agentsByKey = _agentsByKey(responses[1]);

    final decoded = jsonDecode(progressResponse.body);
    final groupsByKey = <String, _TeacherProgress>{};
    final progressByNumero = <String, _TeacherProgress>{};
    final progressByCle = <String, _TeacherProgress>{};
    if (decoded is List) {
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
        final teacher = groupsByKey.putIfAbsent(
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
    }

    // Index secondaires par numeroIdentifiant / cle pour lookup rapide.
    for (final teacher in groupsByKey.values) {
      if (teacher.numeroIdentifiant.isNotEmpty) {
        progressByNumero[teacher.numeroIdentifiant] = teacher;
      }
      if (teacher.cle.isNotEmpty) {
        progressByCle[teacher.cle] = teacher;
      }
    }

    // Enseignants.
    final teachers = <Map<String, dynamic>>[];
    try {
      final teacherDecoded = jsonDecode(responses[1].body);
      if (teacherDecoded is List) {
        for (final item in teacherDecoded.whereType<Map>()) {
          teachers.add(Map<String, dynamic>.from(item));
        }
      }
    } catch (_) {/* réponses enseignants optionnelles */}

    // Écoles.
    final schools = <Map<String, dynamic>>[];
    try {
      final schoolDecoded = jsonDecode(responses[2].body);
      if (schoolDecoded is List) {
        for (final item in schoolDecoded.whereType<Map>()) {
          schools.add(Map<String, dynamic>.from(item));
        }
      }
    } catch (_) {/* réponses écoles optionnelles */}

    if (!mounted) return;
    setState(() {
      _progressByNumero
        ..clear()
        ..addAll(progressByNumero);
      _progressByCle
        ..clear()
        ..addAll(progressByCle);
      _allTeachers = teachers;
      _schools = schools;
    });
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

  /// Progression d'un enseignant donné (lookup par numeroIdentifiant puis cle).
  _TeacherProgress? _progressFor(Map<String, dynamic> teacher) {
    final numero = _firstText([
      teacher['numeroIdentifiant'],
      teacher['matricule'],
    ]);
    final cle = _firstText([teacher['cle']]);
    return _progressByNumero[numero] ?? _progressByCle[cle];
  }

  List<Map<String, dynamic>> _teachersForSchool(String cleEcole) {
    return _allTeachers.where((teacher) {
      final teacherSchool = _firstText([
        teacher['cleEcole'],
        teacher['codeEcole'],
      ]);
      if (teacherSchool.isEmpty) return false;
      return _sameText(teacherSchool, cleEcole);
    }).toList()
      ..sort((a, b) {
        return _personName(a).toLowerCase().compareTo(
              _personName(b).toLowerCase(),
            );
      });
  }

  List<Map<String, dynamic>> _filteredTeachers(
      List<Map<String, dynamic>> teachers) {
    final query = _teacherQuery.trim().toLowerCase();
    if (query.isEmpty) return teachers;
    return teachers.where((teacher) {
      final haystack = [
        _personName(teacher),
        _firstText([teacher['numeroIdentifiant'], teacher['matricule']]),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _filteredSchools() {
    final query = _searchSchoolController.text.trim().toLowerCase();
    return _schools.where((school) {
      bool same(String filter, List<String> keys) {
        if (filter.isEmpty) return true;
        return _sameText(_label(school, keys), filter);
      }

      if (!same(_provinceFilter, ['province'])) return false;
      if (!same(_educationProvinceFilter, ['provinceEducationnelle'])) {
        return false;
      }
      if (!same(_subProvinceFilter, ['sousDevision', 'sousDivision'])) {
        return false;
      }
      if (!same(_networkFilter, ['reseau', 'réseau'])) return false;
      if (query.isEmpty) return true;

      final haystack = [
        _label(school, ['nomEcole', 'nom']),
        _label(school, ['cle', 'cleEcole']),
        _label(school, ['province']),
        _label(school, ['provinceEducationnelle']),
        _label(school, ['sousDevision', 'sousDivision']),
        _label(school, ['reseau', 'réseau']),
        _label(school, ['ville']),
        _label(school, ['commune']),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _EmptyState(
              icon: Icons.cloud_off,
              text: "Chargement impossible: ${snapshot.error}",
            );
          }
          return Row(
            children: [
              SizedBox(width: 360, child: _buildSchoolsPane()),
              const VerticalDivider(width: 1),
              Expanded(child: _buildDetailsPane()),
            ],
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Panneau gauche : liste filtrée des écoles.
  // --------------------------------------------------------------------------
  Widget _buildSchoolsPane() {
    return Container(
      color: const Color(0xFFF7F9FC),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Progression des professeurs',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Actualiser',
                  onPressed: () => setState(() => _future = _load()),
                  icon: const Icon(Icons.refresh, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchSchoolController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Rechercher une ecole",
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          _SchoolFilters(
            schools: _schools,
            province: _provinceFilter,
            educationProvince: _educationProvinceFilter,
            subProvince: _subProvinceFilter,
            network: _networkFilter,
            onProvinceChanged: (value) =>
                setState(() => _provinceFilter = value),
            onEducationProvinceChanged: (value) =>
                setState(() => _educationProvinceFilter = value),
            onSubProvinceChanged: (value) =>
                setState(() => _subProvinceFilter = value),
            onNetworkChanged: (value) => setState(() => _networkFilter = value),
            onReset: () {
              setState(() {
                _provinceFilter = '';
                _educationProvinceFilter = '';
                _subProvinceFilter = '';
                _networkFilter = '';
                _searchSchoolController.clear();
              });
            },
          ),
          Expanded(
            child: _buildSchoolsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolsList() {
    final filtered = _filteredSchools();
    if (filtered.isEmpty) {
      return const _EmptyState(
        icon: Icons.school_outlined,
        text: "Aucune ecole trouvee.",
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final school = filtered[index];
        final selected = identical(school, _selectedSchool);
        return Material(
          color: selected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: ListTile(
            selected: selected,
            leading: CircleAvatar(
              backgroundColor: selected
                  ? Colors.blue.shade700
                  : Colors.green.shade700,
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            title: Text(
              _schoolName(school),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              _schoolSubtitle(school),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _selectSchool(school),
          ),
        );
      },
    );
  }

  void _selectSchool(Map<String, dynamic> school) {
    setState(() {
      _selectedSchool = school;
      _selectedTeacherKey = null;
      _teacherQuery = '';
      _searchTeacherController.clear();
    });
  }

  // --------------------------------------------------------------------------
  // Panneau droit : enseignants de l'école, puis progression d'un enseignant.
  // --------------------------------------------------------------------------
  Widget _buildDetailsPane() {
    final school = _selectedSchool;
    if (school == null) {
      return const _EmptyState(
        icon: Icons.touch_app_outlined,
        text: "Selectionnez une ecole pour voir ses enseignants et leur "
            "progression SCORM.",
      );
    }

    // Un enseignant est sélectionné : on affiche sa progression détaillée.
    if (_selectedTeacherKey != null) {
      return _buildTeacherProgressPane(school);
    }

    return _buildTeachersPane(school);
  }

  Widget _buildTeachersPane(Map<String, dynamic> school) {
    final cleEcole = _schoolKey(school);
    final teachers = _filteredTeachers(_teachersForSchool(cleEcole));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _schoolName(school),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _schoolSubtitle(school),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchTeacherController,
                onChanged: (value) => setState(() => _teacherQuery = value),
                decoration: InputDecoration(
                  hintText: 'Rechercher un enseignant',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF7F9FC),
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
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: teachers.isEmpty
              ? const _EmptyState(
                  icon: Icons.person_off_outlined,
                  text: "Aucun enseignant trouve pour cette ecole.",
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: teachers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _teacherListTile(teachers[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _teacherListTile(Map<String, dynamic> teacher) {
    final progress = _progressFor(teacher);
    final name = _personName(teacher);
    final matricule = _firstText([
      teacher['numeroIdentifiant'],
      teacher['matricule'],
    ]);
    final hasProgress = progress != null && progress.coursesByKey.isNotEmpty;
    final percent = progress?.averagePercent ?? 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _selectedTeacherKey =
            '${progress?.key ?? matricule}::${name.isEmpty ? matricule : name}'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5EAF2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: hasProgress
                    ? Colors.blue.shade700
                    : Colors.blueGrey.shade200,
                child: Icon(
                  hasProgress
                      ? Icons.person_pin
                      : Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty
                          ? (matricule.isEmpty
                              ? 'Enseignant'
                              : 'Enseignant $matricule')
                          : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (matricule.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          matricule,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (hasProgress) ...[
                _chip(
                    Icons.menu_book_outlined, '${progress.courses.length} cours'),
                const SizedBox(width: 6),
                _percentBadge(percent),
              ] else
                _chip(Icons.hourglass_empty, 'Aucune progression'),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Color(0xFF475569)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _percentBadge(double percent) {
    final clamped = percent.clamp(0, 100);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF1D4ED8).withAlpha(50)),
      ),
      child: Text(
        '${clamped.round()}%',
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildTeacherProgressPane(Map<String, dynamic> school) {
    // On retrouve l'enseignant sélectionné à partir de sa clef construite
    // (cf. _teacherListTile). On regénère la liste et on cherche.
    final cleEcole = _schoolKey(school);
    final teachers = _teachersForSchool(cleEcole);
    Map<String, dynamic>? selectedTeacher;
    _TeacherProgress? progress;

    for (final teacher in teachers) {
      final numero = _firstText([
        teacher['numeroIdentifiant'],
        teacher['matricule'],
      ]);
      final name = _personName(teacher);
      final candidateProgress = _progressFor(teacher);
      final candidateKey =
          '${candidateProgress?.key ?? numero}::${name.isEmpty ? numero : name}';
      if (candidateKey == _selectedTeacherKey) {
        selectedTeacher = teacher;
        progress = candidateProgress;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Retour a la liste',
                onPressed: () => setState(() => _selectedTeacherKey = null),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _personName(selectedTeacher ?? {}).isEmpty
                          ? 'Enseignant'
                          : _personName(selectedTeacher!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _schoolName(school),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedTeacher != null &&
                  _firstText([
                    selectedTeacher['numeroIdentifiant'],
                    selectedTeacher['matricule'],
                  ]).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _chip(
                    Icons.badge_outlined,
                    _firstText([
                      selectedTeacher['numeroIdentifiant'],
                      selectedTeacher['matricule'],
                    ]),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: progress == null || progress.coursesByKey.isEmpty
              ? const _EmptyState(
                  icon: Icons.analytics_outlined,
                  text: "Aucune progression SCORM synchronisee pour cet "
                      "enseignant.",
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  children: [_teacherCard(progress)],
                ),
        ),
      ],
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
        initiallyExpanded: true,
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
}

// =============================================================================
// Modèles de progression (inchangés par rapport à la version d'origine).
// =============================================================================
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

// =============================================================================
// Widgets réutilisables (panneau filtres écoles, état vide).
// =============================================================================
class _SchoolFilters extends StatelessWidget {
  const _SchoolFilters({
    required this.schools,
    required this.province,
    required this.educationProvince,
    required this.subProvince,
    required this.network,
    required this.onProvinceChanged,
    required this.onEducationProvinceChanged,
    required this.onSubProvinceChanged,
    required this.onNetworkChanged,
    required this.onReset,
  });

  final List<Map<String, dynamic>> schools;
  final String province;
  final String educationProvince;
  final String subProvince;
  final String network;
  final ValueChanged<String> onProvinceChanged;
  final ValueChanged<String> onEducationProvinceChanged;
  final ValueChanged<String> onSubProvinceChanged;
  final ValueChanged<String> onNetworkChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final provinces = _mergeFilterValues(
      provincesEducationnellesRdc.keys.toList(),
      _filterValues(schools, ['province']),
    );
    final educationProvinces = province.isEmpty
        ? _mergeFilterValues(
            provincesEducationnellesRdc.values
                .expand((items) => items)
                .toList(),
            _filterValues(schools, ['provinceEducationnelle']),
          )
        : _mergeFilterValues(
            provincesEducationnellesRdc[_canonicalProvince(province)] ??
                const [],
            _filterValues(
              schools
                  .where((school) =>
                      _sameText(_label(school, ['province']), province))
                  .toList(),
              ['provinceEducationnelle'],
            ),
          );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          _FilterDropdown(
            label: "Province",
            value: province,
            values: provinces,
            onChanged: onProvinceChanged,
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            label: "Province educationnelle",
            value: educationProvince,
            values: educationProvinces,
            onChanged: onEducationProvinceChanged,
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            label: "Sous-province educationnelle",
            value: subProvince,
            values: _filterValues(schools, ['sousDevision', 'sousDivision']),
            onChanged: onSubProvinceChanged,
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            label: "Reseau d'ecoles",
            value: network,
            values: _filterValues(schools, ['reseau', 'réseau']),
            onChanged: onNetworkChanged,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.filter_alt_off, size: 18),
              label: const Text("Reinitialiser"),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = ['', ...values];
    final currentValue = items.contains(value) ? value : '';
    return DropdownButtonFormField<String>(
      initialValue: currentValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item.isEmpty ? "Toutes" : item,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) => onChanged(value ?? ''),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Helpers partagés (labels école, normalisation, filtres).
// =============================================================================
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

String _personName(Map<String, dynamic> item) {
  return [
    _firstText([item['nom']]),
    _firstText([item['postnom']]),
    _firstText([item['prenom']]),
  ].where((part) => part.isNotEmpty).join(' ');
}

String _schoolName(Map<String, dynamic> school) {
  final name = _label(school, ['nomEcole', 'nom', 'name']);
  return name.isEmpty ? "Ecole sans nom" : name;
}

String _schoolKey(Map<String, dynamic> school) {
  return _label(school, ['cle', 'cleEcole', 'id']);
}

String _schoolSubtitle(Map<String, dynamic> school) {
  final parts = [
    _label(school, ['province']),
    _label(school, ['provinceEducationnelle']),
    _label(school, ['ville']),
    _label(school, ['commune']),
  ].where((item) => item.isNotEmpty).toList();
  if (parts.isEmpty) return _schoolKey(school);
  return parts.join(' | ');
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

String _label(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final text = _firstText([map[key]]);
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _normalize(String value) {
  return value
      .toLowerCase()
      .replaceAll('à', 'a')
      .replaceAll('â', 'a')
      .replaceAll('è', 'e')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('ë', 'e')
      .replaceAll('ï', 'i')
      .replaceAll('î', 'i')
      .replaceAll('ô', 'o')
      .replaceAll('ù', 'u')
      .replaceAll('û', 'u')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll('-', ' ')
      .trim();
}

bool _sameText(String a, String b) => _normalize(a) == _normalize(b);

String _canonicalProvince(String value) {
  for (final key in provincesEducationnellesRdc.keys) {
    if (_sameText(key, value)) return key;
  }
  return value;
}

List<String> _filterValues(
    List<Map<String, dynamic>> schools, List<String> keys) {
  final seen = <String>{};
  final values = <String>[];
  for (final school in schools) {
    final value = _label(school, keys);
    if (value.isEmpty) continue;
    if (seen.add(value)) values.add(value);
  }
  values.sort();
  return values;
}

List<String> _mergeFilterValues(List<String> base, List<String> extra) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in [...base, ...extra]) {
    if (value.isEmpty) continue;
    if (seen.add(value)) result.add(value);
  }
  return result;
}
