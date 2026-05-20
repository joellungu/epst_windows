import 'package:epst_windows_app/pages/classes/classe_controller.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AjouterClassePage extends StatefulWidget {
  @override
  _AjouterClassePageState createState() => _AjouterClassePageState();
}

class _AjouterClassePageState extends State<AjouterClassePage> {
  final _formKey = GlobalKey<FormState>();

  final ClasseController classeController = ClasseController();

  String? nom;
  String? niveau;
  String? cycle;
  String? enseignement;
  String? section;
  String? option;
  int? code;
  DateTime? dateEnregistrement;

  final List<String> cycles = [
    'Pre-primaire',
    'Primaire',
    'CTEB (7e - 8e)',
    'Humanites generales & techniques (Cycle long)',
    'Humanites generales & techniques (Cycle court)',
  ];

  final List<String> niveaux = [
    '1ere',
    '2eme',
    '3eme',
    '4eme',
    '5eme',
    '6eme',
    '7eme',
    '8eme',
  ];

  final Map<String, List<Map<String, dynamic>>> optionsParSection = {
    'PREPRIMAIRE': [
      {'code': 097, 'nom': 'CRESH'},
      {'code': 098, 'nom': 'MATERNELLE'},
    ],
    'PRIMAIRE': [
      {'code': 099, 'nom': 'PRIMAIRE'},
    ],
    'CTEB': [
      {'code': 100, 'nom': 'CTEB'},
    ],
    'LITTERAIRE': [
      {'code': 101, 'nom': 'LATIN-PHILOSOPHIE'},
      {'code': 104, 'nom': 'LATIN-GREC'},
      {'code': 105, 'nom': 'LATIN-MATHEMATIQUE'},
    ],
    'SCIENTIFIQUE': [
      {'code': 102, 'nom': 'MATHEMATIQUE-PHYSIQUE'},
      {'code': 103, 'nom': 'CHIMIE-BIOLOGIE'},
      {'code': 106, 'nom': 'SCIENCES'},
    ],
    'PEDAGOGIQUE': [
      {'code': 201, 'nom': 'PEDAGOGIE GENERALE'},
      {'code': 202, 'nom': 'EDUCATION PHYSIQUE'},
      {'code': 203, 'nom': 'NORMALE'},
      {'code': 204, 'nom': 'PEDAGOGIE MATERNELLE'},
      {'code': 205, 'nom': 'PEDAGOGIE PRE-SCOLAIRE'},
      {'code': 206, 'nom': 'HUMANITE PEDAGOGIQUE RENOVE'},
    ],
    'TECHNIQUE': [
      {'code': 301, 'nom': 'COMMERCIALE ET GESTION'},
      {'code': 302, 'nom': 'SECRETARIAT ADMINISTRATION'},
      {'code': 401, 'nom': 'SOCIALE'},
      {'code': 501, 'nom': 'ARTS PLASTIQUES'},
      {'code': 502, 'nom': 'ARTS DRAMATIQUES'},
      {'code': 503, 'nom': 'MUSIQUE'},
      {'code': 504, 'nom': 'ESTHETIQUE & COIFFURE'},
      {'code': 505, 'nom': 'COIFFURE'},
      {'code': 601, 'nom': 'COUPE-COUTURE'},
      {'code': 701, 'nom': "HOTESSE D'ACCUEIL"},
      {'code': 702, 'nom': 'HOTELLERIE & RESTAURATION'},
      {'code': 703, 'nom': 'HEBERGEMENT'},
      {'code': 704, 'nom': 'TOURISME'},
      {'code': 801, 'nom': 'AGRICULTURE GENERALE'},
      {'code': 802, 'nom': 'PECHE ET NAVIGATION'},
      {'code': 803, 'nom': 'VETERINAIRE'},
      {'code': 804, 'nom': 'INDUSTRIES AGRICOLES'},
      {'code': 805, 'nom': 'NUTRITION'},
      {'code': 806, 'nom': 'FORESTERIE'},
      {'code': 901, 'nom': 'MECANIQUE GENERALE'},
      {'code': 902, 'nom': 'MECANIQUE MACHINES-OUTILS'},
      {'code': 903, 'nom': 'ELECTRICITE'},
      {'code': 904, 'nom': 'CONSTRUCTION'},
      {'code': 905, 'nom': 'CHIMIE INDUSTRIELLE'},
      {'code': 906, 'nom': 'ELECTRONIQUE INDUSTRIELLE'},
      {'code': 907, 'nom': 'IMPRIMERIE'},
      {'code': 908, 'nom': 'COMMUTATION'},
      {'code': 909, 'nom': 'RADIO TRANSMISSION'},
      {'code': 910, 'nom': 'METEOROLOGIE'},
      {'code': 911, 'nom': 'AVIATION CIVILE'},
      {'code': 912, 'nom': 'MECANIQUE DESSIN'},
      {'code': 913, 'nom': 'HYDRO PNEUMATIQUE'},
      {'code': 914, 'nom': 'PETROCHIMIE'},
      {'code': 915, 'nom': 'MECANIQUE AUTOMOBILE'},
      {'code': 916, 'nom': 'CONSTRUCTION METALLIQUE'},
      {'code': 917, 'nom': 'MENUISERIE'},
      {'code': 918, 'nom': 'MINES ET GEOLOGIE'},
      {'code': 919, 'nom': 'METALLURGIE'},
      {'code': 920, 'nom': 'DESSIN DE BATIMENT'},
      {'code': 921, 'nom': 'PLOMBERIE INSTALLATION SANITAIRE'},
      {'code': 922, 'nom': 'MINES ET CARRIERES'},
    ],
  };

