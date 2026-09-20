class Redacteur {
  final int? id;
  final String nom;
  final String prenom;
  final String email;

  // Constructeur principal (avec id, utilisé quand on relit un rédacteur existant)
  Redacteur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Constructeur nommé sans id (utilisé lors de la création d'un nouveau rédacteur,
  // car l'id sera généré automatiquement par la base de données)
  Redacteur.sansId({
    required this.nom,
    required this.prenom,
    required this.email,
  }) : id = null;

  // Transforme l'objet en Map pour l'insertion/mise à jour dans SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
  }

  // Reconstruit un objet Redacteur à partir d'une ligne de la base (Map)
  factory Redacteur.fromMap(Map<String, dynamic> map) {
    return Redacteur(
      id: map['id'] as int?,
      nom: map['nom'] as String,
      prenom: map['prenom'] as String,
      email: map['email'] as String,
    );
  }
}