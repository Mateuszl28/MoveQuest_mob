import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../quest/application/quest_controller.dart';
import '../../quest/domain/quest.dart';
import '../../workout/application/workout_controller.dart';
import '../application/location_controller.dart';

/// Wygląd questu danego rodzaju (tytuł, kolor, ikona).
({String title, Color color, IconData icon}) _questMeta(
  AppLocalizations l10n,
  QuestKind kind,
) {
  return switch (kind) {
    QuestKind.parkTreasure =>
      (title: l10n.mapQuestParkTreasure, color: AppColors.accent, icon: Icons.park),
    QuestKind.viewpoint => (
        title: l10n.mapQuestViewpoint,
        color: AppColors.secondary,
        icon: Icons.visibility
      ),
    QuestKind.riversideRun => (
        title: l10n.mapQuestRiversideRun,
        color: AppColors.primary,
        icon: Icons.directions_run
      ),
  };
}

/// Ekran „Mapa" – aktualna lokalizacja + questy w terenie z ukończaniem (OSM).
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  static const String path = '/map';

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _controller = MapController();
  bool _centeredOnUser = false;

  // Centrum startowe – Warszawa (do czasu pierwszego odczytu GPS).
  static const LatLng _fallbackCenter = LatLng(52.2297, 21.0122);

  // Punkt zakotwiczenia questów (ustawiany przy pierwszym odczycie pozycji),
  // dzięki czemu questy są blisko użytkownika i nie „skaczą".
  LatLng? _anchor;

  // Przesunięcia questów względem zakotwiczenia (w stopniach ~ metry).
  static const Map<QuestKind, ({double dLat, double dLng})> _offsets = {
    QuestKind.parkTreasure: (dLat: 0.00022, dLng: 0.00012), // ~28 m
    QuestKind.viewpoint: (dLat: 0.0011, dLng: -0.0009), // ~150 m
    QuestKind.riversideRun: (dLat: -0.0032, dLng: 0.0021), // ~390 m
  };

  LatLng _positionFor(QuestKind kind, LatLng anchor) {
    final o = _offsets[kind]!;
    return LatLng(anchor.latitude + o.dLat, anchor.longitude + o.dLng);
  }

  void _openQuestSheet(QuestKind kind, LatLng position) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _QuestSheet(kind: kind, position: position),
    );
  }

  void _recenter(LocationState location) {
    if (location.position != null) {
      _controller.move(location.position!, 16);
    } else {
      ref.read(locationProvider.notifier).retry();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final location = ref.watch(locationProvider);
    final quests = ref.watch(questProvider);
    final workout = ref.watch(workoutProvider);

    // Wyśrodkuj mapę i zakotwicz questy przy pierwszym odczycie pozycji.
    ref.listen(locationProvider, (previous, next) {
      if (!_centeredOnUser && next.position != null) {
        _centeredOnUser = true;
        setState(() => _anchor = next.position);
        _controller.move(next.position!, 16);
      }
    });

    final anchor = _anchor ?? location.position ?? _fallbackCenter;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: const MapOptions(
              initialCenter: _fallbackCenter,
              initialZoom: 14,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.movequest.movequest_mob',
              ),
              if (workout.route.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: workout.route,
                      strokeWidth: 5,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              if (location.position != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location.position!,
                      width: 28,
                      height: 28,
                      child: const _UserLocationDot(),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (final quest in quests)
                    () {
                      final pos = _positionFor(quest.kind, anchor);
                      final meta = _questMeta(l10n, quest.kind);
                      return Marker(
                        point: pos,
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () => _openQuestSheet(quest.kind, pos),
                          child: _QuestMarker(
                            color: meta.color,
                            icon: meta.icon,
                            completed: quest.completed,
                          ),
                        ),
                      );
                    }(),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _InfoPill(
                        icon: Icons.explore,
                        label: l10n.mapQuestsNearby(quests.length),
                      ),
                      const Spacer(),
                      _CircleButton(
                        loading: location.status == LocationStatus.loading,
                        onTap: () => _recenter(location),
                      ),
                    ],
                  ),
                  if (location.status == LocationStatus.permissionRequired ||
                      location.status == LocationStatus.serviceDisabled) ...[
                    const SizedBox(height: 10),
                    _LocationBanner(status: location.status),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: const _WorkoutPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Okrągły przycisk „moja lokalizacja" w rogu mapy.
class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.onTap, this.loading = false});

  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(13),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location, color: AppColors.secondary),
        ),
      ),
    );
  }
}

