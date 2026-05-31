import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Odznaka zdobyta przez użytkownika (model tymczasowy).
class _Badge {
  const _Badge(this.label, this.icon, this.color, {this.unlocked = true});
  final String label;
  final IconData icon;
  final Color color;
  final bool unlocked;
}

/// Ekran „Profil" – poziom, doświadczenie i odznaki.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String path = '/profile';

  static const List<_Badge> _badges = [
    _Badge('Pierwszy krok', Icons.directions_walk, AppColors.primary),
    _Badge('Odkrywca', Icons.explore, AppColors.secondary),
    _Badge('Maratończyk', Icons.local_fire_department, AppColors.warning),
    _Badge('Ranny ptaszek', Icons.wb_sunny, AppColors.accent),
    _Badge('Mistrz', Icons.workspace_premium, AppColors.danger,
        unlocked: false),
    _Badge('Legenda', Icons.military_tech, AppColors.primaryDark,
        unlocked: false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined),
            ),
          ),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor:
                      AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(Icons.person,
                      size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Podróżnik',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Poziom 7 • Łowca questów',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _LevelCard(level: 7, xp: 2540, xpForNext: 3000),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                child: _MiniStat(value: '38', label: 'Questy'),
              ),
              Expanded(
                child: _MiniStat(value: '142 km', label: 'Łącznie'),
              ),
              Expanded(
                child: _MiniStat(value: '12', label: 'Dni z rzędu'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Odznaki',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
            children: [for (final b in _badges) _BadgeTile(badge: b)],
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.xp,
    required this.xpForNext,
  });

  final int level;
  final int xp;
  final int xpForNext;

  @override
  Widget build(BuildContext context) {
    final progress = xp / xpForNext;
    return Card(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, Color(0xFF0039CB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Doświadczenie',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Poziom $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$xp / $xpForNext XP do poziomu ${level + 1}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final _Badge badge;

  @override
  Widget build(BuildContext context) {
    final color = badge.unlocked ? badge.color : AppColors.textSecondary;
    return Opacity(
      opacity: badge.unlocked ? 1 : 0.4,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  badge.unlocked ? badge.icon : Icons.lock_outline,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                badge.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
