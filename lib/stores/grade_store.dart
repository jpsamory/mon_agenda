import 'package:flutter/foundation.dart';
import '../models/grade_models.dart';
import '../services/database_service.dart';

class GradeStore extends ChangeNotifier {
  GradeStore._internal();
  static final GradeStore instance = GradeStore._internal();

  List<Subject> subjects = [];
  Map<int, List<Grade>> gradesBySubject = {};

  Future<void> load() async {
    final db = await DatabaseService.instance.database;
    final subjectRows = await db.query('subjects', orderBy: 'nom');
    subjects = subjectRows.map((r) => Subject.fromMap(r)).toList();

    final gradeRows = await db.query('grades', orderBy: 'date DESC');
    gradesBySubject = {};
    for (final r in gradeRows) {
      final g = Grade.fromMap(r);
      gradesBySubject.putIfAbsent(g.subjectId, () => []).add(g);
    }
    notifyListeners();
  }

  Future<void> addSubject(Subject s) async {
    final db = await DatabaseService.instance.database;
    s.id = await db.insert('subjects', s.toMap());
    subjects.add(s);
    notifyListeners();
  }

  Future<void> updateSubject(Subject s) async {
    final db = await DatabaseService.instance.database;
    await db.update('subjects', s.toMap(), where: 'id = ?', whereArgs: [s.id]);
    notifyListeners();
  }

  Future<void> deleteSubject(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete('grades', where: 'subjectId = ?', whereArgs: [id]);
    await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
    subjects.removeWhere((e) => e.id == id);
    gradesBySubject.remove(id);
    notifyListeners();
  }

  Future<void> addGrade(Grade g) async {
    final db = await DatabaseService.instance.database;
    g.id = await db.insert('grades', g.toMap());
    gradesBySubject.putIfAbsent(g.subjectId, () => []).insert(0, g);
    notifyListeners();
  }

  Future<void> deleteGrade(Grade g) async {
    final db = await DatabaseService.instance.database;
    await db.delete('grades', where: 'id = ?', whereArgs: [g.id]);
    gradesBySubject[g.subjectId]?.removeWhere((e) => e.id == g.id);
    notifyListeners();
  }

  /// Moyenne pondérée d'une matière (moyenne de ses notes, pondérée par coefficientNote)
  double? moyenneMatiere(int subjectId) {
    final grades = gradesBySubject[subjectId];
    if (grades == null || grades.isEmpty) return null;
    final total = grades.fold<double>(0, (sum, g) => sum + g.valeurSur20 * g.coefficientNote);
    final sommeCoef = grades.fold<double>(0, (sum, g) => sum + g.coefficientNote);
    return sommeCoef > 0 ? total / sommeCoef : null;
  }

  /// Moyenne générale : moyenne de chaque matière pondérée par le coefficient de la matière
  double? get moyenneGenerale {
    final entries = <(double moyenne, double coef)>[];
    for (final s in subjects) {
      final moy = moyenneMatiere(s.id!);
      if (moy != null) entries.add((moy, s.coefficient));
    }
    if (entries.isEmpty) return null;
    final total = entries.fold<double>(0, (sum, e) => sum + e.$1 * e.$2);
    final sommeCoef = entries.fold<double>(0, (sum, e) => sum + e.$2);
    return sommeCoef > 0 ? total / sommeCoef : null;
  }
}
