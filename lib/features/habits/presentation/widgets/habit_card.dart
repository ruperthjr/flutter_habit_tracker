import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../domain/models.dart';
import '../../../../core/theme/app_theme.dart';
import 'streak_badge.dart';
import 'add_habit_sheet.dart';

class HabitCard extends ConsumerWidget {
  const HabitCard({
    super.key,
    required this.habit,
    required this.entry,
    required this.date,
  });

  final Habit      habit;
  final HabitEntry? entry;
  final DateTime   date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress    = entry?.progress ?? 0;
    final isCompleted = entry?.isCompleted ?? false;
    final streakAsync = ref.watch(streakProvider(habit.id));

    return GestureDetector(
      onTap: () => ref.read(entryNotifier.notifier).toggle(
        habit: habit, date: date, current: entry,
      ),
      onLongPress: () => _showOptions(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isCompleted
              ? habit.color.withOpacity(0.12)
              : AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? habit.color.withOpacity(0.4) : AppTheme.divider,
            width: isCompleted ? 1.5 : 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ── Icon ────────────────────────────────────────────────────────
              _IconBadge(habit: habit, isCompleted: isCompleted),
              const SizedBox(width: 14),
              // ── Name & streak ────────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.name,
                      style: TextStyle(
                        color: isCompleted ? AppTheme.textHigh : AppTheme.textHigh,
                        fontSize: 15, fontWeight: FontWeight.w600,
                        decoration: isCompleted ? TextDecoration.none : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    streakAsync.when(
                      data: (s) => s > 0
                          ? StreakBadge(streak: s)
                          : const _NewBadge(),
                      loading: () => const _NewBadge(),
                      error:   (_, __) => const _NewBadge(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ── Progress indicator ───────────────────────────────────────────
              _ProgressWidget(
                habit: habit, progress: progress, isCompleted: isCompleted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textLow,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppTheme.accent),
              title: const Text('Edit Habit', style: TextStyle(color: AppTheme.textHigh)),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddHabitSheet(editHabit: habit),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh_rounded, color: AppTheme.textMid),
              title: const Text('Reset Today', style: TextStyle(color: AppTheme.textHigh)),
              onTap: () {
                Navigator.pop(context);
                ref.read(entryNotifier.notifier).reset(
                  habitId: habit.id, date: date,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('Delete Habit',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                ref.read(habitsProvider.notifier).remove(habit.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.habit, required this.isCompleted});
  final Habit habit; final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: habit.color.withOpacity(isCompleted ? 0.25 : 0.15),
        border: Border.all(
          color: habit.color.withOpacity(isCompleted ? 0.8 : 0.3),
          width: 1.5,
        ),
        boxShadow: isCompleted
            ? [BoxShadow(color: habit.color.withOpacity(0.3), blurRadius: 12)]
            : null,
      ),
      child: Center(
        child: Text(habit.icon, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

class _ProgressWidget extends StatelessWidget {
  const _ProgressWidget({
    required this.habit, required this.progress, required this.isCompleted,
  });
  final Habit habit; final int progress; final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (habit.goalType == GoalType.check) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 28, height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? habit.color : Colors.transparent,
          border: Border.all(
            color: isCompleted ? habit.color : AppTheme.textLow,
            width: 2,
          ),
          boxShadow: isCompleted
              ? [BoxShadow(color: habit.color.withOpacity(0.4), blurRadius: 8)]
              : null,
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
            : null,
      );
    }

    if (habit.goalType == GoalType.timer) {
      return Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? habit.color : habit.color.withOpacity(0.15),
          border: Border.all(color: habit.color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_rounded : Icons.timer_rounded,
              color: isCompleted ? Colors.white : habit.color, size: 18,
            ),
            if (!isCompleted)
              Text('${habit.goalValue}m',
                  style: TextStyle(color: habit.color, fontSize: 10,
                      fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // Count type
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: '$progress',
              style: TextStyle(
                color: isCompleted ? habit.color : AppTheme.accent,
                fontSize: 20, fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: '/${habit.goalValue}',
              style: const TextStyle(color: AppTheme.textMid, fontSize: 13),
            ),
          ]),
        ),
        Text(habit.unit,
            style: const TextStyle(color: AppTheme.textLow, fontSize: 11)),
      ],
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Icon(Icons.star_rounded, color: Color(0xFF4A9EFF), size: 12),
      const SizedBox(width: 3),
      Text('New', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.accent, fontSize: 11,
      )),
    ],
  );
}