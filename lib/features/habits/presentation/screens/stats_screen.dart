import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers.dart';
import '../../domain/models.dart';
import '../../../../core/theme/app_theme.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekly = ref.watch(weeklyStatsProvider);
    final habits = ref.watch(habitsProvider);
    final streaks = ref.watch(allStreaksProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bg,
            title: const Text('Statistics',
                style: TextStyle(color: AppTheme.textHigh, fontWeight: FontWeight.bold)),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Weekly overview ──────────────────────────────────────────
                _SectionTitle('Weekly Overview'),
                const SizedBox(height: 12),
                weekly.when(
                  data: (data) => _WeeklyChart(data: data),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                ),
                const SizedBox(height: 24),

                // ── Today's progress ring ────────────────────────────────────
                _SectionTitle("Today's Progress"),
                const SizedBox(height: 12),
                ref.watch(todayStatsProvider).when(
                  data: (s) => _TodayRing(completed: s['completed'], total: s['total']),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('$e'),
                ),
                const SizedBox(height: 24),

                // ── Streak leaderboard ───────────────────────────────────────
                _SectionTitle('Streak Leaders 🔥'),
                const SizedBox(height: 12),
                habits.when(
                  data: (hs) => streaks.when(
                    data: (sm) {
                      final sorted = [...hs]
                        ..sort((a, b) => (sm[b.id] ?? 0).compareTo(sm[a.id] ?? 0));
                      return Column(
                        children: sorted.take(5).map((h) =>
                          _StreakRow(habit: h, streak: sm[h.id] ?? 0),
                        ).toList(),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('$e'),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('$e'),
                ),
                const SizedBox(height: 24),

                // ── Habit heatmap hint ────────────────────────────────────────
                _SectionTitle('30-Day Activity'),
                const SizedBox(height: 12),
                habits.when(
                  data: (hs) => hs.isEmpty
                      ? const _EmptyStats()
                      : Column(
                          children: hs.take(3).map((h) =>
                            _HabitHeatmapRow(habit: h, ref: ref),
                          ).toList(),
                        ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('$e'),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _SectionTitle(String t) => Text(t,
  style: const TextStyle(
    color: AppTheme.textHigh, fontSize: 17, fontWeight: FontWeight.bold,
  ));

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.data});
  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final maxPct = data.fold<int>(
      1, (m, d) => math.max(m, (d['pct'] as int? ?? 0)));
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          final pct  = (d['pct'] as int? ?? 0);
          final date = d['date'] as DateTime;
          final isToday = _today(date);
          final frac = pct / 100.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('$pct%',
                    style: TextStyle(
                      color: isToday ? AppTheme.accent : AppTheme.textLow,
                      fontSize: 9, fontWeight: FontWeight.w600,
                    )),
                  const SizedBox(height: 4),
                  Flexible(
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 600),
                      heightFactor: frac.clamp(0.04, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: isToday
                                ? [AppTheme.accent, const Color(0xFF1A6ECC)]
                                : [AppTheme.green.withOpacity(0.7),
                                   AppTheme.green.withOpacity(0.3)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(DateFormat('E').format(date).substring(0, 1),
                    style: TextStyle(
                      color: isToday ? AppTheme.accent : AppTheme.textLow,
                      fontSize: 11, fontWeight: FontWeight.w600,
                    )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _today(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }
}

class _TodayRing extends StatelessWidget {
  const _TodayRing({required this.completed, required this.total});
  final int completed, total;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? completed / total : 0.0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80, height: 80,
            child: CustomPaint(
              painter: _RingPainter(progress: pct),
              child: Center(
                child: Text(
                  '${(pct * 100).round()}%',
                  style: const TextStyle(
                    color: AppTheme.textHigh, fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatChip('✅  Completed', '$completed', AppTheme.green),
              const SizedBox(height: 8),
              _StatChip('📋  Total', '$total', AppTheme.accent),
              const SizedBox(height: 8),
              _StatChip('⏳  Remaining', '${total - completed}', AppTheme.orange),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _StatChip(String label, String value, Color color) => Row(
  children: [
    Text(label, style: const TextStyle(color: AppTheme.textMid, fontSize: 13)),
    const SizedBox(width: 8),
    Text(value, style: TextStyle(
      color: color, fontSize: 15, fontWeight: FontWeight.bold,
    )),
  ],
);

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    final bg = Paint()
      ..color = AppTheme.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    if (progress > 0) {
      final fg = Paint()
        ..shader = const LinearGradient(
          colors: [AppTheme.green, AppTheme.accent],
        ).createShader(Rect.fromCircle(center: c, radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2,
        2 * math.pi * progress,
        false, fg,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({required this.habit, required this.streak});
  final Habit habit; final int streak;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppTheme.card, borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Text(habit.icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(habit.name,
          style: const TextStyle(color: AppTheme.textHigh, fontWeight: FontWeight.w600))),
        Text('🔥 $streak', style: TextStyle(
          color: streak >= 7 ? AppTheme.orange : AppTheme.textMid,
          fontWeight: FontWeight.bold,
        )),
      ],
    ),
  );
}

class _HabitHeatmapRow extends StatelessWidget {
  const _HabitHeatmapRow({required this.habit, required this.ref});
  final Habit habit; final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(habit.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(habit.name,
              style: const TextStyle(color: AppTheme.textHigh,
                  fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          _Heatmap(habitId: habit.id, color: habit.color),
        ],
      ),
    );
  }
}

class _Heatmap extends ConsumerWidget {
  const _Heatmap({required this.habitId, required this.color});
  final String habitId; final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(
      FutureProvider.family<List<HabitEntry>, String>((r, id) =>
        r.watch(repoProvider).entriesForHabit(id, days: 30),
      )(habitId),
    );
    return entries.when(
      data: (es) {
        final map = {for (final e in es) dateKey(e.date): e.isCompleted};
        final today = DateTime.now();
        return Wrap(
          spacing: 4, runSpacing: 4,
          children: List.generate(30, (i) {
            final d = today.subtract(Duration(days: 29 - i));
            final done = map[dateKey(d)] ?? false;
            return Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: done ? color : AppTheme.divider,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text('Add habits to see your stats here',
          style: TextStyle(color: AppTheme.textMid)),
    ),
  );
}