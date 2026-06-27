import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TransfertsElevesPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const TransfertsElevesPage(this.user, {Key? key}) : super(key: key);

  @override
  State<TransfertsElevesPage> createState() => _TransfertsElevesPageState();
}

class _TransfertsElevesPageState extends State<TransfertsElevesPage> {
  static const _baseUrl = 'https://smartkelasi-7109ee9b9b9b.herokuapp.com/';

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _rows = [];
  String _status = 'EN_ATTENTE';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl}eleve/transferts?statut=$_status'),
        headers: const {'Accept': 'application/json'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Serveur ${response.statusCode}');
      }
      final body = jsonDecode(response.body);
      _rows = body is List
          ? body
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : [];
    } catch (e) {
      _error = 'Erreur: $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _decide(Map<String, dynamic> detail, String statut) async {
    final eleve = _map(detail['eleve']);
    final motifCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(statut == 'APPROUVE' ? 'Approuver' : 'Rejeter'),
        content: TextField(
          controller: motifCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Note ou motif de decision',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final cle = _label(eleve, ['cle']);
    if (cle.isEmpty) return;
    final admin =
        '${widget.user['postnom'] ?? ''} ${widget.user['prenom'] ?? ''}'.trim();
    final response = await http.put(
      Uri.parse(
        '${_baseUrl}eleve/transferts/${Uri.encodeComponent(cle)}/decision',
      ),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode({
        'statut': statut,
        'motif': motifCtrl.text.trim(),
        'admin': admin.isEmpty ? widget.user['matricule']?.toString() : admin,
      }),
    );
    if (!mounted) return;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            statut == 'APPROUVE' ? 'Transfert approuve' : 'Transfert rejete',
          ),
          backgroundColor: Colors.green,
        ),
      );
      await _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur decision: ${response.statusCode}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Transferts eleves',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _status,
                items: const [
                  DropdownMenuItem(
                    value: 'EN_ATTENTE',
                    child: Text('En attente'),
                  ),
                  DropdownMenuItem(value: 'APPROUVE', child: Text('Approuves')),
                  DropdownMenuItem(value: 'REJETE', child: Text('Rejetes')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _status = value);
                  _load();
                },
              ),
              IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : _rows.isEmpty
                      ? const Center(child: Text('Aucun transfert trouve.'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _rows.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) => _TransferCard(
                            detail: _rows[index],
                            onApprove: () => _decide(_rows[index], 'APPROUVE'),
                            onReject: () => _decide(_rows[index], 'REJETE'),
                          ),
                        ),
        ),
      ],
    );
  }
}

