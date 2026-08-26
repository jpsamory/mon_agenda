class TaskItem {
  int? id;
  String titre;
  String details;
  DateTime echeance;
  bool estFaite;
  int notificationId; // id unique utilisé par flutter_local_notifications

  TaskItem({
    this.id,
    required this.titre,
    this.details = '',
    required this.echeance,
    this.estFaite = false,
    int? notificationId,
  }) : notificationId = notificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

  Map<String, dynamic> toMap() => {
        'id': id,
        'titre': titre,
        'details': details,
        'echeance': echeance.toIso8601String(),
        'estFaite': estFaite ? 1 : 0,
        'notificationId': notificationId,
      };

  factory TaskItem.fromMap(Map<String, dynamic> m) => TaskItem(
        id: m['id'] as int?,
        titre: m['titre'] as String,
        details: m['details'] as String,
        echeance: DateTime.parse(m['echeance'] as String),
        estFaite: (m['estFaite'] as int) == 1,
        notificationId: m['notificationId'] as int,
      );
}
