import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/log/models/food_log_entry.dart';

class MealLogDatabaseService {
  MealLogDatabaseService._();
  static final MealLogDatabaseService instance = MealLogDatabaseService._();

  static const _dbName = 'aahar_logs.db';
  static const _dbVersion = 2;
  static const _table = 'meal_logs';

  Database? _db;

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, _dbName),
      version: _dbVersion,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE $_table (
          id         TEXT    PRIMARY KEY,
          food_name  TEXT    NOT NULL,
          quantity   REAL    NOT NULL,
          unit       TEXT    NOT NULL,
          kcal       REAL    NOT NULL,
          protein_g  REAL    NOT NULL,
          carbs_g    REAL    NOT NULL,
          fat_g      REAL    NOT NULL,
          logged_at  INTEGER NOT NULL,
          meal_type  TEXT    NOT NULL,
          iron_mg    REAL    NOT NULL DEFAULT 0.0
        )
      '''),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $_table ADD COLUMN iron_mg REAL NOT NULL DEFAULT 0.0',
          );
        }
      },
    );
  }

  Future<void> insertEntry(FoodLogEntry entry) async {
    final db = await _database;
    await db.insert(_table, entry.toDbMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteEntry(String id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  // Identical to insert (INSERT OR REPLACE covers both).
  Future<void> updateEntry(FoodLogEntry entry) => insertEntry(entry);

  Future<List<FoodLogEntry>> getEntriesForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return getEntriesForDateRange(start, end);
  }

  Future<List<FoodLogEntry>> getEntriesForDateRange(
      DateTime start, DateTime end) async {
    final db = await _database;
    final rows = await db.query(
      _table,
      where: 'logged_at >= ? AND logged_at < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'logged_at ASC',
    );
    return rows.map(FoodLogEntry.fromDbMap).toList();
  }

  Future<List<FoodLogEntry>> getEntriesForLastNDays(int n) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final start = todayStart.subtract(Duration(days: n - 1));
    final end = todayStart.add(const Duration(days: 1));
    return getEntriesForDateRange(start, end);
  }
}
