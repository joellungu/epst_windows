part of 'smart_kelasi_schools.dart';

// ===========================================================================
// NOTES PEDAGOGIQUES
//
// Onglet "Ecole" > notes. L'affichage est centre sur l'eleve :
//   1. liste des eleves (filtrable par classe et par nom) ;
//   2. un clic ouvre le bulletin complet de l'eleve.
//
// Toute la logique de calcul (index des notes, periodes, moyennes, place) est
// centralisee dans [_NotesIndex] pour que l'interface reste simple. Les
// donnees manquantes/invalides sont tolerees : aucun acces direct non verifie.
// ===========================================================================

class _NotesPedagogiquesPage extends StatefulWidget {
  const _NotesPedagogiquesPage({
    required this.schoolName,
    required this.cleEcole,
    required this.anneescolaire,
    required this.classes,
    required this.students,
    required this.courses,
    required this.notes,
    this.initialStudent,
  });

  final String schoolName;
  final String cleEcole;
  final String anneescolaire;
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> notes;
  final Map<String, dynamic>? initialStudent;

  @override
  State<_NotesPedagogiquesPage> createState() => _NotesPedagogiquesPageState();
}

class _NotesPedagogiquesPageState extends State<_NotesPedagogiquesPage> {
  final _api = _SmartKelasiApi();
  final _searchController = TextEditingController();

  late _NotesIndex _index;
  _NotesPeriods _periods = const _NotesPeriods.empty();

  int _classIndex = -1;
  bool _loadingPeriods = true;
  bool _refreshing = false;
  bool _autoOpened = false;
  late bool _awaitingRefresh;

