import 'package:epst_windows_app/main.dart';
import 'package:epst_windows_app/pages/chat/ConversationList.dart';
import 'package:epst_windows_app/pages/classes/classe.dart';
import 'package:epst_windows_app/pages/cours/scorm_progression_eleves.dart';
import 'package:epst_windows_app/pages/demande_documents/demande_documents.dart';
import 'package:epst_windows_app/pages/document_officiel/arretes_ministeriel.dart';
import 'package:epst_windows_app/pages/document_officiel/message_phonique.dart';
import 'package:epst_windows_app/pages/document_officiel/notes_circulaires.dart';
import 'package:epst_windows_app/pages/document_officiel/notifications_arretes.dart';
import 'package:epst_windows_app/pages/formation_distante/formation_distante.dart';
import 'package:epst_windows_app/pages/formation_distante/horaires_admin.dart';
import 'package:epst_windows_app/pages/formation_distante/live_sessions_admin.dart';
import 'package:epst_windows_app/pages/plainte/plainte.dart';
import 'package:epst_windows_app/pages/profile/profile.dart';
import 'package:epst_windows_app/pages/sms_compagne.dart';
import 'package:epst_windows_app/pages/reformes/uploade_reformes.dart';
import 'package:epst_windows_app/splash.dart';
import 'package:epst_windows_app/utils/roles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:split_view/split_view.dart';
import 'admin/admin.dart';
import 'annonces/annonces.dart';
import 'archive/archive.dart';
import 'cours/cours.dart';
import 'cours/scorm_progression_professeurs.dart';
import 'demande_diplome/demande_diplome.dart';
import 'secretariat/secretaria_general.dart';
import 'ecoles/smart_kelasi_schools.dart';
import 'load_mag/uploade_magasin.dart';
import 'mutuelle/mutuelle.dart';
import 'parametre/taux.dart';
import 'transferts_eleves/transferts_eleves.dart';

class Accueil extends StatefulWidget {
  final Map<String, dynamic> u;
  const Accueil(this.u, {Key? key}) : super(key: key);
  //
  @override
  State<StatefulWidget> createState() {
    return _Accueil();
  }
}

class _Accueil extends State<Accueil> {
  Widget? aff;
  String titre = "Accueil";
  List<Map<String, dynamic>> sections = [];

  int get _role => roleIndex(widget.u['role']);

  bool _is(List<int> roles) => roles.contains(_role);

  List<Map<String, dynamic>> _options(List<Map<String, dynamic>> ops) =>
      ops.where((o) => o.isNotEmpty).toList();

