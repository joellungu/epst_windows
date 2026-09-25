const List<String> listeRoles = [
  "Administrateur",
  "Uploader",
  "MGP-utilisateur",
  "MGP-admin",
  "Chat-utilisateur",
  "Editeurs SMS",
  "Agent mutuelle",
  "Inspecteur charge des titres et pieces scolaires",
  "Inspecteur exetat",
  "Inspecteur tenassop",
  "Inspecteur tenafepe",
  "Agent sernie",
  "Agent sernie id",
  "Inspecteur de juty cycle court",
  "Inspecteur transfere",
  "Inspecteur gestion doublants",
  "Ministre",
  "SG",
  "IGE",
  "Inspecteur sernafor (eleves)",
  "Inspecteur sernafor (enseignants)",
  "Inspecteur video streaming",
];

String roleLabel(dynamic role) {
  final int i = role is int ? role : int.tryParse("$role") ?? -1;
  if (i < 0 || i >= listeRoles.length) return "Inconnu";
  return listeRoles[i];
}

int roleIndex(dynamic role) {
  return role is int ? role : int.tryParse("$role") ?? -1;
}
