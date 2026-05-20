import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cours_categorie.dart';
import 'cours_controller.dart';

class UploadCours extends GetView<CoursController> {
  UploadCours() {
    initState();
  }

  RxInt typeFormation = 0.obs;
  Rx<Widget> vue = Rx(Container());
  Widget? vue2;
  TextEditingController nom = TextEditingController();
  RxInt classe = 1.obs;
  Map classeMap = {};
  RxInt categorie = 1.obs;
  RxString id = "".obs;
  RxInt ix = RxInt(-1);

  void initState() {
    controller.getAllClasse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FB),
      child: Row(
        children: [
          Container(
            width: 360,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5EAF2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.local_library_outlined,
                            color: Color(0xFF1D4ED8),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Bibliothèque",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _formationButton(
                                label: "Eleves",
                                icon: Icons.school_outlined,
                                selected: typeFormation.value == 0,
                                onPressed: () {
                                  typeFormation.value = 0;
                                  vue.value = CoursCategorie(
                                    classeMap,
                                    "Eleve",
                                  );
                                },
                              ),
                              _formationButton(
                                label: "Professeurs",
                                icon: Icons.co_present_outlined,
                                selected: typeFormation.value == 1,
                                onPressed: () {
                                  typeFormation.value = 1;
                                  vue.value = CoursCategorie(
                                    classeMap,
                                    "Professeur",
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: controller.obx(
                    (s) {
                      final listeClasses = s as List;
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: listeClasses.length,
                        itemBuilder: (context, index) {
                          final classe = listeClasses[index] as Map;
                          classeMap = classe;
                          return Obx(
                            () {
                              final selected = ix.value == index;
                              return Material(
                                color: selected
                                    ? const Color(0xFFE9F2FF)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    vue.value = CoursCategorie(
                                      classe,
                                      typeFormation.value == 0
                                          ? "Eleve"
                                          : "Professeur",
                                    );
                                    ix.value = index;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 44,
                                          width: 44,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: selected
                                                ? const Color(0xFF1D4ED8)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.school_outlined,
                                            color: selected
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${classe['niveau']} ${classe['cycle']}",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                classe['section'] != null
                                                    ? "${classe['section']}"
                                                    : "Section non renseignee",
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: "Supprimer",
                                          onPressed: () async {
                                            controller
                                                .deleteClasse(classe['id']);
                                          },
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    onEmpty: _emptySidebar(),
                    onLoading: const Center(
                      child: SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(16),
                //   child: SizedBox(
                //     width: double.infinity,
                //     child: ElevatedButton.icon(
                //       onPressed: () => _showNewClassDialog(context),
                //       icon: const Icon(Icons.add),
                //       label: const Text("Ajouter une classe"),
                //       style: ElevatedButton.styleFrom(
                //         padding: const EdgeInsets.symmetric(vertical: 14),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
              child: Obx(() => vue.value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formationButton({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(
          foregroundColor: selected ? Colors.white : const Color(0xFF475569),
          backgroundColor:
              selected ? const Color(0xFF1D4ED8) : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _emptySidebar() {
    return const Center(
      child: Text(
        "Aucune classe disponible",
        style: TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }

  void _showNewClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nouvelle classe"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nom,
                  decoration: InputDecoration(
                    labelText: "Nom",
                    prefixIcon: const Icon(Icons.edit_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => DropdownButtonFormField<int>(
                    value: categorie.value,
                    decoration: InputDecoration(
                      labelText: "Categorie",
                      prefixIcon: const Icon(Icons.category_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text("Primaire")),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("Education de base"),
                      ),
                      DropdownMenuItem(value: 3, child: Text("Secondaire")),
                      DropdownMenuItem(value: 4, child: Text("FOAD Maternel")),
                      DropdownMenuItem(value: 5, child: Text("FOAD Primaire")),
                      DropdownMenuItem(
                        value: 6,
                        child: Text("FOAD Secondaire"),
                      ),
                      DropdownMenuItem(value: 7, child: Text("FOAD Technique")),
                    ],
                    onChanged: (value) {
                      categorie.value = value!;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Obx(
                  () => DropdownButtonFormField<int>(
                    value: classe.value,
                    decoration: InputDecoration(
                      labelText: "Classe",
                      prefixIcon: const Icon(Icons.pin_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: List.generate(8, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text("${index + 1}"),
                      );
                    }),
                    onChanged: (value) {
                      classe.value = value!;
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Annuler"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (nom.text.isNotEmpty) {
                  controller.addClasse(
                    {
                      "nom": nom.text,
                      "categorie": _categoryLabel(categorie.value),
                      "cls": classe.value,
                    },
                  );
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.check),
              label: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  String _categoryLabel(int value) {
    return {
          1: "Primaire",
          2: "Education de base",
          3: "Secondaire",
          4: "FOAD Maternel",
          5: "FOAD Primaire",
          6: "FOAD Secondaire",
          7: "FOAD Technique",
        }[value] ??
        "Primaire";
  }

  Widget detailsVue(Map<String, dynamic> mag) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 350,
            child: ListView(
              controller: ScrollController(),
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
              ),
              children: [
                SizedBox(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: const Text('Libelle'),
                    subtitle: Text('${mag['']}'),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListTile(
                    onTap: () {},
                    title: const Text('Description'),
                    subtitle: Text('${mag['']}'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: vue2!,
          )
        ],
      ),
    );
  }
}
