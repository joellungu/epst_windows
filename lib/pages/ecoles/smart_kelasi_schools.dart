import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';

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

  void _showMapModal() {
    final school = _selectedSchool;
    if (school == null) return;
    _showLargeModal(
      title: "Carte - ${_schoolName(school)}",
      icon: Icons.map_outlined,
      child: _SchoolLocationCard(school: school, expanded: true),
    );
  }

  void _showDigeModal() {
    final dashboard = _dashboard;
    final school = _selectedSchool;
    if (dashboard == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _DigeReportPage(
          forms: dashboard.forms,
          schoolName: school == null ? "École" : _schoolName(school),
        ),
      ),
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
        : _withoutTechnicalIdentity(item);
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
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _showMapModal,
              icon: const Icon(Icons.map_outlined),
              label: const Text("Carte"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _InfoSection(
          title: "Identite de l'ecole",
          child: _KeyValueGrid(values: _identityFields(school)),
        ),
        const SizedBox(height: 16),
        _InfoSection(
          title: "Localisation geographique",
          child: _SchoolLocationCard(
            school: school,
            onExpand: _showMapModal,
          ),
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
    final locationRaw = _schoolLocationRaw(school);
    final coords = _parseSchoolCoordinates(locationRaw);
    final coordsLabel = coords == null
        ? locationRaw
        : "$locationRaw  (lat: ${coords.lat.toStringAsFixed(6)}, lon: ${coords.lon.toStringAsFixed(6)})";
    return [
      _FieldValue("Cle", _schoolKey(school)),
      _FieldValue("Code ecole", _label(school, ['cleEcole'])),
      _FieldValue("Province", _label(school, ['province'])),
      _FieldValue("Province educationnelle",
          _label(school, ['provinceEducationnelle'])),
      _FieldValue(
          "Sous-division", _label(school, ['sousDevision', 'sousDivision'])),
      _FieldValue("Ville", _label(school, ['ville'])),
      _FieldValue("Commune", _label(school, ['commune'])),
      _FieldValue("Territoire", _label(school, ['territoire'])),
      _FieldValue("Secteur", _label(school, ['secteur'])),
      _FieldValue("Groupement", _label(school, ['groupement'])),
      _FieldValue("Village", _label(school, ['village'])),
      _FieldValue("Chef-lieu", _label(school, ['chefLieu'])),
      _FieldValue(
          "Centre regroupement", _label(school, ['centreRegroupement'])),
      _FieldValue("Adresse", _label(school, ['adresse'])),
      _FieldValue("Coordonnees geographiques", coordsLabel),
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

  // Le serveur limite les routes de sync a 3 requetes concurrentes par ecole
  // (429 + Retry-After au-dela). Le dashboard envoie ~20 lectures /since/ en
  // parallele : sans bride, presque tout revenait 429 et les listes
  // arrivaient vides (erreurs avalees par _safe). On bride a 3 concurrents
  // et on rejoue les 429 au lieu de les abandonner.
  static int _syncActive = 0;
  static const int _syncMaxConcurrent = 3;

  static bool _isSyncPath(String path) =>
      path.contains('/since/') || path.contains('/sync/');

  Future<void> _acquireSyncSlot() async {
    while (_syncActive >= _syncMaxConcurrent) {
      await Future.delayed(const Duration(milliseconds: 150));
    }
    _syncActive++;
  }

  void _releaseSyncSlot() {
    if (_syncActive > 0) _syncActive--;
  }

  /// Rejoue une requete sur 429 en respectant Retry-After (plafonne a 3s :
  /// les permis se liberent en quelques ms, inutile d'attendre 20s).
  Future<http.Response> _withRetry(
      Future<http.Response> Function() send) async {
    var attempt = 0;
    while (true) {
      final response = await send();
      if (response.statusCode != 429 || attempt >= 8) return response;
      attempt++;
      final retryAfter =
          int.tryParse(response.headers['retry-after'] ?? '');
      final waitSeconds = (retryAfter ?? (1 << attempt)).clamp(1, 3);
      await Future.delayed(Duration(
          milliseconds: 400 * attempt + waitSeconds * 200));
    }
  }

  Future<dynamic> _getJson(String path) async {
    final response = await _withRetry(() => _client.get(
          Uri.parse('$_baseUrl$path'),
          headers: const {'Accept': 'application/json'},
        ));
    return _decode(response);
  }

  Future<dynamic> _postJson(String path, Map<String, dynamic> body) async {
    final response = await _withRetry(() => _client.post(
          Uri.parse('$_baseUrl$path'),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json; charset=utf-8',
          },
          body: jsonEncode(body),
        ));
    return _decode(response);
  }

  Future<dynamic> _putJson(String path, dynamic body) async {
    final sync = _isSyncPath(path);
    if (sync) await _acquireSyncSlot();
    try {
      final response = await _withRetry(() => _client.put(
            Uri.parse('$_baseUrl$path'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(body),
          ));
      return _decode(response);
    } finally {
      if (sync) _releaseSyncSlot();
    }
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
      final rows = _uniqueRows(data.where(test).toList())
          .map(_withoutTechnicalIdentity)
          .toList();
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
      }).toList()).map(_withoutTechnicalIdentity).toList();
      final diplomas = _uniqueRows(teacherDiplomas.where((row) {
        return _label(row, ['numeroIdentifiant']) == numero;
      }).toList()).map(_withoutTechnicalIdentity).toList();
      final courseIds = _extractStringList(staff['cours']);
      final teacherCourses = _uniqueRows(courses.where((row) {
        final courseKey = _label(row, ['cle']);
        return courseIds.contains(courseKey) ||
            classes.any((classe) => _sameCourseClass(row, classe));
      }).toList()).map(_withoutTechnicalIdentity).toList();
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
      }).toList()).map(_withoutTechnicalIdentity).toList();
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

class _DigeReportPage extends StatelessWidget {
  const _DigeReportPage({
    required this.forms,
    required this.schoolName,
  });

