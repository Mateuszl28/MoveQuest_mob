import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';

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

/// Ekran „Mapa" – questy w terenie oparte na lokalizacji (OpenStreetMap).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const String path = '/map';

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _controller = MapController();

  // Centrum startowe – Warszawa (placeholder do czasu wpięcia GPS).
  static const LatLng _initialCenter = LatLng(52.2297, 21.0122);

  static const List<_MapQuest> _quests = [
    _MapQuest(
      title: 'Skarb w parku',
      position: LatLng(52.2350, 21.0050),
      reward: 200,
      color: AppColors.accent,
      icon: Icons.park,
    ),
    _MapQuest(
      title: 'Punkt widokowy',
      position: LatLng(52.2270, 21.0200),
      reward: 150,
      color: AppColors.secondary,
      icon: Icons.visibility,
    ),
    _MapQuest(
      title: 'Bieg nad rzeką',
      position: LatLng(52.2230, 21.0300),
      reward: 300,
      color: AppColors.primary,
      icon: Icons.directions_run,
    ),
  ];

  void _showQuest(_MapQuest quest) {
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
            const Text(
              'Dotrzyj do tego miejsca, aby ukończyć quest i zgarnąć punkty.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.navigation),
              label: const Text('Nawiguj do questu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: const MapOptions(
              initialCenter: _initialCenter,
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
              MarkerLayer(
                markers: [
                  for (final quest in _quests)
                    Marker(
                      point: quest.position,
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => _showQuest(quest),
                        child: _QuestMarker(color: quest.color, icon: quest.icon),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.explore, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${_quests.length} questy w pobliżu',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _controller.move(_initialCenter, 14),
        child: const Icon(Icons.my_location),
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