  @override
  void initState() {
    super.initState();
    _awaitingRefresh = widget.notes.isEmpty ||
        widget.students.isEmpty ||
        widget.classes.isEmpty;
    _rebuildIndex(
      classes: widget.classes,
      students: widget.students,
      notes: widget.notes,
    );
    _loadPeriods();
    if (_awaitingRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _rebuildIndex({
    required List<Map<String, dynamic>> classes,
    required List<Map<String, dynamic>> students,
    required List<Map<String, dynamic>> notes,
  }) {
    _index = _NotesIndex(
      schoolName: widget.schoolName,
      cleEcole: widget.cleEcole,
      anneescolaire: widget.anneescolaire,
      classes: classes,
      students: students,
      courses: widget.courses,
      notes: notes,
      periods: _periods,
    );
    _classIndex = _index.classIndexFor(widget.initialStudent);
    if (_classIndex < 0) _classIndex = _defaultClassIndex();
  }

  int _defaultClassIndex() {
    for (var i = 0; i < _index.classes.length; i++) {
      if (_index.studentsOfClass(i).isNotEmpty) return i;
    }
    return _index.classes.isEmpty ? -1 : 0;
  }

  Future<void> _loadPeriods() async {
    try {
      final periods =
          await _api.getPeriods(widget.anneescolaire, widget.cleEcole);
      if (!mounted) return;
      setState(() {
        _periods = _NotesPeriods.from(periods);
        _index = _index.withPeriods(_periods);
        _loadingPeriods = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPeriods = false);
    }
    if (!_awaitingRefresh) _maybeAutoOpen();
  }

  Future<void> _refreshData() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final results = await Future.wait<List<Map<String, dynamic>>>([
        _api.getNotes(widget.anneescolaire, widget.cleEcole),
        _api.getPeriods(widget.anneescolaire, widget.cleEcole),
        _api.getStudents(widget.anneescolaire, widget.cleEcole),
        _api.getClasses(widget.anneescolaire, widget.cleEcole),
      ]);
      if (!mounted) return;
      final notes = results[0];
      final periods = results[1];
      final students = results[2];
      final classes = results[3];
      final partial = (notes.isEmpty && _index.notes.isNotEmpty) ||
          (students.isEmpty && _index.students.isNotEmpty) ||
          (classes.isEmpty && _index.classes.isNotEmpty);
      setState(() {
        if (periods.isNotEmpty || _periods.labels.isEmpty) {
          _periods = _NotesPeriods.from(periods);
        }
        _rebuildIndex(
          classes: classes.isNotEmpty ? classes : _index.classes,
          students: students.isNotEmpty ? students : _index.students,
          notes: notes.isNotEmpty ? notes : _index.notes,
        );
        _refreshing = false;
      });
      if (partial) {
        _snack(
          "Actualisation partielle : certaines donnees n'ont pas pu etre "
          "rechargees (serveur sature). Reessayez.",
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _refreshing = false);
      _snack("Actualisation impossible : $e");
    }
    _awaitingRefresh = false;
    _maybeAutoOpen();
  }

  void _maybeAutoOpen() {
    final initial = widget.initialStudent;
    if (initial == null || _autoOpened || !mounted) return;
    _autoOpened = true;
    _openBulletin(initial);
  }

  void _openBulletin(Map<String, dynamic> student) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BulletinElevePage(index: _index, student: student),
      ),
    );
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  List<Map<String, dynamic>> _visibleStudents() {
    final query = _normalize(_searchController.text.trim());
    final source = _classIndex >= 0
        ? _index.studentsOfClass(_classIndex)
        : _index.students;
    if (query.isEmpty) return source;
    return source.where((student) {
      final haystack = _normalize(
        '${_personName(student)} ${_label(student, ['numeroIdentifiant'])} '
        '${_label(student, ['classe'])}',
      );
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Notes pedagogiques"),
            Text(
              "${widget.schoolName} • ${widget.anneescolaire}",
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Actualiser les notes",
            onPressed: _refreshing ? null : _refreshData,
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_index.classes.isEmpty && _index.students.isEmpty) {
      return const _EmptyState(
        icon: Icons.meeting_room_outlined,
        text: "Aucune classe disponible pour cette annee scolaire.",
      );
    }
    final students = _visibleStudents();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 340,
                child: DropdownButtonFormField<int>(
                  initialValue: _classIndex >= 0 ? _classIndex : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Classe",
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var i = 0; i < _index.classes.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          "${_className(_index.classes[i])} "
                          "(${_index.studentsOfClass(i).length} eleves)",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _classIndex = value);
                  },
                ),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Rechercher un eleve",
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (_loadingPeriods)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            "${students.length} eleve(s) - cliquez sur un eleve pour ouvrir "
            "son bulletin.",
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: students.isEmpty
              ? const _EmptyState(
                  icon: Icons.person_search_outlined,
                  text: "Aucun eleve trouve pour cette selection.",
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return _StudentRow(
                      index: _index,
                      student: students[index],
                      onTap: () => _openBulletin(students[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Ligne de la liste des eleves : apercu de la moyenne puis ouverture du
// bulletin au clic.
// ---------------------------------------------------------------------------

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.index,
    required this.student,
    required this.onTap,
  });

  final _NotesIndex index;
  final Map<String, dynamic> student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final summary = index.overallSummary(student);
    final place = index.placeFor(student, null);
    final classSize = index.classSizeFor(student);
    final name = _personName(student);
    final subtitle = [
      _label(student, ['numeroIdentifiant']),
      _label(student, ['classe']),
    ].where((part) => part.isNotEmpty).join(' | ');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onTap,
        leading: _EntityPhoto(
          item: student,
          type: _EntityType.student,
          radius: 22,
        ),
        title: Text(
          name.isEmpty ? "Eleve sans nom" : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _gradePercentLabel(summary.percent).isEmpty
                      ? '-'
                      : _gradePercentLabel(summary.percent),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _gradeColor(summary.percent),
                  ),
                ),
                Text(
                  place != null && classSize != null
                      ? 'Place $place/$classSize'
                      : 'Aucune note',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fiche bulletin de l'eleve.
// ---------------------------------------------------------------------------

class _BulletinElevePage extends StatelessWidget {
  const _BulletinElevePage({required this.index, required this.student});

  final _NotesIndex index;
  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    final name = _personName(student);
    final title = name.isEmpty ? "Bulletin" : "Bulletin - $name";
    final rows = index.courseRowsForStudent(student);
    final periodKeys = index.periodKeysForStudent(student);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: rows.isEmpty
                ? const _EmptyState(
                    icon: Icons.grading_outlined,
                    text: "Aucune cote enregistree pour cet eleve.",
                  )
                : _BulletinDocument(
                    index: index,
                    student: student,
                    rows: rows,
                    periodKeys: periodKeys,
                  ),
          ),
        ),
      ),
    );
  }
}