  final List<String> enseignements = [
    'Enseignement General',
    'Enseignement Normal',
    'Enseignement Technique',
  ];

  final Map<String, List<Map<String, dynamic>>> optionsParEnseignement = {
    'Enseignement General': [
      {'code': 101, 'nom': 'LATIN - PHILO'},
      {'code': 102, 'nom': 'SCIENCES'},
      {'code': 104, 'nom': 'LATIN - GREC'},
      {'code': 105, 'nom': 'LATIN - MATHEMATIQUE'},
    ],
    'Enseignement Normal': [
      {'code': 201, 'nom': 'PEDAGOGIE - GENERALE'},
      {'code': 202, 'nom': 'EDUCATION - PHYSIQUE'},
      {'code': 203, 'nom': 'NORMALE'},
      {'code': 204, 'nom': 'PEDAGOGIE - MATERNELLE'},
      {'code': 205, 'nom': 'PEDAGOGIE - PRE-SCOLAIRE'},
    ],
    'Enseignement Technique': [],
  };

  late List<String> sections;
  List<Map<String, dynamic>> optionsDisponibles = [];
  List<Map<String, dynamic>> optionsFiltrees = [];
  final TextEditingController optionSearchCtrl = TextEditingController();

  Map<String, dynamic>? selectedOption;

