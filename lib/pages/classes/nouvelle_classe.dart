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

  String? nom; // A ou B
  String? niveau; // 1re, 2e
  String? cycle; // Primaire, Secondaire
  String? section; // LITTERAIRE, SCIENTIFIQUE, etc.
  String? option; // LATIN-PHILOSOPHIE, MATHEMATIQUE-PHYSIQUE, etc.
  int? code; // 101, 102, etc.
  DateTime? dateEnregistrement;

  final List<String> cycles = [
    'Pre-primaire',
    'Primaire',
    'CTEB (7e - 8e)',
    'Humanités générales & techniques',
  ];

  final List<String> niveaux = [
    '1ère',
    '2ème',
    '3ème',
    '4ème',
    '5ème',
    '6ème',
    '7ème',
    '8ème',
  ];

  final Map<String, List<Map<String, dynamic>>> optionsParSection = {
    'PREPRIMAIRE': [
      {'code': 097, 'nom': 'CRECHE'},
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
    ],
    'TECHNIQUE': [
      {'code': 301, 'nom': 'COMMERCIALE ET GESTION'},
      {'code': 302, 'nom': 'SECRETARIAT-ADMINISTRATION'},
      {'code': 401, 'nom': 'SOCIALE'},
      {'code': 504, 'nom': 'ESTHETIQUE & COIFFURE'},
      {'code': 505, 'nom': 'COIFFURE'},
      {'code': 601, 'nom': 'COUPE-COUTURE'},
      {'code': 701, 'nom': "HOTESSE D'ACCUEIL"},
      {'code': 702, 'nom': 'HOTELLERIE & RESTAURATION'},
      {'code': 704, 'nom': 'TOURISME'},
    ],
    'ARTISTIQUE': [
      {'code': 501, 'nom': 'ARTS PLASTIQUES'},
      {'code': 502, 'nom': 'ARTS DRAMATIQUES'},
      {'code': 503, 'nom': 'MUSIQUE'},
    ],
    'TECHNIQUE AGRICOLE': [
      {'code': 801, 'nom': 'AGRICULTURE GENERALE'},
      {'code': 802, 'nom': 'PECHE ET NAVIGATION'},
      {'code': 803, 'nom': 'VETERINAIRE'},
      {'code': 804, 'nom': 'INDUSTRIES AGRICOLES'},
      {'code': 805, 'nom': 'NUTRITION'},
      {'code': 806, 'nom': 'FORESTERIE'},
    ],
    'TECHNIQUE INDUSTRIELLE': [
      {'code': 901, 'nom': 'MECANIQUE GENERALE'},
      {'code': 902, 'nom': 'MECANIQUE MACHINES-OUTILS'},
      {'code': 903, 'nom': 'ELECTRICITE'},
      {'code': 904, 'nom': 'CONSTRUCTION'},
      {'code': 905, 'nom': 'CHIMIE INDUSTRIELLE'},
      {'code': 906, 'nom': 'ELECTRONIQUE'},
      {'code': 907, 'nom': 'IMPRIMERIE'},
      {'code': 908, 'nom': 'COMMUTATION'},
      {'code': 909, 'nom': 'RADIO-TRANSMISSION'},
      {'code': 910, 'nom': 'METEOROLOGIE'},
      {'code': 911, 'nom': 'AVIATION CIVILE'},
      {'code': 914, 'nom': 'PETRO-CHIMIE'},
      {'code': 915, 'nom': 'MECANIQUE AUTOMOBILE'},
      {'code': 916, 'nom': 'CONSTRUCTION METALLIQUE'},
      {'code': 917, 'nom': 'MENUISERIE EBENISTERIE'},
      {'code': 918, 'nom': 'MINE ET GEOLOGIE'},
      {'code': 919, 'nom': 'METALLURGIE'},
      {'code': 920, 'nom': 'DESSIN DE BATIMENT'},
      {'code': 921, 'nom': 'INSTALLATION SANITAIRE'},
      {'code': 922, 'nom': 'TOLERIE'},
      {'code': 923, 'nom': 'AJUSTAGE ET SOUDURE'},
    ],
  };

  late List<String> sections;
  List<Map<String, dynamic>> optionsDisponibles = [];
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
    sections = optionsParSection.keys.toList();
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
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdownField(
                      'Niveau',
                      niveaux,
                      (val) => setState(() => niveau = val),
                    ),
                    _buildDropdownField(
                      'Cycle',
                      cycles,
                      (val) => setState(() => cycle = val),
                    ),
                    _buildDropdownField('Section', sections, (val) {
                      setState(() {
                        section = val;
                        selectedOption = null;
                        option = null;
                        code = null;
                        optionsDisponibles = optionsParSection[val] ?? [];
                      });
                    }),
                    if (section != null && optionsDisponibles.isNotEmpty)
                      _buildOptionDropdownField(),
                    _buildDropdownField(
                      'Nom (lettre)',
                      lettres,
                      (val) => nom = val,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: null,
        items: items
            .map((val) => DropdownMenuItem(value: val, child: Text(val)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Ce champ est requis' : null,
        isExpanded: true,
      ),
    );
  }

  Widget _buildOptionDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<Map<String, dynamic>>(
        decoration: InputDecoration(
          labelText: 'Option',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        value: selectedOption,
        items: optionsDisponibles.map((optionItem) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: optionItem,
            child: Text('${optionItem['code']} - ${optionItem['nom']}'),
          );
        }).toList(),
        onChanged: (Map<String, dynamic>? newValue) {
          setState(() {
            selectedOption = newValue;
            if (newValue != null) {
              option = newValue['nom'];
              code = newValue['code'];
            } else {
              option = null;
              code = null;
            }
          });
        },
        validator: (value) =>
            value == null ? 'Veuillez s�lectionner une option' : null,
        isExpanded: true,
      ),
    );
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
        'Classe enregistr�e: $libelle | Option: $option (Code: $code) � la date du ${dt.day}-${dt.month}-${dt.year}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            rep['data']?.toString() ??
                'Classe "$libelle" enregistr�e avec l\'option ${option ?? 'Aucune'}.',
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
}
