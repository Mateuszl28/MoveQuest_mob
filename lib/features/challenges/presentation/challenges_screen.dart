import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Pozycja w rankingu (model tymczasowy).
class _Ranked {
  const _Ranked(this.name, this.points, {this.isMe = false});
  final String name;
  final int points;
  final bool isMe;
}

/// Ekran „Wyzwania" – rywalizacja ze znajomymi i ranking.
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  static const String path = '/challenges';

  static const List<_Ranked> _leaderboard = [
    _Ranked('Ola K.', 3120),
    _Ranked('Marek W.', 2870),
    _Ranked('Ty', 2540, isMe: true),
    _Ranked('Kasia P.', 2210),
    _Ranked('Tomek L.', 1980),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList.list(
              children: [
                Text(
                  'Wyzwania',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _ChallengeCard(
                  title: 'Tydzień 10 000 kroków',
                  subtitle: 'Z Twoją grupą • 3 dni do końca',
                  progress: 0.72,
                  participants: 4,
                ),
                const SizedBox(height: 12),
                _ChallengeCard(
                  title: 'Weekendowy maraton questów',
                  subtitle: 'Ukończ 5 questów w terenie',
                  progress: 0.4,
                  participants: 12,
                ),
                const SizedBox(height: 24),
                Text(
                  'Ranking znajomych',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverList.builder(
              itemCount: _leaderboard.length,
              itemBuilder: (context, index) =>
                  _RankTile(rank: index + 1, entry: _leaderboard[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.participants,
  });

  final String title;
  final String subtitle;
  final double progress;
  final int participants;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _ParticipantsBadge(count: participants),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.black12,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).round()}% ukończone',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantsBadge extends StatelessWidget {
  const _ParticipantsBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.group, size: 16, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  const _RankTile({required this.rank, required this.entry});

  final int rank;
  final _Ranked entry;

  Color get _medalColor => switch (rank) {
        1 => const Color(0xFFFFD700),
        2 => const Color(0xFFC0C0C0),
        3 => const Color(0xFFCD7F32),
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: entry.isMe
          ? AppColors.primary.withValues(alpha: 0.10)
          : Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: rank <= 3
                  ? Icon(Icons.emoji_events, color: _medalColor)
                  : Text(
                      '$rank',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
              child: Text(
                entry.name.characters.first,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.name,
                style: TextStyle(
                  fontWeight:
                      entry.isMe ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.stars_rounded,
                color: AppColors.accent, size: 18),
            const SizedBox(width: 4),
            Text(
              '${entry.points}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