  final List<Map<String, dynamic>> forms;
  final String schoolName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SIGE / DIGE — $schoolName"),
        centerTitle: false,
      ),
      body: _DigeFormsViewer(forms: forms),
    );
  }
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
          ? level.contains('preschool') ||
              level.contains('prescolaire') ||
              level.contains('st1') ||
              level.contains('lt1')
          : index == 1
              ? level.contains('primary') ||
                  level.contains('primaire') ||
                  level.contains('st2') ||
                  level.contains('lt2')
              : level.contains('secondary') ||
                  level.contains('secondaire') ||
                  level.contains('st3') ||
                  level.contains('lt3');
      if (matches) return form;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.forms.isEmpty) {
      return const Center(
        child: Text("Aucun formulaire SIGE/DIGE trouvé pour cette année."),
      );
    }
    final form = _formForLevel(_selectedLevel);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ToggleButtons(
                  isSelected:
                      List.generate(3, (index) => index == _selectedLevel),
                  onPressed: (index) => setState(() => _selectedLevel = index),
                  borderRadius: BorderRadius.circular(10),
                  constraints:
                      const BoxConstraints(minWidth: 170, minHeight: 48),
                  selectedColor: Colors.white,
                  fillColor: Colors.indigo,
                  children: const [
                    _DigeLevelButton(label: "ST1", subtitle: "Préscolaire"),
                    _DigeLevelButton(label: "ST2", subtitle: "Primaire"),
                    _DigeLevelButton(label: "ST3", subtitle: "Secondaire"),
                  ],
                ),
              ),
              if (form != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SmallBadge(
                      text: [
                        'ST1 — Préscolaire',
                        'ST2 — Primaire',
                        'ST3 — Secondaire'
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
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: form == null
              ? Center(
                  child: _EmptyState(
                    icon: Icons.assignment_late_outlined,
                    text: "Aucun formulaire ${[
                      'ST1',
                      'ST2',
                      'ST3'
                    ][_selectedLevel]} disponible.",
                  ),
                )
              : _buildFormContent(form),
        ),
      ],
    );
  }

  Widget _buildFormContent(Map<String, dynamic> form) {
    final decoded = _decodeJsonValue(form['data']);
    if (decoded is! Map) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: _DynamicViewer(value: decoded ?? form),
      );
    }
    final groups = Map<String, dynamic>.from(decoded).entries.toList();
    if (groups.isEmpty) {
      return const Center(
        child: Text("Ce formulaire ne contient aucune donnée."),
      );
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
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                child: DropdownButtonFormField<int>(
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
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  child: _DigeGroupContent(group: selectedGroup),
                ),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 290,
              child: Container(
                margin: const EdgeInsets.fromLTRB(18, 14, 0, 18),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueGrey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Text(
                        "Sous-groupes",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.blueGrey.shade800,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
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
                                backgroundColor: active
                                    ? Colors.indigo
                                    : Colors.blueGrey.shade200,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color:
                                        active ? Colors.white : Colors.black87,
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
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 14, 18, 18),
                child: _DigeGroupContent(group: selectedGroup),
              ),
            ),
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
            title: map == null ? "Élément" : _recordTitle(map),
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

/// Valeur brute du champ coordonnees geographiques de la table ecole.
/// Recherche insensible a la casse/accents + champs separes latitude/longitude.
String _schoolLocationRaw(Map<String, dynamic> school) {
  final direct = _labelInsensitive(school, [
    'localisation',
    'location',
    'localization',
    'coordonnees',
    'coordonneesGeographiques',
    'coordonnee',
    'geolocalisation',
    'geolocation',
    'geo',
    'gps',
    'latLon',
    'latLng',
    'latitude_longitude',
    'position',
    'wkt',
    'geom',
    'geometry',
  ]);
  if (direct.isNotEmpty) return direct;
  // Champs separes : reconstruit "lat, lon" pour affichage/debug.
  final lat = _findDoubleInsensitive(school, ['latitude', 'lat']);
  final lon = _findDoubleInsensitive(school, ['longitude', 'long', 'lon', 'lng']);
  if (lat != null && lon != null) return '$lat, $lon';
  return '';
}

/// Lecture insensible casse/accents/espaces dans une Map.
String _labelInsensitive(Map<dynamic, dynamic> map, List<String> keys) {
  final wanted = keys.map(_normalize).toSet();
  for (final entry in map.entries) {
    if (entry.key == null) continue;
    if (wanted.contains(_normalize('${entry.key}'))) {
      final v = entry.value;
      if (v != null && '$v'.trim().isNotEmpty) return '$v'.trim();
    }
  }
  // Repli exact (ancien comportement).
  return _label(map, keys);
}

double? _findDoubleInsensitive(Map<dynamic, dynamic> map, List<String> keys) {
  final wanted = keys.map(_normalize).toSet();
  for (final entry in map.entries) {
    if (entry.key == null) continue;
    if (wanted.contains(_normalize('${entry.key}'))) {
      final parsed = _toDouble(entry.value);
      if (parsed != null) return parsed;
    }
  }
  // Cherche aussi dans les sous-objets (ex. coordonnees: {latitude, longitude}).
  for (final entry in map.entries) {
    final v = entry.value;
    if (v is Map) {
      final nested = _findDoubleInsensitive(v, keys);
      if (nested != null) return nested;
    }
  }
  return null;
}

/// Point latitude/longitude parse depuis le champ localisation.
class _LatLng {
  const _LatLng(this.lat, this.lon);
  final double lat;
  final double lon;
}

/// Resultat parse avec source pour debug/affichage.
class _ParsedLocation {
  const _ParsedLocation(this.coords, this.raw, this.source);
  final _LatLng coords;
  final String raw;
  final String source;
}

/// Parse a partir de toute la fiche ecole (recommande) :
/// 1) champ combine (localisation, gps, wkt, GeoJSON string...)
/// 2) champs separes latitude/longitude (y compris nested)
/// 3) objet GeoJSON {type: Point, coordinates: [lon, lat]}
_ParsedLocation? _parseSchoolLocation(Map<String, dynamic> school) {
  // 3) GeoJSON en sous-objet.
  for (final entry in school.entries) {
    final v = entry.value;
    if (v is Map) {
      final geo = _parseGeoJsonMap(Map<String, dynamic>.from(v));
      if (geo != null) {
        return _ParsedLocation(geo, _schoolLocationRaw(school), 'GeoJSON (${entry.key})');
      }
      // 2b) lat/lon separes dans sous-objet.
      final lat = _findDoubleInsensitive(v, ['latitude', 'lat']);
      final lon = _findDoubleInsensitive(v, ['longitude', 'long', 'lon', 'lng']);
      if (lat != null && lon != null && _isValidLatLon(lat, lon)) {
        return _ParsedLocation(
            _LatLng(lat, lon), _schoolLocationRaw(school), 'champs separes (${entry.key})');
      }
    }
  }
  // 2) champs separes au niveau racine (prioritaire car nommes explicitement).
  final lat = _findDoubleInsensitive(school, ['latitude', 'lat']);
  final lon = _findDoubleInsensitive(school, ['longitude', 'long', 'lon', 'lng']);
  if (lat != null && lon != null && _isValidLatLon(lat, lon)) {
    return _ParsedLocation(
        _LatLng(lat, lon), '$lat, $lon', 'champs latitude/longitude');
  }
  // 1) champ combine.
  final raw = _schoolLocationRaw(school);
  if (raw.isEmpty) return null;
  final coords = _parseSchoolCoordinates(raw);
  if (coords == null) return null;
  return _ParsedLocation(coords, raw, 'champ localisation');
}

_LatLng? _parseGeoJsonMap(Map<String, dynamic> map) {
  final normalized = <String, dynamic>{};
  for (final e in map.entries) {
    normalized[_normalize('${e.key}')] = e.value;
  }
  final coordsValue = normalized['coordinates'] ?? normalized['coords'];
  if (coordsValue is List && coordsValue.length >= 2) {
    final lon = _toDouble(coordsValue[0]);
    final lat = _toDouble(coordsValue[1]);
    if (lat != null && lon != null && _isValidLatLon(lat, lon)) {
      return _LatLng(lat, lon);
    }
  }
  return null;
}

bool _isValidLatLon(double lat, double lon) {
  if (lat.isNaN || lon.isNaN) return false;
  if (lat == 0 && lon == 0) return false; // souvent = non renseigne
  return lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
}

