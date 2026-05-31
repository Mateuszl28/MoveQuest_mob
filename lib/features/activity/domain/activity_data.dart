import 'package:flutter/foundation.dart';

/// Status zbierania danych o aktywności.
enum ActivityStatus {
  /// Trwa inicjalizacja / sprawdzanie uprawnień.
  loading,

  /// Brak zgody na dostęp do aktywności fizycznej – wymagane działanie usera.
  permissionRequired,

  /// Urządzenie nie ma czujnika kroków.
  unavailable,

  /// Dane są zbierane na żywo.
  tracking,
}

/// Migawka danych o aktywności użytkownika, liczona na żywo z czujnika kroków.
@immutable
class ActivityData {
  const ActivityData({
    this.steps = 0,
    this.distanceKm = 0,
    this.calories = 0,
    this.activeMinutes = 0,
    this.isWalking = false,
  });

  /// Liczba kroków zrobionych dzisiaj.
  final int steps;

  /// Pokonany dystans (km), szacowany z liczby kroków.
  final double distanceKm;

  /// Spalone kalorie (kcal), szacowane z liczby kroków.
  final int calories;

  /// Łączny czas aktywności (minuty) na podstawie statusu chodzenia.
  final int activeMinutes;

  /// Czy użytkownik aktualnie idzie.
  final bool isWalking;
}

/// Stan kontrolera aktywności: status + dane.
@immutable
class ActivityState {
  const ActivityState({
    required this.status,
    this.data = const ActivityData(),
  });

  final ActivityStatus status;
  final ActivityData data;

  ActivityState copyWith({ActivityStatus? status, ActivityData? data}) {
    return ActivityState(
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }
}