class _BulletinDocument extends StatelessWidget {
  const _BulletinDocument({
    required this.index,
    required this.student,
    required this.rows,
    required this.periodKeys,
  });

  final _NotesIndex index;
  final Map<String, dynamic> student;
  final List<_BulletinCourseRow> rows;
  final List<String> periodKeys;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BulletinDocumentHeader(index: index, student: student),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _BulletinMarkTable(
                  index: index,
                  student: student,
                  rows: rows,
                  periodKeys: periodKeys,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          _BulletinFooter(index: index, student: student),
        ],
      ),
    );
  }
}

class _BulletinDocumentHeader extends StatelessWidget {
  const _BulletinDocumentHeader({required this.index, required this.student});

  final _NotesIndex index;
  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    final name = _personName(student);
    final items = <_InfoItem>[
      _InfoItem("Eleve", name),
      _InfoItem("No identifiant", _label(student, ['numeroIdentifiant'])),
      _InfoItem("Classe", _label(student, ['classe'])),
      _InfoItem("Sexe", _label(student, ['sexe', 'genre'])),
      _InfoItem("Date de naissance", _label(student, ['dateNaissance'])),
      _InfoItem("Lieu de naissance", _label(student, ['lieuNaissance'])),
    ].where((item) => item.value.trim().isNotEmpty).toList();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _BulletinLogo(cleEcole: index.cleEcole),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      "REPUBLIQUE DEMOCRATIQUE DU CONGO",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Text(
                      "BULLETIN DE L'ELEVE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${index.schoolName}  •  Annee scolaire "
                      "${index.anneescolaire}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _BulletinStudentPhoto(student: student),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 28,
              runSpacing: 8,
              children: [
                for (final item in items)
                  SizedBox(
                    width: 220,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                        ),
                        children: [
                          TextSpan(
                            text: "${item.label} : ",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: item.value),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}

// Logo de l'ecole : telecharge depuis le serveur smart-kelasi (parametres de
// l'ecole). Si l'image est indisponible (pas de logo, hors ligne, serveur sans
// endpoint), on retombe sur le logo officiel embarque dans l'application.
class _BulletinLogo extends StatelessWidget {
  const _BulletinLogo({required this.cleEcole});

  final String cleEcole;

  @override
  Widget build(BuildContext context) {
    final fallback = Image.asset(
      'assets/logo_min_edu_nc.png',
      width: 64,
      height: 64,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.school_outlined,
        size: 40,
        color: Colors.blueGrey.shade300,
      ),
    );
    final url = _SmartKelasiApi.schoolLogoUrl(cleEcole);
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: url.isEmpty
          ? fallback
          : Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => fallback,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
    );
  }
}

// Photo d'identite de l'eleve : telechargee depuis le serveur smart-kelasi.
// Repli sur une icone si l'eleve n'a pas de photo ou en cas d'erreur reseau.
class _BulletinStudentPhoto extends StatelessWidget {
  const _BulletinStudentPhoto({required this.student});

  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 78,
      height: 78,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Icon(Icons.person, size: 46, color: Colors.blueGrey.shade300),
    );
    final url = _SmartKelasiApi.photoUrl(_EntityType.student, student);
    if (url.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 78,
        height: 78,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }
}

class _BulletinMarkTable extends StatelessWidget {
  const _BulletinMarkTable({
    required this.index,
    required this.student,
    required this.rows,
    required this.periodKeys,
  });

