import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static DatabaseHelper? _inst;
  static Database?       _db;

  DatabaseHelper._();
  factory DatabaseHelper() => _inst ??= DatabaseHelper._();

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dir  = await getDatabasesPath();
    final path = p.join(dir, 'habit_tracker_v1.db');
    return openDatabase(path, version: 1, onCreate: _create);
  }

  Future<void> _create(Database db, int v) async {
    await db.execute('''
      CREATE TABLE habits (
        id           TEXT    PRIMARY KEY,
        name         TEXT    NOT NULL,
        icon         TEXT    NOT NULL,
        color        INTEGER NOT NULL,
        time_of_day  TEXT    NOT NULL,
        goal_type    TEXT    NOT NULL,
        goal_value   INTEGER NOT NULL DEFAULT 1,
        unit         TEXT    NOT NULL,
        sort_order   INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT    NOT NULL,
        is_active    INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE habit_entries (
        id           TEXT    PRIMARY KEY,
        habit_id     TEXT    NOT NULL,
        date         TEXT    NOT NULL,
        progress     INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        UNIQUE(habit_id, date)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_entries ON habit_entries(habit_id, date)',
    );
  }
}