  final List<String> lettres = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
  ];

  @override
  void initState() {
    super.initState();
    sections = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter une Nouvelle Classe')),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 500,
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDropdownField(
                            'Enseignement',
                            enseignements,
                            enseignement,
                            (val) {
                              setState(() {
                                enseignement = val;
                                if (val == 'Enseignement Technique') {
                                  sections = ['TECHNIQUE'];
                                  optionsDisponibles =
                                      optionsParSection['TECHNIQUE'] ?? [];
                                } else {
                                  sections =
                                      (optionsParEnseignement[val] ?? [])
                                          .map((e) => e['nom'] as String)
                                          .toList();
                                  optionsDisponibles = [];
                                }
                                section = null;
                                selectedOption = null;
                                option = null;
                                code = null;
                                optionsFiltrees = [];
                                optionSearchCtrl.clear();
                                if (sections.length == 1) {
                                  section = sections.first;
                                  if (enseignement ==
                                      'Enseignement Technique') {
                                    optionsFiltrees =
                                        List<Map<String, dynamic>>.from(
                                      optionsDisponibles,
                                    );
                                  }
                                }
                              });
                            },
                          ),
                          _buildDropdownField(
                            'Niveau',
                            niveaux,
                            niveau,
                            (val) => setState(() => niveau = val),
                          ),
                          _buildDropdownField('Cycle', cycles, cycle, (val) {
                            setState(() {
                              cycle = val;
                              if (cycle == 'Pre-primaire' ||
                                  cycle == 'Primaire' ||
                                  cycle == 'CTEB (7e - 8e)') {
                                section = cycle;
                                final key = cycle == 'Pre-primaire'
                                    ? 'PREPRIMAIRE'
                                    : (cycle == 'Primaire'
                                        ? 'PRIMAIRE'
                                        : 'CTEB');
                                optionsDisponibles =
                                    optionsParSection[key] ?? [];
                                optionsFiltrees =
                                    List<Map<String, dynamic>>.from(
                                  optionsDisponibles,
                                );
                                if (cycle == 'Pre-primaire') {
                                  option = null;
                                  code = null;
                                  selectedOption = null;
                                } else {
                                  final first = optionsDisponibles.isNotEmpty
                                      ? optionsDisponibles.first
                                      : null;
                                  if (first != null) {
                                    option = first['nom'];
                                    code = first['code'];
                                    selectedOption = first;
                                  }
                                }
                              } else {
                                if (enseignement != 'Enseignement Technique' &&
                                    enseignement != null) {
                                  sections =
                                      (optionsParEnseignement[enseignement] ??
                                              [])
                                          .map((e) => e['nom'] as String)
                                          .toList();
                                }
                              }
                            });
                          }),
                          if (sections.isNotEmpty &&
                              cycle != 'Pre-primaire' &&
                              cycle != 'Primaire' &&
                              cycle != 'CTEB (7e - 8e)')
                            _buildDropdownField(
                              enseignement == 'Enseignement Technique'
                                  ? 'Section'
                                  : 'Section / Option',
                              sections,
                              section,
                              (val) {
                                setState(() {
                                  section = val;
                                  selectedOption = null;
                                  option = null;
                                  code = null;
                                  if (enseignement ==
                                      'Enseignement Technique') {
                                    optionsDisponibles =
                                        optionsParSection[val] ?? [];
                                    optionsFiltrees =
                                        List<Map<String, dynamic>>.from(
                                      optionsDisponibles,
                                    );
                                  } else {
                                    final list =
                                        optionsParEnseignement[enseignement] ??
                                            [];
                                    final match = list.firstWhere(
                                      (e) => e['nom'] == val,
                                      orElse: () => {},
                                    );
                                    if (match.isNotEmpty) {
                                      option = match['nom'];
                                      code = match['code'];
                                      selectedOption = match;
                                    }
                                  }
                                  optionSearchCtrl.clear();
                                });
                              },
                            ),
                          if (section != null &&
                              optionsDisponibles.isNotEmpty &&
                              (enseignement == 'Enseignement Technique' ||
                                  cycle == 'Pre-primaire' ||
                                  cycle == 'Primaire' ||
                                  cycle == 'CTEB (7e - 8e)'))
                            _buildOptionDropdownField(),
                          _buildDropdownField(
                            'Nom (lettre)',
                            lettres,
                            nom,
                            (val) => setState(() => nom = val),
                          ),
                          _buildDatePicker(context),
                          SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            onPressed: _submit,
                            child: Text(
                              'Enregistrer',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    final effectiveValue =
        (value != null && items.contains(value)) ? value : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: effectiveValue,
        items: items
            .map((val) => DropdownMenuItem(value: val, child: Text(val)))
            .toList(),
        onChanged: items.isEmpty ? null : onChanged,
        validator: (value) => value == null ? 'Ce champ est requis' : null,
        isExpanded: true,
      ),
    );
  }

  Widget _buildOptionDropdownField() {
    if (optionsFiltrees.isEmpty && optionSearchCtrl.text.isEmpty) {
      optionsFiltrees = List<Map<String, dynamic>>.from(optionsDisponibles);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: optionSearchCtrl,
            decoration: InputDecoration(
              labelText: 'Rechercher une option',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              final q = value.trim().toLowerCase();
              setState(() {
                if (q.isEmpty) {
                  optionsFiltrees = List<Map<String, dynamic>>.from(
                    optionsDisponibles,
                  );
                } else {
                  optionsFiltrees = optionsDisponibles.where((opt) {
                    final nomOpt =
                        opt['nom']?.toString().toLowerCase() ?? '';
                    final codeOpt =
                        opt['code']?.toString().toLowerCase() ?? '';
                    return nomOpt.contains(q) || codeOpt.contains(q);
                  }).toList();
                }
              });
            },
            validator: (_) => selectedOption == null
                ? 'Veuillez selectionner une option'
                : null,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                itemCount: _buildOptionDisplayList().length,
                itemBuilder: (context, index) {
                  final item = _buildOptionDisplayList()[index];
                  if (item['isHeader'] == true) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        item['label'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    );
                  }
                  final opt = item['option'] as Map<String, dynamic>;
                  final isSelected = selectedOption != null &&
                      selectedOption!['code'] == opt['code'];
                  return RadioListTile<Map<String, dynamic>>(
                    dense: true,
                    value: opt,
                    groupValue: selectedOption,
                    title: Text('${opt['code']} - ${opt['nom']}'),
                    onChanged: (val) {
                      setState(() {
                        selectedOption = val;
                        option = val?['nom'];
                        code = val?['code'];
                      });
                    },
                    selected: isSelected,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildOptionDisplayList() {
    final list = optionsFiltrees.isEmpty
        ? List<Map<String, dynamic>>.from(optionsDisponibles)
        : optionsFiltrees;
    if (section != 'TECHNIQUE') {
      return list.map((o) => {'isHeader': false, 'option': o}).toList();
    }

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final opt in list) {
      final codeVal = opt['code'];
      final codeNum =
          codeVal is int ? codeVal : int.tryParse(codeVal.toString());
      final label = _techniqueGroupLabel(codeNum);
      grouped.putIfAbsent(label, () => []).add(opt);
    }

    final display = <Map<String, dynamic>>[];
    for (final entry in grouped.entries) {
      display.add({'isHeader': true, 'label': entry.key});
      for (final opt in entry.value) {
        display.add({'isHeader': false, 'option': opt});
      }
    }
    return display;
  }

  String _techniqueGroupLabel(int? code) {
    if (code == null) return 'Autres';
    if (code >= 300 && code < 400) return 'Commercial';
    if (code >= 400 && code < 500) return 'Social';
    if (code >= 500 && code < 600) return 'Arts';
    if (code >= 600 && code < 700) return 'Couture';
    if (code >= 700 && code < 800) return 'Hotellerie & Tourisme';
    if (code >= 800 && code < 900) return 'Agricole';
    if (code >= 900 && code < 1000) return 'Industriel';
    return 'Autres';
  }

  Widget _buildDatePicker(BuildContext context) {
    DateTime dt = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date d\'enregistrement',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          '${dt.day}-${dt.month}-${dt.year}',
          style: TextStyle(
            color: dateEnregistrement != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final libelle =
          '$niveau $cycle${section != null ? ' $section' : ''} $nom';

      DateTime dt = DateTime.now();
      var uuid = Uuid();
      String cle = uuid.v1();

      final now = DateTime.now();
      final localDateTimeStr = now.toLocal().toIso8601String().split('Z').first;

      Map rep = await classeController.ajouterClasse(
        cle: cle,
        nom: nom!,
        niveau: niveau!,
        cycle: cycle!,
        section: section,
        option: option,
        code: code,
        dateEnregistrement: '${dt.day}-${dt.month}-${dt.year}',
        updatedAt: localDateTimeStr,
      );

      print(
        'Classe enregistree: $libelle | Option: $option (Code: $code) a la date du ${dt.day}-${dt.month}-${dt.year}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            rep['data']?.toString() ??
                'Classe "$libelle" enregistree avec l\'option ${option ?? 'Aucune'}.',
          ),
          backgroundColor: rep['success'] ? Colors.green : Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  void dispose() {
    optionSearchCtrl.dispose();
    super.dispose();
  }
}
