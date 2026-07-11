import 'dart:convert';

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

class SmartKelasiSchoolsPage extends StatefulWidget {
  const SmartKelasiSchoolsPage({Key? key}) : super(key: key);

  @override
  State<SmartKelasiSchoolsPage> createState() => _SmartKelasiSchoolsPageState();
}

class _SmartKelasiSchoolsPageState extends State<SmartKelasiSchoolsPage> {
  final _api = _SmartKelasiApi();
  final _searchController = TextEditingController();

  late Future<List<Map<String, dynamic>>> _schoolsFuture;
  List<Map<String, dynamic>> _schools = [];
  String _provinceFilter = '';
  String _educationProvinceFilter = '';
  String _subProvinceFilter = '';
  String _networkFilter = '';
  Map<String, dynamic>? _selectedSchool;
  List<Map<String, dynamic>> _years = [];
  String? _selectedYear;
  _SchoolDashboard? _dashboard;
  bool _loadingYears = false;
  bool _loadingDashboard = false;
  int _dashboardRequestId = 0;
  Set<String> _dashboardLoadingCategories = {};
  String? _message;

  @override
  void initState() {
    super.initState();
    _schoolsFuture = _loadSchools();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadSchools() async {
    final schools = await _api.getSchools();
    _schools = schools;
    return schools;
  }

  Future<void> _selectSchool(Map<String, dynamic> school) async {
    _dashboardRequestId++;
    setState(() {
      _selectedSchool = school;
      _selectedYear = null;
      _years = [];
      _dashboard = null;
      _dashboardLoadingCategories = {};
      _message = null;
      _loadingYears = true;
    });

    try {
      final cle = _schoolKey(school);
      final years = await _api.getYears(cle);
      if (!mounted) return;
      setState(() {
        _years = years;
        _loadingYears = false;
        if (years.isEmpty) {
          _message = "Aucune annee scolaire trouvee pour cette ecole.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingYears = false;
        _message = "Impossible de charger les annees: $e";
      });
    }
  }

  Future<void> _selectYear(String year) async {
    final school = _selectedSchool;
    if (school == null) return;
    final requestId = ++_dashboardRequestId;

    setState(() {
      _selectedYear = year;
      _dashboard = null;
      _dashboardLoadingCategories = {};
      _message = null;
      _loadingDashboard = true;
    });

    try {
      final dashboard = await _api.getDashboard(
        cleEcole: _schoolKey(school),
        anneescolaire: year,
        onProgress: (partialDashboard, loadingCategories) {
          if (!mounted || requestId != _dashboardRequestId) return;
          setState(() {
            _dashboard = partialDashboard;
            _dashboardLoadingCategories = loadingCategories;
            _loadingDashboard = true;
          });
        },
      );
      if (!mounted || requestId != _dashboardRequestId) return;
      setState(() {
        _dashboard = dashboard;
        _dashboardLoadingCategories = {};
        _loadingDashboard = false;
      });
    } catch (e) {
      if (!mounted || requestId != _dashboardRequestId) return;
      setState(() {
        _loadingDashboard = false;
        _message = "Impossible de charger les informations: $e";
      });
    }
  }

  void _showSchoolModal() {
    final school = _selectedSchool;
    if (school == null) return;
    _showLargeModal(
      title: "Informations de l'ecole",
      icon: Icons.school_outlined,
      child: _DynamicViewer(value: school),
    );
  }

  void _showDigeModal() {
    final dashboard = _dashboard;
    if (dashboard == null) return;
    _showLargeModal(
      title: "Informations SIGE / DIGE",
      icon: Icons.assignment_outlined,
      child: _DigeFormsViewer(forms: dashboard.forms),
      maxWidth: 1280,
      heightFactor: 0.94,
    );
  }

  void _showSchedulesModal() {
    final dashboard = _dashboard;
    if (dashboard == null) return;
    _showLargeModal(
      title: "Horaires",
      icon: Icons.schedule_outlined,
      child: dashboard.schedules.isEmpty
          ? const Text("Aucun horaire trouve pour cette annee.")
          : _ScheduleViewer(schedules: dashboard.schedules),
    );
  }

  void _showBuildingsModal() {
    final school = _selectedSchool;
    final dashboard = _dashboard;
    if (school == null) return;
    _showLargeModal(
      title: "Locaux et batiments",
      icon: Icons.domain_outlined,
      child: dashboard == null
          ? const Text("Veuillez d'abord choisir une annee scolaire.")
          : _LocalsViewer(
              locals: dashboard.locals,
              school: school,
            ),
    );
  }

  void _showEntityListModal({
    required String title,
    required List<Map<String, dynamic>> items,
    required _EntityType type,
  }) {
    _showLargeModal(
      title: title,
      icon: _entityIcon(type),
      child: _SearchableEntityList(
        items: items,
        type: type,
        onTap: (item) => _showEntityDetailModal(item, type),
      ),
    );
  }

  void _showClassDetails(Map<String, dynamic> classe) {
    final dashboard = _dashboard;
    if (dashboard == null) return;
    final students = dashboard.studentsList.where((student) {
      final studentClass = _label(student, ['classe']);
      return _sameClass(studentClass, classe);
    }).toList();
    final schedules = dashboard.schedules.where((schedule) {
      return _sameScheduleClass(schedule, classe);
    }).toList();
    _showLargeModal(
      title: "Classe - ${_className(classe)}",
      icon: Icons.meeting_room_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InfoSection(
            title: "Informations de la classe",
            child: _DynamicViewer(value: classe),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: "Horaire de la classe",
            child: schedules.isEmpty
                ? const Text("Aucun horaire trouve pour cette classe.")
                : _ScheduleViewer(schedules: schedules),
          ),
          const SizedBox(height: 16),
          _InfoSection(
            title: "Eleves",
            child: _SearchableEntityList(
              items: students,
              type: _EntityType.student,
              onTap: (item) =>
                  _showEntityDetailModal(item, _EntityType.student),
            ),
          ),
        ],
      ),
    );
  }

