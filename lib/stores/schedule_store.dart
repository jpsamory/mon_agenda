import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../services/database_service.dart';

class ScheduleStore extends ChangeNotifier {
  ScheduleStore._internal();
  static final ScheduleStore instance = ScheduleStore._internal();

  List<Course> courses = [];

  Future<void> load() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('courses', orderBy: 'jour, heureDebut');
    courses = rows.map((r) => Course.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> add(Course c) async {
    final db = await DatabaseService.instance.database;
    c.id = await db.insert('courses', c.toMap());
    courses.add(c);
    notifyListeners();
  }

  Future<void> update(Course c) async {
    final db = await DatabaseService.instance.database;
    await db.update('courses', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
    final idx = courses.indexWhere((e) => e.id == c.id);
    if (idx != -1) courses[idx] = c;
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
    courses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Map<int, List<Course>> get courseParJour {
    final map = <int, List<Course>>{};
    for (final c in courses) {
      map.putIfAbsent(c.jour, () => []).add(c);
    }
    return map;
  }
}
