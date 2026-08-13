import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:vac_dashboard_app/services/log_service.dart';

class DatabaseHelper {
  static const _databaseName = "vac_dashboard.db";
  static const _databaseVersion = 2;
  static const _dbKeyStorageKey = 'vac_db_encryption_key';

  static const table = 'therapy_sessions';

  static const columnId = 'id';
  static const columnSessionDate = 'session_date';
  static const columnTitle = 'title';
  static const columnDate = 'date';
  static const columnMode = 'mode';
  static const columnDuration = 'duration';
  static const columnIsSynced = 'is_synced';

  final FlutterSecureStorage _secureStorage;
  String? _cachedKey;

  DatabaseHelper._privateConstructor({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  factory DatabaseHelper.withStorage(FlutterSecureStorage storage) {
    return DatabaseHelper._privateConstructor(secureStorage: storage);
  }

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Retrieve or generate AES-256 encryption key stored in flutter_secure_storage
  Future<String> getOrCreateEncryptionKey() async {
    if (_cachedKey != null) return _cachedKey!;

    String? key = await _secureStorage.read(key: _dbKeyStorageKey);
    if (key != null && key.isNotEmpty) {
      _cachedKey = key;
      return key;
    }
    final secureRandom = Random.secure();
    final bytes = List<int>.generate(32, (_) => secureRandom.nextInt(256));
    key = base64Url.encode(bytes);
    await _secureStorage.write(key: _dbKeyStorageKey, value: key);
    _cachedKey = key;
    return key;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    final password = await getOrCreateEncryptionKey();
    try {
      return await openDatabase(
        path,
        password: password,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      LogService.log('[DB] SQLCipher open database failed: $e');
      rethrow;
    }
  }

  static const auditTable = 'audit_logs';

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

    await db.execute('''
          CREATE TABLE $auditTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            username TEXT,
            hospital_name TEXT,
            device_id TEXT,
            action TEXT NOT NULL,
            details TEXT,
            timestamp TEXT NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 0
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
    Database db = await database;
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
    Database db = await database;
    return await db.query(table, orderBy: '$columnId DESC');
  }

  Future<List<Map<String, dynamic>>> getUnsynced() async {
    Database db = await database;
    return await db.query(table, where: '$columnIsSynced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(int id) async {
    Database db = await database;
    return await db.update(
      table,
      {columnIsSynced: 1},
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getByYear(String year) async {
    Database db = await database;
    return await db.query(
      table,
      where: '$columnSessionDate LIKE ?',
      whereArgs: ['$year%'],
      orderBy: '$columnId DESC',
    );
  }

  Future<List<String>> getYears() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT substr($columnSessionDate, 1, 4) as year FROM $table ORDER BY year DESC',
    );
    return result.map((r) => r['year'] as String).toList();
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> insertAuditLog(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(auditTable, {
      'user_id': row['userId'],
      'username': row['username'],
      'hospital_name': row['hospitalName'],
      'device_id': row['deviceId'],
      'action': row['action'],
      'details': row['details'],
      'timestamp': row['timestamp'] ?? DateTime.now().toIso8601String(),
      'is_synced': row['isSynced'] == true ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getUnsyncedAuditLogs() async {
    Database db = await database;
    try {
      return await db.query(auditTable, where: 'is_synced = ?', whereArgs: [0]);
    } catch (_) {
      return [];
    }
  }

  Future<int> markAuditLogsAsSynced(List<int> ids) async {
    if (ids.isEmpty) return 0;
    Database db = await database;
    final inClause = ids.join(',');
    return await db.rawUpdate(
      'UPDATE $auditTable SET is_synced = 1 WHERE id IN ($inClause)',
    );
  }
}
