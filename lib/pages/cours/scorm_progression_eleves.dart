import 'dart:convert';

import 'package:epst_windows_app/utils/connexion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'scorm_progression_professeurs.dart'
    show provincesEducationnellesRdc;

/// Progression SCORM des élèves (fichiers SCORM lus dans l'app élève).
///
/// Même principe que [ScormProgressionProfesseursPage] mais jointure sur
/// les élèves Smart-Kelasi (GET {lien2}eleve) :
/// numeroIdentifiant (ID Smart-Kelasi) -> progression SCORM.
/// Les IDs élèves viennent de Smart-Kelasi, comme les enseignants.
class ScormProgressionElevesPage extends StatefulWidget {
  const ScormProgressionElevesPage({Key? key}) : super(key: key);

  @override
  State<ScormProgressionElevesPage> createState() =>
      _ScormProgressionElevesPageState();
}

class _ScormProgressionElevesPageState
    extends State<ScormProgressionElevesPage> {
  late Future<void> _future;
  final Map<String, _EleveProgress> _progressByNumero = {};
  final Map<String, _EleveProgress> _progressByCle = {};
  List<Map<String, dynamic>> _allEleves = [];
  List<Map<String, dynamic>> _schools = [];

  final TextEditingController _searchSchoolController =
      TextEditingController();
  String _provinceFilter = '';
  String _educationProvinceFilter = '';
  String _subProvinceFilter = '';
  String _networkFilter = '';

  Map<String, dynamic>? _selectedSchool;
  String? _selectedEleveKey;
  final TextEditingController _searchEleveController = TextEditingController();
  String _eleveQuery = '';
  String _classeFilter = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchSchoolController.dispose();
    _searchEleveController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final responses = await Future.wait([
      http.get(
        Uri.parse('${Connexion.lien}scorm-progressions'),
        headers: const {'Accept': 'application/json'},
      ),
      http.get(
        Uri.parse('${Connexion.lien2}eleve'),
        headers: const {'Accept': 'application/json'},
      ),
      http.get(
        Uri.parse('${Connexion.lien2}ecoleinfosservice'),
        headers: const {'Accept': 'application/json'},
      ),
    ]);

    final progressResponse = responses[0];
    if (responses[1].statusCode != 200 || responses[2].statusCode != 200) {
      throw Exception('Le service scolaire est indisponible. Réessayez pour charger les élèves et les écoles.');
    }
    if (progressResponse.statusCode != 200 &&
        progressResponse.statusCode != 201) {
      throw Exception('Erreur serveur ${progressResponse.statusCode}');
    }

    final elevesByKey = _agentsByKey(responses[1]);

    final decoded = jsonDecode(progressResponse.body);
    final groupsByKey = <String, _EleveProgress>{};
    final progressByNumero = <String, _EleveProgress>{};
    final progressByCle = <String, _EleveProgress>{};
    if (decoded is List) {
      for (final item in decoded.whereType<Map>()) {
        final row = Map<String, dynamic>.from(item);
        final numeroIdentifiant = _firstText([
          row['numeroIdentifiant'],
          row['matricule'],
        ]);
        final cle = _firstText([row['cle'], numeroIdentifiant]);
        if (numeroIdentifiant.isEmpty && cle.isEmpty) continue;

        final key = '$numeroIdentifiant::$cle';
        final eleve = elevesByKey[cle] ?? elevesByKey[numeroIdentifiant];
        // The shared SCORM table also contains teacher records.
        if (eleve == null) continue;
        final group = groupsByKey.putIfAbsent(
          key,
          () => _EleveProgress(
            key: key,
            numeroIdentifiant: numeroIdentifiant,
            cle: cle,
            nomComplet: _eleveName(eleve, numeroIdentifiant, cle),
            classe: _firstText([eleve['classe'], row['classe']]),
            cleEcole:
                _firstText([eleve['cleEcole'], eleve['codeEcole']]),
          ),
        );

        group.totalSynchronisations++;
        final courseId = _firstText([row['courseId']]);
        if (courseId.isEmpty) continue;

        final courseKey = '$key::$courseId';
        final existing = group.coursesByKey[courseKey];
        if (existing == null ||
            _dateValue(row['clientCreatedAt'] ?? row['synchronizedAt']).compareTo(
                  _dateValue(existing.derniereSynchronisation),
                ) >
                0) {
          final latest = _CourseProgress.from(row);
          latest.totalSynchronisations = existing?.totalSynchronisations ?? 0;
          group.coursesByKey[courseKey] = latest;
        }
        group.coursesByKey[courseKey]!.totalSynchronisations++;
      }
    }

    for (final group in groupsByKey.values) {
      if (group.numeroIdentifiant.isNotEmpty) {
        progressByNumero[group.numeroIdentifiant] = group;
      }
      if (group.cle.isNotEmpty) {
        progressByCle[group.cle] = group;
      }
    }

    final eleves = <Map<String, dynamic>>[];
    try {
      final decodedEleves = jsonDecode(responses[1].body);
      if (decodedEleves is List) {
        for (final item in decodedEleves.whereType<Map>()) {
          eleves.add(Map<String, dynamic>.from(item));
        }
      }
    } catch (_) {}

    final schools = <Map<String, dynamic>>[];
    try {
      final decodedSchools = jsonDecode(responses[2].body);
      if (decodedSchools is List) {
        for (final item in decodedSchools.whereType<Map>()) {
          schools.add(Map<String, dynamic>.from(item));
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _progressByNumero
        ..clear()
        ..addAll(progressByNumero);
      _progressByCle
        ..clear()
        ..addAll(progressByCle);
      _allEleves = eleves;
      _schools = schools;
    });
  }

  Map<String, Map<String, dynamic>> _agentsByKey(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) return {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return {};
      final map = <String, Map<String, dynamic>>{};
      for (final item in decoded.whereType<Map>()) {
        final agent = Map<String, dynamic>.from(item);
        for (final key in [
          agent['matricule'],
          agent['numeroIdentifiant'],
          agent['cle'],
          agent['id'],
        ]) {
          final text = _firstText([key]);
          if (text.isNotEmpty) map[text] = agent;
        }
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  _EleveProgress? _progressFor(Map<String, dynamic> eleve) {
    final numero = _firstText([
      eleve['numeroIdentifiant'],
      eleve['matricule'],
    ]);
    final cle = _firstText([eleve['cle']]);
    return _progressByCle[cle] ?? _progressByNumero[numero];
  }

  List<Map<String, dynamic>> _elevesForSchool(String cleEcole) {
    return _allEleves.where((eleve) {
      final school = _firstText([
        eleve['cleEcole'],
        eleve['codeEcole'],
      ]);
      if (school.isEmpty) return false;
      return _sameText(school, cleEcole);
    }).toList()
      ..sort((a, b) => _personName(a)
          .toLowerCase()
          .compareTo(_personName(b).toLowerCase()));
  }

  List<Map<String, dynamic>> _filteredEleves(
      List<Map<String, dynamic>> eleves) {
    final query = _eleveQuery.trim().toLowerCase();
    return eleves.where((eleve) {
      if (_classeFilter.isNotEmpty) {
        if (!_sameText(
            _firstText([eleve['classe']]), _classeFilter)) {
          return false;
        }
      }
      if (query.isEmpty) return true;
      final haystack = [
        _personName(eleve),
        _firstText([eleve['numeroIdentifiant'], eleve['matricule']]),
        _firstText([eleve['classe']]),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  List<String> _classesForSchool(String cleEcole) {
    final seen = <String>{};
    final values = <String>[];
    for (final eleve in _elevesForSchool(cleEcole)) {
      final classe = _firstText([eleve['classe']]);
      if (classe.isEmpty || !seen.add(classe)) continue;
      values.add(classe);
    }
    values.sort();
    return values;
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
        _label(school, ['ville']),
        _label(school, ['commune']),
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Chargement impossible: ${snapshot.error}'));
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
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.school_outlined,
                      color: Color(0xFF15803D)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progression des eleves',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      Text('Fichiers SCORM - IDs Smart-Kelasi',
                          style:
                              TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
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
                hintText: 'Rechercher une ecole',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          _EleveSchoolFilters(
            schools: _schools,
            province: _provinceFilter,
            educationProvince: _educationProvinceFilter,
            subProvince: _subProvinceFilter,
            network: _networkFilter,
            onProvinceChanged: (v) =>
                setState(() => _provinceFilter = v),
            onEducationProvinceChanged: (v) =>
                setState(() => _educationProvinceFilter = v),
            onSubProvinceChanged: (v) =>
                setState(() => _subProvinceFilter = v),
            onNetworkChanged: (v) =>
                setState(() => _networkFilter = v),
            onReset: () => setState(() {
              _provinceFilter = '';
              _educationProvinceFilter = '';
              _subProvinceFilter = '';
              _networkFilter = '';
              _searchSchoolController.clear();
            }),
          ),
          Expanded(child: _buildSchoolsList()),
        ],
      ),
    );
  }

  Widget _buildSchoolsList() {
    final filtered = _filteredSchools();
    if (filtered.isEmpty) {
      return const Center(child: Text('Aucune ecole trouvee.'));
    }
    // Stats globales.
    final totalEleves = _allEleves.length;
    final avecProgression = _progressByNumero.length;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5EAF2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat('$totalEleves', 'eleves'),
                _miniStat('$avecProgression', 'avec progression'),
                _miniStat('${_schools.length}', 'ecoles'),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final school = filtered[index];
              final selected = identical(school, _selectedSchool);
              return Material(
                color: selected ? Colors.green.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(8),
                child: ListTile(
                  selected: selected,
                  leading: CircleAvatar(
                    backgroundColor: selected
                        ? Colors.green.shade700
                        : Colors.teal.shade700,
                    child: const Icon(Icons.school,
                        color: Colors.white, size: 20),
                  ),
                  title: Text(_schoolName(school),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(_schoolSubtitle(school),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => setState(() {
                    _selectedSchool = school;
                    _selectedEleveKey = null;
                    _eleveQuery = '';
                    _classeFilter = '';
                    _searchEleveController.clear();
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
      ],
    );
  }

  Widget _buildDetailsPane() {
    final school = _selectedSchool;
    if (school == null) {
      return const Center(
        child: Text(
          'Selectionnez une ecole pour voir ses eleves et leur progression SCORM.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_selectedEleveKey != null) {
      return _buildEleveProgressPane(school);
    }
    return _buildElevesPane(school);
  }

  Widget _buildElevesPane(Map<String, dynamic> school) {
    final cleEcole = _schoolKey(school);
    final allForSchool = _elevesForSchool(cleEcole);
    final classes = _classesForSchool(cleEcole);
    final eleves = _filteredEleves(allForSchool);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_schoolName(school),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                  '${allForSchool.length} eleves - ${_schoolSubtitle(school)}',
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchEleveController,
                      onChanged: (v) =>
                          setState(() => _eleveQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un eleve (nom ou ID)',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF7F9FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5EAF2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5EAF2)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _classeFilter.isEmpty ? null : _classeFilter,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Classe',
                        filled: true,
                        fillColor: const Color(0xFFF7F9FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5EAF2)),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: '', child: Text('Toutes les classes')),
                        ...classes.map((c) => DropdownMenuItem(
                            value: c, child: Text(c,
                                overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) =>
                          setState(() => _classeFilter = v ?? ''),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: eleves.isEmpty
              ? const Center(
                  child: Text('Aucun eleve trouve pour cette ecole.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: eleves.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _eleveListTile(eleves[index]),
                ),
        ),
      ],
    );
  }

  Widget _eleveListTile(Map<String, dynamic> eleve) {
    final progress = _progressFor(eleve);
    final name = _personName(eleve);
    final matricule = _firstText([
      eleve['numeroIdentifiant'],
      eleve['matricule'],
    ]);
    final classe = _firstText([eleve['classe']]);
    final hasProgress = progress != null && progress.coursesByKey.isNotEmpty;
    final percent = progress?.averagePercent ?? 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _selectedEleveKey =
            '${progress?.key ?? matricule}::${name.isEmpty ? matricule : name}'),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5EAF2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: hasProgress
                    ? Colors.green.shade700
                    : Colors.blueGrey.shade200,
                child: Icon(
                    hasProgress ? Icons.school : Icons.person_outline,
                    color: Colors.white,
                    size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        name.isEmpty
                            ? (matricule.isEmpty
                                ? 'Eleve'
                                : 'Eleve $matricule')
                            : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800)),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        [
                          if (matricule.isNotEmpty) matricule,
                          if (classe.isNotEmpty) classe,
                        ].join(' - '),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ),
                    if (hasProgress) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: (percent / 100).clamp(0.0, 1.0),
                          backgroundColor: const Color(0xFFE5EAF2),
                          valueColor:
                              const AlwaysStoppedAnimation(
                                  Color(0xFF15803D)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasProgress) ...[
                _chip(Icons.menu_book_outlined,
                    '${progress.courses.length} cours'),
                const SizedBox(width: 6),
                _percentBadge(percent),
              ] else
                _chip(Icons.hourglass_empty, 'Aucune progression'),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: Color(0xFF475569)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _percentBadge(double percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF15803D).withAlpha(60)),
      ),
      child: Text('${percent.clamp(0, 100).round()}%',
          style: const TextStyle(
              color: Color(0xFF15803D), fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildEleveProgressPane(Map<String, dynamic> school) {
    final cleEcole = _schoolKey(school);
    final eleves = _elevesForSchool(cleEcole);
    Map<String, dynamic>? selected;
    _EleveProgress? progress;
    for (final eleve in eleves) {
      final numero = _firstText([
        eleve['numeroIdentifiant'],
        eleve['matricule'],
      ]);
      final name = _personName(eleve);
      final candidate = _progressFor(eleve);
      final candidateKey =
          '${candidate?.key ?? numero}::${name.isEmpty ? numero : name}';
      if (candidateKey == _selectedEleveKey) {
        selected = eleve;
        progress = candidate;
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
                onPressed: () =>
                    setState(() => _selectedEleveKey = null),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        _personName(selected ?? {}).isEmpty
                            ? 'Eleve'
                            : _personName(selected!),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    Text(_schoolName(school),
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12)),
                  ],
                ),
              ),
              if (selected != null)
                _chip(Icons.badge_outlined,
                    _firstText([
                      selected['numeroIdentifiant'],
                      selected['matricule']
                    ])),
              if (selected != null &&
                  _firstText([selected['classe']]).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _chip(Icons.class_outlined,
                      _firstText([selected['classe']])),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: progress == null || progress.coursesByKey.isEmpty
              ? const Center(
                  child: Text(
                      'Aucune progression SCORM synchronisee pour cet eleve.'))
              : ListView(
                  padding:
                      const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  children: [_eleveCard(progress)],
                ),
        ),
      ],
    );
  }

  Widget _eleveCard(_EleveProgress eleve) {
    final percent = eleve.averagePercent.clamp(0, 100);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Row(
          children: [
            Expanded(
              child: Text(eleve.nomComplet,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontWeight: FontWeight.w800)),
            ),
            Text('${percent.round()}%',
                style:
                    const TextStyle(fontWeight: FontWeight.w900)),
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
                  valueColor: const AlwaysStoppedAnimation(
                      Color(0xFF15803D)),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(Icons.menu_book_outlined,
                      '${eleve.courses.length} cours lus'),
                  _chip(Icons.sync,
                      '${eleve.totalSynchronisations} synchronisations'),
                  if (eleve.numeroIdentifiant.isNotEmpty)
                    _chip(Icons.badge_outlined,
                        eleve.numeroIdentifiant),
                  if (eleve.classe.isNotEmpty)
                    _chip(Icons.class_outlined, eleve.classe),
                  if (eleve.derniereSynchronisation.isNotEmpty)
                    _chip(Icons.schedule,
                        eleve.derniereSynchronisation),
                ],
              ),
            ],
          ),
        ),
        children: eleve.courses.map(_courseTile).toList(),
      ),
    );
  }

  Widget _courseTile(_CourseProgress course) {
    final percent = course.progressPercent.clamp(0, 100);
    final termine = percent >= 100;
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
              Icon(
                  termine
                      ? Icons.check_circle
                      : Icons.play_circle_outline,
                  color: termine
                      ? Colors.green.shade700
                      : const Color(0xFF1D4ED8),
                  size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(course.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800)),
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
              valueColor: AlwaysStoppedAnimation(termine
                  ? Colors.green.shade700
                  : const Color(0xFF1D4ED8)),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(Icons.flag_outlined, course.status),
              if (course.score.isNotEmpty)
                _chip(Icons.emoji_events_outlined,
                    'Score ${course.score}'),
              if (course.lessonLocation.isNotEmpty)
                _chip(Icons.bookmark_border,
                    'Position ${course.lessonLocation}'),
              _chip(Icons.sync,
                  '${course.totalSynchronisations} sync'),
              if (course.derniereSynchronisation.isNotEmpty)
                _chip(Icons.schedule,
                    course.derniereSynchronisation),
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

class _EleveProgress {
  final String key;
  final String numeroIdentifiant;
  final String cle;
  final String nomComplet;
  final String classe;
  final String cleEcole;
  final Map<String, _CourseProgress> coursesByKey = {};
  int totalSynchronisations = 0;

  _EleveProgress({
    required this.key,
    required this.numeroIdentifiant,
    required this.cle,
    required this.nomComplet,
    required this.classe,
    required this.cleEcole,
  });

  List<_CourseProgress> get courses {
    final list = coursesByKey.values.toList();
    list.sort((a, b) => _dateValue(b.derniereSynchronisation)
        .compareTo(_dateValue(a.derniereSynchronisation)));
    return list;
  }

  double get averagePercent {
    if (coursesByKey.isEmpty) return 0;
    final total = coursesByKey.values
        .fold<double>(0, (sum, c) => sum + c.progressPercent);
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
        row['clientCreatedAt'],
        row['synchronizedAt'],
        row['derniereSynchronisation'],
      ]),
    );
  }
}

