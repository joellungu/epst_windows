import 'package:epst_windows_app/pages/cours/cours_categorie_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'nouveau_cours.dart';
import 'scorm_progression_cours.dart';

class CoursCategorie extends GetView<CoursCategorieController> {
  final Map classe;
  final String typeFormation;

  CoursCategorie(this.classe, this.typeFormation, {Key? key})
      : super(key: key) {
    controller.getAllClasse(classe['id'] ?? "0", typeFormation);
  }

  final RxString cs = "".obs;

  @override
  Widget build(BuildContext context) {
    final title =
        "${classe['niveau'] ?? 'Classe'} ${classe['cycle'] ?? ''}".trim();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5EAF2)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isEmpty ? "Cours" : title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          typeFormation,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Get.to(NouveauCours(classe, typeFormation));
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Nouveau cours"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (t) {
                  cs.value = t;
                },
                decoration: InputDecoration(
                  hintText: "Rechercher un cours",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
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
            ),
            const SizedBox(height: 8),
            Expanded(
              child: controller.obx(
                (s) {
                  final coursList = s ?? [];
                  return Obx(
                    () {
                      final filtered = coursList.where((cours) {
                        return "${cours['cours']}"
                            .toLowerCase()
                            .contains(cs.value.toLowerCase());
                      }).toList();

                      if (filtered.isEmpty) {
                        return _emptyState();
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final cours = filtered[index] as Map;
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE5EAF2)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              leading: Container(
                                height: 44,
                                width: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.play_lesson_outlined,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                              title: Text(
                                "${cours['cours']}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                "Branche: ${cours['banche']} / Notion: ${cours['notion']}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Wrap(
                                spacing: 6,
                                children: [
                                  if ('${cours['type']}'.toLowerCase() == 'zip')
                                    IconButton(
                                      tooltip: "Progressions",
                                      onPressed: () {
                                        Get.to(
                                          ScormProgressionCoursPage(
                                            cours: Map<String, dynamic>.from(
                                              cours,
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.analytics_outlined,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                    ),
                                  IconButton(
                                    tooltip: "Supprimer",
                                    onPressed: () async {
                                      controller.deleteCours(
                                        {
                                          "id": cours['id'],
                                          "cls": classe['cls'],
                                          "categorie": classe['categorie'],
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                onEmpty: _emptyState(),
                onLoading: const Center(
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.menu_book_outlined,
            size: 54,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 10),
          Text(
            "Aucun cours disponible",
            style: TextStyle(
              color: Color(0xFF475569),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Ajoutez un cours pour alimenter la bibliotheque.",
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
