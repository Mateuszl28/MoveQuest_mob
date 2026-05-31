import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../map/application/location_controller.dart';
import '../../points/points_controller.dart';
import '../domain/workout_record.dart';
import 'workout_history_controller.dart';

/// Liczba punktów przyznawana za każdy przebyty kilometr treningu.
const int kPointsPerKm = 100;

/// Czy trening jest aktualnie nagrywany.
enum WorkoutStatus { idle, recording }

/// Stan treningu: status, trasa, dystans i czas trwania.
@immutable
class WorkoutState {
  const WorkoutState({
    this.status = WorkoutStatus.idle,
    this.route = const [],
    this.distanceKm = 0,
    this.elapsed = Duration.zero,
  });

  final WorkoutStatus status;
  final List<LatLng> route;
  final double distanceKm;
  final Duration elapsed;

  bool get isRecording => status == WorkoutStatus.recording;

  WorkoutState copyWith({
    WorkoutStatus? status,
    List<LatLng>? route,
    double? distanceKm,
    Duration? elapsed,
  }) {
    return WorkoutState(
      status: status ?? this.status,
      route: route ?? this.route,
      distanceKm: distanceKm ?? this.distanceKm,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}

/// Podsumowanie zakończonego treningu.
@immutable
class WorkoutSummary {
  const WorkoutSummary({
    required this.distanceKm,
    required this.elapsed,
    required this.points,
  });

  final double distanceKm;
  final Duration elapsed;
  final int points;
}

/// Provider treningu opartego na GPS.
final workoutProvider =
    NotifierProvider<WorkoutController, WorkoutState>(WorkoutController.new);

/// Nagrywa trening: zbiera trasę z [locationProvider], liczy dystans i czas,
/// a po zakończeniu przyznaje punkty za przebyty dystans.
class WorkoutController extends Notifier<WorkoutState> {
  Timer? _ticker;
  DateTime? _startedAt;

  @override
  WorkoutState build() {
    // Reużywamy jednego strumienia GPS z kontrolera lokalizacji.
    ref.listen(locationProvider, (previous, next) {
      if (state.isRecording && next.position != null) {
        _addPoint(next.position!);
      }
    });
    ref.onDispose(() => _ticker?.cancel());
    return const WorkoutState();
  }

  /// Rozpoczyna nagrywanie treningu.
  void start() {
    _startedAt = DateTime.now();
    final start = ref.read(locationProvider).position;
    state = WorkoutState(
      status: WorkoutStatus.recording,
      route: [?start],
      distanceKm: 0,
      elapsed: Duration.zero,
    );
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!state.isRecording || _startedAt == null) return;
    state = state.copyWith(elapsed: DateTime.now().difference(_startedAt!));
  }

  void _addPoint(LatLng point) {
    final route = state.route;
    var distance = state.distanceKm;
    if (route.isNotEmpty) {
      final last = route.last;
      final meters = Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        point.latitude,
        point.longitude,
      );
      // Pomijamy mikro-skoki (szum GPS) poniżej 2 m.
      if (meters < 2) return;
      distance += meters / 1000;
    }
    state = state.copyWith(route: [...route, point], distanceKm: distance);
  }

  /// Kończy trening, przyznaje punkty i zwraca podsumowanie.
  Future<WorkoutSummary> stop() async {
    _ticker?.cancel();
    _ticker = null;
    final points = (state.distanceKm * kPointsPerKm).round();
    final summary = WorkoutSummary(
      distanceKm: state.distanceKm,
      elapsed: state.elapsed,
      points: points,
    );
    await ref.read(bonusPointsProvider.notifier).add(points);
    await ref.read(workoutHistoryProvider.notifier).add(
          WorkoutRecord(
            timestampMs: DateTime.now().millisecondsSinceEpoch,
            distanceKm: state.distanceKm,
            durationSeconds: state.elapsed.inSeconds,
            points: points,
          ),
        );
    state = const WorkoutState();
    return summary;
  }
}