  void _showEntityDetailModal(Map<String, dynamic> item, _EntityType type) {
    final title =
        _personName(item).isEmpty ? _entityTitle(type) : _personName(item);
    final dashboard = _dashboard;
    final school = _selectedSchool;
    final studentDetails = type == _EntityType.student && dashboard != null
        ? dashboard.studentDetails(item)
        : (dashboard != null
            ? dashboard.staffDetails(item, type)
            : const <String, dynamic>{});
    final displayItem = type == _EntityType.student && school != null
        ? _studentDisplayMap(item, school)
        : item;
    _showLargeModal(
      title: title,
      icon: _entityIcon(type),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (type == _EntityType.student || type == _EntityType.teacher) ...[
            Center(child: _EntityPhoto(item: item, type: type, radius: 72)),
            const SizedBox(height: 16),
          ],
          _DynamicViewer(value: displayItem),
          if (studentDetails.isNotEmpty) ...[
            const SizedBox(height: 16),
            _InfoSection(
              title: type == _EntityType.student
                  ? "Informations liees a l'eleve"
                  : "Informations liees",
              child: _DynamicViewer(value: studentDetails),
            ),
          ],
        ],
      ),
    );
  }

  void _showLargeModal({
    required String title,
    required IconData icon,
    required Widget child,
    double maxWidth = 1040,
    double heightFactor = 0.88,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 44, vertical: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: MediaQuery.of(context).size.height * heightFactor,
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: "Fermer",
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 360,
            child: _buildSchoolsPane(),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _buildDetailsPane(),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolsPane() {
    return Container(
      color: const Color(0xFFF7F9FC),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
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
                _searchController.clear();
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _schoolsFuture,
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
                          child: const Icon(Icons.school,
                              color: Colors.white, size: 20),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredSchools() {
    final query = _searchController.text.trim().toLowerCase();
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

  Widget _buildDetailsPane() {
    final school = _selectedSchool;
    if (school == null) {
      return const _EmptyState(
        icon: Icons.touch_app_outlined,
        text:
            "Selectionnez une ecole pour voir ses annees et ses informations.",
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
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
                      fontSize: 24,
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
            IconButton(
              tooltip: "Actualiser",
              onPressed: () => _selectSchool(school),
              icon: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _showSchoolModal,
              icon: const Icon(Icons.info_outline),
              label: const Text("Infos ecole"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoSection(
          title: "Identite de l'ecole",
          child: _KeyValueGrid(values: _identityFields(school)),
        ),
        const SizedBox(height: 16),
        _buildYearsSection(),
        if (_message != null) ...[
          const SizedBox(height: 12),
          _Notice(text: _message!),
        ],
        const SizedBox(height: 16),
        _buildDashboardSection(),
      ],
    );
  }

  Widget _buildYearsSection() {
    if (_loadingYears) {
      return const _InfoSection(
        title: "Annees scolaires",
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return _InfoSection(
      title: "Annees scolaires",
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _years.map((yearMap) {
          final year = _label(yearMap, ['anneescolaire', 'anneeScolaire']);
          final active = year == _selectedYear;
          return ChoiceChip(
            selected: active,
            label: Text(year.isEmpty ? "Sans libelle" : year),
            onSelected: (_) => _selectYear(year),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDashboardSection() {
    if (_selectedYear == null) {
      return const _EmptyState(
        icon: Icons.calendar_month_outlined,
        text: "Choisissez une annee scolaire pour charger les donnees.",
      );
    }

    if (_loadingDashboard && _dashboard == null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final dashboard = _dashboard;
    if (dashboard == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loadingDashboard) ...[
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Text(
            _dashboardLoadingLabel(_dashboardLoadingCategories),
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
          const SizedBox(height: 16),
        ],
        _MetricsGrid(cards: dashboard.metricCards),
        const SizedBox(height: 16),
        _ActionStrip(
          actions: [
            _ActionItem(
              label: "Classes",
              icon: Icons.meeting_room_outlined,
              onTap: () => _showEntityListModal(
                title: "Toutes les classes",
                items: dashboard.classes,
                type: _EntityType.classe,
              ),
            ),
            _ActionItem(
              label: "Eleves",
              icon: Icons.groups_outlined,
              onTap: () => _showEntityListModal(
                title: "Liste des eleves",
                items: dashboard.studentsList,
                type: _EntityType.student,
              ),
            ),
            _ActionItem(
              label: "Enseignants",
              icon: Icons.person_pin_outlined,
              onTap: () => _showEntityListModal(
                title: "Liste des enseignants",
                items: dashboard.teachersList,
                type: _EntityType.teacher,
              ),
            ),
            _ActionItem(
              label: "Personnel",
              icon: Icons.badge_outlined,
              onTap: () => _showEntityListModal(
                title: "Personnel administratif",
                items: dashboard.adminStaffList,
                type: _EntityType.admin,
              ),
            ),
            _ActionItem(
              label: "SIGE / DIGE",
              icon: Icons.assignment_outlined,
              onTap: _showDigeModal,
            ),
            _ActionItem(
              label: "Horaires",
              icon: Icons.schedule_outlined,
              onTap: _showSchedulesModal,
            ),
            _ActionItem(
              label: "Batiments",
              icon: Icons.domain_outlined,
              onTap: _showBuildingsModal,
            ),
            _ActionItem(
              label: "Conflits inter-écoles",
              icon: Icons.warning_amber_outlined,
              onTap: () => _showLargeModal(
                title: "Conflits inter-écoles",
                icon: Icons.warning_amber_outlined,
                child: _ConflictsViewer(conflicts: dashboard.conflicts),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoSection(
          title: "Classes",
          child: dashboard.classes.isEmpty
              ? const Text("Aucune classe trouvee.")
              : _ClassesGrid(
                  classes: dashboard.classes,
                  students: dashboard.studentsList,
                  onTap: _showClassDetails,
                ),
        ),
        const SizedBox(height: 16),
        // _InfoSection(
        //   title: "Horaires",
        //   child: const Text(
        //       "Cliquez sur une classe pour consulter son horaire detaille."),
        // ),
        // const SizedBox(height: 16),
        // _InfoSection(
        //   title: "Resume general",
        //   child: _DynamicViewer(value: dashboard.summary),
        // ),
        // const SizedBox(height: 16),
        // _InfoSection(
        //   title: "Eleves",
        //   child: _DynamicViewer(value: dashboard.students),
        // ),
        // const SizedBox(height: 16),
        // _InfoSection(
        //   title: "Enseignants",
        //   child: _DynamicViewer(value: dashboard.teachers),
        // ),
        // const SizedBox(height: 16),
        // _InfoSection(
        //   title: "Personnel administratif",
        //   child: _DynamicViewer(value: dashboard.adminStaff),
        // ),
        // const SizedBox(height: 16),
        // _InfoSection(
        //   title: "Repartitions et performances",
        //   child: _ChartsCardsViewer(charts: dashboard.charts),
        // ),
        // const SizedBox(height: 16),
        // _InfoSection(
        //   title: "Listes consultees",
        //   child: _ConsultedListsPreview(
        //     students: dashboard.studentsList,
        //     teachers: dashboard.teachersList,
        //     adminStaff: dashboard.adminStaffList,
        //     onTap: _showEntityDetailModal,
        //     onOpenAll: (title, items, type) => _showEntityListModal(
        //       title: title,
        //       items: items,
        //       type: type,
        //     ),
        //   ),
        // ),
      ],
    );
  }

  List<_FieldValue> _identityFields(Map<String, dynamic> school) {
    final classCount = _dashboard?.classes.length ?? 0;
    final rooms = _label(school, ['nombreSalles']).isNotEmpty
        ? _label(school, ['nombreSalles'])
        : classCount > 0
            ? classCount.toString()
            : '';
    return [
      _FieldValue("Cle", _schoolKey(school)),
      _FieldValue("Code ecole", _label(school, ['cleEcole'])),
      _FieldValue("Province", _label(school, ['province'])),
      _FieldValue("Province educationnelle",
          _label(school, ['provinceEducationnelle'])),
      _FieldValue("Ville", _label(school, ['ville'])),
      _FieldValue("Commune", _label(school, ['commune'])),
      _FieldValue("Adresse", _label(school, ['adresse'])),
      _FieldValue("Telephone", _label(school, ['telephone'])),
      _FieldValue("Email", _label(school, ['email'])),
      _FieldValue("Site", _label(school, ['site'])),
      _FieldValue("Reseau", _label(school, ['reseau'])),
      _FieldValue("Promoteur", _label(school, ['promoteur'])),
      _FieldValue("DINACOPE", _label(school, ['dinacope'])),
      //_FieldValue("Salles / classes", rooms),
      _FieldValue("Etat batiments", _label(school, ['etatBatiments'])),
      _FieldValue("Type batiment", _label(school, ['typeBatiment'])),
    ];
  }
}

class _SmartKelasiApi {
  static const _baseUrl = 'https://smartkelasi-7109ee9b9b9b.herokuapp.com/';
  final http.Client _client = http.Client();

  Future<List<Map<String, dynamic>>> getSchools() async {
    final data = await _getJson('ecoleinfosservice');
    return _asMapList(data);
  }

  Future<List<Map<String, dynamic>>> getYears(String cleEcole) async {
    final data = await _getJson('anneescolaireservice/encours/$cleEcole');
    final years = _asMapList(data);
    final seen = <String>{};
    return years.where((year) {
      final label = _label(year, ['anneescolaire', 'anneeScolaire']);
      return seen.add(label);
    }).toList();
  }

  Future<_SchoolDashboard> getDashboard({
    required String cleEcole,
    required String anneescolaire,
    void Function(
      _SchoolDashboard dashboard,
      Set<String> loadingCategories,
    )? onProgress,
  }) async {
    final filter = {
      'cleEcole': cleEcole,
      'anneescolaire': anneescolaire,
      'limit': 50,
      'offset': 0,
    };

    final dashboard = _SchoolDashboard.empty();
    final loadingCategories = <String>{};
    void publish() =>
        onProgress?.call(dashboard, Set<String>.from(loadingCategories));

    Future<void> load(
      String label,
      Future<dynamic> request,
      void Function(dynamic value) apply,
    ) async {
      loadingCategories.add(label);
      publish();
      final value = await _safe(label, request);
      apply(value);
      loadingCategories.remove(label);
      publish();
    }

    final tasks = <Future<void>>[
      load('statistiquesEcole', _getJson('statistiques/ecoles/$cleEcole'),
          (v) => dashboard.schoolStats = v),
      load('summary', _postJson('analytics/summary', filter),
          (v) => dashboard.summary = v),
      load('studentsSummary', _postJson('analytics/students/summary', filter),
          (v) => dashboard.students = v),
      load('teachersSummary', _postJson('analytics/teachers/summary', filter),
          (v) => dashboard.teachers = v),
      load('adminSummary', _postJson('analytics/admin-staff/summary', filter),
          (v) => dashboard.adminStaff = v),
      load('classes', _putJson('classe/since/$anneescolaire/$cleEcole', []),
          (v) => dashboard.classes = _asMapList(v)),
      load(
          'enseignants',
          _putJson('enseignant/since/$anneescolaire/$cleEcole', []),
          (v) => dashboard.teachersList = _asMapList(v)),
      load(
          'personnelAdministratif',
          _putJson('personnelAdministratif/sync/$anneescolaire/$cleEcole', []),
          (v) => dashboard.adminStaffList = _asMapList(v)),
      load('horaires', _putJson('horaire/since/$anneescolaire/$cleEcole', []),
          (v) => dashboard.schedules = _asMapList(v)),
      load('forms', _putJson('forms/sync/$anneescolaire/$cleEcole', []),
          (v) => dashboard.forms = _asMapList(v)),
      load('cours', _putJson('cours/since/$anneescolaire/$cleEcole', []),
          (v) => dashboard.courses = _asMapList(v)),
      load(
          'classeenseignant',
          _putJson('classeenseignant/since/$anneescolaire/$cleEcole', []),
          (v) => dashboard.teacherClasses = _asMapList(v)),
      load(
          'diplomeenseignant',
          _putJson('diplomeenseignant/since/$anneescolaire/$cleEcole', []),
          (v) => dashboard.teacherDiplomas = _asMapList(v)),
      load(
          'adressePersonnelAdmin',
          _putJson('adressePersonnelAdmin/sync/$anneescolaire/$cleEcole', []),
          (v) => dashboard.adminAddresses = _asMapList(v)),
      load('locaux', _putJson('local/since/$anneescolaire/$cleEcole', []),
          (v) => dashboard.locals = _asMapList(v)),
      load('studentsByClass', _postJson('analytics/students/by-class', filter),
          (v) => dashboard.charts['elevesParClasse'] = v),
      load('studentsBySex', _postJson('analytics/students/by-sex', filter),
          (v) => dashboard.charts['elevesParSexe'] = v),
      load('teachersBySex', _postJson('analytics/teachers/by-sex', filter),
          (v) => dashboard.charts['enseignantsParSexe'] = v),
      load(
          'adminByFunction',
          _postJson('analytics/admin-staff/by-function', filter),
          (v) => dashboard.charts['personnelParFonction'] = v),
      load(
          'topCourses',
          _postJson('analytics/schools/top-courses-hours', filter),
          (v) => dashboard.charts['topCoursParHeures'] = v),
      load('studentsAnalytics', _postJson('analytics/students', filter),
          (v) => dashboard.lists['eleves'] = v),
      load('teachersAnalytics', _postJson('analytics/teachers', filter),
          (v) => dashboard.lists['enseignants'] = v),
      load('adminStaffAnalytics', _postJson('analytics/admin-staff', filter),
          (v) => dashboard.lists['personnelAdministratif'] = v),
      () async {
        const label = 'elevesEtConflits';
        loadingCategories.add(label);
        publish();
        final students = await _getPagedStudents(anneescolaire, cleEcole);
        dashboard.studentsList = students;
        dashboard.lists['eleves'] = students;
        publish();
        dashboard.conflicts = await _getConflictGroups(cleEcole, students);
        loadingCategories.remove(label);
        publish();
      }(),
      () async {
        const label = 'informationsEleves';
        loadingCategories.add(label);
        publish();
        final related = await _getStudentRelatedData(anneescolaire, cleEcole);
        dashboard.responsables = related['responsables'] ?? const [];
        dashboard.peres = related['peres'] ?? const [];
        dashboard.meres = related['meres'] ?? const [];
        dashboard.urgences = related['urgences'] ?? const [];
        dashboard.sanitaires = related['sanitaires'] ?? const [];
        dashboard.adresses = related['adresses'] ?? const [];
        dashboard.presencesEleves = related['presencesEleves'] ?? const [];
        dashboard.notesEleves = related['notesEleves'] ?? const [];
        loadingCategories.remove(label);
        publish();
      }(),
    ];

    await Future.wait(tasks);
    return dashboard;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _getStudentRelatedData(
      String anneescolaire, String cleEcole) async {
    final results = await Future.wait<List<Map<String, dynamic>>>([
      _getPagedSync('responsable/since/$anneescolaire/$cleEcole'),
      _getPagedSync('peres/since/$anneescolaire/$cleEcole'),
      _getPagedSync('meres/since/$anneescolaire/$cleEcole'),
      _getPagedSync('urgence/since/$anneescolaire/$cleEcole'),
      _getPagedSync('infosanitaires/since/$anneescolaire/$cleEcole'),
      _getPagedSync('adresse/since/$anneescolaire/$cleEcole'),
      _getSimpleSync('presenceeleve/since/$anneescolaire/$cleEcole'),
      _getSimpleSync('notecoursobtenue/since/$anneescolaire/$cleEcole'),
    ]);
    return {
      'responsables': results[0],
      'peres': results[1],
      'meres': results[2],
      'urgences': results[3],
      'sanitaires': results[4],
      'adresses': results[5],
      'presencesEleves': results[6],
      'notesEleves': results[7],
    };
  }

  Future<List<Map<String, dynamic>>> _getConflictGroups(
      String cleEcole, List<Map<String, dynamic>> schoolStudents) async {
    final encodedSchool = Uri.encodeComponent(cleEcole);
    final currentSchoolConflicts = schoolStudents.where((student) {
      final studentSchool = _label(student, ['cleEcole']);
      final belongsToSchool =
          studentSchool.isEmpty || _sameText(studentSchool, cleEcole);
      return belongsToSchool && _isTruthy(student['conflit']);
    }).toList();
    final groups =
        await Future.wait(currentSchoolConflicts.map((student) async {
      final numero = _label(student, ['numeroIdentifiant']);
      if (numero.isEmpty) {
        return {
          ...student,
          'correspondants': const <Map<String, dynamic>>[],
        };
      }
      final encodedNumero = Uri.encodeComponent(numero);
      final details = _asMapList(await _safe(
        'conflitsDetails',
        _getJson('eleve/conflits/$encodedNumero?cleEcole=$encodedSchool'),
      ))
          .where((detail) {
        final matched = _conflictMatchedStudent(detail);
        final matchedSchool = _label(matched, ['cleEcole']);
        return matchedSchool.isEmpty || !_sameText(matchedSchool, cleEcole);
      }).toList();
      return {
        ...student,
        'correspondants': details,
      };
    }));
    return groups;
  }

  Future<List<Map<String, dynamic>>> _getSimpleSync(String path) async {
    final data = await _safe(path, _putJson(path, []));
    return _asMapList(data);
  }

  Future<List<Map<String, dynamic>>> _getPagedSync(String path) async {
    final all = <Map<String, dynamic>>[];
    var page = 0;
    while (true) {
      final separator = path.contains('?') ? '&' : '?';
      final data = await _safe(
        path,
        _putJson('$path${separator}page=$page&size=100', []),
      );
      final rows = _asMapList(data);
      all.addAll(rows);
      if (rows.length < 100 || page >= 49) break;
      page++;
    }
    return all;
  }

  Future<List<Map<String, dynamic>>> _getPagedStudents(
      String anneescolaire, String cleEcole) async {
    final all = <Map<String, dynamic>>[];
    var page = 0;
    while (true) {
      final data = await _safe(
        'eleves',
        _putJson(
            'eleve/since/$anneescolaire/$cleEcole?page=$page&size=100', []),
      );
      final rows = _asMapList(data);
      all.addAll(rows);
      if (rows.length < 100 || page >= 49) break;
      page++;
    }
    return all;
  }

  Future<dynamic> _getJson(String path) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl$path'),
      headers: const {'Accept': 'application/json'},
    );
    return _decode(response);
  }

  Future<dynamic> _postJson(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> _putJson(String path, dynamic body) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  static String photoUrl(_EntityType type, Map<String, dynamic> item) {
    final id = _label(item, ['numeroIdentifiant']);
    if (id.isEmpty) return '';
    if (type == _EntityType.student) {
      return '${_baseUrl}eleve/$id/download-photo';
    }
    if (type == _EntityType.teacher) {
      return '${_baseUrl}enseignant/$id/download-photo';
    }
    return '';
  }

  Future<dynamic> _safe(String label, Future<dynamic> request) async {
    try {
      return await request;
    } catch (e) {
      return {'erreur': '$label: $e'};
    }
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}');
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return [];
  }
}

class _SchoolDashboard {
  _SchoolDashboard({
    required this.schoolStats,
    required this.summary,
    required this.students,
    required this.teachers,
    required this.adminStaff,
    required this.classes,
    required this.studentsList,
    required this.teachersList,
    required this.adminStaffList,
    required this.schedules,
    required this.forms,
    required this.courses,
    required this.teacherClasses,
    required this.teacherDiplomas,
    required this.adminAddresses,
    required this.locals,
    required this.conflicts,
    required this.responsables,
    required this.peres,
    required this.meres,
    required this.urgences,
    required this.sanitaires,
    required this.adresses,
    required this.presencesEleves,
    required this.notesEleves,
    required this.charts,
    required this.lists,
  });

  factory _SchoolDashboard.empty() => _SchoolDashboard(
        schoolStats: const <String, dynamic>{},
        summary: const <String, dynamic>{},
        students: const <String, dynamic>{},
        teachers: const <String, dynamic>{},
        adminStaff: const <String, dynamic>{},
        classes: [],
        studentsList: [],
        teachersList: [],
        adminStaffList: [],
        schedules: [],
        forms: [],
        courses: [],
        teacherClasses: [],
        teacherDiplomas: [],
        adminAddresses: [],
        locals: [],
        conflicts: [],
        responsables: [],
        peres: [],
        meres: [],
        urgences: [],
        sanitaires: [],
        adresses: [],
        presencesEleves: [],
        notesEleves: [],
        charts: {},
        lists: {},
      );

  dynamic schoolStats;
  dynamic summary;
  dynamic students;
  dynamic teachers;
  dynamic adminStaff;
  List<Map<String, dynamic>> classes;
  List<Map<String, dynamic>> studentsList;
  List<Map<String, dynamic>> teachersList;
  List<Map<String, dynamic>> adminStaffList;
  List<Map<String, dynamic>> schedules;
  List<Map<String, dynamic>> forms;
  List<Map<String, dynamic>> courses;
  List<Map<String, dynamic>> teacherClasses;
  List<Map<String, dynamic>> teacherDiplomas;
  List<Map<String, dynamic>> adminAddresses;
  List<Map<String, dynamic>> locals;
  List<Map<String, dynamic>> conflicts;
  List<Map<String, dynamic>> responsables;
  List<Map<String, dynamic>> peres;
  List<Map<String, dynamic>> meres;
  List<Map<String, dynamic>> urgences;
  List<Map<String, dynamic>> sanitaires;
  List<Map<String, dynamic>> adresses;
  List<Map<String, dynamic>> presencesEleves;
  List<Map<String, dynamic>> notesEleves;
  final Map<String, dynamic> charts;
  final Map<String, dynamic> lists;

  List<_MetricCard> get metricCards {
    final stats = schoolStats is Map ? schoolStats as Map : const {};
    final girls = studentsList.where((student) => _isFemale(student)).length;
    final boys = studentsList.where((student) => _isMale(student)).length;
    final localRooms = locals.fold<int>(0, (sum, local) {
      return sum + (int.tryParse(_label(local, ['nombrePiece'])) ?? 0);
    });
    return [
      _MetricCard("Eleves", _fallbackCount(stats['nombreEleves'], studentsList),
          Icons.groups_outlined, Colors.blue),
      _MetricCard("Filles", _fallbackNumber(stats['nombreElevesFilles'], girls),
          Icons.girl_outlined, Colors.pink),
      _MetricCard(
          "Garcons",
          _fallbackNumber(stats['nombreElevesGarcons'], boys),
          Icons.boy_outlined,
          Colors.indigo),
      _MetricCard(
          "Enseignants",
          _fallbackCount(stats['nombreEnseignants'], teachersList),
          Icons.person_pin_outlined,
          Colors.green),
      _MetricCard("Classes", _fallbackCount(stats['nombreClasses'], classes),
          Icons.meeting_room_outlined, Colors.deepOrange),
      _MetricCard("Locaux", locals.length.toString(), Icons.domain_outlined,
          Colors.brown),
      _MetricCard("Pieces", localRooms > 0 ? localRooms.toString() : "-",
          Icons.door_front_door_outlined, Colors.deepPurple),
      _MetricCard("Cours", _formatValue(stats['nombreCours']),
          Icons.menu_book_outlined, Colors.teal),
      _MetricCard("Personnel", adminStaffList.length.toString(),
          Icons.badge_outlined, Colors.blueGrey),
      _MetricCard("Horaires", schedules.length.toString(),
          Icons.schedule_outlined, Colors.purple),
      _MetricCard("Conflits", conflicts.length.toString(),
          Icons.warning_amber_outlined, Colors.red),
    ];
  }

  Map<String, dynamic> studentDetails(Map<String, dynamic> student) {
    final numero = _label(student, ['numeroIdentifiant']);
    final cle = _label(student, ['cle']);
    final details = <String, dynamic>{};
    void addList(String label, List<Map<String, dynamic>> data,
        bool Function(Map<String, dynamic>) test) {
      final rows = _uniqueRows(data.where(test).toList());
      if (rows.isNotEmpty) details[label] = rows;
    }

    bool byNumero(Map<String, dynamic> row) {
      return numero.isNotEmpty &&
          _label(row, ['numeroIdentifiantEleve', 'numeroIdentifiant']) ==
              numero;
    }

    bool byCle(Map<String, dynamic> row) {
      return cle.isNotEmpty && _label(row, ['idEleve', 'cleEleve']) == cle;
    }

    void addPublicList(String label, List<Map<String, dynamic>> data,
        bool Function(Map<String, dynamic>) test) {
      final rows = _uniqueRows(data.where(test).toList())
          .map(_withoutTechnicalIdentity)
          .toList();
      if (rows.isNotEmpty) details[label] = rows;
    }

    addPublicList("Responsable", responsables, byNumero);
    addPublicList("Pere", peres, byNumero);
    addPublicList("Mere", meres, byNumero);
    addPublicList("Urgence", urgences, byNumero);
    final sanitaryRows = _uniqueRows(sanitaires.where(byNumero).toList())
        .map(_sanitaryDisplayMap)
        .toList();
    if (sanitaryRows.isNotEmpty) {
      details["Informations sanitaires"] = sanitaryRows;
    }
    addList("Adresse", adresses, byNumero);
    addList("Presences", presencesEleves, byCle);
    addList("Notes", notesEleves, byCle);
    return details;
  }

  Map<String, dynamic> staffDetails(
      Map<String, dynamic> staff, _EntityType type) {
    final numero = _label(staff, ['numeroIdentifiant']);
    final cle = _label(staff, ['cle']);
    final details = <String, dynamic>{};

    if (type == _EntityType.teacher) {
      final classes = _uniqueRows(teacherClasses.where((row) {
        return _label(row, ['idEnseignant']) == cle ||
            _label(row, ['numeroIdentifiant']) == numero;
      }).toList());
      final diplomas = _uniqueRows(teacherDiplomas.where((row) {
        return _label(row, ['numeroIdentifiant']) == numero;
      }).toList());
      final courseIds = _extractStringList(staff['cours']);
      final teacherCourses = _uniqueRows(courses.where((row) {
        final courseKey = _label(row, ['cle']);
        return courseIds.contains(courseKey) ||
            classes.any((classe) => _sameCourseClass(row, classe));
      }).toList());
      if (classes.isNotEmpty) details["Classes"] = classes;
      if (teacherCourses.isNotEmpty) details["Cours"] = teacherCourses;
      if (diplomas.isNotEmpty) details["Diplomes"] = diplomas;
      details["Poste"] = {
        "statut": _label(staff, ['statut']),
        "typeEnseignant": _label(staff, ['typeEnseignant']),
        "gradeActuel": _label(staff, ['gradeActuel']),
        "tacheSupplementaire": _label(staff, ['tacheSupplementaire']),
        "tachesSupplementaires": _label(staff, ['tachesSupplementaires']),
      };
    }

    if (type == _EntityType.admin) {
      final addresses = _uniqueRows(adminAddresses.where((row) {
        return _label(row, ['numeroIdentifiant']) == numero;
      }).toList());
      if (addresses.isNotEmpty) details["Adresse"] = addresses;
      details["Poste"] = {
        "fonction": _label(staff, ['fonction']),
        "departement": _label(staff, ['departement']),
        "statut": _label(staff, ['statut']),
        "gradeActuel": _label(staff, ['gradeActuel']),
        "acteEngagement": _label(staff, ['acteEngagement']),
        "actePromoGrade": _label(staff, ['actePromoGrade']),
        "classes": _label(staff, ['classes']),
        "cours": _label(staff, ['cours']),
      };
      details["Diplomes"] =
          "Aucun endpoint diplome personnel administratif n'est expose par le serveur actuel.";
    }

    return details;
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.cards});

  final List<_MetricCard> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final count = width > 1100
            ? 4
            : width > 760
                ? 3
                : 2;
        final itemWidth = (width - (12 * (count - 1))) / count;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards.map((card) {
            return SizedBox(
              width: itemWidth,
              height: 88,
              child: _MetricTile(card: card),
            );
          }).toList(),
        );
      },
    );
  }
}

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

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.card});

  final _MetricCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card.color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: card.color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Icon(card.icon, color: card.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  card.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                Text(
                  card.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyValueGrid extends StatelessWidget {
  const _KeyValueGrid({required this.values});

  final List<_FieldValue> values;

  @override
  Widget build(BuildContext context) {
    final visibleValues =
        values.where((item) => item.value.isNotEmpty).toList();
    if (visibleValues.isEmpty) {
      return const Text("Aucune information disponible.");
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 860 ? 3 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 4.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 8,
          children: visibleValues
              .map(
                (item) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({required this.actions});

  final List<_ActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: actions.map((action) {
        return OutlinedButton.icon(
          onPressed: action.onTap,
          icon: Icon(action.icon, size: 18),
          label: Text(action.label),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionItem {
  _ActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

class _DigeFormsViewer extends StatefulWidget {
  const _DigeFormsViewer({required this.forms});
  final List<Map<String, dynamic>> forms;

  @override
  State<_DigeFormsViewer> createState() => _DigeFormsViewerState();
}

class _DigeFormsViewerState extends State<_DigeFormsViewer> {
  int _selectedLevel = 0;
  final Map<int, int> _selectedGroups = {};

  Map<String, dynamic>? _formForLevel(int index) {
    for (final form in widget.forms) {
      final level = _normalize(_label(form, ['level']));
      final matches = index == 0
          ? level.contains('preschool') || level.contains('prescolaire')
          : index == 1
              ? level.contains('primary') || level.contains('primaire')
              : level.contains('secondary') || level.contains('secondaire');
      if (matches) return form;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forms.isEmpty) {
      return const Text("Aucun formulaire SIGE/DIGE trouvé pour cette année.");
    }
    final form = _formForLevel(_selectedLevel);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ToggleButtons(
            isSelected: List.generate(3, (index) => index == _selectedLevel),
            onPressed: (index) => setState(() => _selectedLevel = index),
            borderRadius: BorderRadius.circular(10),
            constraints: const BoxConstraints(minWidth: 170, minHeight: 48),
            selectedColor: Colors.white,
            fillColor: Colors.indigo,
            children: const [
              _DigeLevelButton(label: "LT1", subtitle: "Préscolaire"),
              _DigeLevelButton(label: "LT2", subtitle: "Primaire"),
              _DigeLevelButton(label: "LT3", subtitle: "Secondaire"),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (form == null)
          _EmptyState(
            icon: Icons.assignment_late_outlined,
            text: "Aucun formulaire ${[
              'LT1',
              'LT2',
              'LT3'
            ][_selectedLevel]} disponible.",
          )
        else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallBadge(
                text: [
                  'LT1 — Préscolaire',
                  'LT2 — Primaire',
                  'LT3 — Secondaire'
                ][_selectedLevel],
                color: Colors.indigo,
              ),
              _SmallBadge(
                text: _digeStatusLabel(_label(form, ['status'])),
                color: Colors.green,
              ),
              if (_label(form, ['academicYear']).isNotEmpty)
                _SmallBadge(
                  text: _label(form, ['academicYear']),
                  color: Colors.blueGrey,
                ),
            ],
          ),
          const SizedBox(height: 14),
          _buildFormContent(form),
        ],
      ],
    );
  }

  Widget _buildFormContent(Map<String, dynamic> form) {
    final decoded = _decodeJsonValue(form['data']);
    if (decoded is! Map) return _DynamicViewer(value: decoded ?? form);
    final groups = Map<String, dynamic>.from(decoded).entries.toList();
    if (groups.isEmpty) {
      return const Text("Ce formulaire ne contient aucune donnée.");
    }
    final selected =
        (_selectedGroups[_selectedLevel] ?? 0).clamp(0, groups.length - 1);
    final selectedGroup = groups[selected];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selected,
                decoration: const InputDecoration(
                  labelText: "Sous-groupe",
                  border: OutlineInputBorder(),
                ),
                items: List.generate(
                  groups.length,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text(_prettyLabel(groups[index].key)),
                  ),
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedGroups[_selectedLevel] = value);
                  }
                },
              ),
              const SizedBox(height: 14),
              _DigeGroupContent(group: selectedGroup),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 270,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueGrey.shade100),
                ),
                child: Column(
                  children: List.generate(groups.length, (index) {
                    final active = index == selected;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        selected: active,
                        selectedTileColor: Colors.indigo.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              active ? Colors.indigo : Colors.blueGrey.shade200,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: active ? Colors.white : Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          _prettyLabel(groups[index].key),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => setState(
                          () => _selectedGroups[_selectedLevel] = index,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: _DigeGroupContent(group: selectedGroup)),
          ],
        );
      },
    );
  }
}

class _DigeLevelButton extends StatelessWidget {
  const _DigeLevelButton({required this.label, required this.subtitle});
  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(subtitle, style: const TextStyle(fontSize: 11)),
          ],
        ),
      );
}

class _DigeGroupContent extends StatelessWidget {
  const _DigeGroupContent({required this.group});
  final MapEntry<String, dynamic> group;

  @override
  Widget build(BuildContext context) => _InfoSection(
        title: _prettyLabel(group.key),
        child: _DynamicViewer(value: group.value),
      );
}

class _ClassesGrid extends StatelessWidget {
  const _ClassesGrid({
    required this.classes,
    required this.students,
    required this.onTap,
  });

  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> students;
  final ValueChanged<Map<String, dynamic>> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth > 1000
            ? 4
            : constraints.maxWidth > 680
                ? 3
                : 2;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: classes.map((classe) {
            final total = students.where((student) {
              return _sameClass(_label(student, ['classe']), classe);
            }).length;
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onTap(classe),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.indigo.shade700,
                      child: const Icon(Icons.meeting_room_outlined,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _className(classe),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            "$total eleves",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _LocalsViewer extends StatelessWidget {
  const _LocalsViewer({
    required this.locals,
    required this.school,
  });

  final List<Map<String, dynamic>> locals;
  final Map<String, dynamic> school;

  @override
  Widget build(BuildContext context) {
    final buildingValues = [
      _FieldValue("Nombre de salles", _label(school, ['nombreSalles'])),
      _FieldValue("Etat batiments", _label(school, ['etatBatiments'])),
      _FieldValue("Type batiment", _label(school, ['typeBatiment'])),
      _FieldValue("Statut batiment", _label(school, ['statutBatiment'])),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (buildingValues.any((item) => item.value.isNotEmpty)) ...[
          _InfoSection(
            title: "Informations batiments de l'ecole",
            child: _KeyValueGrid(values: buildingValues),
          ),
          const SizedBox(height: 14),
        ],
        _InfoSection(
          title: "Locaux saisis par l'ecole",
          child: locals.isEmpty
              ? const Text("Aucun local trouve pour cette annee scolaire.")
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: locals.map((local) {
                    return _LocalCard(local: local);
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _ConflictsViewer extends StatelessWidget {
  const _ConflictsViewer({required this.conflicts});

  final List<Map<String, dynamic>> conflicts;

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) {
      return Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
          const SizedBox(width: 8),
          const Expanded(
              child: Text("Aucun conflit détecté pour cette école.")),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            "${conflicts.length} élève(s) avec un conflit détecté.",
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        ...conflicts.map((conflict) {
          return _ConflictCard(conflict: conflict);
        }),
      ],
    );
  }
}

class _ConflictCard extends StatelessWidget {
  const _ConflictCard({required this.conflict});

  final Map<String, dynamic> conflict;

  @override
  Widget build(BuildContext context) {
    final correspondants =
        _asMapListLocal(conflict['correspondants']).where((detail) {
      return detail.isNotEmpty;
    }).toList();
    final sourceDetails = correspondants.isEmpty
        ? <String, dynamic>{'eleve': conflict}
        : _conflictDetailMap(correspondants.first, 'detailsEleve1');
    final sourceStudent = _mapValue(sourceDetails['eleve'], fallback: conflict);
    final sourceSchool = _mapValue(
      sourceDetails['ecole'],
      fallback: {'nomEcole': conflict['nomEcole']},
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EntityPhoto(
                  item: sourceStudent, type: _EntityType.student, radius: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _personName(conflict).isEmpty
                          ? "Eleve sans nom"
                          : _personName(sourceStudent),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SmallBadge(
                            text: _label(conflict, ['classe']).isEmpty
                                ? "Classe non renseignee"
                                : _label(sourceStudent, ['classe']),
                            color: Colors.deepOrange),
                        _SmallBadge(
                            text: _label(sourceSchool, ['nomEcole', 'nom'])
                                    .isEmpty
                                ? "Ecole selectionnee"
                                : _label(sourceSchool, ['nomEcole', 'nom']),
                            color: Colors.blueGrey),
                        _SmallBadge(
                            text: _label(sourceStudent, ['numeroIdentifiant'])
                                    .isEmpty
                                ? ""
                                : "N. ${_label(sourceStudent, [
                                        'numeroIdentifiant'
                                      ])}",
                            color: Colors.indigo),
                        _SmallBadge(
                            text: _label(sourceStudent, ['sexe']).isEmpty
                                ? ""
                                : _label(sourceStudent, ['sexe']),
                            color: Colors.purple),
                        _SmallBadge(
                            text:
                                _label(sourceStudent, ['dateNaissance']).isEmpty
                                    ? ""
                                    : "Ne(e) ${_label(sourceStudent, [
                                            'dateNaissance'
                                          ])}",
                            color: Colors.green),
                        _SmallBadge(
                            text:
                                _label(sourceStudent, ['lieuNaissance']).isEmpty
                                    ? ""
                                    : _label(sourceStudent, ['lieuNaissance']),
                            color: Colors.teal),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ConflictLinkedDetails(details: sourceDetails, color: Colors.orange),
          const SizedBox(height: 12),
          if (correspondants.isEmpty)
            Text(
              "Aucun correspondant detaille n'est expose par le serveur.",
              style: TextStyle(color: Colors.grey.shade700),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Correspondant(s) detecte(s)",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ...correspondants.map((detail) {
                  return _ConflictMatchCard(detail: detail);
                }),
              ],
            ),
        ],
      ),
    );
  }
}

class _ConflictMatchCard extends StatelessWidget {
  const _ConflictMatchCard({required this.detail});

  final Map<String, dynamic> detail;

  @override
  Widget build(BuildContext context) {
    final detailBlock = _conflictDetailMap(detail, 'detailsEleve2');
    final student = _mapValue(detailBlock['eleve'],
        fallback: _conflictMatchedStudent(detail));
    final school = _mapValue(detailBlock['ecole'],
        fallback: _conflictMatchedSchool(detail));
    final similarity = _conflictSimilarity(detail);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _EntityPhoto(
                  item: student, type: _EntityType.student, radius: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _personName(student).isEmpty
                          ? "Correspondant sans nom"
                          : _personName(student),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SmallBadge(
                            text: _label(school, ['nomEcole', 'nom']).isEmpty
                                ? "Ecole inconnue"
                                : _label(school, ['nomEcole', 'nom']),
                            color: Colors.indigo),
                        _SmallBadge(
                            text: _label(student, ['classe']).isEmpty
                                ? "Classe non renseignee"
                                : _label(student, ['classe']),
                            color: Colors.green),
                        _SmallBadge(
                            text: similarity.isEmpty
                                ? "Similarite non renseignee"
                                : "Similarite $similarity",
                            color: Colors.red),
                        _SmallBadge(
                            text: _label(student, ['numeroIdentifiant']).isEmpty
                                ? ""
                                : "N. ${_label(student, [
                                        'numeroIdentifiant'
                                      ])}",
                            color: Colors.blueGrey),
                        _SmallBadge(
                            text: _label(student, ['sexe']).isEmpty
                                ? ""
                                : _label(student, ['sexe']),
                            color: Colors.purple),
                        _SmallBadge(
                            text: _label(student, ['dateNaissance']).isEmpty
                                ? ""
                                : "Ne(e) ${_label(student, ['dateNaissance'])}",
                            color: Colors.orange),
                        _SmallBadge(
                            text: _label(student, ['lieuNaissance']).isEmpty
                                ? ""
                                : _label(student, ['lieuNaissance']),
                            color: Colors.teal),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ConflictLinkedDetails(details: detailBlock, color: Colors.indigo),
        ],
      ),
    );
  }
}

