import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers.dart';
import '../../../../core/theme/app_theme.dart';

class CalendarStrip extends ConsumerStatefulWidget {
  const CalendarStrip({super.key});
  @override
  ConsumerState<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends ConsumerState<CalendarStrip> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _weekStart = today.subtract(Duration(days: today.weekday % 7));
  }

  List<DateTime> get _days =>
      List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedDateProvider);
    return Column(
      children: [
        // Month label + nav
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.textMid),
                onPressed: () =>
                    setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7))),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy').format(_weekStart),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textMid, fontSize: 13, fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMid),
                onPressed: () =>
                    setState(() => _weekStart = _weekStart.add(const Duration(days: 7))),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        // Days row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days.map((d) {
              final isSelected = _sameDay(d, selected);
              final isToday    = _sameDay(d, DateTime.now());
              return GestureDetector(
                onTap: () => ref.read(selectedDateProvider.notifier).state =
                    DateTime(d.year, d.month, d.day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40, height: 58,
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isToday && !isSelected
                        ? Border.all(color: AppTheme.accent, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(d).substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textLow,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.textHigh,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}