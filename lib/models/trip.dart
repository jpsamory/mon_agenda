class Trip {
  int? id;
  String origine;
  String destination;
  DateTime date;
  String moyenTransport;
  int dureeMinutes;
  String notes;

  Trip({
    this.id,
    required this.origine,
    required this.destination,
    required this.date,
    this.moyenTransport = 'Pied',
    this.dureeMinutes = 0,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'origine': origine,
        'destination': destination,
        'date': date.toIso8601String(),
        'moyenTransport': moyenTransport,
        'dureeMinutes': dureeMinutes,
        'notes': notes,
      };

  factory Trip.fromMap(Map<String, dynamic> m) => Trip(
        id: m['id'] as int?,
        origine: m['origine'] as String,
        destination: m['destination'] as String,
        date: DateTime.parse(m['date'] as String),
        moyenTransport: m['moyenTransport'] as String,
        dureeMinutes: m['dureeMinutes'] as int,
        notes: m['notes'] as String,
      );
}
