import 'package:flutter/foundation.dart';
import '../models/activity_item.dart';
import '../services/database_service.dart';

class ActivityStore extends ChangeNotifier {
  ActivityStore._internal();
  static final ActivityStore instance = ActivityStore._internal();

  List<ActivityItem> items = [];

  Future<void> load() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('activities', orderBy: 'date');
    items = rows.map((r) => ActivityItem.fromMap(r)).toList();
    notifyListeners();
  }

  List<ActivityItem> byCategory(ActivityCategory cat) =>
      items.where((e) => e.categorie == cat).toList();

  Future<void> add(ActivityItem item) async {
    final db = await DatabaseService.instance.database;
    item.id = await db.insert('activities', item.toMap());
    items.add(item);
    notifyListeners();
  }

  Future<void> update(ActivityItem item) async {
    final db = await DatabaseService.instance.database;
    await db.update('activities', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    final idx = items.indexWhere((e) => e.id == item.id);
    if (idx != -1) items[idx] = item;
    notifyListeners();
  }

  Future<void> toggleFait(ActivityItem item) async {
    item.estFait = !item.estFait;
    final db = await DatabaseService.instance.database;
    await db.update('activities', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
    notifyListeners();
  }

  Future<void> delete(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('activities', where: 'id = ?', whereArgs: [id]);
    items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
