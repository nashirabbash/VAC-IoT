import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "vac_dashboard.db";
  static const _databaseVersion = 1;

  static const table = 'therapy_sessions';

  static const columnId = 'id';
  static const columnSessionDate = 'session_date';
  static const columnTitle = 'title';
  static const columnDate = 'date';
  static const columnMode = 'mode';
  static const columnDuration = 'duration';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnSessionDate TEXT NOT NULL,
            $columnTitle TEXT NOT NULL,
            $columnDate TEXT NOT NULL,
            $columnMode TEXT NOT NULL,
            $columnDuration TEXT NOT NULL
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    // Map JSON payload fields to SQLite columns
    final dbRow = {
      columnSessionDate: row['sessionDate'],
      columnTitle: row['title'],
      columnDate: row['date'],
      columnMode: row['mode'],
      columnDuration: row['duration'],
    };
    return await db.insert(table, dbRow);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> getByYear(String year) async {
    Database db = await instance.database;
    return await db.query(
      table,
      where: '$columnSessionDate LIKE ?',
      whereArgs: ['$year%'],
    );
  }

  Future<List<String>> getYears() async {
    Database db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT substr($columnSessionDate, 1, 4) as year FROM $table ORDER BY year DESC',
    );
    return result.map((r) => r['year'] as String).toList();
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
