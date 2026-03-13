import 'package:epst_windows_app/pages/classes/nouvelle_classe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'classe_controller.dart';

class ListeClassePage extends StatefulWidget {
  @override
  _ListeClassePageState createState() => _ListeClassePageState();
}

class _ListeClassePageState extends State<ListeClassePage> {
  List classes = [];
  String? filtreNiveau;
  String? filtreCycle;
  String? filtreSection;
  //
  ClasseController classeController = ClasseController();

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
  final List<String> cycles = [
    'Maternelle',
    "Primaire",
    "CTEB (7e - 8e)",
    "Humanités générales & techniques",
  ];
  final List<String> sections = [
    // Primaire
    "Primaire",
    // CTEB
    "CTEB Général",
    // Humanités Générales
    "Latin - Philosophie",
    "Latin - Mathématiques",
    "Sciences",
    "Pédagogie Générale",
    "Commerciale et Administrative",
    "Scientifique",
    // Techniques Agricoles
    "Agriculture Générale",
    "Génie Rural",
    "Zootechnie",
    "Pédologie",
    "Technologie Agricole",
    "Agrostologie",
    "Phytopathologie",
    "Amélioration des plantes",
    // Techniques Artistiques
    "Arts Plastiques",
    "Arts Dramatiques",
    "Esthétique",
    "Filmologie",
    "Histoire de l'art",
    "Musicologie",
    "Anatomie Artistique",
    "Croquis",
    "Atelier",
    "Technologie Ameublement",
    // Techniques Commerciales
    "Comptabilité",
    "Gestion",
    "Informatique de Gestion",
    "Secrétariat",
    "Banque & Assurance",
    "Marketing",
    // Techniques Industrielles
    "Électricité Générale",
    "Électronique",
    "Mécanique Générale",
    "Mécanique Automobile",
    "Construction",
    "Travaux Publics",
    "Géomètre",
    "Métallurgie",
    "Plomberie",
    // Techniques Sociales
    "Coiffure",
    "Nutrition",
    "Hôtellerie & Tourisme",
    "Soins Infirmiers",
    "Sciences Sociales",
    // Autres trouvées dans PDF
    "Informatique",
    "Entrepreneuriat",
    "Ergonomie",
    "Coupe Cheveux",
    "Coloration & Décoloration",
    "Soutien de Coiffure",
    "Soins de Beauté",
    "Gestion & Administration",
    "Législation Sociale",
  ];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final data = await classeController.getClasses();
    setState(() => classes = data);
  }

  void _resetFiltres() {
    classeController.resetFiltres(
      niveau: filtreNiveau!,
      cycle: filtreCycle!,
      section: filtreSection,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildDropdown('Niveau', niveaux, filtreNiveau, (val) {
                  print("Data: $val");
                  setState(() => filtreNiveau = val);
                  //_loadClasses();
                }),
                _buildDropdown('Cycle', cycles, filtreCycle, (val) {
                  setState(() => filtreCycle = val);
                  //_loadClasses();
                }),
                _buildDropdown('Section', sections, filtreSection, (val) {
                  setState(() => filtreSection = val);
                  //_loadClasses();
                }),
                ElevatedButton(
                  onPressed: _resetFiltres,
                  child: Text(
                    'Filtre',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _loadClasses();
                  },
                  child: Text(
                    'Tout',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: classes.isEmpty
                ? Center(child: Text("Aucune classe trouvée"))
                : Center(
                    child: Container(
                      width: 500,
                      child: ListView.builder(
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final classe = classes[index];
                          final libelle =
                              '${classe['niveau']} ${classe['cycle']}'
                              '${classe['section'] != null ? ' ${classe['section']}' : ''}';
                          return ListTile(
                            leading: SvgPicture.asset(
                              "assets/HugeiconsMortarboard02.svg",
                              width: 35,
                              colorFilter: const ColorFilter.mode(
                                Colors.blue,
                                BlendMode.srcIn,
                              ),
                              semanticsLabel: 'Red dash paths',
                            ),
                            title: Text(
                              libelle,
                              style: TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              'Enregistrée le ${classe['dateEnregistrement']}',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                //
                                classeController.supprimerClasse(
                                  id: classe['id'],
                                );
                                _loadClasses();
                              },
                              icon: Icon(Icons.delete, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //
          Get.to(AjouterClassePage());
          //
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(label),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        // onChanged: (onChanged) {
        //   //
        //   setState(() {
        //     value = onChanged;
        //     _loadClasses();
        //   });
        // },
      ),
    );
  }
}
