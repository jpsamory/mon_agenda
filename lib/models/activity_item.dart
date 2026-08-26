/// Catégorie d'activité : réutilisée pour le programme de sport ET les matchs du Barça
/// -> un seul modèle + un seul écran générique, filtré par catégorie.
enum ActivityCategory { sport, barca }

extension ActivityCategoryX on ActivityCategory {
  String get label => this == ActivityCategory.sport ? 'Salle de sport' : 'Matchs du Barça';
  String get dbValue => this == ActivityCategory.sport ? 'sport' : 'barca';

  static ActivityCategory fromDb(String v) =>
      v == 'sport' ? ActivityCategory.sport : ActivityCategory.barca;
}

class ActivityItem {
  int? id;
  ActivityCategory categorie;
  String titre;
  String details;
  DateTime date;
  bool estFait;

  ActivityItem({
    this.id,
    required this.categorie,
    required this.titre,
    this.details = '',
    required this.date,
    this.estFait = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'categorie': categorie.dbValue,
        'titre': titre,
        'details': details,
        'date': date.toIso8601String(),
        'estFait': estFait ? 1 : 0,
      };

  factory ActivityItem.fromMap(Map<String, dynamic> m) => ActivityItem(
        id: m['id'] as int?,
        categorie: ActivityCategoryX.fromDb(m['categorie'] as String),
        titre: m['titre'] as String,
        details: m['details'] as String,
        date: DateTime.parse(m['date'] as String),
        estFait: (m['estFait'] as int) == 1,
      );
}
