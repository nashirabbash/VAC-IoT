import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:vac_dashboard_app/models/therapy_session.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _db;

  DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'vac_dashboard.db'),
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE therapy_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_date TEXT NOT NULL,
          title TEXT NOT NULL,
          date TEXT NOT NULL,
          mode TEXT NOT NULL,
          duration TEXT NOT NULL
        )
      '''),
    );
  }

  Future<int> insert(TherapySession session) async {
    final db = await database;
    return db.insert(
      'therapy_sessions',
      session.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TherapySession>> getAll() async {
    final db = await database;
    final rows = await db.query('therapy_sessions', orderBy: 'session_date DESC');
    return rows.map(TherapySession.fromMap).toList();
  }

  Future<List<TherapySession>> getByYear(String year) async {
    final db = await database;
    final rows = await db.query(
      'therapy_sessions',
      where: "session_date LIKE ?",
      whereArgs: ['$year%'],
      orderBy: 'session_date DESC',
    );
    return rows.map(TherapySession.fromMap).toList();
  }

  Future<List<String>> getYears() async {
    final db = await database;
    final rows = await db.rawQuery(
      "SELECT DISTINCT substr(session_date, 1, 4) as year FROM therapy_sessions ORDER BY year DESC",
    );
    return rows.map((r) => r['year'] as String).toList();
  }

  Future<int> update(TherapySession session) async {
    final db = await database;
    return db.update(
      'therapy_sessions',
      session.toMap(),
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('therapy_sessions', where: 'id = ?', whereArgs: [id]);
  }
}
