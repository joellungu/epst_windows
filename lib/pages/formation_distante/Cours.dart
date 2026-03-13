class Cours {
  final int id;
  final String cours;

  Cours({
    required this.id,
    required this.cours,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['id'],
      cours: json['cours'],
    );
  }
}
