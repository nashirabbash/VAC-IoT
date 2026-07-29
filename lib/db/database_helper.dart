import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "vac_dashboard.db";
  static const _databaseVersion = 2;

  static const table = 'therapy_sessions';

  static const columnId = 'id';
  static const columnSessionDate = 'session_date';
  static const columnTitle = 'title';
  static const columnDate = 'date';
  static const columnMode = 'mode';
  static const columnDuration = 'duration';
  static const columnIsSynced = 'is_synced';

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
      onUpgrade: _onUpgrade,
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
            $columnDuration TEXT NOT NULL,
            $columnIsSynced INTEGER NOT NULL DEFAULT 0
          )
          ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $columnIsSynced INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<int> insert(Map<String, dynamic> row, {bool isSynced = false}) async {
    Database db = await instance.database;
    final dbRow = {
      columnSessionDate: row['sessionDate'],
      columnTitle: row['title'],
      columnDate: row['date'],
      columnMode: row['mode'],
      columnDuration: row['duration'],
      columnIsSynced: isSynced ? 1 : 0,
    };
    return await db.insert(table, dbRow);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    Database db = await instance.database;
    return await db.query(table, orderBy: '$columnId DESC');
  }

  Future<List<Map<String, dynamic>>> getUnsynced() async {
    Database db = await instance.database;
    return await db.query(table, where: '$columnIsSynced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(int id) async {
    Database db = await instance.database;
    return await db.update(
      table,
      {columnIsSynced: 1},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getByYear(String year) async {
    Database db = await instance.database;
    return await db.query(
      table,
      where: '$columnSessionDate LIKE ?',
      whereArgs: ['$year%'],
      orderBy: '$columnId DESC',
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