/// Parse robuste du champ localisation.
///
/// Formats acceptes :
/// - "-4.322, 15.312" / "-4.322; 15.312" / "-4.322 15.312" (virgule ou point)
/// - "POINT(15.312 -4.322)" / "SRID=4326;POINT(15.312 -4.322)"
/// - '{"lat": -4.32, "lon": 15.31}' / '{"latitude":..,"longitude":..}'
/// - GeoJSON '{"type":"Point","coordinates":[15.31,-4.32]}'
/// L'ordre lat/lon ou lon/lat est detecte automatiquement :
/// en RDC lat ~ [-13.5, 5.5] et lon ~ [11, 32].
/// Quand la chaine contient des numeros parasites (adresse, n° rue...),
/// on prend la meilleure paire (derniere paire RDC-valide en priorite).
_LatLng? _parseSchoolCoordinates(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;

  // JSON / GeoJSON
  if (text.startsWith('{')) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        final geo = _parseGeoJsonMap(map);
        if (geo != null) return geo;
        final normalized = <String, dynamic>{};
        for (final e in map.entries) {
          normalized[_normalize('${e.key}')] = e.value;
        }
        final lat = _toDouble(normalized['latitude'] ?? normalized['lat']);
        final lon = _toDouble(normalized['longitude'] ??
            normalized['long'] ??
            normalized['lon'] ??
            normalized['lng']);
        if (lat != null && lon != null && _isValidLatLon(lat, lon)) {
          // Champs nommes : on fait confiance, sauf inversion evidente.
          return _orderLatLon(lat, lon);
        }
      }
    } catch (_) {
      // Repli : extraction des nombres ci-dessous.
    }
  }

  // WKT POINT(...) : extrait uniquement l'interieur des parentheses
  // (evite de prendre le "4326" de "SRID=4326;POINT(...)").
  final upper = text.toUpperCase();
  if (upper.contains('POINT')) {
    final m = RegExp(r'POINT\s*\(\s*(-?\d+(?:[.,]\d+)?)\s+(-?\d+(?:[.,]\d+)?)',
            caseSensitive: false)
        .firstMatch(text);
    if (m != null) {
      final lon = _toDouble(m.group(1));
      final lat = _toDouble(m.group(2));
      if (lat != null && lon != null && _isValidLatLon(lat, lon)) {
        // WKT = (lon lat) : ordre explicite, on le respecte.
        return _LatLng(lat, lon);
      }
    }
  }

  // Extraction des nombres (point OU virgule decimale).
  final matches =
      RegExp(r'-?\d+(?:[.,]\d+)?').allMatches(text).toList();
  if (matches.length < 2) return null;
  final numbers = matches
      .map((m) => _toDouble(m.group(0)))
      .whereType<double>()
      .toList();
  if (numbers.length < 2) return null;

  // Ignore un SRID isole en tete (ex. 4326 dans "SRID=4326;POINT...").
  var nums = numbers;
  if (upper.contains('SRID') && nums.length >= 3 && nums[0].abs() > 180) {
    nums = nums.sublist(1);
  }
  if (nums.length < 2) return null;

  // Cherche la meilleure paire : priorite a la derniere paire valide en RDC,
  // sinon derniere paire valide dans le monde.
  for (var i = nums.length - 2; i >= 0; i--) {
    final a = nums[i];
    final b = nums[i + 1];
    // Elimine les numeros de rue/quartier non decimaux trop grands/petits ?
    // On garde tout ce qui est geographiquement possible.
    if (!_isValidLatLon(a, b) && !_isValidLatLon(b, a)) continue;
    final ordered = _orderLatLon(a, b);
    if (_isRdc(ordered.lat, ordered.lon)) return ordered;
  }
  // Aucune paire RDC : prend la derniere paire valide.
  final a = nums[nums.length - 2];
  final b = nums[nums.length - 1];
  if (_isValidLatLon(a, b)) return _orderLatLon(a, b);
  if (_isValidLatLon(b, a)) return _orderLatLon(b, a);
  return null;
}

bool _isRdc(double lat, double lon) =>
    lat >= -13.5 && lat <= 5.5 && lon >= 11 && lon <= 32;

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    final t = value.trim().replaceAll(',', '.');
    // Garde le premier nombre valide si la chaine contient du texte autour.
    final direct = double.tryParse(t);
    if (direct != null) return direct;
    final m = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(t);
    if (m != null) return double.tryParse(m.group(0)!);
    return null;
  }
  return null;
}

/// Ordonne deux nombres en (lat, lon) en se basant sur l'emprise de la RDC.
/// Si l'ordre reste ambigu, on garde l'ordre saisi (lat, lon).
_LatLng _orderLatLon(double a, double b) {
  bool isLat(double v) => v >= -13.5 && v <= 5.5;
  bool isLon(double v) => v >= 11 && v <= 32;
  if (isLat(a) && isLon(b)) return _LatLng(a, b);
  if (isLat(b) && isLon(a)) return _LatLng(b, a);
  // Cas "lon, lat" evident hors RDC (ex. 15.3, -4.3) : corrige quand meme.
  if (a >= -90 && a <= 90 && (b < -90 || b > 90)) return _LatLng(a, b);
  if (b >= -90 && b <= 90 && (a < -90 || a > 90)) return _LatLng(b, a);
  return _LatLng(a, b);
}

String _googleMapsUrl(_LatLng coords) =>
    "https://www.google.com/maps/search/?api=1&query=${coords.lat},${coords.lon}";

String _osmUrl(_LatLng coords) =>
    "https://www.openstreetmap.org/?mlat=${coords.lat}&mlon=${coords.lon}#map=15/${coords.lat}/${coords.lon}";

/// Image statique OpenStreetMap historique (service staticmap.openstreetmap.de
/// souvent indisponible). Conservee pour compatibilite, mais l'apercu integre
/// utilise desormais [_OsmMapPreview] base sur les tuiles OSM officielles.
// ignore: unused_element
String _staticOsmMapUrl(_LatLng coords, {int width = 640, int height = 360}) =>
    "https://staticmap.openstreetmap.de/staticmap.php?center=${coords.lat},${coords.lon}"
    "&zoom=14&size=${width}x$height&maptype=mapnik"
    "&markers=${coords.lat},${coords.lon},red-pushpin";

/// Ouvre une URL dans le navigateur par defaut (Windows : cmd start).
/// Affiche un message avec le lien copiable en cas d'echec.
Future<void> _openExternalUrl(BuildContext context, String url) async {
  try {
    if (Platform.isWindows) {
      await Shell().run('cmd /c start "" "$url"');
      return;
    }
    if (Platform.isLinux) {
      await Process.run('xdg-open', [url]);
      return;
    }
    if (Platform.isMacOS) {
      await Process.run('open', [url]);
      return;
    }
    throw UnsupportedError('Plateforme non prise en charge');
  } catch (e) {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lien copie (ouverture impossible: $e) : $url")),
      );
    }
  }
}

/// Carte "Localisation" affichee sous l'identite de l'ecole + dans l'onglet Carte.
class _SchoolLocationCard extends StatelessWidget {
  const _SchoolLocationCard({required this.school, this.onExpand, this.expanded = false});

  final Map<String, dynamic> school;
  final VoidCallback? onExpand;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final parsed = _parseSchoolLocation(school);
    final raw = parsed?.raw ?? _schoolLocationRaw(school);
    final coords = parsed?.coords;
    final source = parsed?.source ?? '';
    final schoolName = _schoolName(school);
    final addressParts = [
      _labelInsensitive(school, ['adresse']),
      _labelInsensitive(school, ['village']),
      _labelInsensitive(school, ['groupement']),
      _labelInsensitive(school, ['secteur']),
      _labelInsensitive(school, ['territoire']),
      _labelInsensitive(school, ['commune']),
      _labelInsensitive(school, ['ville']),
      _labelInsensitive(school, ['province']),
    ].where((item) => item.isNotEmpty).toList();
    final addressLine = addressParts.join(', ');

