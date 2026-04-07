import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../../../core/theme/app_theme.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  static const _challenges = [
    _Challenge('🌅', '7-Day Morning Warrior',
        'Complete all morning habits for 7 consecutive days', 7, AppTheme.gold),
    _Challenge('💧', 'Hydration Hero',
        'Drink 8 glasses of water daily for 14 days', 14, AppTheme.accent),
    _Challenge('🧘', '30-Day Mindfulness',
        'Meditate every day for 30 days straight', 30, AppTheme.purple),
    _Challenge('📚', 'Knowledge Seeker',
        'Read every day for 21 days without missing once', 21, AppTheme.green),
    _Challenge('🏃', 'Iron Body',
        'Exercise 5 times per week for 4 weeks', 20, AppTheme.orange),
    _Challenge('🌙', 'Sleep Champion',
        'Maintain a consistent sleep schedule for 2 weeks', 14, AppTheme.teal),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streaks = ref.watch(allStreaksProvider);
    final maxStreak = streaks.when(
      data: (m) => m.values.fold(0, (a, b) => a > b ? a : b),
      loading: () => 0, error: (_, __) => 0,
    );

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true, backgroundColor: AppTheme.bg,
            title: const Text('Challenges',
                style: TextStyle(color: AppTheme.textHigh, fontWeight: FontWeight.bold)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Hero card
                _ActiveStreak(maxStreak: maxStreak),
                const SizedBox(height: 20),
                const Text('Available Challenges',
                  style: TextStyle(color: AppTheme.textHigh,
                      fontSize: 17, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._challenges.map((c) => _ChallengeCard(
                  challenge: c, progress: maxStreak,
                )),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveStreak extends StatelessWidget {
  const _ActiveStreak({required this.maxStreak});
  final int maxStreak;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF1E2D40), Color(0xFF0A3D62)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Text('🔥', style: TextStyle(fontSize: 44)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$maxStreak Days',
              style: const TextStyle(color: AppTheme.textHigh,
                  fontSize: 28, fontWeight: FontWeight.bold)),
            const Text('Best Current Streak',
              style: TextStyle(color: AppTheme.textMid, fontSize: 13)),
          ],
        ),
      ],
    ),
  );
}

class _Challenge {
  const _Challenge(this.icon, this.title, this.desc, this.days, this.color);
  final String icon, title, desc; final int days; final Color color;
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.progress});
  final _Challenge challenge; final int progress;

  @override
  Widget build(BuildContext context) {
    final pct  = (progress / challenge.days).clamp(0.0, 1.0);
    final done = pct >= 1.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done
              ? challenge.color.withOpacity(0.5)
              : AppTheme.divider,
          width: done ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(challenge.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(challenge.title,
                      style: const TextStyle(color: AppTheme.textHigh,
                          fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${challenge.days} days',
                      style: TextStyle(color: challenge.color, fontSize: 12)),
                  ],
                ),
              ),
              if (done)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: challenge.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Done! 🎉',
                    style: TextStyle(color: challenge.color,
                        fontSize: 11, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(challenge.desc,
            style: const TextStyle(color: AppTheme.textMid, fontSize: 12)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct, minHeight: 6,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$progress / ${challenge.days} days',
                style: const TextStyle(color: AppTheme.textMid, fontSize: 11)),
              Text('${(pct * 100).round()}%',
                style: TextStyle(color: challenge.color,
                    fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}