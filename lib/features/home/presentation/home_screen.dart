import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../activity/application/activity_controller.dart';
import '../../activity/domain/activity_data.dart';
import '../../points/points_controller.dart';

/// Ekran „Dziś" – pulpit dzienny z danymi aktywności zbieranymi na żywo.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const String path = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityProvider);
    final points = ref.watch(totalPointsProvider);
    return SafeArea(
      child: switch (state.status) {
        ActivityStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
        ActivityStatus.permissionRequired => const _PermissionPrompt(),
        ActivityStatus.unavailable => const _UnavailableMessage(),
        ActivityStatus.tracking => _Dashboard(data: state.data, points: points),
      },
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.data, required this.points});

  final ActivityData data;
  final int points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final localeName = Localizations.localeOf(context).toString();
    final intFmt = NumberFormat.decimalPattern(localeName);
    final kmFmt = NumberFormat('#,##0.0', localeName);

    final goalProgress = (data.steps / kDailyStepGoal).clamp(0.0, 1.0);
    final remaining = (kDailyStepGoal - data.steps).clamp(0, kDailyStepGoal);

    return ListView(
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          l10n.homeSubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (data.isWalking) ...[
                        const SizedBox(width: 8),
                        const _LiveBadge(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            _PointsBadge(points: points),
          ],
        ),
        const SizedBox(height: 20),
        _DailyGoalCard(
          progress: goalProgress,
          title: l10n.homeDailyGoal,
          remaining: remaining == 0
              ? l10n.homeDailyGoalReached
              : l10n.homeDailyGoalRemaining(remaining),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.directions_walk,
                label: l10n.statSteps,
                value: intFmt.format(data.steps),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.route,
                label: l10n.statDistance,
                value: '${kmFmt.format(data.distanceKm)} km',
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
                value: '${intFmt.format(data.calories)} kcal',
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.timer_outlined,
                label: l10n.statActivity,
                value: '${data.activeMinutes} min',
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
          title: l10n.questStepGoalTitle,
          subtitle: l10n.questStepGoalSubtitle(kDailyStepGoal),
          progress: goalProgress,
          reward: 150,
        ),
        const SizedBox(height: 10),
        _QuestTile(
          title: l10n.questDistanceTitle,
          subtitle: l10n.questDistanceSubtitle,
          progress: (data.distanceKm / 2).clamp(0.0, 1.0),
          reward: 200,
        ),
        const SizedBox(height: 10),
        _QuestTile(
          title: l10n.questActiveTitle,
          subtitle: l10n.questActiveSubtitle,
          progress: (data.activeMinutes / 30).clamp(0.0, 1.0),
          reward: 120,
        ),
      ],
    );
  }
}

/// Prośba o uprawnienie do aktywności fizycznej.
class _PermissionPrompt extends ConsumerWidget {
  const _PermissionPrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.directions_walk,
                  size: 56, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.activityPermissionTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.activityPermissionBody,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(activityProvider.notifier).requestPermission(),
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l10n.activityPermissionButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableMessage extends StatelessWidget {
  const _UnavailableMessage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sensors_off,
                size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              l10n.activityUnavailable,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fiber_manual_record,
              size: 10, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context).liveLabel,
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
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
  const _DailyGoalCard({
    required this.progress,
    required this.title,
    required this.remaining,
  });

  final double progress;
  final String title;
  final String remaining;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
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
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
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
