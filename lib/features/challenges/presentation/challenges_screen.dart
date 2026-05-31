import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../application/leaderboard_controller.dart';

/// Ekran „Wyzwania" – rywalizacja ze znajomymi i ranking.
class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  static const String path = '/challenges';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final leaderboard = ref.watch(leaderboardProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverList.list(
              children: [
                Text(
                  l10n.challengesTitle,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _ChallengeCard(
                  title: l10n.challenge1Title,
                  subtitle: l10n.challenge1Subtitle,
                  progress: 0.72,
                  participants: 4,
                ),
                const SizedBox(height: 12),
                _ChallengeCard(
                  title: l10n.challenge2Title,
                  subtitle: l10n.challenge2Subtitle,
                  progress: 0.4,
                  participants: 12,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.challengesLeaderboard,
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
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final entry = leaderboard[index];
                final name = entry.isMe
                    ? (entry.name ?? l10n.challengesYou)
                    : (entry.name ?? '');
                return _RankTile(
                  rank: index + 1,
                  name: name,
                  points: entry.points,
                  isMe: entry.isMe,
                );
              },
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
    final l10n = AppLocalizations.of(context);
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
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.challengesPercentComplete((progress * 100).round()),
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
  const _RankTile({
    required this.rank,
    required this.name,
    required this.points,
    required this.isMe,
  });

  final int rank;
  final String name;
  final int points;
  final bool isMe;

  Color get _medalColor => switch (rank) {
        1 => const Color(0xFFFFD700),
        2 => const Color(0xFFC0C0C0),
        3 => const Color(0xFFCD7F32),
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isMe
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
                name.isEmpty ? '?' : name.characters.first,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.stars_rounded, color: AppColors.accent, size: 18),
            const SizedBox(width: 4),
            Text(
              '$points',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