  final _NotesIndex index;
  final Map<String, dynamic> student;
  final List<_BulletinCourseRow> rows;
  final List<String> periodKeys;

  @override
  Widget build(BuildContext context) {
    final periodSummaries = index.periodSummariesForStudent(student);
    final overall = index.overallSummary(student);
    return DataTable(
      headingRowHeight: 44,
      dataRowMinHeight: 36,
      dataRowMaxHeight: 46,
      columnSpacing: 20,
      horizontalMargin: 12,
      columns: [
        const DataColumn(
          label: SizedBox(width: 240, child: Text("Cours")),
        ),
        for (final key in periodKeys)
          DataColumn(
            label: SizedBox(
              width: 92,
              child: Text(
                index.periodLabelOf(key),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        const DataColumn(label: Text("Total")),
        const DataColumn(label: Text("Moy.")),
      ],
      rows: [
        for (final row in rows)
          DataRow(
            cells: [
              DataCell(
                Text(
                  row.course,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              for (final key in periodKeys)
                DataCell(
                  Text(
                    _cellLabel(row.periods[key]),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              DataCell(
                Text(
                  row.total.totalLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              DataCell(
                Text(
                  _percentLabel(row.total.percent),
                  style: TextStyle(
                    color: _gradeColor(row.total.percent),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        DataRow(
          color: WidgetStateProperty.all(Colors.blueGrey.shade50),
          cells: [
            const DataCell(
              Text("MOYENNE", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
            for (final key in periodKeys)
              DataCell(
                Text(
                  _percentLabel(periodSummaries[key]?.percent),
                  style: TextStyle(
                    color: _gradeColor(periodSummaries[key]?.percent),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            DataCell(
              Text(
                overall.totalLabel,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            DataCell(
              Text(
                _percentLabel(overall.percent),
                style: TextStyle(
                  color: _gradeColor(overall.percent),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _cellLabel(_NotesSummary? summary) {
    if (summary == null || summary.count == 0) return '-';
    return _gradeNumber(summary.points);
  }
}

class _BulletinFooter extends StatelessWidget {
  const _BulletinFooter({required this.index, required this.student});

  final _NotesIndex index;
  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    final overall = index.overallSummary(student);
    final place = index.placeFor(student, null);
    final classSize = index.classSizeFor(student);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              spacing: 28,
              runSpacing: 10,
              children: [
                _FooterStat(
                  label: "Moyenne generale",
                  value: _percentLabel(overall.percent),
                  color: _gradeColor(overall.percent),
                ),
                _FooterStat(label: "Total general", value: overall.totalLabel),
                _FooterStat(
                  label: "Place",
                  value: place != null && classSize != null
                      ? '$place / $classSize'
                      : '-',
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          const _SignatureSlot(title: "Le Titulaire"),
          const SizedBox(width: 40),
          const _SignatureSlot(title: "Le Directeur"),
        ],
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  const _FooterStat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SignatureSlot extends StatelessWidget {
  const _SignatureSlot({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 40),
        Container(width: 130, height: 1, color: Colors.blueGrey.shade200),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Logique metier : index des notes et calculs.
// ---------------------------------------------------------------------------

class _NotesPeriods {
  const _NotesPeriods({required this.labels, required this.order});

  const _NotesPeriods.empty()
      : labels = const {},
        order = const {};

  final Map<String, String> labels;
  final Map<String, int> order;

  static _NotesPeriods from(List<Map<String, dynamic>> periods) {
    final labels = <String, String>{};
    final order = <String, int>{};
    var index = 0;
    for (final period in periods) {
      final key = _label(period, ['cle', 'id']);
      if (key.isEmpty) continue;
      final name = _label(period, ['nom', 'periode']);
      labels[key] = name.isEmpty ? key : name;
      order[key] = index++;
    }
    return _NotesPeriods(labels: labels, order: order);
  }

  String label(String key) {
    if (key.isEmpty) return "Periode non renseignee";
    return labels[key] ?? key;
  }

  int orderOf(String key) => order[key] ?? 100000;
}

class _NotesIndex {
  _NotesIndex({
    required this.schoolName,
    required this.cleEcole,
    required this.anneescolaire,
    required List<Map<String, dynamic>> classes,
    required List<Map<String, dynamic>> students,
    required List<Map<String, dynamic>> courses,
    required List<Map<String, dynamic>> notes,
    required this.periods,
  })  : classes = List<Map<String, dynamic>>.from(classes)
          ..sort((a, b) =>
              _normalize(_className(a)).compareTo(_normalize(_className(b)))),
        students = List<Map<String, dynamic>>.from(students)
          ..sort((a, b) =>
              _normalize(_personName(a)).compareTo(_normalize(_personName(b)))),
        courses = List<Map<String, dynamic>>.from(courses),
        notes = List<Map<String, dynamic>>.from(notes) {
    _studentsByClass = [
      for (final classe in this.classes)
        this
            .students
            .where((student) =>
                _sameClass(_label(student, ['classe']), classe))
            .toList(),
    ];
    for (final note in this.notes) {
      final id = _normalize(_label(note, ['idEleve', 'cleEleve']));
      if (id.isEmpty) continue;
      _notesByStudent.putIfAbsent(id, () => []).add(note);
    }
  }

  final String schoolName;
  final String cleEcole;
  final String anneescolaire;
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> notes;
  final _NotesPeriods periods;

  List<List<Map<String, dynamic>>> _studentsByClass = const [];
  final Map<String, List<Map<String, dynamic>>> _notesByStudent = {};

  _NotesIndex withPeriods(_NotesPeriods periods) => _NotesIndex(
        schoolName: schoolName,
        cleEcole: cleEcole,
        anneescolaire: anneescolaire,
        classes: classes,
        students: students,
        courses: courses,
        notes: notes,
        periods: periods,
      );

  List<Map<String, dynamic>> studentsOfClass(int index) {
    if (index < 0 || index >= _studentsByClass.length) return const [];
    return _studentsByClass[index];
  }

  int classIndexFor(Map<String, dynamic>? student) {
    if (student == null) return -1;
    final label = _label(student, ['classe']);
    return classes.indexWhere((classe) => _sameClass(label, classe));
  }

  Map<String, dynamic>? classForStudent(Map<String, dynamic> student) {
    final index = classIndexFor(student);
    return index >= 0 ? classes[index] : null;
  }

  int? classSizeFor(Map<String, dynamic> student) {
    final index = classIndexFor(student);
    if (index < 0) return null;
    final count = _studentsByClass[index].length;
    return count > 0 ? count : null;
  }

  List<String> _keysOf(Map<String, dynamic> student) {
    return [
      _normalize(_label(student, ['numeroIdentifiant'])),
      _normalize(_label(student, ['cle'])),
    ].where((key) => key.isNotEmpty).toList();
  }

  Set<String> _keysOfAll(List<Map<String, dynamic>> students) {
    final keys = <String>{};
    for (final student in students) {
      keys.addAll(_keysOf(student));
    }
    return keys;
  }

  List<Map<String, dynamic>> notesForStudent(Map<String, dynamic> student) {
    final result = <Map<String, dynamic>>[];
    final seen = <Object>{};
    for (final key in _keysOf(student)) {
      for (final note
          in _notesByStudent[key] ?? const <Map<String, dynamic>>[]) {
        if (seen.add(note)) result.add(note);
      }
    }
    return result;
  }

  String _identityOf(Map<String, dynamic> student) {
    final numero = _label(student, ['numeroIdentifiant']);
    if (numero.isNotEmpty) return numero;
    return _label(student, ['cle']);
  }

  String periodKeyOf(Map<String, dynamic> note) {
    return _label(note, ['idPeriode', 'idPeriodeCle', 'periode', 'nomPeriode']);
  }

  String courseKeyOf(Map<String, dynamic> note) {
    final id = _label(note, ['idCours', 'cleCours']);
    if (id.isNotEmpty) return 'id:$id';
    return 'cours:${_normalize(_label(note, ['cours', 'nomCours', 'branche']))}';
  }

  String courseLabelOf(Map<String, dynamic> note) {
    final label = _label(note, ['cours', 'nomCours', 'branche']);
    if (label.isNotEmpty) return label;
    final id = _label(note, ['idCours', 'cleCours']);
    for (final course in courses) {
      if (_label(course, ['cle', 'id']) == id) {
        final name = _label(course, ['nom', 'cours', 'intitule']);
        if (name.isNotEmpty) return name;
      }
    }
    return id.isEmpty ? "Cours sans nom" : id;
  }

  bool _noteInClass(
    Map<String, dynamic> note,
    Map<String, dynamic>? classe,
    Set<String> classStudentKeys,
  ) {
    if (classe != null) {
      final noteClass = [
        _label(note, ['niveau']),
        _label(note, ['cycle']),
        _label(note, ['section']),
        _label(note, ['option']),
        _label(note, ['lettre']),
      ].where((part) => part.isNotEmpty).join(' ');
      if (noteClass.isNotEmpty && _sameClass(noteClass, classe)) return true;
      final label = _label(note, ['classe']);
      if (label.isNotEmpty && _sameClass(label, classe)) return true;
    }
    final studentId = _normalize(_label(note, ['idEleve', 'cleEleve']));
    if (studentId.isEmpty) return false;
    return classStudentKeys.contains(studentId);
  }

  _NotesSummary summarize(Iterable<Map<String, dynamic>> notes) {
    var points = 0.0;
    var totals = 0.0;
    var count = 0;
    for (final note in notes) {
      points += _toDouble(_label(note, ['point', 'points'])) ?? 0;
      totals += _toDouble(_label(note, ['total', 'maximum'])) ?? 0;
      count++;
    }
    return _NotesSummary(points: points, totals: totals, count: count);
  }

  _NotesSummary overallSummary(Map<String, dynamic> student) =>
      summarize(notesForStudent(student));

  int? placeFor(Map<String, dynamic> student, String? periodKey) {
    final classe = classForStudent(student);
    if (classe == null) return null;
    final classIndex = classes.indexOf(classe);
    final classmates = classIndex >= 0
        ? _studentsByClass[classIndex]
        : const <Map<String, dynamic>>[];
    if (classmates.isEmpty) return null;
    final classKeys = _keysOfAll(classmates);
    final scores = <String, double>{};
    for (final item in classmates) {
      var points = 0.0;
      for (final note in notesForStudent(item)) {
        if (!_noteInClass(note, classe, classKeys)) continue;
        if (periodKey != null &&
            periodKey.isNotEmpty &&
            periodKeyOf(note) != periodKey) {
          continue;
        }
        points += _toDouble(_label(note, ['point', 'points'])) ?? 0;
      }
      final identity = _identityOf(item);
      if (identity.isEmpty) continue;
      scores[identity] = points;
    }
    final identity = _identityOf(student);
    if (identity.isEmpty || scores.isEmpty) return null;
    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final position = ranked.indexWhere((entry) => entry.key == identity) + 1;
    return position <= 0 ? null : position;
  }

  String periodLabelOf(String key) => periods.label(key);

  int _comparePeriodKeys(String a, String b) {
    final emptyA = a.isEmpty ? 1 : 0;
    final emptyB = b.isEmpty ? 1 : 0;
    if (emptyA != emptyB) return emptyA.compareTo(emptyB);
    final orderA = periods.orderOf(a);
    final orderB = periods.orderOf(b);
    if (orderA != orderB) return orderA.compareTo(orderB);
    return _normalize(periods.label(a)).compareTo(_normalize(periods.label(b)));
  }

  List<String> periodKeysForStudent(Map<String, dynamic> student) {
    final keys = <String>{};
    for (final note in notesForStudent(student)) {
      keys.add(periodKeyOf(note));
    }
    return keys.toList()..sort(_comparePeriodKeys);
  }

  Map<String, _NotesSummary> periodSummariesForStudent(
    Map<String, dynamic> student,
  ) {
    final result = <String, _NotesSummary>{};
    for (final note in notesForStudent(student)) {
      final key = periodKeyOf(note);
      final previous = result[key];
      result[key] = _NotesSummary(
        points: (previous?.points ?? 0) +
            (_toDouble(_label(note, ['point', 'points'])) ?? 0),
        totals: (previous?.totals ?? 0) +
            (_toDouble(_label(note, ['total', 'maximum'])) ?? 0),
        count: (previous?.count ?? 0) + 1,
      );
    }
    return result;
  }

  List<_BulletinCourseRow> courseRowsForStudent(Map<String, dynamic> student) {
    final labels = <String, String>{};
    final perCourse = <String, Map<String, _NotesSummary>>{};
    for (final note in notesForStudent(student)) {
      final courseKey = courseKeyOf(note);
      labels.putIfAbsent(courseKey, () => courseLabelOf(note));
      final periodKey = periodKeyOf(note);
      final map = perCourse.putIfAbsent(
        courseKey,
        () => <String, _NotesSummary>{},
      );
      final previous = map[periodKey];
      map[periodKey] = _NotesSummary(
        points: (previous?.points ?? 0) +
            (_toDouble(_label(note, ['point', 'points'])) ?? 0),
        totals: (previous?.totals ?? 0) +
            (_toDouble(_label(note, ['total', 'maximum'])) ?? 0),
        count: (previous?.count ?? 0) + 1,
      );
    }
    final rows = <_BulletinCourseRow>[];
    perCourse.forEach((courseKey, periodMap) {
      var points = 0.0;
      var totals = 0.0;
      var count = 0;
      periodMap.forEach((_, summary) {
        points += summary.points;
        totals += summary.totals;
        count += summary.count;
      });
      rows.add(_BulletinCourseRow(
        key: courseKey,
        course: labels[courseKey] ?? "Cours sans nom",
        periods: periodMap,
        total: _NotesSummary(points: points, totals: totals, count: count),
      ));
    });
    rows.sort((a, b) => _normalize(a.course).compareTo(_normalize(b.course)));
    return rows;
  }
}

class _BulletinCourseRow {
  const _BulletinCourseRow({
    required this.key,
    required this.course,
    required this.periods,
    required this.total,
  });

  final String key;
  final String course;
  final Map<String, _NotesSummary> periods;
  final _NotesSummary total;
}

class _NotesSummary {
  const _NotesSummary({
    required this.points,
    required this.totals,
    required this.count,
  });

  final double points;
  final double totals;
  final int count;

  double? get percent => totals > 0 ? (points / totals) * 100 : null;

  String get totalLabel => totals > 0
      ? '${_gradeNumber(points)} / ${_gradeNumber(totals)}'
      : _gradeNumber(points);
}

// ---------------------------------------------------------------------------
// Formatage des notes.
// ---------------------------------------------------------------------------

String _gradeNumber(double value) {
  if (value.isNaN || value.isInfinite) return '-';
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

String _gradePercentLabel(double? percent) {
  if (percent == null || percent.isNaN || percent.isInfinite) return '';
  return '${percent.toStringAsFixed(1)}%';
}

String _percentLabel(double? percent) {
  final label = _gradePercentLabel(percent);
  return label.isEmpty ? '-' : label;
}

Color _gradeColor(double? percent) {
  if (percent == null || percent.isNaN || percent.isInfinite) {
    return Colors.blueGrey.shade700;
  }
  if (percent >= 70) return Colors.green.shade700;
  if (percent >= 50) return Colors.lightGreen.shade800;
  if (percent >= 40) return Colors.orange.shade800;
  return Colors.red.shade700;
}
