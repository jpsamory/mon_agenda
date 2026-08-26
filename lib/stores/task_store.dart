import 'package:flutter/foundation.dart';
import '../models/task_item.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskStore extends ChangeNotifier {
  TaskStore._internal();
  static final TaskStore instance = TaskStore._internal();

  List<TaskItem> tasks = [];

  Future<void> load() async {
    final db = await DatabaseService.instance.database;
    final rows = await db.query('tasks', orderBy: 'echeance');
    tasks = rows.map((r) => TaskItem.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> add(TaskItem t) async {
    final db = await DatabaseService.instance.database;
    t.id = await db.insert('tasks', t.toMap());
    tasks.add(t);
    await NotificationService.instance.planifierRappel(
      notificationId: t.notificationId,
      titre: t.titre,
      echeance: t.echeance,
    );
    notifyListeners();
  }

  Future<void> update(TaskItem t) async {
    final db = await DatabaseService.instance.database;
    await db.update('tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
    final idx = tasks.indexWhere((e) => e.id == t.id);
    if (idx != -1) tasks[idx] = t;
    await NotificationService.instance.replanifierRappel(
      notificationId: t.notificationId,
      titre: t.titre,
      echeance: t.echeance,
    );
    notifyListeners();
  }

  Future<void> toggleFaite(TaskItem t) async {
    t.estFaite = !t.estFaite;
    final db = await DatabaseService.instance.database;
    await db.update('tasks', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
    notifyListeners();
  }

  Future<void> delete(TaskItem t) async {
    final db = await DatabaseService.instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [t.id]);
    await NotificationService.instance.annulerRappel(t.notificationId);
    tasks.removeWhere((e) => e.id == t.id);
    notifyListeners();
  }
}