  @override
  void initState() {
    aff = Center(
      child: Container(
        height: 300,
        width: 300,
        alignment: Alignment.center,
        child: Image.asset(
          "assets/logo_min_edu_nc.png",
          fit: BoxFit.fill,
        ),
      ),
    );
    //
    role = _role;
    //
    nomC = "${widget.u['postnom']} ${widget.u['prenom']}";
    //
    sections = [
      {
        "titre": "Communication",
        "options": _options([
          if (_is([0, 1, 16, 17]))
            {"nom": "Annonces", "icon": Icons.campaign},
          if (_is([0, 4]))
            {"nom": "Chat avec public", "icon": Icons.forum_outlined},
          if (_is([0, 5]))
            {"nom": "SMS compagne", "icon": Icons.sms_outlined},
          if (_is([0])) {"nom": "Chat archive", "icon": Icons.archive_outlined},
        ]),
      },
      {
        "titre": "Documents officiels",
        "options": _options([
          if (_is([0, 1, 16, 17]))
            {"nom": "Arretés ministeriels", "icon": Icons.gavel},
          if (_is([0, 1, 16]))
            {
              "nom": "Notification arretés",
              "icon": Icons.notifications_active_outlined
            },
          if (_is([0, 1, 16, 17]))
            {"nom": "Notes circulaires", "icon": Icons.sticky_note_2_outlined},
          if (_is([0, 1, 16]))
            {
              "nom": "Message phonique",
              "icon": Icons.record_voice_over_outlined
            },
          if (_is([0, 1, 16, 17]))
            {
              "nom": "Secrétariat général",
              "icon": Icons.account_balance_outlined
            },
        ]),
      },
      {
        "titre": "Demandes et services",
        "options": _options([
          if (_is([0, 2, 3]))
            {
              "nom": "MGP plainte orientation",
              "icon": Icons.support_agent
            },
          if (_is([0, 1, 7, 9, 10]))
            {"nom": "Demande Documents", "icon": Icons.folder_copy_outlined},
          if (_is([0, 1, 7, 8, 13]))
            {
              "nom": "Demande Diplome",
              "icon": Icons.workspace_premium_outlined
            },
          if (_is([0, 1, 7, 8, 14, 15]))
            {"nom": "Transferts eleves", "icon": Icons.swap_horiz},
          if (_is([0, 6]))
            {"nom": "Mutuelle", "icon": Icons.volunteer_activism},
        ]),
      },
      {
        "titre": "Formation et cours",
        "options": _options([
          if (_is([0, 18, 19, 20, 21]))
            {"nom": "Formation en ligne", "icon": Icons.ondemand_video},
          if (_is([0, 18, 19, 20, 21]))
            {"nom": "Horaires cours", "icon": Icons.schedule},
          if (_is([0, 21]))
            {"nom": "Lives streaming", "icon": Icons.live_tv},
          if (_is([0])) {"nom": "Classes", "icon": Icons.class_},
          if (_is([0]))
            {
              "nom": "Bibliothèque",
              "icon": Icons.local_library_outlined
            },
          if (_is([0, 1]))
            {
              "nom": "Upload formation EPST",
              "icon": Icons.cast_for_education
            },
          if (_is([0]))
            {
              "nom": "Progression professeurs",
              "icon": Icons.insights
            },
          if (_is([0]))
            {
              "nom": "Progression eleves",
              "icon": Icons.school_outlined
            },
        ]),
      },
      {
        "titre": "Écoles et gestion",
        "options": _options([
          if (_is([0, 11, 12])) {"nom": "Ecoles", "icon": Icons.school},
          if (_is([0])) {"nom": "Taux", "icon": Icons.currency_exchange},
          if (_is([0, 1]))
            {"nom": "Upload magasin", "icon": Icons.storefront_outlined},
          if (_is([0, 1]))
            {"nom": "Upload réformes", "icon": Icons.fact_check_outlined},
        ]),
      },
      {
        "titre": "Administration",
        "options": _options([
          if (_is([0]))
            {
              "nom": "Admin",
              "icon": Icons.admin_panel_settings_outlined
            },
        ]),
      },
      {
        "titre": "Compte",
        "options": _options([
          {"nom": "Profile", "icon": Icons.account_circle_outlined},
          {"nom": "Quitter", "icon": Icons.logout},
        ]),
      },
    ];
    //
    super.initState();
  }

