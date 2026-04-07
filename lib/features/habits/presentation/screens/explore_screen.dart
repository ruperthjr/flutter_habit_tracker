import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../domain/models.dart';
import '../widgets/add_habit_sheet.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  static const _categories = [
    _Category('💪', 'Fitness', [
      _Template('🏃', 'Morning Run', 'morning', GoalType.timer, 30, 'min'),
      _Template('🏋️', 'Workout', 'morning', GoalType.check, 1, 'times'),
      _Template('🚴', 'Cycling', 'afternoon', GoalType.timer, 45, 'min'),
      _Template('🤸', 'Stretching', 'evening', GoalType.timer, 15, 'min'),
    ]),
    _Category('🧠', 'Mind', [
      _Template('🧘', 'Meditate', 'morning', GoalType.timer, 10, 'min'),
      _Template('📚', 'Read', 'evening', GoalType.count, 20, 'pages'),
      _Template('✍️', 'Journal', 'evening', GoalType.check, 1, 'times'),
      _Template('🎯', 'Focus Session', 'morning', GoalType.timer, 25, 'min'),
    ]),
    _Category('💊', 'Health', [
      _Template('💧', 'Drink Water', 'all', GoalType.count, 8, 'glasses'),
      _Template('🥗', 'Eat Vegetables', 'all', GoalType.count, 3, 'portions'),
      _Template('😴', 'Sleep 8h', 'evening', GoalType.check, 1, 'times'),
      _Template('💊', 'Take Vitamins', 'morning', GoalType.check, 1, 'times'),
    ]),
    _Category('✨', 'Productivity', [
      _Template('💻', 'Deep Work', 'morning', GoalType.timer, 90, 'min'),
      _Template('📝', 'Planning', 'morning', GoalType.check, 1, 'times'),
      _Template('🧹', 'Tidy Desk', 'evening', GoalType.check, 1, 'times'),
      _Template('🌿', 'No Phone 1h', 'morning', GoalType.check, 1, 'times'),
    ]),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, backgroundColor: AppTheme.bg,
            title: const Text('Explore',
              style: TextStyle(color: AppTheme.textHigh, fontWeight: FontWeight.bold)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  style: const TextStyle(color: AppTheme.textHigh),
                  decoration: InputDecoration(
                    hintText: 'Search habit templates…',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMid),
                    filled: true, fillColor: AppTheme.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _CategorySection(cat: _categories[i], ref: ref),
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.cat, required this.ref});
  final _Category cat; final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 16),
          child: Text('${cat.icon} ${cat.name}',
            style: const TextStyle(color: AppTheme.textHigh,
                fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...cat.templates.map((t) => _TemplateCard(template: t, ref: ref)),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.ref});
  final _Template template; final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.habitColors[
        template.icon.codeUnitAt(0) % AppTheme.habitColors.length];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(template.icon,
              style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(template.name,
                  style: const TextStyle(color: AppTheme.textHigh,
                      fontWeight: FontWeight.w600)),
                Text(
                  '${template.goalType.name} · ${template.goalValue} ${template.unit}',
                  style: const TextStyle(color: AppTheme.textMid, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitsProvider.notifier).add(Habit(
                id: const Uuid().v4(),
                name: template.name,
                icon: template.icon,
                color: color,
                timeOfDay: HabitTimeX.fromKey(template.timeKey),
                goalType: template.goalType,
                goalValue: template.goalValue,
                unit: template.unit,
                createdAt: DateTime.now(),
              ));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${template.name} added!'),
                backgroundColor: AppTheme.green,
                duration: const Duration(seconds: 2),
              ));
            },
            style: TextButton.styleFrom(
              backgroundColor: color.withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('Add', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _Category {
  const _Category(this.icon, this.name, this.templates);
  final String icon, name; final List<_Template> templates;
}

class _Template {
  const _Template(this.icon, this.name, this.timeKey,
      this.goalType, this.goalValue, this.unit);
  final String icon, name, timeKey, unit;
  final GoalType goalType; final int goalValue;
}