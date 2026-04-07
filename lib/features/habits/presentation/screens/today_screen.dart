import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers.dart';
import '../widgets/calendar_strip.dart';
import '../widgets/time_filter_bar.dart';
import '../widgets/nature_scene.dart';
import '../widgets/habit_card.dart';
import '../../../../core/theme/app_theme.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate   = ref.watch(selectedDateProvider);
    final habitsAsync    = ref.watch(filteredHabitsProvider);
    final entriesAsync   = ref.watch(entriesForDateProvider(selectedDate));
    final statsAsync     = ref.watch(todayStatsProvider);
    final isToday        = _isSameDay(selectedDate, DateTime.now());
    final dateLabel      = isToday
        ? 'Today'
        : DateFormat('EEEE, MMM d').format(selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: false,
            floating: true,
            backgroundColor: AppTheme.bg,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dateLabel,
                              style: Theme.of(context).textTheme.displaySmall),
                            statsAsync.when(
                              data: (s) => Text(
                                '${s['completed']}/${s['total']} completed · ${s['pct']}%',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined,
                              color: AppTheme.textMid),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const CalendarStrip(),
                ],
              ),
            ),
          ),

          // ── Nature Scene ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: Stack(
                children: [
                  const NatureScene(),
                  // Progress bar overlay
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: statsAsync.when(
                      data: (s) => _ProgressOverlay(pct: (s['pct'] as int) / 100),
                      loading: () => const _ProgressOverlay(pct: 0),
                      error: (_, __) => const _ProgressOverlay(pct: 0),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Time Filter ───────────────────────────────────────────────────
          const SliverToBoxAdapter(child: TimeFilterBar()),

          // ── Habit List ────────────────────────────────────────────────────
          habitsAsync.when(
            data: (habits) {
              if (habits.isEmpty) {
                return SliverToBoxAdapter(child: _EmptyState(isToday: isToday));
              }
              return entriesAsync.when(
                data: (entries) {
                  final entryMap = {for (final e in entries) e.habitId: e};
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: HabitCard(
                            habit: habits[i],
                            entry: entryMap[habits[i].id],
                            date:  selectedDate,
                          ),
                        ),
                        childCount: habits.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: AppTheme.accent),
                    ))),
                error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $e'))),
              );
            },
            loading: () => const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ))),
            error: (e, _) => SliverToBoxAdapter(child: Text('$e')),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _ProgressOverlay extends StatelessWidget {
  const _ProgressOverlay({required this.pct});
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(2),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: pct.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AppTheme.green, AppTheme.accent],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isToday});
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text(
            isToday ? 'No habits yet' : 'No habits for this day',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isToday
                ? 'Tap + to add your first habit and start building\nyour best self!'
                : 'Switch to Today to add new habits.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}