class _EleveSchoolFilters extends StatelessWidget {
  const _EleveSchoolFilters({
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          _FilterDropdown(
              label: 'Province',
              value: province,
              values: provinces,
              onChanged: onProvinceChanged),
          const SizedBox(height: 8),
          _FilterDropdown(
              label: 'Province educationnelle',
              value: educationProvince,
              values: _filterValues(
                  schools, ['provinceEducationnelle']),
              onChanged: onEducationProvinceChanged),
          const SizedBox(height: 8),
          _FilterDropdown(
              label: 'Sous-province',
              value: subProvince,
              values: _filterValues(
                  schools, ['sousDevision', 'sousDivision']),
              onChanged: onSubProvinceChanged),
          const SizedBox(height: 8),
          _FilterDropdown(
              label: "Reseau d'ecoles",
              value: network,
              values:
                  _filterValues(schools, ['reseau', 'réseau']),
              onChanged: onNetworkChanged),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.filter_alt_off, size: 18),
              label: const Text('Reinitialiser'),
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
    final current = items.contains(value) ? value : '';
    return DropdownButtonFormField<String>(
      initialValue: current,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item.isEmpty ? 'Toutes' : item,
                    overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (v) => onChanged(v ?? ''),
    );
  }
}

String _eleveName(
    Map<String, dynamic>? eleve, String numero, String cle) {
  if (eleve != null) {
    final names = [
      _firstText([eleve['nom']]),
      _firstText([eleve['postnom']]),
      _firstText([eleve['prenom']]),
    ].where((t) => t.isNotEmpty).join(' ');
    if (names.isNotEmpty) return names;
  }
  return _firstText([numero, cle, 'Eleve']);
}

String _personName(Map<String, dynamic> item) {
  return [
    _firstText([item['nom']]),
    _firstText([item['postnom']]),
    _firstText([item['prenom']]),
  ].where((p) => p.isNotEmpty).join(' ');
}

String _schoolName(Map<String, dynamic> school) {
  final name = _label(school, ['nomEcole', 'nom', 'name']);
  return name.isEmpty ? 'Ecole sans nom' : name;
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
  ].where((i) => i.isNotEmpty).toList();
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

List<String> _filterValues(
    List<Map<String, dynamic>> schools, List<String> keys) {
  final seen = <String>{};
  final values = <String>[];
  for (final school in schools) {
    final value = _label(school, keys);
    if (value.isEmpty || !seen.add(value)) continue;
    values.add(value);
  }
  values.sort();
  return values;
}

List<String> _mergeFilterValues(List<String> base, List<String> extra) {
  final seen = <String>{};
  final result = <String>[];
  for (final value in [...base, ...extra]) {
    if (value.isEmpty || !seen.add(value)) continue;
    result.add(value);
  }
  return result;
}
