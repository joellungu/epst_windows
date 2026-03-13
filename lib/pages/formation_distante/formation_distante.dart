import 'package:epst_windows_app/pages/formation_distante/InspecteurCoursScreen.dart';
import 'package:epst_windows_app/pages/formation_distante/details_inspecteur.dart';
import 'package:epst_windows_app/pages/formation_distante/horaires_admin.dart';
import 'package:epst_windows_app/pages/formation_distante/inspecteur_cours_service.dart';
import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/requette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FormationDistante extends StatefulWidget {
  final Map user;
  const FormationDistante(this.user, {Key? key}) : super(key: key);

  @override
  State<FormationDistante> createState() => _FormationDistanteState();
}

class _FormationDistanteState extends State<FormationDistante> {
  //
  final Rx<Widget> vue =
      Rx(const Center(child: Text("Selectionnez un inspecteur")));
  //
  final Requette requette = Requette();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  //
  int? _selectedInspecteurId;
  int? _selectedInspecteurRole;
  String _selectedInspecteurName = '';

  bool _loadingAssigned = false;
  Set<int> _assignedInspecteurIds = {};

  @override
  void initState() {
    super.initState();
    _loadAssignedInspecteurs();
  }

  Future<void> _loadAssignedInspecteurs() async {
    setState(() => _loadingAssigned = true);
    try {
      final resp = await InspecteurCoursService.getAll(pageIndex: 0, pageSize: 1000);
      final ids = resp.data.map((e) => e.idInspecteur).toSet();
      setState(() => _assignedInspecteurIds = ids);
    } catch (_) {
      setState(() => _assignedInspecteurIds = {});
    } finally {
      setState(() => _loadingAssigned = false);
    }
  }

  Future<void> _openHorairesForSelected() async {
    if (_selectedInspecteurId == null) return;
    vue.value = const Center(child: CircularProgressIndicator());
    setState(() {});
    try {
      final assignments =
          await InspecteurCoursService.getByInspecteurId(_selectedInspecteurId!);
      final classIds = <String>{};
      for (final a in assignments) {
        classIds.addAll(a.classe);
      }
      final listIds = classIds.toList();
      vue.value = HorairesAdminScreen(
        widget.user,
        classFilter: listIds,
        initialClassId: listIds.isNotEmpty ? listIds.first : null,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
      vue.value = HorairesAdminScreen(widget.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Rechercher inspecteur',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _query = value.trim().toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (_loadingAssigned)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: LinearProgressIndicator(),
                  ),
                FutureBuilder(
                    future: getAllInspecteurs(),
                    builder: (c, t) {
                      //
                      if (t.hasData) {
                        //
                        List list1 = t.data as List;
                        //
                        List liste = list1.where((e) {
                          int role = e['role'];
                          return role == 19 || role == 20;
                        }).toList();
                        if (_query.isNotEmpty) {
                          liste = liste.where((e) {
                            final nom = (e['nom'] ?? '').toString().toLowerCase();
                            final postnom =
                                (e['postnom'] ?? '').toString().toLowerCase();
                            final prenom =
                                (e['prenom'] ?? '').toString().toLowerCase();
                            final numero =
                                (e['numero'] ?? '').toString().toLowerCase();
                            final province =
                                (e['province'] ?? '').toString().toLowerCase();
                            return nom.contains(_query) ||
                                postnom.contains(_query) ||
                                prenom.contains(_query) ||
                                numero.contains(_query) ||
                                province.contains(_query);
                          }).toList();
                        }

                        final assignedList = liste
                            .where((e) => _assignedInspecteurIds.contains(e['id']))
                            .toList();

                        return Expanded(
                          flex: 9,
                          child: Column(
                            children: [
                              if (assignedList.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Inspecteurs deja affectes (${assignedList.length})',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: assignedList.take(6).map((ag) {
                                          return Chip(
                                            label: Text(
                                              '${ag['nom']} ${ag['postnom']}',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            backgroundColor:
                                                Colors.green.withOpacity(0.12),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                child: ListView(
                                  children: List.generate(liste.length, (a) {
                                    //
                                    Map ag = liste[a];
                                    //
                                    String roleLabel = _roleLabel(ag['role']);
                                    final bool selected =
                                        _selectedInspecteurId == ag['id'];
                                    final bool assigned =
                                        _assignedInspecteurIds.contains(ag['id']);
                                    //
                                    return ListTile(
                                      selected: selected,
                                      selectedTileColor:
                                          Colors.green.withOpacity(0.12),
                                      onTap: () {
                                        //
                                        print("Agent: $ag");
                                        _selectedInspecteurId = ag['id'];
                                        _selectedInspecteurRole = ag['role'];
                                        _selectedInspecteurName =
                                            "${ag['nom']} ${ag['postnom']} ${ag['prenom']}";
                                        //
                                        vue.value = InspecteurCoursScreen(
                                          ag['id'],
                                          roleInspecteur: ag['role'],
                                        );
                                        setState(() {});
                                      },
                                      leading: Icon(
                                        Icons.person,
                                        color: selected ? Colors.green : null,
                                      ),
                                      title: Text(
                                          "${ag['nom']} ${ag['postnom']} ${ag['prenom']}"),
                                      subtitle: Text(
                                          "$roleLabel / ${ag['numero']} / ${ag['province']}"),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (assigned)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.green
                                                    .withOpacity(0.15),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Affecte',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          selected
                                              ? const Icon(Icons.check_circle,
                                                  color: Colors.green)
                                              : const Icon(
                                                  Icons.arrow_forward_ios),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (t.hasError) {
                        //
                        print("Le data: ${t.error}");
                        //
                        return Container();
                      }

                      return const Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    })
              ],
            ),
          ),
          Expanded(
            flex: 8,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedInspecteurName.isEmpty
                              ? "Aucun inspecteur selectionne"
                              : "Inspecteur: $_selectedInspecteurName",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _selectedInspecteurId == null
                            ? null
                            : () {
                                vue.value = InspecteurCoursScreen(
                                  _selectedInspecteurId!,
                                  roleInspecteur: _selectedInspecteurRole ?? 19,
                                );
                              },
                        icon: const Icon(Icons.assignment_ind),
                        label: const Text("Affectation"),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed:
                            _selectedInspecteurId == null ? null : _openHorairesForSelected,
                        icon: const Icon(Icons.calendar_month),
                        label: const Text("Voir horaires"),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Obx(() => vue.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(int role) {
    if (role == 19) return "Inspecteur sernafor (eleves)";
    if (role == 20) return "Inspecteur sernafor (enseignants)";
    return "Inspecteur";
  }

  //
  Future<List> getAllInspecteurs() async {
    //
    List<Map<String, dynamic>> liste = await Connexion.liste_utilisateur();
    //Response response = await requette.get("");
    //
    return liste;
  }
}
