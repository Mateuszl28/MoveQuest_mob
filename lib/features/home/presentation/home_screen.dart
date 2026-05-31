import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Ekran „Dziś" – pulpit dzienny: postęp aktywności, punkty i aktywne questy.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String path = '/';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeGreeting,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.homeSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const _PointsBadge(points: 1240),
            ],
          ),
          const SizedBox(height: 20),
          _DailyGoalCard(
            title: l10n.homeDailyGoal,
            remaining: l10n.homeDailyGoalRemaining(3600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.directions_walk,
                  label: l10n.statSteps,
                  value: '6 420',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.route,
                  label: l10n.statDistance,
                  value: '4,8 km',
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  label: l10n.statCalories,
                  value: '312 kcal',
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_outlined,
                  label: l10n.statActivity,
                  value: '54 min',
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.homeActiveQuests,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _QuestTile(
            title: l10n.questWalkParkTitle,
            subtitle: l10n.questWalkParkSubtitle,
            progress: 0.6,
            reward: 150,
          ),
          const SizedBox(height: 10),
          _QuestTile(
            title: l10n.questMorningTitle,
            subtitle: l10n.questMorningSubtitle,
            progress: 1.0,
            reward: 80,
          ),
          const SizedBox(height: 10),
          _QuestTile(
            title: l10n.questExplorerTitle,
            subtitle: l10n.questExplorerSubtitle,
            progress: 0.0,
            reward: 200,
          ),
        ],
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points});

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 6),
          Text(
            '$points',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  const _DailyGoalCard({required this.title, required this.remaining});

  final String title;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    const progress = 0.64;
    return Card(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const Text(
                    '64%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remaining,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.reward,
  });

  final String title;
  final String subtitle;
  final double progress;
  final int reward;

  @override
  Widget build(BuildContext context) {
    final done = progress >= 1.0;
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (done ? AppColors.success : AppColors.secondary)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                done ? Icons.check_circle : Icons.flag_outlined,
                color: done ? AppColors.success : AppColors.secondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation(
                        done ? AppColors.success : AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                const Icon(Icons.stars_rounded,
                    color: AppColors.accent, size: 18),
                Text(
                  '+$reward',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
