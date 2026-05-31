import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../application/location_controller.dart';

/// Punkt questu na mapie (model tymczasowy – docelowo z backendu).
class _MapQuest {
  const _MapQuest({
    required this.title,
    required this.position,
    required this.reward,
    required this.color,
    required this.icon,
  });

  final String title;
  final LatLng position;
  final int reward;
  final Color color;
  final IconData icon;
}

/// Ekran „Mapa" – aktualna lokalizacja użytkownika + questy w terenie (OSM).
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

  List<_MapQuest> _buildQuests(AppLocalizations l10n) => [
        _MapQuest(
          title: l10n.mapQuestParkTreasure,
          position: const LatLng(52.2350, 21.0050),
          reward: 200,
          color: AppColors.accent,
          icon: Icons.park,
        ),
        _MapQuest(
          title: l10n.mapQuestViewpoint,
          position: const LatLng(52.2270, 21.0200),
          reward: 150,
          color: AppColors.secondary,
          icon: Icons.visibility,
        ),
        _MapQuest(
          title: l10n.mapQuestRiversideRun,
          position: const LatLng(52.2230, 21.0300),
          reward: 300,
          color: AppColors.primary,
          icon: Icons.directions_run,
        ),
      ];

  void _showQuest(_MapQuest quest) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: quest.color.withValues(alpha: 0.15),
                  child: Icon(quest.icon, color: quest.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    quest.title,
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
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.navigation),
              label: Text(l10n.mapNavigateToQuest),
            ),
          ],
        ),
      ),
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
    final quests = _buildQuests(l10n);
    final location = ref.watch(locationProvider);

    // Wyśrodkuj mapę na użytkowniku przy pierwszym odczycie pozycji.
    ref.listen(locationProvider, (previous, next) {
      if (!_centeredOnUser && next.position != null) {
        _centeredOnUser = true;
        _controller.move(next.position!, 16);
      }
    });

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
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.movequest.movequest_mob',
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
                    Marker(
                      point: quest.position,
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => _showQuest(quest),
                        child:
                            _QuestMarker(color: quest.color, icon: quest.icon),
                      ),
                    ),
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
                  _InfoPill(
                    icon: Icons.explore,
                    label: l10n.mapQuestsNearby(quests.length),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _recenter(location),
        child: location.status == LocationStatus.loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.my_location),
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

class _QuestMarker extends StatelessWidget {
  const _QuestMarker({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}
