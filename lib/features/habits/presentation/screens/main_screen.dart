import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'today_screen.dart';
import 'stats_screen.dart';
import 'explore_screen.dart';
import '../widgets/add_habit_sheet.dart';
import '../../../../core/theme/app_theme.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(activeTabProvider);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: IndexedStack(index: tab, children: [
        const TodayScreen(),
        const StatsScreen(),
        const SizedBox.shrink(),
        const ExploreScreen(),
      ]),
      bottomNavigationBar: _BottomBar(currentTab: tab),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.currentTab});
  final int currentTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                  icon: Icons.today_rounded,
                  label: 'Today',
                  idx: 0,
                  cur: currentTab),
              _NavItem(
                  icon: Icons.emoji_events_rounded,
                  label: 'Challenges',
                  idx: 1,
                  cur: currentTab),
              // FAB
              Expanded(
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddHabitSheet(),
                  ),
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF4A9EFF), Color(0xFF1A6ECC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x664A9EFF),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
              _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Stats',
                  idx: 2,
                  cur: currentTab),
              _NavItem(
                  icon: Icons.explore_rounded,
                  label: 'Explore',
                  idx: 3,
                  cur: currentTab),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.idx,
      required this.cur});
  final IconData icon;
  final String label;
  final int idx, cur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = idx == cur;
    return Expanded(
      child: InkWell(
        onTap: () => ref.read(activeTabProvider.notifier).state = idx,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? AppTheme.accent : AppTheme.textLow, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppTheme.accent : AppTheme.textLow,
                )),
          ],
        ),
      ),
    );
  }
}