  void _ouvrir(String nom) {
    switch (nom) {
      case "Upload magasin":
        setState(() => aff = UploadMagasin());
        break;
      case "Upload réformes":
        setState(() => aff = UploadReformes());
        break;
      case "Formation en ligne":
        setState(() => aff = FormationDistante(widget.u));
        break;
      case "Chat avec public":
        setState(
            () => aff = ConversationList(widget.u,
                agentMatricule: widget.u['matricule']));
        break;
      case "Bibliothèque":
      case "Upload formation EPST":
        setState(() => aff = UploadCours());
        break;
      case "Progression professeurs":
        setState(() => aff = const ScormProgressionProfesseursPage());
        break;
      case "Progression eleves":
        setState(() => aff = const ScormProgressionElevesPage());
        break;
      case "Lives streaming":
        setState(() => aff = LiveSessionsAdminScreen(widget.u));
        break;
      case "MGP plainte orientation":
        setState(() => aff = Plainte(widget.u['role']));
        break;
      case "Demande Documents":
        setState(() => aff = DemandeDocuments(widget.u));
        break;
      case "Demande Diplome":
        setState(() => aff = DemandeDiplomes(widget.u));
        break;
      case "Chat archive":
        setState(
            () => aff = Archive(
                "${widget.u['postnom']} ${widget.u['prenom']}"));
        break;
      case "SMS compagne":
        setState(() => aff = SmsCompagne());
        break;
      case "Admin":
        if (_role != 0) return;
        setState(() => aff = Admin());
        break;
      case "Profile":
        setState(() => aff = Profile(widget.u));
        break;
      case "Arretés ministeriels":
        setState(() => aff = ArretesMinisteriel());
        break;
      case "Notification arretés":
        setState(() => aff = NotificationsArretes());
        break;
      case "Notes circulaires":
        setState(() => aff = NotesCirculaire());
        break;
      case "Message phonique":
        setState(() => aff = MessagePhonique());
        break;
      case "Secrétariat général":
        setState(() => aff = SecretariaGeneral());
        break;
      case "Classes":
        setState(() => aff = ListeClassePage());
        break;
      case "Horaires cours":
        setState(() => aff = HorairesAdminScreen(widget.u));
        break;
      case "Mutuelle":
        setState(() => aff = Mutuelle(widget.u));
        break;
      case "Taux":
        setState(() => aff = Taux());
        break;
      case "Transferts eleves":
        setState(() => aff = TransfertsElevesPage(widget.u));
        break;
      case "Ecoles":
        if (!_is([0, 11, 12])) return;
        setState(() => aff = SmartKelasiSchoolsPage());
        break;
      case "Annonces":
        setState(() => aff = Annonces());
        break;
      case "Quitter":
        _demanderQuitter();
        break;
    }
  }

  List<Widget> _buildMenu() {
    final menu = <Widget>[];
    for (final section in sections) {
      final ops = (section["options"] as List<Map<String, dynamic>>);
      if (ops.isEmpty) continue;
      menu.add(Padding(
        padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
        child: Text(
          "${section["titre"]}",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.grey.shade500,
          ),
        ),
      ));
      for (final option in ops) {
        menu.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 3,
              height: 44,
              color: Colors.green,
            ),
            Expanded(
              flex: 1,
              child: ListTile(
                dense: true,
                onTap: () {
                  titre = option["nom"];
                  _ouvrir(option["nom"]);
                  Navigator.of(context).pop();
                },
                leading: Icon(option["icon"], size: 21),
                title: Text(option["nom"]),
              ),
            )
          ],
        ));
      }
    }
    return menu;
  }

  void _demanderQuitter() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Quitter"),
          content: const Text(
              "Voulez-vous vraiment quitter l'applicaton ?"),
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
            IconButton(
              onPressed: () {
                Get.offAll(Splash());
              },
              icon: const Icon(Icons.check),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titre),
        centerTitle: false,
      ),
      drawer: Drawer(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                child: DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ListTile(
                        leading: Container(
                          height: 40,
                          width: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            CupertinoIcons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text("${widget.u['nom']}"),
                        subtitle: Text(
                            "${widget.u['postnom']} ${widget.u['prenom']}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(roleLabel(widget.u['role'])),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.u['email']}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  controller: ScrollController(),
                  children: _buildMenu(),
                ),
              )
            ],
          ),
        ),
      ),
      body: aff,
    );
  }
}

/*
viewMode: SplitViewMode.Vertical,
        indicator: SplitIndicator(viewMode: SplitViewMode.Vertical),
        activeIndicator: SplitIndicator(
          viewMode: SplitViewMode.Vertical,
          isActive: true,
        ),
        controller: SplitViewController(limits: [null, WeightLimit(max: 0.5)]),
        onWeightChanged: (w) => print("Vertical $w"),
*/