class _ConflictLinkedDetails extends StatelessWidget {
  const _ConflictLinkedDetails({
    required this.details,
    required this.color,
  });

  final Map<String, dynamic> details;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final sections = [
      _DetailSectionData("Pere", details['pere']),
      _DetailSectionData("Mere", details['mere']),
      _DetailSectionData("Responsable", details['responsable']),
      _DetailSectionData("Urgence", details['urgence']),
      _DetailSectionData(
          "Informations sanitaires", details['informationsSanitaires']),
      _DetailSectionData("Adresse", details['adresse']),
    ].where((section) => _detailRows(section.value).isNotEmpty).toList();

    if (sections.isEmpty) {
      return Text(
        "Aucune information liee disponible.",
        style: TextStyle(color: Colors.grey.shade700),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections.map((section) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                section.title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              ..._detailRows(section.value).map((row) {
                return _ConflictDetailRow(row: row);
              }),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DetailSectionData {
  const _DetailSectionData(this.title, this.value);

  final String title;
  final dynamic value;
}

class _ConflictDetailRow extends StatelessWidget {
  const _ConflictDetailRow({required this.row});

  final Map<String, dynamic> row;

  @override
  Widget build(BuildContext context) {
    final entries = row.entries
        .where((entry) => !_isTechnicalKey(entry.key))
        .where((entry) => '${entry.value}'.trim().isNotEmpty)
        .toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: entries.map((entry) {
          return SizedBox(
            width: 210,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _prettyLabel(entry.key),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.value}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LocalCard extends StatelessWidget {
  const _LocalCard({required this.local});

  final Map<String, dynamic> local;

  @override
  Widget build(BuildContext context) {
    final equipments = _parseEquipments(local['equipements']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.brown.shade700,
                child: const Icon(Icons.location_city_outlined,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(local, ['nom']).isEmpty
                          ? "Local sans nom"
                          : _label(local, ['nom']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _label(local, ['adresse']).isEmpty
                          ? "Adresse non renseignee"
                          : _label(local, ['adresse']),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _KeyValueGrid(
            values: [
              _FieldValue("Responsable", _label(local, ['responsable'])),
              _FieldValue("Nombre de pieces", _label(local, ['nombrePiece'])),
              _FieldValue("Annee scolaire", _label(local, ['anneescolaire'])),
              _FieldValue(
                  "Date enregistrement", _label(local, ['dateEnregistrement'])),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Equipements",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (equipments.isEmpty)
            const Text("Aucun equipement renseigne.")
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: equipments.map((equipment) {
                final name = _label(equipment, ['nom', 'name']);
                final count = _label(equipment, ['nombre', 'quantite']);
                return _SmallBadge(
                  text: count.isEmpty ? name : "$name ($count)",
                  color: Colors.blueGrey,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _ScheduleViewer extends StatelessWidget {
  const _ScheduleViewer({required this.schedules});

  final List<Map<String, dynamic>> schedules;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: schedules.map((schedule) {
        final raw = _decodeJsonValue(schedule['horaire']);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _scheduleTitle(schedule),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SmallBadge(
                      text: "Debut ${_label(schedule, ['heureDebut'])}",
                      color: Colors.green),
                  _SmallBadge(
                      text: "${_label(schedule, ['nombreHeure'])} heures",
                      color: Colors.blue),
                  _SmallBadge(
                      text: "Duree ${_label(schedule, ['dureeHeure'])}",
                      color: Colors.orange),
                ],
              ),
              const SizedBox(height: 10),
              if (raw is List)
                _ScheduleGrid(rows: raw, schedule: schedule)
              else
                _DynamicViewer(value: raw ?? schedule['horaire']),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ChartsCardsViewer extends StatelessWidget {
  const _ChartsCardsViewer({required this.charts});

  final Map<String, dynamic> charts;

  @override
  Widget build(BuildContext context) {
    final entries = [
      _ChartBlockData("Eleves par classe", charts['elevesParClasse']),
      _ChartBlockData("Eleves par sexe", charts['elevesParSexe']),
      _ChartBlockData("Enseignants par sexe", charts['enseignantsParSexe']),
      _ChartBlockData("Personnel par fonction", charts['personnelParFonction']),
      _ChartBlockData("Top cours par heures", charts['topCoursParHeures']),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: entries.map((entry) {
        final rows = _chartRows(entry.value);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                entry.title,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (rows.isEmpty)
                Text(
                  "Aucune donnee disponible.",
                  style: TextStyle(color: Colors.grey.shade700),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: rows.map((row) {
                    return _ChartValueCard(
                      row: row,
                      emphasizeLabel: entry.title == "Eleves par classe",
                    );
                  }).toList(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ChartBlockData {
  const _ChartBlockData(this.title, this.value);

  final String title;
  final dynamic value;
}

class _ChartValueData {
  const _ChartValueData({
    required this.label,
    required this.value,
    this.detail = '',
  });

  final String label;
  final String value;
  final String detail;
}

class _ChartValueCard extends StatelessWidget {
  const _ChartValueCard({
    required this.row,
    this.emphasizeLabel = false,
  });

  final _ChartValueData row;
  final bool emphasizeLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: emphasizeLabel ? 280 : 230,
      constraints: BoxConstraints(minHeight: emphasizeLabel ? 84 : 72),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              row.label,
              maxLines: emphasizeLabel ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: emphasizeLabel
                    ? Colors.blueGrey.shade900
                    : Colors.grey.shade800,
                fontSize: emphasizeLabel ? 15 : 14,
                fontWeight: emphasizeLabel ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  row.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: row.value.length > 12 ? 14 : 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (row.detail.isNotEmpty)
                  Text(
                    row.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchableEntityList extends StatefulWidget {
  const _SearchableEntityList({
    required this.items,
    required this.type,
    required this.onTap,
  });

  final List<Map<String, dynamic>> items;
  final _EntityType type;
  final ValueChanged<Map<String, dynamic>> onTap;

  @override
  State<_SearchableEntityList> createState() => _SearchableEntityListState();
}

class _SearchableEntityListState extends State<_SearchableEntityList> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim().toLowerCase();
    final filtered = widget.items.where((item) {
      if (query.isEmpty) return true;
      return item.values.join(' ').toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: "Rechercher",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Text("${filtered.length} element(s)"),
        const SizedBox(height: 10),
        if (filtered.isEmpty)
          const Text("Aucune donnee trouvee.")
        else
          ...filtered.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading:
                    _EntityPhoto(item: item, type: widget.type, radius: 22),
                title: Text(
                  _entityRowTitle(item, widget.type),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  _entityRowSubtitle(item, widget.type),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.visibility_outlined),
                onTap: () => widget.onTap(item),
              ),
            );
          }),
      ],
    );
  }
}

class _ConsultedListsPreview extends StatelessWidget {
  const _ConsultedListsPreview({
    required this.students,
    required this.teachers,
    required this.adminStaff,
    required this.onTap,
    required this.onOpenAll,
  });

  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> adminStaff;
  final void Function(Map<String, dynamic>, _EntityType) onTap;
  final void Function(String, List<Map<String, dynamic>>, _EntityType)
      onOpenAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewGroup(
          title: "Eleves",
          items: students,
          type: _EntityType.student,
          onTap: onTap,
          onOpenAll: onOpenAll,
        ),
        const SizedBox(height: 12),
        _PreviewGroup(
          title: "Enseignants",
          items: teachers,
          type: _EntityType.teacher,
          onTap: onTap,
          onOpenAll: onOpenAll,
        ),
        const SizedBox(height: 12),
        _PreviewGroup(
          title: "Personnel administratif",
          items: adminStaff,
          type: _EntityType.admin,
          onTap: onTap,
          onOpenAll: onOpenAll,
        ),
      ],
    );
  }
}

class _PreviewGroup extends StatelessWidget {
  const _PreviewGroup({
    required this.title,
    required this.items,
    required this.type,
    required this.onTap,
    required this.onOpenAll,
  });

  final String title;
  final List<Map<String, dynamic>> items;
  final _EntityType type;
  final void Function(Map<String, dynamic>, _EntityType) onTap;
  final void Function(String, List<Map<String, dynamic>>, _EntityType)
      onOpenAll;

  @override
  Widget build(BuildContext context) {
    final preview = items.take(8).toList();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                Icon(_entityIcon(type), size: 18, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "$title (${items.length})",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          if (preview.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                "Aucune donnee.",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            )
          else
            ...preview.map((item) {
              return InkWell(
                onTap: () => onTap(item, type),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _entityRowTitle(item, type),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _entityRowSubtitle(item, type),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                ),
              );
            }),
          if (items.length > preview.length)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => onOpenAll(title, items, type),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(
                    "+ ${items.length - preview.length} autres elements",
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blueGrey.shade700,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EntityPhoto extends StatelessWidget {
  const _EntityPhoto({
    required this.item,
    required this.type,
    required this.radius,
  });

  final Map<String, dynamic> item;
  final _EntityType type;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = _SmartKelasiApi.photoUrl(type, item);
    final fallback = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueGrey.shade100,
      child: Icon(_entityIcon(type), color: Colors.blueGrey, size: radius),
    );
    if (url.isEmpty) return fallback;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blueGrey.shade100,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
      child: null,
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ScheduleGrid extends StatelessWidget {
  const _ScheduleGrid({required this.rows, required this.schedule});

  final List rows;
  final Map<String, dynamic> schedule;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      if (row is! Map) continue;
      final item = Map<String, dynamic>.from(row);
      final day = _scheduleDayLabel(_label(item, ['jour']));
      grouped.putIfAbsent(day.isEmpty ? 'Jour' : day, () => []).add(item);
    }
    if (grouped.isEmpty) return _DynamicViewer(value: rows);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: grouped.entries.map((entry) {
        final items = entry.value.toList()
          ..sort(
              (a, b) => _label(a, ['heure']).compareTo(_label(b, ['heure'])));
        return SizedBox(
          width: 300,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blueGrey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                ...items.map((item) {
                  final course = _label(item, ['cour', 'cours', 'nom']);
                  final hour = _label(item, ['heure']);
                  final timeRange = _scheduleTimeRange(schedule, item);
                  final isBreak =
                      _label(item, ['type']).toLowerCase() == 'extra';
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isBreak
                                ? Colors.orange.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hour,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: isBreak
                                  ? Colors.orange.shade800
                                  : Colors.green.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course.isEmpty
                                      ? "Cours non renseigné"
                                      : course,
                                  style: TextStyle(
                                    fontWeight: course.isEmpty
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                    color: course.isEmpty
                                        ? Colors.grey.shade600
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (timeRange.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  timeRange,
                                  style: TextStyle(
                                    color: Colors.blueGrey.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DynamicViewer extends StatelessWidget {
  const _DynamicViewer({required this.value});

  final dynamic value;

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return const Text("Aucune donnee disponible.");
    }
    if (value is List) {
      final list = value as List;
      if (list.isEmpty) return const Text("Aucune donnee disponible.");
      return Column(
        children: list.take(50).map((item) {
          final map = item is Map ? Map<String, dynamic>.from(item) : null;
          return _PrettyRecordCard(
            title: map == null ? "Element" : _recordTitle(map),
            subtitle: map == null ? "" : _recordSubtitle(map),
            child: _DynamicViewer(value: item),
          );
        }).toList(),
      );
    }
    if (value is Map) {
      final entries = (value as Map)
          .entries
          .where((entry) => entry.value != null)
          .where((entry) => '${entry.value}'.isNotEmpty)
          .where((entry) =>
              entry.value is! Map ||
              (entry.value as Map).values.any((v) => '$v'.trim().isNotEmpty))
          .toList();
      if (entries.isEmpty) return const Text("Aucune donnee disponible.");
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: entries.map((entry) {
          final nested = entry.value is Map || entry.value is List;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: nested
                ? _PrettySectionCard(
                    title: _prettyLabel('${entry.key}'),
                    child: _DynamicViewer(value: entry.value),
                  )
                : _InfoLine(
                    label: _prettyLabel('${entry.key}'),
                    value: _formatValue(entry.value),
                  ),
          );
        }).toList(),
      );
    }
    return Text(_formatValue(value));
  }
}

class _PrettySectionCard extends StatelessWidget {
  const _PrettySectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _PrettyRecordCard extends StatelessWidget {
  const _PrettyRecordCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.article_outlined,
                      color: Colors.indigo.shade700, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 210,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
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

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text),
    );
  }
}

class _FieldValue {
  _FieldValue(this.label, this.value);

  final String label;
  final String value;
}

class _MetricCard {
  _MetricCard(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

enum _EntityType { classe, student, teacher, admin }

String _dashboardLoadingLabel(Set<String> categories) {
  if (categories.isEmpty) return "Finalisation du chargement…";
  const labels = <String, String>{
    'statistiquesEcole': 'statistiques de l’école',
    'summary': 'résumé général',
    'studentsSummary': 'résumé des élèves',
    'teachersSummary': 'résumé des enseignants',
    'adminSummary': 'résumé du personnel',
    'classes': 'classes',
    'enseignants': 'enseignants',
    'personnelAdministratif': 'personnel administratif',
    'horaires': 'horaires',
    'forms': 'formulaires SIGE/DIGE',
    'cours': 'cours',
    'classeenseignant': 'affectations des enseignants',
    'diplomeenseignant': 'diplômes des enseignants',
    'adressePersonnelAdmin': 'adresses du personnel',
    'locaux': 'bâtiments et locaux',
    'studentsByClass': 'élèves par classe',
    'studentsBySex': 'élèves par sexe',
    'teachersBySex': 'enseignants par sexe',
    'adminByFunction': 'personnel par fonction',
    'topCourses': 'classement des cours',
    'studentsAnalytics': 'statistiques des élèves',
    'teachersAnalytics': 'statistiques des enseignants',
    'adminStaffAnalytics': 'statistiques du personnel',
    'elevesEtConflits': 'élèves et conflits inter-écoles',
    'informationsEleves': 'familles, santé, présences et notes',
  };
  final names = categories.map((key) => labels[key] ?? key).toList()..sort();
  const visibleCount = 4;
  final visible = names.take(visibleCount).join(', ');
  final remaining = names.length - visibleCount;
  return remaining > 0
      ? "Téléchargement : $visible et $remaining autre(s) catégorie(s)…"
      : "Téléchargement : $visible…";
}

String _digeStatusLabel(String status) {
  switch (_normalize(status)) {
    case 'draft':
      return 'Brouillon';
    case 'submitted':
      return 'Soumis';
    case 'validated':
      return 'Validé';
    case 'rejected':
      return 'Rejeté';
    default:
      return status.isEmpty ? 'Statut inconnu' : status;
  }
}

String _schoolName(Map<String, dynamic> school) {
  final name = _label(school, ['nomEcole', 'nom', 'name']);
  return name.isEmpty ? "Ecole sans nom" : name;
}

String _schoolKey(Map<String, dynamic> school) {
  final key = _label(school, ['cle', 'cleEcole', 'id']);
  return key;
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

String _className(Map<String, dynamic> classe) {
  final letter = _label(classe, ['lettre', 'nom']);
  final parts = [
    _label(classe, ['niveau']),
    _label(classe, ['cycle']),
    letter,
  ].where((item) => item.isNotEmpty).toList();
  if (parts.isNotEmpty) return parts.join(' ');
  final nom = _label(classe, ['nom']);
  return nom.isEmpty ? "Classe sans nom" : nom;
}

String _scheduleTitle(Map<String, dynamic> schedule) {
  final parts = [
    _label(schedule, ['niveau']),
    _label(schedule, ['cycle']),
    _label(schedule, ['section']),
    _label(schedule, ['lettre']),
  ].where((item) => item.isNotEmpty).toList();
  return parts.isEmpty ? "Horaire" : parts.join(' ');
}

String _scheduleTimeRange(
  Map<String, dynamic> schedule,
  Map<String, dynamic> course,
) {
  final slot = int.tryParse(_label(course, ['heure']));
  final start = _parseClockMinutes(_label(schedule, ['heureDebut']));
  final lessonDuration = int.tryParse(_label(schedule, ['dureeHeure']));
  if (slot == null || slot < 1 || start == null || lessonDuration == null) {
    return '';
  }

  final breaks = <int, int>{};
  final decodedBreaks = _decodeJsonValue(schedule['recreation']);
  if (decodedBreaks is List) {
    for (final value in decodedBreaks) {
      if (value is! Map) continue;
      final item = Map<String, dynamic>.from(value);
      final breakStart = _parseClockMinutes(_label(item, ['heure']));
      final breakDuration = int.tryParse(_label(item, ['duree', 'duration']));
      if (breakStart != null && breakDuration != null) {
        breaks[breakStart] = breakDuration;
      }
    }
  }

  var current = start;
  for (var index = 1; index <= slot; index++) {
    final nominalStart = start + ((index - 1) * lessonDuration);
    final duration = breaks[nominalStart] ?? lessonDuration;
    final end = current + duration;
    if (index == slot) {
      return '${_formatClockMinutes(current)} – ${_formatClockMinutes(end)}';
    }
    current = end;
  }
  return '';
}

int? _parseClockMinutes(String value) {
  final parts = value.trim().split(':');
  if (parts.length < 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null || minute < 0 || minute > 59) return null;
  return hour * 60 + minute;
}

String _formatClockMinutes(int value) {
  final normalized = value % (24 * 60);
  final hour = normalized ~/ 60;
  final minute = normalized % 60;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

String _scheduleDayLabel(String value) {
  final text = value.trim();
  if (text.isEmpty) return '';
  final normalized = _normalize(text);
  const days = {
    '1': 'Lundi',
    '2': 'Mardi',
    '3': 'Mercredi',
    '4': 'Jeudi',
    '5': 'Vendredi',
    '6': 'Samedi',
    '7': 'Dimanche',
    '0': 'Dimanche',
  };
  if (days.containsKey(normalized)) return days[normalized]!;
  if (normalized == 'lun' || normalized == 'lundi') return 'Lundi';
  if (normalized == 'mar' || normalized == 'mardi') return 'Mardi';
  if (normalized == 'mer' || normalized == 'mercredi') return 'Mercredi';
  if (normalized == 'jeu' || normalized == 'jeudi') return 'Jeudi';
  if (normalized == 'ven' || normalized == 'vendredi') return 'Vendredi';
  if (normalized == 'sam' || normalized == 'samedi') return 'Samedi';
  if (normalized == 'dim' || normalized == 'dimanche') return 'Dimanche';
  return text;
}

bool _sameClass(String value, Map<String, dynamic> classe) {
  final normalizedValue = _normalize(value);
  if (normalizedValue.isEmpty) return false;
  final candidates = _classCandidates(classe);
  final normalizedCandidates = candidates
      .map(_normalize)
      .where((candidate) => candidate.isNotEmpty)
      .toList();
  return normalizedCandidates.any((candidate) {
    return candidate == normalizedValue ||
        candidate.contains(normalizedValue) ||
        normalizedValue.contains(candidate);
  });
}

bool _sameScheduleClass(
    Map<String, dynamic> schedule, Map<String, dynamic> classe) {
  final scheduleName = [
    _label(schedule, ['niveau']),
    _label(schedule, ['cycle']),
    _label(schedule, ['section']),
    _label(schedule, ['option']),
    _label(schedule, ['lettre']),
  ].where((item) => item.isNotEmpty).join(' ');
  return _sameClass(scheduleName, classe);
}

bool _sameCourseClass(
    Map<String, dynamic> course, Map<String, dynamic> classe) {
  final courseName = [
    _label(course, ['niveau']),
    _label(course, ['cycle']),
    _label(course, ['section']),
    _label(course, ['option']),
    _label(course, ['lettre']),
  ].where((item) => item.isNotEmpty).join(' ');
  return _sameClass(courseName, classe);
}

List<String> _classCandidates(Map<String, dynamic> classe) {
  final niveau = _label(classe, ['niveau']);
  final cycle = _label(classe, ['cycle']);
  final section = _label(classe, ['section']);
  final option = _label(classe, ['option']);
  final letter = _label(classe, ['lettre', 'nom']);
  return [
    _className(classe),
    [niveau, cycle, option, letter].where((item) => item.isNotEmpty).join(' '),
    [niveau, cycle, section, letter].where((item) => item.isNotEmpty).join(' '),
    [niveau, cycle, letter].where((item) => item.isNotEmpty).join(' '),
    [niveau, option, letter].where((item) => item.isNotEmpty).join(' '),
  ];
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

String _personName(Map<String, dynamic> item) {
  return [
    _label(item, ['nom']),
    _label(item, ['postnom']),
    _label(item, ['prenom']),
  ].where((part) => part.isNotEmpty).join(' ');
}

String _entityTitle(_EntityType type) {
  switch (type) {
    case _EntityType.student:
      return "Eleve";
    case _EntityType.teacher:
      return "Enseignant";
    case _EntityType.admin:
      return "Personnel administratif";
    case _EntityType.classe:
      return "Classe";
  }
}

IconData _entityIcon(_EntityType type) {
  switch (type) {
    case _EntityType.student:
      return Icons.person_outline;
    case _EntityType.teacher:
      return Icons.person_pin_outlined;
    case _EntityType.admin:
      return Icons.badge_outlined;
    case _EntityType.classe:
      return Icons.meeting_room_outlined;
  }
}

String _entityRowTitle(Map<String, dynamic> item, _EntityType type) {
  if (type == _EntityType.classe) return _className(item);
  final name = _personName(item);
  if (name.isNotEmpty) return name;
  return _label(item, ['numeroIdentifiant', 'cle', 'id']);
}

String _entityRowSubtitle(Map<String, dynamic> item, _EntityType type) {
  if (type == _EntityType.classe) {
    return [
      _label(item, ['niveau']),
      _label(item, ['cycle']),
      _label(item, ['section']),
      _label(item, ['option']),
      _label(item, ['code']),
    ].where((part) => part.isNotEmpty).join(' | ');
  }
  return [
    _label(item, ['numeroIdentifiant']),
    _label(item, ['classe']),
    _label(item, ['fonction']),
    _label(item, ['typeEnseignant']),
    _label(item, ['telephone']),
  ].where((part) => part.isNotEmpty).join(' | ');
}

String _recordTitle(Map<String, dynamic> item) {
  final person = _personName(item);
  if (person.isNotEmpty) return person;
  final fullName = _label(item, ['nomComplet']);
  if (fullName.isNotEmpty) return fullName;
  final title = _label(item, ['intitule', 'fonction', 'cours', 'cour', 'nom']);
  if (title.isNotEmpty) return title;
  final role = _label(item, ['role', 'relation', 'typeEnseignant']);
  if (role.isNotEmpty) return role;
  return _label(item, ['numeroIdentifiant', 'numeroIdentifiantEleve', 'cle'])
          .isEmpty
      ? "Information"
      : _label(item, ['numeroIdentifiant', 'numeroIdentifiantEleve', 'cle']);
}

String _recordSubtitle(Map<String, dynamic> item) {
  return [
    _label(item, ['role']),
    _label(item, ['relation']),
    _label(item, ['telephone', 'telephone1']),
    _label(item, ['classe']),
    _label(item, ['niveau']),
    _label(item, ['date', 'date_obtention']),
  ].where((part) => part.isNotEmpty).join(' | ');
}

Map<String, dynamic> _studentDisplayMap(
    Map<String, dynamic> student, Map<String, dynamic> school) {
  final display = Map<String, dynamic>.from(student);
  final schoolName = _schoolName(school);
  if (schoolName.isNotEmpty) {
    display.remove('cleEcole');
    display.remove('idEcole');
    display.remove('ecoleId');
    display['ecole'] = schoolName;
  }
  return display;
}

Map<String, dynamic> _withoutTechnicalIdentity(Map<String, dynamic> row) {
  final clean = <String, dynamic>{};
  for (final entry in row.entries) {
    final key = entry.key;
    final normalized = _normalize(key);
    if (normalized == 'id' ||
        normalized.startsWith('id') ||
        normalized.contains('cle') ||
        normalized == 'synced' ||
        normalized == 'updatedat' ||
        normalized == 'numeroidentifianteleve') {
      continue;
    }
    clean[key] = entry.value;
  }
  return clean;
}

Map<String, dynamic> _sanitaryDisplayMap(Map<String, dynamic> row) {
  final fields = <String, dynamic>{
    "Allergies connues": _label(row, ['allergies']),
    "Antecedents medicaux": _label(row, ['antecedents']),
    "Traitements en cours": _label(row, ['traitements']),
    "Handicap / besoins particuliers": _label(row, ['handicap']),
    "Medecin traitant": _label(row, ['medecin']),
    "Contact d'urgence": _label(row, ['contactUrgence']),
    "Hopital prefere": _label(row, ['hopital']),
  };
  fields.removeWhere((_, value) => '$value'.trim().isEmpty);
  return fields;
}

List<Map<String, dynamic>> _asMapListLocal(dynamic value) {
  if (value is List) {
    return value.whereType<Map>().map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
  }
  return const [];
}

Map<String, dynamic> _conflictDetailMap(
    Map<String, dynamic> detail, String key) {
  final value = detail[key];
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

Map<String, dynamic> _mapValue(
  dynamic value, {
  Map<String, dynamic> fallback = const {},
}) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return fallback;
}

List<Map<String, dynamic>> _detailRows(dynamic value) {
  if (value is List) {
    return value.whereType<Map>().map((item) {
      return Map<String, dynamic>.from(item);
    }).where((item) {
      return item.entries.any((entry) =>
          !_isTechnicalKey(entry.key) && '${entry.value}'.trim().isNotEmpty);
    }).toList();
  }
  if (value is Map) {
    final row = Map<String, dynamic>.from(value);
    return row.entries.any((entry) =>
            !_isTechnicalKey(entry.key) && '${entry.value}'.trim().isNotEmpty)
        ? [row]
        : const [];
  }
  return const [];
}

bool _isTechnicalKey(String key) {
  final normalized = _normalize(key);
  return normalized == 'id' ||
      normalized.startsWith('id') ||
      normalized.contains('cle') ||
      normalized == 'synced' ||
      normalized == 'updatedat' ||
      normalized == 'numeroidentifianteleve';
}

Map<String, dynamic> _conflictMatchedStudent(Map<String, dynamic> detail) {
  final eleve2 = detail['eleve2'];
  if (eleve2 is Map) return Map<String, dynamic>.from(eleve2);
  final eleve = detail['eleve'];
  if (eleve is Map) return Map<String, dynamic>.from(eleve);
  final correspondant = detail['correspondant'];
  if (correspondant is Map) return Map<String, dynamic>.from(correspondant);
  return detail;
}

Map<String, dynamic> _conflictMatchedSchool(Map<String, dynamic> detail) {
  final ecole2 = detail['ecole2'];
  if (ecole2 is Map) return Map<String, dynamic>.from(ecole2);
  final ecole = detail['ecole'];
  if (ecole is Map) return Map<String, dynamic>.from(ecole);
  return const {};
}

String _conflictSimilarity(Map<String, dynamic> detail) {
  final raw = detail['pourcentageSimilarite'] ??
      detail['similarite'] ??
      detail['score'] ??
      detail['taux'];
  if (raw is num) {
    final value = raw <= 1 ? raw * 100 : raw;
    return "${value.toStringAsFixed(1)}%";
  }
  final text = '$raw'.trim();
  if (text.isEmpty || text == 'null') return '';
  final parsed = double.tryParse(text);
  if (parsed != null) {
    final value = parsed <= 1 ? parsed * 100 : parsed;
    return "${value.toStringAsFixed(1)}%";
  }
  return text;
}

dynamic _decodeJsonValue(dynamic value) {
  if (value == null) return null;
  if (value is Map || value is List) return value;
  final text = '$value'.trim();
  if (text.isEmpty) return null;
  try {
    return jsonDecode(text);
  } catch (_) {
    return value;
  }
}

List<Map<String, dynamic>> _parseEquipments(dynamic value) {
  final decoded = _decodeJsonValue(value);
  if (decoded is List) {
    return decoded.whereType<Map>().map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
  }
  return const [];
}

List<Map<String, dynamic>> _uniqueRows(List<Map<String, dynamic>> rows) {
  final seen = <String>{};
  final unique = <Map<String, dynamic>>[];
  for (final row in rows) {
    final key = [
      _label(row, ['cle']),
      _label(row, ['id']),
      _label(row, ['numeroIdentifiant']),
      _label(row, ['numeroIdentifiantEleve']),
      _label(row, ['nomComplet']),
      _label(row, ['nom']),
      _label(row, ['telephone']),
      _label(row, ['role']),
    ].where((part) => part.isNotEmpty).join('|');
    final fallback = jsonEncode(row);
    if (seen.add(key.isEmpty ? fallback : key)) {
      unique.add(row);
    }
  }
  return unique;
}

List<String> _extractStringList(dynamic value) {
  final decoded = _decodeJsonValue(value);
  if (decoded is List) {
    return decoded
        .map((item) => '$item')
        .where((item) => item.isNotEmpty)
        .toList();
  }
  if (decoded is String && decoded.trim().isNotEmpty) return [decoded.trim()];
  return [];
}

List<_ChartValueData> _chartRows(dynamic value) {
  final decoded = _decodeJsonValue(value);
  if (decoded == null) return const [];
  if (decoded is Map) {
    final labels = _asList(decoded['labels'] ?? decoded['label']);
    final values = _asList(decoded['values'] ??
        decoded['data'] ??
        decoded['datasets'] ??
        decoded['series']);
    if (labels.isNotEmpty && values.isNotEmpty) {
      final flatValues = values.length == 1 && values.first is Map
          ? _asList((values.first as Map)['data'])
          : values;
      return List.generate(labels.length, (index) {
        final rawValue = index < flatValues.length ? flatValues[index] : '';
        return _ChartValueData(
          label: _formatValue(labels[index]),
          value: _formatValue(rawValue),
        );
      });
    }

    final mapRows = decoded.entries
        .where((entry) =>
            !_isChartMetadataKey('${entry.key}') &&
            entry.value != null &&
            '${entry.value}'.isNotEmpty)
        .map((entry) {
      return _ChartValueData(
        label: _prettifyKey('${entry.key}'),
        value: _formatValue(entry.value),
      );
    }).toList();
    if (mapRows.length == 1 && decoded.values.first is List) {
      return _chartRows(decoded.values.first);
    }
    return mapRows;
  }

  if (decoded is List) {
    return decoded.whereType<Map>().map((item) {
      final row = Map<String, dynamic>.from(item);
      final label = _chartLabel(row);
      final value = _chartValue(row, label);
      final detail = _chartDetail(row, label, value);
      return _ChartValueData(
        label: label.isEmpty ? "Sans libelle" : label,
        value: value.isEmpty ? "-" : value,
        detail: detail,
      );
    }).toList();
  }

  return [
    _ChartValueData(label: "Valeur", value: _formatValue(decoded)),
  ];
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  if (value == null) return const [];
  return [value];
}

bool _isChartMetadataKey(String key) {
  final normalized = _normalize(key);
  return normalized == 'title' ||
      normalized == 'titre' ||
      normalized == 'description' ||
      normalized == 'type';
}

String _chartLabel(Map<String, dynamic> row) {
  final preferred = _label(row, [
    'label',
    'libelle',
    'nom',
    'name',
    'classe',
    'sexe',
    'genre',
    'fonction',
    'cours',
    'cour',
    'intitule',
    'matiere',
  ]);
  if (preferred.isNotEmpty) return preferred;

  for (final entry in row.entries) {
    final value = entry.value;
    if (value is! num && value is! bool && '$value'.trim().isNotEmpty) {
      return '$value'.trim();
    }
  }
  return '';
}

String _chartValue(Map<String, dynamic> row, String label) {
  final preferred = _label(row, [
    'value',
    'valeur',
    'total',
    'count',
    'nombre',
    'effectif',
    'heures',
    'nombreHeure',
    'dureeHeure',
    'taux',
    'pourcentage',
  ]);
  if (preferred.isNotEmpty && preferred != label) return preferred;

  for (final entry in row.entries) {
    final value = entry.value;
    if (value is num) return _formatValue(value);
  }
  return '';
}

String _chartDetail(Map<String, dynamic> row, String label, String value) {
  final parts = <String>[];
  for (final key in ['pourcentage', 'taux', 'anneescolaire', 'niveau']) {
    final text = _label(row, [key]);
    if (text.isNotEmpty && text != label && text != value) {
      parts.add("${_prettifyKey(key)} $text");
    }
  }
  return parts.take(2).join(' | ');
}

String _prettifyKey(String key) {
  final text = key
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) {
        return '${match.group(1)} ${match.group(2)}';
      })
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .trim();
  if (text.isEmpty) return key;
  return text[0].toUpperCase() + text.substring(1);
}

List<String> _filterValues(List<Map<String, dynamic>> rows, List<String> keys) {
  final values = rows
      .map((row) => _label(row, keys))
      .where((value) => value.trim().isNotEmpty)
      .toSet()
      .toList();
  values.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return values;
}

List<String> _mergeFilterValues(List<String> base, List<String> extra) {
  final values = <String>[];
  void add(String value) {
    if (value.trim().isEmpty) return;
    if (values.any((item) => _sameText(item, value))) return;
    values.add(value);
  }

  for (final value in base) {
    add(value);
  }
  for (final value in extra) {
    add(value);
  }
  values.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return values;
}

String _label(Map<dynamic, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && '$value'.trim().isNotEmpty) {
      return '$value'.trim();
    }
  }
  return '';
}

String _formatValue(dynamic value) {
  if (value == null) return "-";
  if (value is num) {
    final number = value.toDouble();
    if (number == number.roundToDouble()) return number.toInt().toString();
    return number.toStringAsFixed(2);
  }
  if (value is bool) return value ? "Oui" : "Non";
  return '$value';
}

String _fallbackCount(dynamic serverValue, List items) {
  if (serverValue is num && serverValue > 0) return _formatValue(serverValue);
  return items.length.toString();
}

String _fallbackNumber(dynamic serverValue, int fallback) {
  if (serverValue is num && serverValue > 0) return _formatValue(serverValue);
  return fallback.toString();
}

bool _isFemale(Map<String, dynamic> item) {
  final sex = _normalize(_label(item, ['sexe', 'genre']));
  return sex.startsWith('f') ||
      sex.contains('feminin') ||
      sex.contains('fille');
}

bool _isMale(Map<String, dynamic> item) {
  final sex = _normalize(_label(item, ['sexe', 'genre']));
  return sex.startsWith('m') ||
      sex.contains('masculin') ||
      sex.contains('garcon');
}

bool _isTruthy(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = _normalize('$value');
  return text == 'true' || text == 'vrai' || text == 'oui' || text == '1';
}

String _prettyLabel(String key) {
  const frenchLabels = <String, String>{
    'academicYear': 'Année scolaire',
    'address': 'Adresse',
    'age': 'Âge',
    'boys': 'Garçons',
    'building': 'Bâtiment',
    'buildings': 'Bâtiments',
    'category': 'Catégorie',
    'city': 'Ville',
    'class': 'Classe',
    'classes': 'Classes',
    'className': 'Nom de la classe',
    'code': 'Code',
    'comment': 'Commentaire',
    'comments': 'Commentaires',
    'commune': 'Commune',
    'completed': 'Terminé',
    'createdAt': 'Date de création',
    'data': 'Données',
    'date': 'Date',
    'description': 'Description',
    'district': 'District',
    'email': 'Adresse e-mail',
    'endDate': 'Date de fin',
    'female': 'Filles',
    'firstName': 'Prénom',
    'form': 'Formulaire',
    'forms': 'Formulaires',
    'gender': 'Sexe',
    'girls': 'Filles',
    'id': 'Identifiant',
    'isActive': 'Actif',
    'isCompleted': 'Terminé',
    'lastName': 'Nom',
    'latitude': 'Latitude',
    'level': 'Niveau',
    'longitude': 'Longitude',
    'male': 'Garçons',
    'name': 'Nom',
    'network': 'Réseau',
    'number': 'Nombre',
    'phone': 'Téléphone',
    'province': 'Province',
    'school': 'École',
    'schoolCode': 'Code de l’école',
    'schoolKey': 'Clé de l’école',
    'schoolName': 'Nom de l’école',
    'section': 'Section',
    'startDate': 'Date de début',
    'status': 'Statut',
    'student': 'Élève',
    'students': 'Élèves',
    'submittedAt': 'Date de soumission',
    'teacher': 'Enseignant',
    'teachers': 'Enseignants',
    'total': 'Total',
    'totalBoys': 'Total garçons',
    'totalGirls': 'Total filles',
    'totalStudents': 'Total des élèves',
    'type': 'Type',
    'updatedAt': 'Date de modification',
    'value': 'Valeur',
    'year': 'Année',
  };
  final translated = frenchLabels[key];
  if (translated != null) return translated;
  final withSpaces = key
      .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAll('_', ' ');
  if (withSpaces.isEmpty) return key;
  return withSpaces[0].toUpperCase() + withSpaces.substring(1);
}
