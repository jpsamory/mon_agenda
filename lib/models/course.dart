/// Un cours de l'emploi du temps. On ne stocke que jour + heure (pas de date fixe),
/// donc il "revient" automatiquement chaque semaine sans action de l'utilisateur.
class Course {
  int? id;
  String matiere;
  String salle;
  int jour; // 0 = lundi ... 6 = dimanche
  int heureDebut;
  int minuteDebut;
  int heureFin;
  int minuteFin;
  String couleurHex;

  Course({
    this.id,
    required this.matiere,
    required this.salle,
    required this.jour,
    required this.heureDebut,
    required this.minuteDebut,
    required this.heureFin,
    required this.minuteFin,
    this.couleurHex = '3478F6',
  });

  static const joursNoms = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  String get jourNom => joursNoms[jour];

  String get horaireTexte {
    String h2(int n) => n.toString().padLeft(2, '0');
    return '${h2(heureDebut)}:${h2(minuteDebut)} - ${h2(heureFin)}:${h2(minuteFin)}';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'matiere': matiere,
        'salle': salle,
        'jour': jour,
        'heureDebut': heureDebut,
        'minuteDebut': minuteDebut,
        'heureFin': heureFin,
        'minuteFin': minuteFin,
        'couleurHex': couleurHex,
      };

  factory Course.fromMap(Map<String, dynamic> m) => Course(
        id: m['id'] as int?,
        matiere: m['matiere'] as String,
        salle: m['salle'] as String,
        jour: m['jour'] as int,
        heureDebut: m['heureDebut'] as int,
        minuteDebut: m['minuteDebut'] as int,
        heureFin: m['heureFin'] as int,
        minuteFin: m['minuteFin'] as int,
        couleurHex: m['couleurHex'] as String,
      );
}
