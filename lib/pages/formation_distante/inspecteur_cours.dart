class InspecteurCours {
  int? id;
  int idInspecteur;
  List<int> cours;
  List<int> classe;

  InspecteurCours({
    this.id,
    required this.idInspecteur,
    required this.cours,
    required this.classe,
  });

  factory InspecteurCours.fromJson(Map<String, dynamic> json) {
    return InspecteurCours(
      id: json['id'],
      idInspecteur: json['idInspecteur'],
      cours: List<int>.from(json['cours'] ?? []),
      classe: List<int>.from(json['classe'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'idInspecteur': idInspecteur,
      'cours': cours,
      'classe': classe,
    };
  }
}
