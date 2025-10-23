class Classe {
  final int id;
  final String nom;
  final int cls;
  final String categorie;

  Classe({
    required this.id,
    required this.nom,
    required this.cls,
    required this.categorie,
  });

  factory Classe.fromJson(Map<String, dynamic> json) {
    return Classe(
      id: json['id'],
      nom: json['nom'],
      cls: json['cls'],
      categorie: json['categorie'],
    );
  }
}
