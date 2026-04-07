import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../../../core/theme/app_theme.dart';

class TimeFilterBar extends ConsumerWidget {
  const TimeFilterBar({super.key});

  static const _filters = [
    ('all', 'All Day'), ('morning', 'Morning'),
    ('afternoon', 'Afternoon'), ('evening', 'Evening'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(timeFilterProvider);
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label) = _filters[i];
          final selected = key == current;
          return GestureDetector(
            onTap: () => ref.read(timeFilterProvider.notifier).state = key,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppTheme.accent : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: selected ? null : Border.all(color: AppTheme.divider),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppTheme.textMid,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}