import 'package:epst_windows_app/pages/formation_distante/Classe.dart';
import 'package:epst_windows_app/pages/formation_distante/ClasseService.dart';
import 'package:epst_windows_app/pages/formation_distante/live_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// Ecran Admin : pilotage des lives / vidéo streaming.
///
/// - Voir les sessions LIVE en cours (clé d'accès, salle Zego, audience).
/// - Démarrer une session (inspecteur 19/20/21, audience Eleves/Enseignants/Tous).
/// - Voir les participants et arrêter une session.
/// - Consulter l'historique récent.
class LiveSessionsAdminScreen extends StatefulWidget {
  final Map user;

  const LiveSessionsAdminScreen(this.user, {Key? key}) : super(key: key);

  @override
  State<LiveSessionsAdminScreen> createState() =>
      _LiveSessionsAdminScreenState();
}

class _LiveSessionsAdminScreenState extends State<LiveSessionsAdminScreen> {
  late Future<void> _future;
  List<Map<String, dynamic>> _live = [];
  List<Map<String, dynamic>> _recent = [];
  List<Classe> _classes = [];

  Map<String, dynamic>? _selected;
  List<Map<String, dynamic>> _participants = [];
  bool _loadingParticipants = false;

  // Formulaire nouveau live.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hostController = TextEditingController();
  Classe? _selectedClasse;
  String _audience = 'STUDENT';
  String _hostRole = 'INSPECTOR_STREAMING';
  int _maxParticipants = 100;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _hostController.text = '${widget.user['matricule'] ?? ''}';
    _future = _load();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      LiveSessionService.listLive(),
      LiveSessionService.listRecent(limit: 60),
      ClasseService.getAllClasses().catchError((_) => <Classe>[]),
    ]);
    if (!mounted) return;
    setState(() {
      _live = (results[0] as List<Map<String, dynamic>>);
      _recent = (results[1] as List<Map<String, dynamic>>);
      _classes = (results[2] as List<Classe>);
      if (_selectedClasse == null && _classes.isNotEmpty) {
        _selectedClasse = _classes.first;
      }
      // Si la sélection n'existe plus, on la garde quand même pour l'historique.
    });
  }

  Future<void> _selectSession(Map<String, dynamic> session) async {
    setState(() {
      _selected = session;
      _participants = [];
      _loadingParticipants = true;
    });
    try {
      final id = _asInt(session['id']);
      if (id > 0) {
        final parts = await LiveSessionService.participants(id);
        if (!mounted) return;
        setState(() => _participants = parts);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _participants = []);
    } finally {
      if (mounted) setState(() => _loadingParticipants = false);
    }
  }

  Future<void> _createLive() async {
    if (_selectedClasse == null) {
      _snack('Veuillez choisir une classe.', error: true);
      return;
    }
    final title =
        _titleController.text.trim().isEmpty
            ? 'Cours en direct'
            : _titleController.text.trim();
    final host = _hostController.text.trim();
    if (host.isEmpty) {
      _snack(
        'Veuillez saisir le matricule de l\'hote (inspecteur).',
        error: true,
      );
      return;
    }
    setState(() => _creating = true);
    try {
      final created = await LiveSessionService.start(
        classId: _selectedClasse!.id,
        title: title,
        hostMatricule: host,
        hostRole: _hostRole,
        audience: _audience,
        maxParticipants: _maxParticipants,
      );
      _titleController.clear();
      await _load();
      final session =
          (created['session'] as Map?) != null
              ? Map<String, dynamic>.from(created['session'] as Map)
              : <String, dynamic>{};
      session['accessKey'] = created['accessKey'];
      session['zegoRoomId'] = created['zegoRoomId'];
      if (session.isNotEmpty) await _selectSession(session);
      _snack(
        'Live demarre - Cle ${created['accessKey'] ?? ''} - Salle ${created['zegoRoomId'] ?? ''}',
      );
    } catch (e) {
      _snack('$e', error: true);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _endLive(Map<String, dynamic> session) async {
    final id = _asInt(session['id']);
    if (id <= 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Arreter le live'),
            content: Text(
              'Arreter "${session['title'] ?? 'Session'}" (cle ${session['accessKey'] ?? '-'}) ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Arreter'),
              ),
            ],
          ),
    );
    if (ok != true) return;
    try {
      await LiveSessionService.end(
        sessionId: id,
        endedByMatricule: '${widget.user['matricule'] ?? 'ADMIN'}',
      );
      await _load();
      setState(() => _selected = null);
      _snack('Live arrete.');
    } catch (e) {
      _snack('$e', error: true);
    }
  }

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: FutureBuilder<void>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _live.isEmpty &&
              _recent.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && _live.isEmpty && _recent.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 42, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('Chargement impossible: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _future = _load()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reessayer'),
                  ),
                ],
              ),
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 380, child: _buildLeftPane()),
              const VerticalDivider(width: 1),
              Expanded(child: _buildRightPane()),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------- gauche
  Widget _buildLeftPane() {
    return Container(
      color: const Color(0xFFF7F9FC),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.live_tv,
                    color: Colors.red.shade700,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Lives streaming',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                _statChip('${_live.length} en direct', Colors.red),
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Actualiser',
                  onPressed: () => setState(() => _future = _load()),
                  icon: const Icon(Icons.refresh, size: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              children: [
                const _SectionTitle(
                  icon: Icons.fiber_manual_record,
                  color: Colors.red,
                  title: 'En direct maintenant',
                ),
                const SizedBox(height: 8),
                if (_live.isEmpty)
                  const _EmptyBox(
                    icon: Icons.videocam_off_outlined,
                    text: 'Aucun live en cours.',
                  ),
                ..._live.map(_liveTile),
                const SizedBox(height: 16),
                const _SectionTitle(
                  icon: Icons.history,
                  color: Color(0xFF475569),
                  title: 'Historique recent',
                ),
                const SizedBox(height: 8),
                if (_recent.isEmpty)
                  const _EmptyBox(
                    icon: Icons.history_toggle_off,
                    text: 'Aucune session recente.',
                  ),
                ..._recent.take(20).map(_recentTile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveTile(Map<String, dynamic> s) {
    final selected =
        _selected != null &&
        '${_selected!['id']}' == '${s['id']}' &&
        _selected!['status'] == s['status'];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF1F2) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? Colors.red.shade200 : const Color(0xFFE5EAF2),
        ),
      ),
      child: ListTile(
        onTap: () => _selectSession(s),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.red.shade700,
              child: const Icon(Icons.videocam, color: Colors.white, size: 20),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                height: 10,
                width: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          '${s['title'] ?? 'Session'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _miniChip(Icons.key, 'Cle ${s['accessKey'] ?? '-'}'),
                _miniChip(
                  Icons.group,
                  LiveSessionService.audienceLabel('${s['audience']}'),
                ),
                _miniChip(Icons.meeting_room, '${s['zegoRoomId'] ?? '-'}'),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _recentTile(Map<String, dynamic> s) {
    final isLive = '${s['status']}' == 'LIVE';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: ListTile(
        dense: true,
        onTap: () => _selectSession(s),
        leading: CircleAvatar(
          backgroundColor:
              isLive ? Colors.red.shade700 : Colors.blueGrey.shade200,
          child: Icon(
            isLive ? Icons.videocam : Icons.history,
            color: Colors.white,
            size: 18,
          ),
        ),
        title: Text(
          '${s['title'] ?? 'Session'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${s['status'] ?? '-'} - ${LiveSessionService.audienceLabel('${s['audience']}')}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing:
            isLive
                ? IconButton(
                  tooltip: 'Arreter',
                  icon: const Icon(
                    Icons.stop_circle,
                    color: Colors.red,
                    size: 22,
                  ),
                  onPressed: () => _endLive(s),
                )
                : null,
      ),
    );
  }

  // ---------------------------------------------------------------- droite
  Widget _buildRightPane() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _buildCreateCard(),
        const SizedBox(height: 14),
        _buildDetailsCard(),
      ],
    );
  }

  Widget _buildCreateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.video_call, color: Color(0xFF1D4ED8)),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demarrer un live streaming',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Inspecteur video streaming (role 21) : donne la cle aux eleves et enseignants.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titre du cours en direct',
              hintText: 'Ex : Mathematiques - Fractions',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<Classe>(
                  value: _selectedClasse,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Classe',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items:
                      _classes
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c.label.isNotEmpty ? c.label : c.id,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedClasse = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: _audience,
                  decoration: const InputDecoration(
                    labelText: 'Public',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'STUDENT', child: Text('Eleves')),
                    DropdownMenuItem(
                      value: 'TEACHER',
                      child: Text('Enseignants'),
                    ),
                    DropdownMenuItem(value: 'BOTH', child: Text('Tous')),
                  ],
                  onChanged: (v) => setState(() => _audience = v ?? 'STUDENT'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hostController,
                  decoration: const InputDecoration(
                    labelText: 'Matricule hote (inspecteur)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _hostRole,
                  decoration: const InputDecoration(
                    labelText: 'Role hote',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'INSPECTOR_STUDENT',
                      child: Text('Inspecteur eleves (19)'),
                    ),
                    DropdownMenuItem(
                      value: 'INSPECTOR_TEACHER',
                      child: Text('Inspecteur enseignants (20)'),
                    ),
                    DropdownMenuItem(
                      value: 'INSPECTOR_STREAMING',
                      child: Text('Video streaming (21)'),
                    ),
                  ],
                  onChanged:
                      (v) => setState(
                        () => _hostRole = v ?? 'INSPECTOR_STREAMING',
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Participants max :'),
              Expanded(
                child: Slider(
                  value: _maxParticipants.toDouble(),
                  min: 10,
                  max: 500,
                  divisions: 49,
                  label: '$_maxParticipants',
                  onChanged:
                      (v) => setState(() => _maxParticipants = v.round()),
                ),
              ),
              Text(
                '$_maxParticipants',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _creating ? null : _createLive,
                icon:
                    _creating
                        ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.play_arrow),
                label: const Text('Demarrer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final s = _selected;
    if (s == null) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5EAF2)),
        ),
        child: const Column(
          children: [
            Icon(Icons.touch_app_outlined, size: 42, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Selectionnez un live pour voir la cle, la salle Zego et les participants.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      );
    }
    final isLive = '${s['status']}' == 'LIVE';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${s['title'] ?? 'Session'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _statChip(
                '${s['status'] ?? '-'}',
                isLive ? Colors.red : Colors.blueGrey,
              ),
              const SizedBox(width: 8),
              if (isLive)
                ElevatedButton.icon(
                  onPressed: () => _endLive(s),
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text('Arreter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                Icons.key,
                'Cle',
                '${s['accessKey'] ?? '-'}',
                copyable: true,
              ),
              _infoChip(
                Icons.meeting_room,
                'Salle Zego',
                '${s['zegoRoomId'] ?? '-'}',
                copyable: true,
              ),
              _infoChip(
                Icons.group,
                'Public',
                LiveSessionService.audienceLabel('${s['audience']}'),
              ),
              _infoChip(Icons.class_, 'Classe', '${s['classId'] ?? '-'}'),
              _infoChip(Icons.person, 'Hote', '${s['hostMatricule'] ?? '-'}'),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Text(
              'Partagez la clé avec les élèves de la classe. L’inspecteur désigné ouvre sa caméra '
              'puis lance la diffusion depuis EPST mobile. Les élèves rejoignent le cours dans l’onglet Direct.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 18),
              const SizedBox(width: 6),
              Text(
                'Participants (${_participants.length})',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (_loadingParticipants)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_loadingParticipants && _participants.isEmpty)
            const Text(
              'Aucun participant pour le moment.',
              style: TextStyle(color: Colors.black54),
            ),
          ..._participants.map(
            (p) => ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: _roleColor('${p['role']}'),
                child: Icon(
                  _roleIcon('${p['role']}'),
                  color: Colors.white,
                  size: 16,
                ),
              ),
              title: Text(
                '${p['displayName'] ?? p['matricule'] ?? '-'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${p['matricule'] ?? ''} - ${p['role'] ?? ''} - ${p['status'] ?? ''}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _miniChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FA),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF475569)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String title,
    String value, {
    bool copyable = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1D4ED8)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
              SelectableText(
                value,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (copyable) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                _snack('Copie : $value');
              },
              child: const Icon(Icons.copy, size: 14, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role.toUpperCase()) {
      case 'STUDENT':
        return Colors.green.shade700;
      case 'TEACHER':
        return Colors.blue.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  IconData _roleIcon(String role) {
    switch (role.toUpperCase()) {
      case 'STUDENT':
        return Icons.school;
      case 'TEACHER':
        return Icons.person;
      default:
        return Icons.verified_user;
    }
  }

  int _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.color,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ],
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EmptyBox({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EAF2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
