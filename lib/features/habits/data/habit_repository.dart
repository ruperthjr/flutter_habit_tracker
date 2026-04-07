import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../domain/models.dart';
import '../../../core/database/database_helper.dart';

class HabitRepository {
  HabitRepository(this._db);
  final DatabaseHelper _db;
  final _uuid = const Uuid();

  // ── Habits ────────────────────────────────────────────────────────────────

  Future<List<Habit>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('habits',
        where: 'is_active=?', whereArgs: [1],
        orderBy: 'sort_order ASC, created_at ASC');
    return rows.map(Habit.fromMap).toList();
  }

  Future<void> insert(Habit h) async {
    final db = await _db.database;
    await db.insert('habits', h.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(Habit h) async {
    final db = await _db.database;
    await db.update('habits', h.toMap(),
        where: 'id=?', whereArgs: [h.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.update('habits', {'is_active': 0},
        where: 'id=?', whereArgs: [id]);
  }

  Future<void> reorder(List<Habit> habits) async {
    final db = await _db.database;
    final batch = db.batch();
    for (var i = 0; i < habits.length; i++) {
      batch.update('habits', {'sort_order': i},
          where: 'id=?', whereArgs: [habits[i].id]);
    }
    await batch.commit(noResult: true);
  }

  // ── Entries ───────────────────────────────────────────────────────────────

  Future<List<HabitEntry>> entriesForDate(DateTime date) async {
    final db = await _db.database;
    final rows = await db.query('habit_entries',
        where: 'date=?', whereArgs: [dateKey(date)]);
    return rows.map(HabitEntry.fromMap).toList();
  }

  Future<HabitEntry?> entry(String habitId, DateTime date) async {
    final db = await _db.database;
    final rows = await db.query('habit_entries',
        where: 'habit_id=? AND date=?',
        whereArgs: [habitId, dateKey(date)], limit: 1);
    return rows.isEmpty ? null : HabitEntry.fromMap(rows.first);
  }

  Future<HabitEntry> upsert({
    required String habitId,
    required DateTime date,
    required int progress,
    required bool isCompleted,
  }) async {
    final db = await _db.database;
    final existing = await entry(habitId, date);
    final now = DateTime.now();

    if (existing != null) {
      final updated = existing.copyWith(
        progress: progress,
        isCompleted: isCompleted,
        completedAt: isCompleted ? now : null,
      );
      await db.update('habit_entries', updated.toMap(),
          where: 'id=?', whereArgs: [updated.id]);
      return updated;
    }

    final e = HabitEntry(
      id: _uuid.v4(), habitId: habitId, date: date,
      progress: progress, isCompleted: isCompleted,
      completedAt: isCompleted ? now : null,
    );
    await db.insert('habit_entries', e.toMap());
    return e;
  }

  // ── Streaks ───────────────────────────────────────────────────────────────

  Future<int> streak(String habitId) async {
    final db = await _db.database;
    int count = 0;
    var day = DateTime.now();
    while (true) {
      final rows = await db.query('habit_entries',
          where: 'habit_id=? AND date=? AND is_completed=?',
          whereArgs: [habitId, dateKey(day), 1], limit: 1);
      if (rows.isEmpty) break;
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  Future<Map<String, int>> allStreaks() async {
    final habits = await getAll();
    final result = <String, int>{};
    for (final h in habits) result[h.id] = await streak(h.id);
    return result;
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> statsForDate(DateTime date) async {
    final db = await _db.database;
    final total = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM habits WHERE is_active=1')) ?? 0;
    final done = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM habit_entries WHERE date=? AND is_completed=1',
      [dateKey(date)])) ?? 0;
    return {
      'total': total, 'completed': done,
      'pct': total > 0 ? (done / total * 100).round() : 0,
    };
  }

  Future<List<Map<String, dynamic>>> weeklyStats() async {
    final today = DateTime.now();
    final stats = <Map<String, dynamic>>[];
    for (var i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      stats.add({...await statsForDate(d), 'date': d});
    }
    return stats;
  }

  Future<List<HabitEntry>> entriesForHabit(String habitId,
      {int days = 30}) async {
    final db = await _db.database;
    final end   = DateTime.now();
    final start = end.subtract(Duration(days: days));
    final rows  = await db.query('habit_entries',
        where: 'habit_id=? AND date>=? AND date<=?',
        whereArgs: [habitId, dateKey(start), dateKey(end)],
        orderBy: 'date ASC');
    return rows.map(HabitEntry.fromMap).toList();
  }

  Future<int> totalCompletions(String habitId) async {
    final db = await _db.database;
    return Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM habit_entries WHERE habit_id=? AND is_completed=1',
      [habitId])) ?? 0;
  }
}