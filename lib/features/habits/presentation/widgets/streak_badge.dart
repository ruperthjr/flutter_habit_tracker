import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final color = streak >= 30 ? AppTheme.gold
        : streak >= 7  ? AppTheme.orange
        : streak >= 3  ? AppTheme.green
        : AppTheme.accent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('🔥', style: const TextStyle(fontSize: 11)),
        const SizedBox(width: 3),
        Text(
          '$streak day${streak == 1 ? '' : 's'}',
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}