    if (raw.isEmpty) {
      return Row(
        children: [
          Icon(Icons.location_off_outlined, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          const Expanded(
            child: Text("Aucune coordonnee geographique renseignee pour cette ecole."),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (raw.isNotEmpty) _SmallBadge(text: raw, color: Colors.indigo),
            if (coords != null)
              _SmallBadge(
                text:
                    "Puce : ${coords.lat.toStringAsFixed(6)}, ${coords.lon.toStringAsFixed(6)}",
                color: Colors.green,
              ),
            if (source.isNotEmpty)
              _SmallBadge(text: source, color: Colors.blueGrey),
          ],
        ),
        if (addressLine.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            addressLine,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
        const SizedBox(height: 12),
        if (coords == null)
          Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  raw.isEmpty
                      ? "Aucune coordonnee geographique renseignee pour cette ecole (localisation / latitude+longitude vides)."
                      : "Format de coordonnees non reconnu pour \"$raw\" (attendu : \"latitude, longitude\" ou \"POINT(longitude latitude)\", ou champs latitude/longitude separes).",
                ),
              ),
            ],
          )
        else
          _OsmMapPreview(
            key: ValueKey(
                '${coords.lat.toStringAsFixed(6)},${coords.lon.toStringAsFixed(6)}-$expanded'),
            coords: coords,
            expanded: expanded,
            schoolName: schoolName,
            address: addressLine,
            raw: raw,
          ),
        if (coords != null) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: "${coords.lat},${coords.lon}"),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Coordonnees copiees.")),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text("Copier"),
              ),
              OutlinedButton.icon(
                onPressed: () => _openExternalUrl(context, _googleMapsUrl(coords)),
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text("Google Maps"),
              ),
              OutlinedButton.icon(
                onPressed: () => _openExternalUrl(context, _osmUrl(coords)),
                icon: const Icon(Icons.public_outlined, size: 18),
                label: const Text("OpenStreetMap"),
              ),
              if (onExpand != null && !expanded)
                ElevatedButton.icon(
                  onPressed: onExpand,
                  icon: const Icon(Icons.fullscreen, size: 18),
                  label: const Text("Agrandir la carte"),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            "Google Maps : ${_googleMapsUrl(coords)}\nOpenStreetMap : ${_osmUrl(coords)}",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

/// Apercu carte integre base sur les tuiles OpenStreetMap officielles.
///
/// Remplace l'ancien appel a staticmap.openstreetmap.de (service souvent HS,
/// d'ou le faux message "hors-ligne" alors que l'utilisateur est connecte).
/// Aucune cle API requise, fonctionne sur Windows sans dependance supplementaire.
class _OsmMapPreview extends StatefulWidget {
  const _OsmMapPreview(
      {Key? key,
      required this.coords,
      this.expanded = false,
      this.schoolName = '',
      this.address = '',
      this.raw = ''})
      : super(key: key);

  final _LatLng coords;
  final bool expanded;
  final String schoolName;
  final String address;
  final String raw;

  @override
  State<_OsmMapPreview> createState() => _OsmMapPreviewState();
}

class _OsmMapPreviewState extends State<_OsmMapPreview> {
  int _zoom = 14;
  int _retry = 0;

  static const _tileSize = 256.0;
  static const _headers = {'User-Agent': 'EPST-Windows-App/1.0'};

  String _tileUrl(int z, int x, int y) {
    const subs = ['a', 'b', 'c'];
    final s = subs[(x + y).abs() % subs.length];
    return 'https://$s.tile.openstreetmap.org/$z/$x/$y.png';
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.expanded ? 420.0 : 260.0;
    final gridSize = widget.expanded ? 4 : 3;

    final lat = widget.coords.lat.clamp(-85.05112878, 85.05112878);
    final lon = widget.coords.lon;
    final n = math.pow(2, _zoom).toDouble();
    final latRad = lat * math.pi / 180.0;
    final xFloat = (lon + 180.0) / 360.0 * n;
    final yFloat =
        (1.0 - math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi) /
            2.0 *
            n;
    final xCenter = xFloat.floor();
    final yCenter = yFloat.floor();
    final dxPixels = (xFloat - xCenter - 0.5) * _tileSize;
    final dyPixels = (yFloat - yCenter - 0.5) * _tileSize;
    final half = gridSize ~/ 2;

    Widget tile(int x, int y) {
      final wrappedX = ((x % n.toInt()) + n.toInt()) % n.toInt();
      if (y < 0 || y >= n.toInt()) {
        return Container(width: _tileSize, height: _tileSize, color: const Color(0xFFE2E8F0));
      }
      return SizedBox(
        width: _tileSize,
        height: _tileSize,
        child: Image.network(
          _tileUrl(_zoom, wrappedX, y),
          key: ValueKey('osm-${_zoom}-${wrappedX}-$y-$_retry'),
          headers: _headers,
          fit: BoxFit.fill,
          gaplessPlayback: true,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: _tileSize,
              height: _tileSize,
              color: const Color(0xFFE2E8F0),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: _tileSize,
              height: _tileSize,
              color: const Color(0xFFE2E8F0),
              child: Icon(Icons.cloud_off_outlined, color: Colors.grey.shade500, size: 28),
            );
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: const Color(0xFFE2E8F0),
                  child: Center(
                    child: OverflowBox(
                      maxWidth: gridSize * _tileSize,
                      maxHeight: gridSize * _tileSize,
                      child: Transform.translate(
                        offset: Offset(-dxPixels, -dyPixels),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(gridSize, (row) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(gridSize, (col) {
                                return tile(xCenter - half + col, yCenter - half + row);
                              }),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Marqueur central : utilise EXACTEMENT widget.coords
              // (les tuiles ci-dessus sont centrees sur ces memes coords).
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message:
                          '${widget.coords.lat.toStringAsFixed(6)}, ${widget.coords.lon.toStringAsFixed(6)}',
                      child: const Icon(Icons.location_on,
                          color: Colors.red, size: 44),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        '${widget.coords.lat.toStringAsFixed(5)}, ${widget.coords.lon.toStringAsFixed(5)}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              // Controles zoom + retry en haut a droite.
              Positioned(
                right: 8,
                top: 8,
                child: Column(
                  children: [
                    _MapControlButton(
                      icon: Icons.add,
                      tooltip: 'Zoom +',
                      onTap: _zoom >= 18 ? null : () => setState(() => _zoom++),
                    ),
                    const SizedBox(height: 6),
                    _MapControlButton(
                      icon: Icons.remove,
                      tooltip: 'Zoom -',
                      onTap: _zoom <= 3 ? null : () => setState(() => _zoom--),
                    ),
                    const SizedBox(height: 6),
                    _MapControlButton(
                      icon: Icons.refresh,
                      tooltip: 'Recharger la carte',
                      onTap: () => setState(() => _retry++),
                    ),
                  ],
                ),
              ),
              // Infos ecole + coords exactes utilisees par la puce, en haut a gauche.
              Positioned(
                left: 8,
                top: 8,
                right: 52,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.schoolName.isNotEmpty)
                        Text(
                          widget.schoolName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (widget.address.isNotEmpty)
                        Text(
                          widget.address,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        'Puce : ${widget.coords.lat.toStringAsFixed(6)}, ${widget.coords.lon.toStringAsFixed(6)} • z$_zoom',
                        style: const TextStyle(
                            color: Colors.green, fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                      if (widget.raw.isNotEmpty)
                        Text(
                          'Source : ${widget.raw}',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
              // Attribution OSM obligatoire en bas.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.white.withOpacity(0.85),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '© OpenStreetMap contributeurs',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                        ),
                      ),
                      const Text(
                        'Connexion requise • ↻ pour recharger',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({Key? key, required this.icon, this.onTap, this.tooltip})
      : super(key: key);
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: onTap == null ? Colors.grey : Colors.black87),
        ),
      ),
    );
  }
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
  final display = _withoutTechnicalIdentity(student);
  final schoolName = _schoolName(school);
  if (schoolName.isNotEmpty) {
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

String _prettifyKey(String key) => _prettyLabel(key);

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
  final text = '$value'.trim();
  if (text.isEmpty) return "-";
  final translated = _frenchValue(text);
  return translated ?? text;
}

String _fallbackCount(dynamic serverValue, List items) {
  if (serverValue is num && serverValue > 0) return _formatValue(serverValue);
  return items.length.toString();
}

String _fallbackNumber(dynamic serverValue, int fallback) {
  if (serverValue is num && serverValue > 0) return _formatValue(serverValue);
  return fallback.toString();
}

String? _frenchValue(String value) {
  const values = <String, String>{
    'true': 'Oui',
    'false': 'Non',
    'yes': 'Oui',
    'no': 'Non',
    'oui': 'Oui',
    'non': 'Non',
    'draft': 'Brouillon',
    'submitted': 'Soumis',
    'validated': 'Validé',
    'rejected': 'Rejeté',
    'pending': 'En attente',
    'approved': 'Approuvé',
    'active': 'Actif',
    'inactive': 'Inactif',
    'enabled': 'Activé',
    'disabled': 'Désactivé',
    'male': 'Masculin',
    'female': 'Féminin',
    'boy': 'Garçon',
    'boys': 'Garçons',
    'girl': 'Fille',
    'girls': 'Filles',
    'man': 'Homme',
    'woman': 'Femme',
    'preschool': 'Préscolaire',
    'prescolaire': 'Préscolaire',
    'primary': 'Primaire',
    'primaire': 'Primaire',
    'secondary': 'Secondaire',
    'secondaire': 'Secondaire',
    'kindergarten': 'Jardin d’enfants',
    'urban': 'Urbain',
    'rural': 'Rural',
    'mechanized_paid': 'Mécanisé et payé',
    'mechanized_unpaid': 'Mécanisé et non payé',
    'non_mechanized': 'Non mécanisé',
    'program': 'Programme officiel',
    'discipline': 'Discipline à part',
    'extracurricular': 'Activité parascolaire',
    'owner': 'Propriétaire',
    'tenant': 'Locataire',
    'co_owner': 'Copropriétaire',
    'semi_dur': 'Semi-dur',
    'hard': 'En dur',
    'hedge': 'Haie',
    'tap': 'Robinet',
    'borehole': 'Forage ou puits',
    'public': 'Public',
    'private': 'Privé',
    'good': 'Bon',
    'fair': 'Moyen',
    'poor': 'Mauvais',
    'excellent': 'Excellent',
    'available': 'Disponible',
    'unavailable': 'Indisponible',
    'present': 'Présent',
    'absent': 'Absent',
    'none': 'Aucun',
    'other': 'Autre',
    'others': 'Autres',
    'unknown': 'Inconnu',
    'n/a': 'N/A',
    'na': 'N/A',
    'st1': 'ST1',
    'st2': 'ST2',
    'st3': 'ST3',
    'lt1': 'ST1',
    'lt2': 'ST2',
    'lt3': 'ST3',
  };
  return values[_normalize(value)];
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

/// Traduit les clés techniques des tableaux SIGE-DIGE en français.
/// Couvre les motifs : type_N, local_N, filial_N, qual_N, niveau_N, total_N,
/// tableauN, matériaux (endur_bon / toles_mauvais…), âges, G/F/GF, etc.
String? _digeGridLabel(String key) {
  final k = _normalize(key);
  if (k.isEmpty) return null;

  const simples = <String, String>{
    'g': 'Garçons',
    'f': 'Filles',
    'gf': 'Total',
    'gh': 'Total gén.',
    'h': 'Hommes',
    'total': 'Total',
    'bon': 'Bon état',
    'mauvais': 'Mauvais état',
    'detruit': 'Détruits',
    'detruits': 'Détruits',
    'synced': 'Synchronisé',
  };
  if (simples.containsKey(k)) return simples[k];

  // Matériaux de construction : endur_bon / semidur_mauvais / paille… / toles_…
  const materials = <String, String>{
    'endur': 'En dur',
    'semidur': 'Semi-dur',
    'paille': 'Paille (chaume)',
    'toles': 'Tôles',
    'toiles': 'Tôles',
    'terre': 'Terre battue',
  };
  final material = RegExp(r'^(endur|semidur|paille|toles|toiles|terre)(bon|mauvais)$')
      .firstMatch(k);
  if (material != null) {
    final name = materials[material.group(1)!] ?? material.group(1)!;
    final state =
        material.group(2) == 'bon' ? 'Bon état' : 'Mauvais état';
    return '$name - $state';
  }

  // Sous-tables d'effectifs (type_N, local_N, filial_N, qual_N, niveau_N…)
  final prefixes = <String, String>{
    'type': 'Type',
    'local': 'Local',
    'filial': 'Filière',
    'qual': 'Qualification',
    'niveau': 'Niveau',
    'total': 'Total',
  };
  for (final entry in prefixes.entries) {
    final match =
        RegExp('^${entry.key}(\\d+)([gh f]+)?\$').firstMatch(k);
    if (match != null) {
      final index = int.tryParse(match.group(1)!);
      final suffix = match.group(2);
      String label = index == null
          ? entry.value
          : '${entry.value} ${index + 1}';
      if (suffix != null && suffix.isNotEmpty) {
        label += ' - ${simples[suffix] ?? suffix.toUpperCase()}';
      }
      return label;
    }
  }

  // Filières / colonnes n_N_f, t_N_f, f_N_f …
  final cell = RegExp(r'^([ftn])(\d+)_(f|h)$').firstMatch(k);
  if (cell != null) {
    final index = int.tryParse(cell.group(2)!);
    final source = cell.group(1) == 'f'
        ? 'Formation'
        : cell.group(1) == 't'
            ? 'Tableau'
            : 'Niveau';
    final sex = cell.group(3) == 'f' ? 'Femmes' : 'Hommes';
    return index == null ? '$source - $sex' : '$source ${index + 1} - $sex';
  }

  final tableau = RegExp(r'^tableau(\d+[a-z]?)$').firstMatch(k);
  if (tableau != null) return 'Tableau ${tableau.group(1)!}';

  final missinfo = RegExp(r'^tableau(\d+)info$').firstMatch(k);
  if (missinfo != null) return 'Tableau ${missinfo.group(1)!} (détails)';

  final age = RegExp(r'^age_(\d+)_ans$').firstMatch(k);
  if (age != null) {
    final n = int.tryParse(age.group(1)!);
    if (n != null) return n == 1 ? 'Âge : 1 an' : 'Âge : $n ans';
  }

  final admis = RegExp(r'^admis_(francais|math|match)$').firstMatch(k);
  if (admis != null) {
    return admis.group(1) == 'francais' ? 'Admis - Français' : 'Admis - Maths';
  }

  return null;
}

String _prettyLabel(String key) {
  final raw = key.trim();
  if (raw.isEmpty) return key;

  // Clés techniques / tableaux des formulaires SIGE-DIGE
  final grid = _digeGridLabel(raw);
  if (grid != null) return grid;

  // Les formulaires SIGE/DIGE utilisent plusieurs conventions de clés
  // (camelCase, snake_case, kebab-case et variations de casse). Cette forme
  // compacte permet d'appliquer la même traduction dans tous les cas.
  final compactKey = _normalize(raw).replaceAll(RegExp(r'[^a-z0-9]'), '');
  const digeLabels = <String, String>{
    'academicYear': 'Année scolaire',
    'schoolId': 'Identifiant de l’école',
    'schoolName': 'Nom de l’école',
    'chefName': 'Nom du chef d’établissement',
    'chefPhone': 'Téléphone du chef d’établissement',
    'chefGender': 'Sexe du chef d’établissement',
    'managementRegime': 'Régime de gestion',
    'dinacopeId': 'Numéro DINACOPE',
    'mechanization': 'Situation de mécanisation',
    'isMechanized': 'Établissement mécanisé',
    'environment': 'Milieu',
    'chiefTown': 'Chef-lieu',
    'territory': 'Territoire ou commune',
    'sector': 'Secteur ou quartier',
    'groupement': 'Groupement ou chefferie',
    'educationalProvince': 'Province éducationnelle',
    'subDivision': 'Sous-division',
    'codeAdmEtablissement': 'Code administratif de l’établissement',
    'centreRegroupement': 'Centre de regroupement',
    'generalInfo': 'Informations générales',
    'statutPropriete': 'Statut de propriété',
    'typeEcole': 'Type d’école',
    'hasLocauxPartages': 'Locaux partagés',
    'nom2emeEtablissement': 'Nom du deuxième établissement',
    'hasActeJuridique': 'Acte juridique disponible',
    'sourceActeJuridique': 'Source de l’acte juridique',
    'acteSourceAutre': 'Autre source de l’acte juridique',
    'actePrefixe': 'Préfixe de l’acte juridique',
    'acteNumero': 'Numéro de l’acte juridique',
    'documentFonctionnement': 'Document de fonctionnement',
    'hasVisitesInspection': 'Visites d’inspection reçues',
    'nombreVisites': 'Nombre de visites',
    'hasInfirmerie': 'Infirmerie disponible',
    'hasInternat': 'Internat disponible',
    'programs': 'Programmes',
    'hasProgrammesOfficiels': 'Programmes officiels disponibles',
    'nombreProgrammes': 'Nombre de programmes',
    'plusAncienAnnee': 'Année du programme le plus ancien',
    'plusRecentAnnee': 'Année du programme le plus récent',
    'hasManuelProcedure': 'Manuel de procédures disponible',
    'hasPlanActionCommunautaire': 'Plan d’action communautaire disponible',
    'hasPlanCommunication': 'Plan de communication disponible',
    'hasPlanDeveloppement': 'Plan de développement disponible',
    'hasPrevisionsBudgetaires': 'Prévisions budgétaires disponibles',
    'hasTableauBord': 'Tableau de bord disponible',
    'activities': 'Activités',
    'hasProjetEtablissement': 'Projet d’établissement disponible',
    'hasFormationContinue': 'Formation continue organisée',
    'hasActivitesParascolaires': 'Activités parascolaires organisées',
    'hasForumsREP': 'Forums REP organisés',
    'hasRAP': 'RAP disponible',
    'hasRLDOperationnels': 'RLD opérationnels',
    'chefParticipeRLD': 'Participation du chef d’établissement au RLD',
    'hasAppuiTechFin': 'Appui technique ou financier reçu',
    'appuiTechFinLequel': 'Nature de l’appui technique ou financier',
    'hasProgrammeRefugies': 'Programme pour les réfugiés',
    'refugiesOrganisme': 'Organisme chargé du programme pour les réfugiés',
    'organs': 'Organes de gestion',
    'hasCOPA': 'Comité des parents disponible',
    'hasCOGES': 'Comité de gestion scolaire disponible',
    'hasMGP': 'Mécanisme de gestion des plaintes disponible',
    'hasGouvernementEleves': 'Gouvernement des élèves disponible',
    'gouvernementEleves': 'Gouvernement des élèves',
    'operational': 'Opérationnel',
    'members': 'Membres',
    'women': 'Femmes',
    'meetings': 'Réunions',
    'reports': 'Rapports',
    'presidentName': 'Nom du président',
    'presidentPhone': 'Téléphone du président',
    'presidentGender': 'Sexe du président',
    'hasCommittee': 'Comité disponible',
    'focalName': 'Nom du point focal',
    'focalPhone': 'Téléphone du point focal',
    'focalGender': 'Sexe du point focal',
    'infrastructure': 'Infrastructures',
    'hasTrees': 'Arbres disponibles',
    'treesPlanted': 'Arbres plantés',
    'hasWasteManagement': 'Gestion des déchets disponible',
    'hasWaterPoint': 'Point d’eau disponible',
    'waterPointType': 'Type de point d’eau',
    'hasEnergy': 'Source d’énergie disponible',
    'energyTypes': 'Types de sources d’énergie',
    'hasLatrines': 'Latrines disponibles',
    'latrineCounts': 'Nombre de latrines',
    'hasPlayground': 'Cour de récréation disponible',
    'hasSportsField': 'Terrain de sport disponible',
    'hasFence': 'Clôture disponible',
    'fenceType': 'Type de clôture',
    'staff': 'Effectifs du personnel',
    'teaching': 'Personnel enseignant',
    'admin': 'Personnel administratif',
    'personnel': 'Personnel',
    'enseignants': 'Enseignants',
    'administratif': 'Personnel administratif',
    'anneeEngagement': 'Année d’engagement',
    'anneeNaiss': 'Année de naissance',
    'nonPaye': 'Non payé',
    'retraite': 'Retraité',
    'themes': 'Thèmes',
    'transversalThemes': 'Thèmes transversaux',
    'hiv': 'VIH/SIDA et IST',
    'sexualHealth': 'Santé sexuelle et reproductive',
    'firstAid': 'Premiers secours',
    'violencePrevention': 'Prévention de la violence et du harcèlement',
    'hygiene': 'Hygiène personnelle et santé bucco-dentaire',
    'alcoholPrevention': 'Prévention de la consommation d’alcool',
    'tobaccoPrevention': 'Prévention du tabac et de la nicotine',
    'physicalActivities': 'Activités physiques',
    'vaccination': 'Vaccination contre les épidémies',
    'diseasePrevention': 'Prévention des maladies infectieuses',
    'genderEquality': 'Égalité des genres',
    'socialInclusion': 'Équité et inclusion sociale',
    'internetSafety': 'Utilisation sécurisée d’Internet',
    'hasProgram': 'Programme disponible',
    'inSchedule': 'Repris dans la grille horaire',
    'taught': 'Enseigné',
    'teachersTrainedEVF': 'Enseignants formés en EVF',
    'numberOfTeachersTeachingEVF': 'Nombre d’enseignants assurant l’EVF',
    'numberOfTrainedTeachers': 'Nombre d’enseignants formés',
    'numberOfTrainedTeachersF': 'Nombre d’enseignantes formées',
    'orientationCouncil': 'Conseil d’orientation',
    'recoveryCenter': 'Centre de récupération',
    'regulations': 'Règlement',
    'training': 'Formation',
    'chefForme': 'Chef d’établissement formé',
    'totalEducateurs': 'Nombre total d’éducateurs',
    'educateursFormes': 'Éducateurs formés',
    'dontFemmes': 'Dont femmes',
    'formes12Mois': 'Formés au cours des 12 derniers mois',
    'formesPremierSecours': 'Formés aux premiers secours',
    'reunionsPV': 'Réunions avec procès-verbal',
    'visitesInspection': 'Visites d’inspection',
    'inspectionC3': 'Inspection C3',
    'formationGenreTotal': 'Formation sur le genre — total',
    'formationGenreFemmes': 'Formation sur le genre — femmes',
    'formationGenreEnseignants': 'Formation des enseignants sur le genre',
    'formationPlanifTotal': 'Formation en planification — total',
    'formationPlanifFemmes': 'Formation en planification — femmes',
    'formationSanteTotal': 'Formation en santé — total',
    'formationSanteFemmes': 'Formation en santé — femmes',
    'violenceCases': 'Cas de violence',
    'statistics': 'Statistiques',
    'preschoolEnrollment': 'Effectifs du préscolaire',
    'primaryEnrollment': 'Effectifs du primaire',
    'secondaryEnrollment': 'Effectifs du secondaire',
    'numberOfFilials': 'Nombre de filières ou sections',
    'materials': 'Matériels',
    'textbooks': 'Manuels scolaires',
    'equipment': 'Équipements',
    'benches': 'Bancs',
    'adminPersonnel': 'Personnel administratif',
    'classrooms': 'Salles de classe',
    'teachers': 'Enseignants',
    'pailleBon': 'Paille — bon état',
    'pailleMauvais': 'Paille — mauvais état',
    'tolesBon': 'Tôles — bon état',
    'tolesMauvais': 'Tôles — mauvais état',
    'detruits': 'Détruits',
    'totalH': 'Total hommes',
    'totalF': 'Total femmes',
    'totalG': 'Total garçons',
    'totalGF': 'Total général',
    'key': 'Clé',
  };
  for (final entry in digeLabels.entries) {
    final candidate =
        _normalize(entry.key).replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (candidate == compactKey) return entry.value;
  }

  const frenchLabels = <String, String>{
    'academicYear': 'Année scolaire',
    'adresse': 'Adresse',
    'address': 'Adresse',
    'admin': 'Administration',
    'administration': 'Administration',
    'administrativeStaff': 'Personnel administratif',
    'age': 'Âge',
    'annee': 'Année',
    'anneeScolaire': 'Année scolaire',
    'attendance': 'Assiduité',
    'availability': 'Disponibilité',
    'average': 'Moyenne',
    'birthDate': 'Date de naissance',
    'birthday': 'Date de naissance',
    'boy': 'Garçon',
    'boys': 'Garçons',
    'building': 'Bâtiment',
    'buildings': 'Bâtiments',
    'capacity': 'Capacité',
    'category': 'Catégorie',
    'city': 'Ville',
    'class': 'Classe',
    'classes': 'Classes',
    'classroom': 'Salle de classe',
    'classrooms': 'Salles de classe',
    'className': 'Nom de la classe',
    'classSize': 'Effectif de la classe',
    'cleEcole': 'Clé de l’école',
    'code': 'Code',
    'comment': 'Commentaire',
    'comments': 'Commentaires',
    'commune': 'Commune',
    'completed': 'Terminé',
    'condition': 'État',
    'construction': 'Construction',
    'contact': 'Contact',
    'count': 'Nombre',
    'country': 'Pays',
    'course': 'Cours',
    'courses': 'Cours',
    'createdAt': 'Date de création',
    'data': 'Données',
    'date': 'Date',
    'dateOfBirth': 'Date de naissance',
    'description': 'Description',
    'device': 'Appareil',
    'devices': 'Appareils',
    'diploma': 'Diplôme',
    'diplomas': 'Diplômes',
    'disability': 'Handicap',
    'district': 'District',
    'duration': 'Durée',
    'education': 'Éducation',
    'effectif': 'Effectif',
    'electricity': 'Électricité',
    'eleve': 'Élève',
    'eleves': 'Élèves',
    'email': 'Adresse e-mail',
    'endDate': 'Date de fin',
    'enseignant': 'Enseignant',
    'enseignants': 'Enseignants',
    'enrollment': 'Inscriptions',
    'equipment': 'Équipement',
    'equipments': 'Équipements',
    'equipements': 'Équipements',
    'female': 'Filles',
    'females': 'Filles',
    'fille': 'Fille',
    'filles': 'Filles',
    'firstName': 'Prénom',
    'form': 'Formulaire',
    'forms': 'Formulaires',
    'function': 'Fonction',
    'furniture': 'Mobilier',
    'garcon': 'Garçon',
    'garcons': 'Garçons',
    'gender': 'Sexe',
    'girl': 'Fille',
    'girls': 'Filles',
    'grade': 'Niveau',
    'group': 'Groupe',
    'groups': 'Groupes',
    'handicap': 'Handicap',
    'health': 'Santé',
    'hour': 'Heure',
    'hours': 'Heures',
    'id': 'Identifiant',
    'identifier': 'Identifiant',
    'infrastructure': 'Infrastructure',
    'internet': 'Internet',
    'isActive': 'Actif',
    'isCompleted': 'Terminé',
    'kindergarten': 'Jardin d’enfants',
    'label': 'Libellé',
    'lastName': 'Nom',
    'latitude': 'Latitude',
    'level': 'Niveau',
    'library': 'Bibliothèque',
    'local': 'Local',
    'locals': 'Locaux',
    'location': 'Localisation',
    'longitude': 'Longitude',
    'male': 'Garçons',
    'males': 'Garçons',
    'manager': 'Responsable',
    'materiel': 'Matériel',
    'material': 'Matériel',
    'materials': 'Matériels',
    'maternity': 'Maternité',
    'name': 'Nom',
    'network': 'Réseau',
    'niveau': 'Niveau',
    'nom': 'Nom',
    'nombre': 'Nombre',
    'note': 'Note',
    'notes': 'Notes',
    'number': 'Nombre',
    'observation': 'Observation',
    'observations': 'Observations',
    'option': 'Option',
    'ownership': 'Propriété',
    'parent': 'Parent',
    'parents': 'Parents',
    'percentage': 'Pourcentage',
    'personnel': 'Personnel',
    'phone': 'Téléphone',
    'photo': 'Photo',
    'postnom': 'Postnom',
    'presence': 'Présence',
    'presences': 'Présences',
    'preschool': 'Préscolaire',
    'prescolaire': 'Préscolaire',
    'primary': 'Primaire',
    'primaire': 'Primaire',
    'principal': 'Préfet / Directeur',
    'profession': 'Profession',
    'promoteur': 'Promoteur',
    'province': 'Province',
    'pupil': 'Élève',
    'pupils': 'Élèves',
    'quantity': 'Quantité',
    'quarter': 'Trimestre',
    'rate': 'Taux',
    'remark': 'Remarque',
    'remarks': 'Remarques',
    'room': 'Salle',
    'rooms': 'Salles',
    'sanitation': 'Assainissement',
    'schedule': 'Horaire',
    'schedules': 'Horaires',
    'school': 'École',
    'schoolCode': 'Code de l’école',
    'schoolKey': 'Clé de l’école',
    'schoolName': 'Nom de l’école',
    'secondary': 'Secondaire',
    'secondaire': 'Secondaire',
    'section': 'Section',
    'sexe': 'Sexe',
    'sex': 'Sexe',
    'shift': 'Vacation',
    'size': 'Taille',
    'source': 'Source',
    'staff': 'Personnel',
    'startDate': 'Date de début',
    'statistics': 'Statistiques',
    'status': 'Statut',
    'student': 'Élève',
    'students': 'Élèves',
    'subject': 'Matière',
    'subjects': 'Matières',
    'submittedAt': 'Date de soumission',
    'summary': 'Résumé',
    'teacher': 'Enseignant',
    'teachers': 'Enseignants',
    'telephone': 'Téléphone',
    'title': 'Titre',
    'toilet': 'Toilette',
    'toilets': 'Toilettes',
    'total': 'Total',
    'totalBoys': 'Total garçons',
    'totalGirls': 'Total filles',
    'totalStudents': 'Total des élèves',
    'type': 'Type',
    'updatedAt': 'Date de modification',
    'value': 'Valeur',
    'ville': 'Ville',
    'water': 'Eau',
    'year': 'Année',
  };

  // Correspondance exacte (clé API)
  final exact = frenchLabels[raw] ?? frenchLabels[_normalize(raw)];
  if (exact != null) return exact;

  // Découpage camelCase / snake_case / kebab-case
  final words = raw
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAllMapped(
          RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m[1]} ${m[2]}')
      .replaceAll(RegExp(r'[_\-.]+'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  const wordMap = <String, String>{
    'academic': 'scolaire',
    'address': 'adresse',
    'admin': 'administratif',
    'administrative': 'administratif',
    'age': 'âge',
    'attendance': 'assiduité',
    'average': 'moyenne',
    'birth': 'naissance',
    'birthday': 'naissance',
    'boy': 'garçon',
    'boys': 'garçons',
    'building': 'bâtiment',
    'buildings': 'bâtiments',
    'capacity': 'capacité',
    'category': 'catégorie',
    'city': 'ville',
    'class': 'classe',
    'classes': 'classes',
    'classroom': 'salle',
    'classrooms': 'salles',
    'code': 'code',
    'comment': 'commentaire',
    'comments': 'commentaires',
    'completed': 'terminé',
    'condition': 'état',
    'contact': 'contact',
    'count': 'nombre',
    'country': 'pays',
    'course': 'cours',
    'courses': 'cours',
    'created': 'création',
    'data': 'données',
    'date': 'date',
    'description': 'description',
    'device': 'appareil',
    'devices': 'appareils',
    'diploma': 'diplôme',
    'diplomas': 'diplômes',
    'disability': 'handicap',
    'district': 'district',
    'duration': 'durée',
    'education': 'éducation',
    'electricity': 'électricité',
    'email': 'e-mail',
    'end': 'fin',
    'enrollment': 'inscriptions',
    'equipment': 'équipement',
    'equipments': 'équipements',
    'female': 'filles',
    'females': 'filles',
    'first': 'prénom',
    'form': 'formulaire',
    'forms': 'formulaires',
    'function': 'fonction',
    'furniture': 'mobilier',
    'gender': 'sexe',
    'girl': 'fille',
    'girls': 'filles',
    'grade': 'niveau',
    'group': 'groupe',
    'groups': 'groupes',
    'health': 'santé',
    'hour': 'heure',
    'hours': 'heures',
    'id': 'identifiant',
    'identifier': 'identifiant',
    'infrastructure': 'infrastructure',
    'internet': 'internet',
    'kindergarten': 'préscolaire',
    'label': 'libellé',
    'last': 'nom',
    'level': 'niveau',
    'library': 'bibliothèque',
    'local': 'local',
    'locals': 'locaux',
    'location': 'localisation',
    'male': 'garçons',
    'males': 'garçons',
    'manager': 'responsable',
    'material': 'matériel',
    'materials': 'matériels',
    'name': 'nom',
    'network': 'réseau',
    'number': 'nombre',
    'observation': 'observation',
    'observations': 'observations',
    'of': 'de',
    'option': 'option',
    'ownership': 'propriété',
    'parent': 'parent',
    'parents': 'parents',
    'percentage': 'pourcentage',
    'personnel': 'personnel',
    'phone': 'téléphone',
    'photo': 'photo',
    'presence': 'présence',
    'presences': 'présences',
    'preschool': 'préscolaire',
    'primary': 'primaire',
    'principal': 'directeur',
    'profession': 'profession',
    'province': 'province',
    'pupil': 'élève',
    'pupils': 'élèves',
    'quantity': 'quantité',
    'quarter': 'trimestre',
    'rate': 'taux',
    'remark': 'remarque',
    'remarks': 'remarques',
    'room': 'salle',
    'rooms': 'salles',
    'sanitation': 'assainissement',
    'schedule': 'horaire',
    'schedules': 'horaires',
    'school': 'école',
    'secondary': 'secondaire',
    'section': 'section',
    'sex': 'sexe',
    'shift': 'vacation',
    'size': 'taille',
    'source': 'source',
    'staff': 'personnel',
    'start': 'début',
    'statistics': 'statistiques',
    'status': 'statut',
    'student': 'élève',
    'students': 'élèves',
    'subject': 'matière',
    'subjects': 'matières',
    'submitted': 'soumission',
    'summary': 'résumé',
    'teacher': 'enseignant',
    'teachers': 'enseignants',
    'telephone': 'téléphone',
    'title': 'titre',
    'toilet': 'toilette',
    'toilets': 'toilettes',
    'total': 'total',
    'type': 'type',
    'updated': 'modification',
    'value': 'valeur',
    'water': 'eau',
    'year': 'année',
    'at': '',
    'women': 'femmes',
    'men': 'hommes',
    //'girls': 'filles',
    'teaching': 'enseignement',
    'members': 'membres',
    'meetings': 'réunions',
    'reports': 'rapports',
    'regulation': 'réglement',
    'regulations': 'réglements',
    'training': 'formation',
    'operational': 'opérationnel',
    'president': 'président',
    'committee': 'comité',
    'council': 'conseil',
    'orientation': 'orientation',
    'center': 'centre',
    'recovery': 'récupération',
    'playground': 'cour de récréation',
    'sports': 'sports',
    'fence': 'clôture',
    'trees': 'arbres',
    'planted': 'plantés',
    'energy': 'énergie',
    'latrines': 'latrines',
    'taught': 'enseigné',
  };

  final translatedWords = <String>[];
  for (final word in words) {
    final lower = word.toLowerCase();
    final mapped = wordMap[lower] ?? frenchLabels[lower];
    if (mapped == null) {
      translatedWords.add(word);
    } else if (mapped.isNotEmpty) {
      translatedWords.add(mapped);
    }
  }

  if (translatedWords.isEmpty) return raw;
  final joined =
      translatedWords.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (joined.isEmpty) return raw;
  return joined[0].toUpperCase() + joined.substring(1);
}
