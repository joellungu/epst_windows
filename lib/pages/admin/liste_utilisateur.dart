import 'package:epst_windows_app/utils/connexion.dart';
import 'package:epst_windows_app/utils/roles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'update_agent.dart';

class ListUtilisateur extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ListUtilisateur();
  }
}

class _ListUtilisateur extends State<ListUtilisateur> {
  List<Map<String, dynamic>> _all = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  String? _error;

  Map<String, dynamic>? _selection;

  final TextEditingController _rechercheC = TextEditingController();
  int? _filtreRole;
  String _filtreStatut = "all";

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final liste = await Connexion.liste_utilisateur();
      if (!mounted) return;
      setState(() {
        _all = liste;
        _loading = false;
        _appliquerFiltres();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Impossible de charger la liste des agents. Vérifiez votre connexion.";
      });
    }
  }

  void _appliquerFiltres() {
    final q = _rechercheC.text.trim().toLowerCase();
    _filtered = _all.where((e) {
      if (_filtreRole != null && e["role"] != _filtreRole) return false;
      if (_filtreStatut != "all" && "${e["id_statut"]}" != _filtreStatut) {
        return false;
      }
      if (q.isNotEmpty) {
        final nom =
            "${e["nom"] ?? ''} ${e["postnom"] ?? ''} ${e["prenom"] ?? ''}"
                .toLowerCase();
        final matricule = "${e["matricule"] ?? ''}".toLowerCase();
        final numero = "${e["numero"] ?? ''}".toLowerCase();
        if (!nom.contains(q) &&
            !matricule.contains(q) &&
            !numero.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  MaterialColor _couleurRole(int role) {
    if (role == 0) return Colors.purple;
    if (role == 1) return Colors.teal;
    return Colors.blueGrey;
  }

  Widget _chipRole(Map<String, dynamic> e) {
    final r = roleIndex(e["role"]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _couleurRole(r).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _couleurRole(r).withOpacity(0.4)),
      ),
      child: Text(
        roleLabel(r),
        style: TextStyle(
          fontSize: 11,
          color: _couleurRole(r).shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _chipStatut(Map<String, dynamic> e) {
    final actif = "${e["id_statut"]}" != "0";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (actif ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: (actif ? Colors.green : Colors.red).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            actif ? Icons.check_circle : Icons.block,
            size: 12,
            color: actif ? Colors.green.shade700 : Colors.red.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            actif ? "Actif" : "Désactivé",
            style: TextStyle(
              fontSize: 11,
              color: actif ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _supprimer(Map<String, dynamic> e) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer l'agent"),
        content: Text(
            "Voulez-vous vraiment supprimer ${e["nom"]} ${e["postnom"]} ? Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirme != true) return;
    final code = await Connexion.supprimer_utilisateur(e["id"]);
    if (code == 200 || code == 201) {
      Get.snackbar("Réussite", "Agent supprimé avec succès");
      _charger();
    } else {
      Get.snackbar("Erreur", "La suppression a échoué");
    }
  }

  Future<void> _changerStatut(Map<String, dynamic> e) async {
    final Map<String, dynamic> m = Map<String, dynamic>.from(e);
    final nouveau = "${m["id_statut"]}" == "0" ? "1" : "0";
    m["id_statut"] = nouveau;
    await Connexion.update_utilisateur(m);
    Get.snackbar(
      "Réussite",
      nouveau == "0" ? "Agent désactivé" : "Agent activé",
    );
    _charger();
  }

  void _ouvrirMiseAJour(Map<String, dynamic> e) {
    showDialog(
      context: context,
      builder: (context) {
        return Material(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 50,
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Expanded(
                flex: 1,
                child: UpdatelUtilisateur(Map<String, dynamic>.from(e)),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarreFiltres() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            controller: _rechercheC,
            onChanged: (v) => setState(_appliquerFiltres),
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: "Nom, matricule, numéro...",
              suffixIcon: _rechercheC.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _rechercheC.clear();
                        setState(_appliquerFiltres);
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  initialValue: _filtreRole,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  hint: const Text("Rôle"),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text("Tous les rôles"),
                    ),
                    ...List.generate(listeRoles.length, (i) {
                      return DropdownMenuItem<int?>(
                        value: i,
                        child: Text(
                          listeRoles[i],
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (v) => setState(() {
                    _filtreRole = v;
                    _appliquerFiltres();
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _filtreStatut,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: "all", child: Text("Tous statuts")),
                    DropdownMenuItem(value: "1", child: Text("Actifs")),
                    DropdownMenuItem(value: "0", child: Text("Désactivés")),
                  ],
                  onChanged: (v) => setState(() {
                    _filtreStatut = v ?? "all";
                    _appliquerFiltres();
                  }),
                ),
              ),
              IconButton(
                tooltip: "Actualiser",
                onPressed: _charger,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "${_filtered.length} agent(s)",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  String _initiale(Map<String, dynamic> e) {
    final nom = "${e["nom"] ?? ''}";
    return nom.isEmpty ? "?" : nom[0].toUpperCase();
  }

  Widget _buildListe() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 10),
      children: List.generate(_filtered.length, (index) {
        final e = _filtered[index];
        final selectionne = _selection != null && _selection!["id"] == e["id"];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: selectionne ? Colors.green.shade50 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: selectionne ? Colors.green.shade700 : Colors.grey.shade200,
            ),
          ),
          child: ListTile(
            onTap: () {
              setState(() {
                _selection = e;
              });
            },
            leading: Container(
              height: 40,
              width: 40,
              alignment: Alignment.center,
              child: Text(
                _initiale(e),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              decoration: BoxDecoration(
                color: _couleurRole(roleIndex(e["role"])),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            title: Text(
              "${e['nom'] ?? ''}  ${e['postnom'] ?? ''}  ${e['prenom'] ?? ''}",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                _chipRole(e),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chipStatut(e),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "${e['numero']}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              onSelected: (t) {
                if (t == 1) {
                  _ouvrirMiseAJour(e);
                } else if (t == 2) {
                  _changerStatut(e);
                } else if (t == 3) {
                  _supprimer(e);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text("Mettre à jour")],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        "${e["id_statut"]}" == "0"
                            ? Icons.check_circle
                            : Icons.block,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text("${e["id_statut"]}" == "0" ? "Activer" : "Désactiver"),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Supprimer"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 420,
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildBarreFiltres(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.wifi_off,
                                      color: Colors.grey.shade400, size: 40),
                                  const SizedBox(height: 10),
                                  Text(_error!, textAlign: TextAlign.center),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: _charger,
                                    child: const Text("Réessayer"),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _filtered.isEmpty
                            ? Center(
                                child: Text(
                                  "Aucun agent ne correspond aux filtres.",
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              )
                            : _buildListe(),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: _selection == null
              ? Center(
                  child: Text(
                    "Sélectionnez un agent pour voir ses détails",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                )
              : detailsVue(_selection!),
        )
      ],
    );
  }

  Widget _champ(String titre, String valeur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valeur.isEmpty ? "-" : valeur,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget detailsVue(Map<String, dynamic> e) {
    final r = roleIndex(e["role"]);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 70,
                width: 70,
                alignment: Alignment.center,
                child: Text(
                  _initiale(e),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                decoration: BoxDecoration(
                  color: _couleurRole(r),
                  borderRadius: BorderRadius.circular(35),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${e["nom"]} ${e["postnom"]} ${e["prenom"]}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _chipRole(e),
                        const SizedBox(width: 8),
                        _chipStatut(e),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Mettre à jour",
                onPressed: () => _ouvrirMiseAJour(e),
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              Expanded(
                child: _champ("Nom", "${e["nom"] ?? ''}"),
              ),
              Expanded(
                child: _champ("Postnom", "${e["postnom"] ?? ''}"),
              ),
              Expanded(
                child: _champ("Prenom", "${e["prenom"] ?? ''}"),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _champ("Date d'enregistrement", "${e["date_de_naissance"] ?? ''}"),
              ),
              Expanded(
                child: _champ("Numéro", "${e["numero"] ?? ''}"),
              ),
              Expanded(
                child: _champ("Email", "${e["email"] ?? ''}"),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _champ("Adresse", "${e["adresse"] ?? ''}"),
              ),
              Expanded(
                child: _champ("Rôle", roleLabel(r)),
              ),
              Expanded(
                child: _champ("Matricule", "${e["matricule"] ?? ''}"),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _champ("Antenne", "${e["antenne"] ?? ''}"),
              ),
              Expanded(
                child: _champ("Province", "${e["province"] ?? ''}"),
              ),
              Expanded(
                child: _champ("District", "${e["district"] ?? ''}"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
