import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Status pozyskiwania lokalizacji użytkownika.
enum LocationStatus {
  /// Trwa sprawdzanie uprawnień / pobieranie pierwszej pozycji.
  loading,

  /// Brak zgody na lokalizację – wymagane działanie użytkownika.
  permissionRequired,

  /// Usługi lokalizacji są wyłączone w systemie.
  serviceDisabled,

  /// Pozycja jest aktualizowana na żywo.
  tracking,
}

/// Stan lokalizacji: status + ostatnia znana pozycja.
class LocationState {
  const LocationState({required this.status, this.position});

  final LocationStatus status;
  final LatLng? position;

  LocationState copyWith({LocationStatus? status, LatLng? position}) {
    return LocationState(
      status: status ?? this.status,
      position: position ?? this.position,
    );
  }
}

/// Provider z aktualną lokalizacją użytkownika (na żywo z GPS).
final locationProvider =
    NotifierProvider<LocationController, LocationState>(LocationController.new);

/// Pobiera i strumieniuje aktualną pozycję użytkownika oraz obsługuje
/// uprawnienia i stan usług lokalizacji.
class LocationController extends Notifier<LocationState> {
  StreamSubscription<Position>? _sub;

  @override
  LocationState build() {
    ref.onDispose(() => _sub?.cancel());
    _init();
    return const LocationState(status: LocationStatus.loading);
  }

  Future<void> _init() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      state = const LocationState(status: LocationStatus.serviceDisabled);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = const LocationState(status: LocationStatus.permissionRequired);
      return;
    }

    await _startTracking();
  }

  /// Ponawia prośbę o uprawnienie / sprawdzenie usługi (przycisk w UI).
  Future<void> retry() async {
    state = const LocationState(status: LocationStatus.loading);
    await _init();
  }

  Future<void> _startTracking() async {
    // Szybki pierwszy odczyt, żeby od razu wycentrować mapę.
    try {
      final first = await Geolocator.getCurrentPosition();
      state = LocationState(
        status: LocationStatus.tracking,
        position: LatLng(first.latitude, first.longitude),
      );
    } catch (_) {
      state = state.copyWith(status: LocationStatus.tracking);
    }

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(
      (pos) {
        state = LocationState(
          status: LocationStatus.tracking,
          position: LatLng(pos.latitude, pos.longitude),
        );
      },
      onError: (_) {},
      cancelOnError: false,
    );
  }
}
