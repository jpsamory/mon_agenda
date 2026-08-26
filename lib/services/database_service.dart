import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton d'accès à la base SQLite locale. Aucune connexion réseau ici :
/// le fichier .db vit dans le stockage interne du téléphone.
class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'mon_agenda.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE courses(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            matiere TEXT NOT NULL,
            salle TEXT NOT NULL,
            jour INTEGER NOT NULL,
            heureDebut INTEGER NOT NULL,
            minuteDebut INTEGER NOT NULL,
            heureFin INTEGER NOT NULL,
            minuteFin INTEGER NOT NULL,
            couleurHex TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titre TEXT NOT NULL,
            details TEXT NOT NULL,
            echeance TEXT NOT NULL,
            estFaite INTEGER NOT NULL,
            notificationId INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE trips(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            origine TEXT NOT NULL,
            destination TEXT NOT NULL,
            date TEXT NOT NULL,
            moyenTransport TEXT NOT NULL,
            dureeMinutes INTEGER NOT NULL,
            notes TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE subjects(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            coefficient REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE grades(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subjectId INTEGER NOT NULL,
            titre TEXT NOT NULL,
            valeurSur20 REAL NOT NULL,
            coefficientNote REAL NOT NULL,
            date TEXT NOT NULL,
            FOREIGN KEY(subjectId) REFERENCES subjects(id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE activities(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            categorie TEXT NOT NULL,
            titre TEXT NOT NULL,
            details TEXT NOT NULL,
            date TEXT NOT NULL,
            estFait INTEGER NOT NULL
          )
        ''');
      },
    );
  }
}
