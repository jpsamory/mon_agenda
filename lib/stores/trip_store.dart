import 'package:flutter/foundation.dart';
import '../models/trip.dart';
import '../services/database_service.dart';

class TripStore extends ChangeNotifier {
  TripStore._internal();
  static final TripStore instance = TripStore._internal();

  List<Trip> trips = [];

  Future<void> load() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('trips', orderBy: 'date DESC');
    trips = rows.map((r) => Trip.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> add(Trip t) async {
    final db = await DatabaseService.instance.database;
    t.id = await db.insert('trips', t.toMap());
    trips.insert(0, t);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('trips', where: 'id = ?', whereArgs: [id]);
    trips.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