/// Arkusz szczegółów questu z liczeniem dystansu i przyciskiem ukończenia.
class _QuestSheet extends ConsumerWidget {
  const _QuestSheet({required this.kind, required this.position});

  final QuestKind kind;
  final LatLng position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final quest = ref.watch(questProvider).firstWhere((q) => q.kind == kind);
    final userPos = ref.watch(locationProvider).position;
    final meta = _questMeta(l10n, kind);

    final double? distance = userPos == null
        ? null
        : Geolocator.distanceBetween(
            userPos.latitude,
            userPos.longitude,
            position.latitude,
            position.longitude,
          );
    final canComplete = !quest.completed &&
        distance != null &&
        distance <= kQuestCompletionRadiusMeters;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: meta.color.withValues(alpha: 0.15),
                child: Icon(meta.icon, color: meta.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  meta.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                avatar: const Icon(Icons.stars_rounded,
                    color: AppColors.accent, size: 18),
                label: Text('+${quest.reward}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.mapQuestDescription,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          if (quest.completed)
            _CompletedRow(label: l10n.questCompletedBadge)
          else ...[
            if (distance != null)
              Row(
                children: [
                  const Icon(Icons.straighten,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    l10n.questDistanceAway(distance.round()),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: canComplete
                  ? () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      final reward = quest.reward;
                      await ref.read(questProvider.notifier).complete(kind);
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.questCompletedToast(reward))),
                      );
                    }
                  : null,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l10n.questComplete),
            ),
            if (!canComplete)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.questTooFar,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _CompletedRow extends StatelessWidget {
  const _CompletedRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Niebieska kropka oznaczająca pozycję użytkownika.
class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Baner zachęcający do włączenia lokalizacji / nadania uprawnienia.
class _LocationBanner extends ConsumerWidget {
  const _LocationBanner({required this.status});

  final LocationStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final message = status == LocationStatus.serviceDisabled
        ? l10n.mapServiceDisabled
        : l10n.mapPermissionRequired;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 13)),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              if (status == LocationStatus.serviceDisabled) {
                await Geolocator.openLocationSettings();
              } else {
                await Geolocator.openAppSettings();
              }
              ref.read(locationProvider.notifier).retry();
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: Text(l10n.mapEnableLocation),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

String _formatPace(Duration d, double km) {
  if (km < 0.05 || d.inSeconds == 0) return '—';
  final secPerKm = d.inSeconds / km;
  final minutes = secPerKm ~/ 60;
  final seconds = (secPerKm % 60).round().toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// Panel treningu na dole mapy: start albo statystyki na żywo + stop.
class _WorkoutPanel extends ConsumerWidget {
  const _WorkoutPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final workout = ref.watch(workoutProvider);
    final location = ref.watch(locationProvider);

    // Pokazuj panel tylko, gdy mamy lokalizację (lub trwa nagrywanie).
    if (!workout.isRecording && location.status != LocationStatus.tracking) {
      return const SizedBox.shrink();
    }

    final localeName = Localizations.localeOf(context).toString();
    final kmFmt = NumberFormat('#,##0.00', localeName);

    if (!workout.isRecording) {
      return FilledButton.icon(
        onPressed: () => ref.read(workoutProvider.notifier).start(),
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.workoutStart),
      );
    }

    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WorkoutStat(
                  value: _formatDuration(workout.elapsed),
                  label: l10n.workoutTime,
                ),
                _WorkoutStat(
                  value: '${kmFmt.format(workout.distanceKm)} km',
                  label: l10n.statDistance,
                ),
                _WorkoutStat(
                  value: _formatPace(workout.elapsed, workout.distanceKm),
                  label: l10n.workoutPace,
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final summary =
                      await ref.read(workoutProvider.notifier).stop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.workoutSavedToast(
                          kmFmt.format(summary.distanceKm),
                          summary.points,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.stop),
                label: Text(l10n.workoutStop),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutStat extends StatelessWidget {
  const _WorkoutStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _QuestMarker extends StatelessWidget {
  const _QuestMarker({
    required this.color,
    required this.icon,
    this.completed = false,
  });

  final Color color;
  final IconData icon;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final fill = completed ? AppColors.success : color;
    return Container(
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(completed ? Icons.check : icon, color: Colors.white, size: 22),
    );
  }
}
