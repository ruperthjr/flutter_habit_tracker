import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models.dart';
import '../data/habit_repository.dart';
import '../../../core/database/database_helper.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final dbProvider   = Provider<DatabaseHelper>((ref) => DatabaseHelper());
final repoProvider = Provider<HabitRepository>((ref) => HabitRepository(ref.watch(dbProvider)));

// ── UI State ──────────────────────────────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((_) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
});

final timeFilterProvider  = StateProvider<String>((_) => 'all');
final activeTabProvider   = StateProvider<int>((_) => 0);

// ── Habits ────────────────────────────────────────────────────────────────────

class HabitsNotifier extends AsyncNotifier<List<Habit>> {
  @override
  Future<List<Habit>> build() => ref.watch(repoProvider).getAll();

  Future<void> add(Habit h)    async { await ref.read(repoProvider).insert(h); ref.invalidateSelf(); }
  Future<void> edit(Habit h)   async { await ref.read(repoProvider).update(h); ref.invalidateSelf(); }
  Future<void> remove(String id) async { await ref.read(repoProvider).delete(id); ref.invalidateSelf(); }
  Future<void> reorder(List<Habit> list) async {
    await ref.read(repoProvider).reorder(list);
    ref.invalidateSelf();
  }
}

final habitsProvider = AsyncNotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

// ── Filtered Habits ───────────────────────────────────────────────────────────

final filteredHabitsProvider = Provider<AsyncValue<List<Habit>>>((ref) {
  final filter = ref.watch(timeFilterProvider);
  return ref.watch(habitsProvider).whenData((habits) =>
      filter == 'all' ? habits : habits.where((h) => h.timeOfDay.key == filter).toList());
});

// ── Entries ───────────────────────────────────────────────────────────────────

final entriesForDateProvider =
    FutureProvider.family<List<HabitEntry>, DateTime>((ref, date) =>
        ref.watch(repoProvider).entriesForDate(date));

// ── Streaks ───────────────────────────────────────────────────────────────────

final streakProvider =
    FutureProvider.family<int, String>((ref, habitId) =>
        ref.watch(repoProvider).streak(habitId));

final allStreaksProvider =
    FutureProvider<Map<String, int>>((ref) => ref.watch(repoProvider).allStreaks());

// ── Stats ─────────────────────────────────────────────────────────────────────

final todayStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(repoProvider).statsForDate(date);
});

final weeklyStatsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) => ref.watch(repoProvider).weeklyStats());

// ── Entry Updater ─────────────────────────────────────────────────────────────

class EntryNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle({
    required Habit habit,
    required DateTime date,
    required HabitEntry? current,
  }) async {
    final repo = ref.read(repoProvider);

    late int  newProgress;
    late bool done;

    if (habit.goalType == GoalType.check) {
      done        = !(current?.isCompleted ?? false);
      newProgress = done ? 1 : 0;
    } else {
      newProgress = ((current?.progress ?? 0) + 1).clamp(0, habit.goalValue * 2);
      done        = newProgress >= habit.goalValue;
    }

    await repo.upsert(
      habitId: habit.id, date: date,
      progress: newProgress, isCompleted: done,
    );

    ref.invalidate(entriesForDateProvider(date));
    ref.invalidate(todayStatsProvider);
    ref.invalidate(streakProvider(habit.id));
    ref.invalidate(allStreaksProvider);
  }

  Future<void> reset({required String habitId, required DateTime date}) async {
    await ref.read(repoProvider).upsert(
      habitId: habitId, date: date, progress: 0, isCompleted: false,
    );
    ref.invalidate(entriesForDateProvider(date));
    ref.invalidate(todayStatsProvider);
    ref.invalidate(streakProvider(habitId));
    ref.invalidate(allStreaksProvider);
  }
}

final entryNotifier = NotifierProvider<EntryNotifier, void>(EntryNotifier.new);