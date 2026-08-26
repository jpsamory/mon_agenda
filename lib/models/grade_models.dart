class Subject {
  int? id;
  String nom;
  double coefficient;

  Subject({this.id, required this.nom, this.coefficient = 1.0});

  Map<String, dynamic> toMap() => {'id': id, 'nom': nom, 'coefficient': coefficient};

  factory Subject.fromMap(Map<String, dynamic> m) => Subject(
        id: m['id'] as int?,
        nom: m['nom'] as String,
        coefficient: (m['coefficient'] as num).toDouble(),
      );
}

class Grade {
  int? id;
  int subjectId;
  String titre;
  double valeurSur20; // toujours ramenée sur 20 pour un calcul homogène
  double coefficientNote;
  DateTime date;

  Grade({
    this.id,
    required this.subjectId,
    required this.titre,
    required this.valeurSur20,
    this.coefficientNote = 1.0,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectId': subjectId,
        'titre': titre,
        'valeurSur20': valeurSur20,
        'coefficientNote': coefficientNote,
        'date': date.toIso8601String(),
      };

  factory Grade.fromMap(Map<String, dynamic> m) => Grade(
        id: m['id'] as int?,
        subjectId: m['subjectId'] as int,
        titre: m['titre'] as String,
        valeurSur20: (m['valeurSur20'] as num).toDouble(),
        coefficientNote: (m['coefficientNote'] as num).toDouble(),
        date: DateTime.parse(m['date'] as String),
      );
}
