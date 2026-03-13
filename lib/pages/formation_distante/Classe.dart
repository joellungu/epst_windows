class Classe {
  final String id;
  final String niveau;
  final String cycle;
  final String? section;
  final String? option;
  final String? nom;

  Classe({
    required this.id,
    required this.niveau,
    required this.cycle,
    this.section,
    this.option,
    this.nom,
  });

  factory Classe.fromJson(Map<String, dynamic> json) {
    return Classe(
      id: json['id'],
      niveau: json['niveau'] ?? '',
      cycle: json['cycle'] ?? '',
      section: json['section'],
      option: json['option'],
      nom: json['nom'],
    );
  }

  String get label {
    final parts = <String>[niveau, cycle];
    if (option != null && option!.isNotEmpty) {
      parts.add(option!);
    } else if (section != null && section!.isNotEmpty) {
      parts.add(section!);
    }
    if (nom != null && nom!.isNotEmpty) {
      parts.add(nom!);
    }
    return parts.join(' ').trim();
  }
}