class _TransferCard extends StatelessWidget {
  final Map<String, dynamic> detail;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _TransferCard({
    required this.detail,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final eleve = _map(detail['eleve']);
    final source = _map(detail['ecoleSource']);
    final destination = _map(detail['ecoleDestination']);
    final classeSource = _map(detail['classeSource']);
    final classeDestination = _map(detail['classeDestination']);
    final pere = _map(detail['pere']);
    final mere = _map(detail['mere']);
    final responsable = _map(detail['responsable']);
    final urgence = _map(detail['urgence']);
    final notes = _list(detail['notes']);
    final finances = _list(detail['finances']);
    final statut = _label(detail, ['statutAdmin']);
    final pending = statut.isEmpty || statut == 'EN_ATTENTE';
    final classeDestinationExiste = detail['classeDestinationExiste'] == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fullName(eleve),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(label: Text(statut.isEmpty ? 'EN_ATTENTE' : statut)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                _Info('ID', _label(eleve, ['numeroIdentifiant'])),
                _Info('Annee', _label(eleve, ['anneescolaire'])),
                _Info('Classe', _label(eleve, ['classe'])),
                _Info('Motif transfert', _label(detail, ['motif'])),
                _Info('Origine', _school(source)),
                _Info('Destination', _school(destination)),
                _Info('Notes', '${notes.length} ligne(s)'),
                _Info('Finances', _financeSummary(finances)),
              ],
            ),
            if (!classeDestinationExiste) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Classe non trouvee dans l ecole destination: ${_label(eleve, [
                              'classe',
                            ]).isEmpty ? 'classe non renseignee' : _label(eleve, [
                                'classe',
                              ])}. L administration peut approuver, mais l ecole destination devra creer/accepter cette classe ou refuser.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailLink(
                  icon: Icons.person_outline,
                  label: 'Infos eleve',
                  onPressed: () => _showMapDialog(
                    context,
                    title: 'Informations generales de l eleve',
                    values: eleve,
                  ),
                ),
                _DetailLink(
                  icon: Icons.logout_outlined,
                  label: 'Ecole origine',
                  onPressed: () => _showMapDialog(
                    context,
                    title: 'Ecole d origine',
                    values: source,
                  ),
                ),
                _DetailLink(
                  icon: Icons.login_outlined,
                  label: 'Ecole destination',
                  onPressed: () => _showMapDialog(
                    context,
                    title: 'Ecole destination',
                    values: destination,
                  ),
                ),
                _DetailLink(
                  icon: Icons.class_outlined,
                  label: 'Classe origine',
                  onPressed: () => _showMapDialog(
                    context,
                    title: 'Classe d origine',
                    values: classeSource,
                  ),
                ),
                _DetailLink(
                  icon: Icons.class_outlined,
                  label: 'Classe destination',
                  onPressed: () => _showMapDialog(
                    context,
                    title: 'Classe destination',
                    values: classeDestination,
                  ),
                ),
                _DetailLink(
                  icon: Icons.man_outlined,
                  label: 'Pere',
                  onPressed: () => _showMapDialog(
                    context,
                    title: 'Informations du pere',
                    values: pere,
                  ),
                ),
                _DetailLink(
                  icon: Icons.woman_outlined,
                  label: 'Mere',
                  onPressed: () => _showMapDialog(
                    context,
                    title: 'Informations de la mere',
                    values: mere,
                  ),
                ),
                _DetailLink(
                  icon: Icons.supervisor_account_outlined,
                  label: 'Responsable',
                  onPressed: () => _showMapDialog(
                    context,
                    title: 'Informations du responsable',
                    values: responsable,
                  ),
                ),
                _DetailLink(
                  icon: Icons.emergency_outlined,
                  label: 'Urgence',
                  onPressed: () => _showMapDialog(
                    context,
                    title: 'Contact d urgence',
                    values: urgence,
                  ),
                ),
                _DetailLink(
                  icon: Icons.fact_check_outlined,
                  label: 'Notes de cours',
                  badge: notes.length,
                  onPressed: () => _showNotesDialog(
                    context,
                    title: 'Notes de cours',
                    rows: notes,
                    emptyText: 'Aucune note recue avec cette demande.',
                  ),
                ),
                _DetailLink(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Finances',
                  badge: finances.length,
                  onPressed: () => _showListDialog(
                    context,
                    title: 'Situation financiere',
                    rows: finances,
                    emptyText: 'Aucune information financiere recue.',
                  ),
                ),
                _DetailLink(
                  icon: Icons.route_outlined,
                  label: 'Mouvements',
                  badge: _list(detail['mouvements']).length,
                  onPressed: () => _showListDialog(
                    context,
                    title: 'Historique des mouvements',
                    rows: _list(detail['mouvements']),
                    emptyText: 'Aucun mouvement associe.',
                  ),
                ),
              ],
            ),
            if (_label(detail, ['motifDecision']).isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Decision: ${_label(detail, ['motifDecision'])}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (pending) ...[
              const Divider(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('Rejeter'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check),
                    label: const Text('Approuver'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _financeSummary(List<Map<String, dynamic>> finances) {
    if (finances.isEmpty) return '0 ligne';
    double total = 0;
    for (final row in finances) {
      total += double.tryParse(_label(row, ['montant'])) ?? 0;
    }
    return '${finances.length} ligne(s), total $total';
  }

  String _school(Map<String, dynamic> school) {
    final name = _label(school, ['nomEcole', 'nom']);
    final cle = _label(school, ['cle', 'cleEcole']);
    return name.isEmpty ? cle : '$name ($cle)';
  }

  String _fullName(Map<String, dynamic> eleve) {
    return [
      _label(eleve, ['nom']),
      _label(eleve, ['postnom']),
      _label(eleve, ['prenom']),
    ].where((e) => e.isNotEmpty).join(' ');
  }

  void _showMapDialog(
    BuildContext context, {
    required String title,
    required Map<String, dynamic> values,
  }) {
    final rows = _visibleEntries(values);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 620,
          child: rows.isEmpty
              ? const Text('Aucune information disponible.')
              : SingleChildScrollView(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: rows
                        .map(
                          (entry) => _DetailField(
                            label: entry.key,
                            value: '${entry.value}',
                          ),
                        )
                        .toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showListDialog(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> rows,
    required String emptyText,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 760,
          height: 480,
          child: rows.isEmpty
              ? Center(child: Text(emptyText))
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entries = _visibleEntries(rows[index]);
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: entries
                            .map(
                              (entry) => _DetailField(
                                label: entry.key,
                                value: '${entry.value}',
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> rows,
    required String emptyText,
  }) {
    final grouped = _groupNotesByPeriod(rows);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 860,
          height: 520,
          child: rows.isEmpty
              ? Center(child: Text(emptyText))
              : ListView.separated(
                  itemCount: grouped.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final entry = grouped.entries.elementAt(index);
                    return _PeriodNotesBlock(
                      period: entry.key,
                      notes: entry.value,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _DetailLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;
  final VoidCallback onPressed;

  const _DetailLink({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final text = badge == null ? label : '$label ($badge)';
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  final String label;
  final String value;

  const _DetailField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodNotesBlock extends StatelessWidget {
  final String period;
  final List<Map<String, dynamic>> notes;

  const _PeriodNotesBlock({required this.period, required this.notes});

  @override
  Widget build(BuildContext context) {
    final totals = _periodTotals(notes);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  period,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _SmallSummary('Total', totals.total),
              const SizedBox(width: 8),
              _SmallSummary('Pourcentage', totals.percentage),
              const SizedBox(width: 8),
              _SmallSummary('Place', totals.place),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 34,
              dataRowMinHeight: 36,
              dataRowMaxHeight: 46,
              columns: const [
                DataColumn(label: Text('Cours')),
                DataColumn(label: Text('Points')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('%')),
                DataColumn(label: Text('Place')),
              ],
              rows: notes.map((note) {
                return DataRow(
                  cells: [
                    DataCell(Text(_courseName(note))),
                    DataCell(Text(_label(note, ['point', 'points']))),
                    DataCell(Text(_label(note, ['total', 'maximum']))),
                    DataCell(Text(_notePercentage(note))),
                    DataCell(Text(_notePlace(note))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallSummary extends StatelessWidget {
  final String label;
  final String value;

  const _SmallSummary(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              color: Colors.indigo.shade800,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;

  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return const [];
}

List<MapEntry<String, dynamic>> _visibleEntries(Map<String, dynamic> map) {
  const hidden = {
    'id',
    'blob',
    'photo',
    'image',
    'createdAt',
    'updatedAt',
  };
  return map.entries.where((entry) {
    final value = entry.value;
    if (hidden.contains(entry.key)) return false;
    if (value == null) return false;
    final text = '$value'.trim();
    return text.isNotEmpty && text != 'null';
  }).toList();
}

Map<String, List<Map<String, dynamic>>> _groupNotesByPeriod(
  List<Map<String, dynamic>> notes,
) {
  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final note in notes) {
    final period = _label(note, [
      'periode',
      'nomPeriode',
      'idPeriode',
      'periodeNom',
      'nom',
    ]);
    final key = period.isEmpty ? 'Periode non renseignee' : period;
    grouped.putIfAbsent(key, () => []).add(note);
  }
  return grouped;
}

String _courseName(Map<String, dynamic> note) {
  return _label(note, ['cours', 'nomCours', 'idCours', 'cleCours', 'branche']);
}

String _notePercentage(Map<String, dynamic> note) {
  final existing = _label(note, ['pourcentage', 'percent']);
  if (existing.isNotEmpty) return '$existing%'.replaceAll('%%', '%');
  final point = _number(_label(note, ['point', 'points']));
  final total = _number(_label(note, ['total', 'maximum']));
  if (point == null || total == null || total <= 0) return '';
  return '${((point / total) * 100).toStringAsFixed(1)}%';
}

String _notePlace(Map<String, dynamic> note) {
  return _label(note, ['place', 'rang', 'classement']);
}

_NoteTotals _periodTotals(List<Map<String, dynamic>> notes) {
  double points = 0;
  double totals = 0;
  String place = '';
  for (final note in notes) {
    points += _number(_label(note, ['point', 'points'])) ?? 0;
    totals += _number(_label(note, ['total', 'maximum'])) ?? 0;
    place = place.isEmpty ? _notePlace(note) : place;
  }
  final percent =
      totals > 0 ? '${((points / totals) * 100).toStringAsFixed(1)}%' : '';
  final totalLabel =
      totals > 0 ? '${_formatNumber(points)} / ${_formatNumber(totals)}' : '';
  return _NoteTotals(total: totalLabel, percentage: percent, place: place);
}

double? _number(String value) {
  return double.tryParse(value.replaceAll(',', '.'));
}

String _formatNumber(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(1);
}

class _NoteTotals {
  final String total;
  final String percentage;
  final String place;

  const _NoteTotals({
    required this.total,
    required this.percentage,
    required this.place,
  });
}

String _label(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null && '$value'.trim().isNotEmpty && '$value' != 'null') {
      return '$value'.trim();
    }
  }
  return '';
}
