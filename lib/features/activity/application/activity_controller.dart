import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../notifications/notification_service.dart';
import '../domain/activity_data.dart';

/// Dzienny cel kroków używany na pulpicie.
const int kDailyStepGoal = 8000;

// Współczynniki szacunkowe (czujnik daje tylko kroki).
const double _strideMeters = 0.762; // średnia długość kroku
const double _kcalPerStep = 0.04; // ~40 kcal / 1000 kroków

/// Provider z danymi aktywności zbieranymi na żywo z czujnika kroków.
final activityProvider =
    NotifierProvider<ActivityController, ActivityState>(ActivityController.new);

/// Zbiera kroki i status chodzenia z czujnika, wylicza dystans, kalorie
/// i aktywne minuty oraz utrwala dzienny punkt odniesienia (baseline),
/// aby pokazywać kroki „od początku dnia".
class ActivityController extends Notifier<ActivityState> {
  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  late SharedPreferences _prefs;

  int _todaySteps = 0;
  int _activeSeconds = 0;
  DateTime? _walkingSince;

  static const _kBaselineValue = 'steps_baseline_value';
  static const _kBaselineDate = 'steps_baseline_date';
  static const _kActiveSeconds = 'active_seconds';
  static const _kActiveDate = 'active_date';

  @override
  ActivityState build() {
    _prefs = ref.read(sharedPreferencesProvider);
    ref.onDispose(() {
      _stepSub?.cancel();
      _statusSub?.cancel();
    });
    _init();
    return const ActivityState(status: ActivityStatus.loading);
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<void> _init() async {
    final status = await Permission.activityRecognition.status;
    if (status.isGranted) {
      _startTracking();
    } else {
      state = state.copyWith(status: ActivityStatus.permissionRequired);
    }
  }

  /// Prosi o uprawnienie do aktywności fizycznej (wywoływane z UI).
  Future<void> requestPermission() async {
    final result = await Permission.activityRecognition.request();
    if (result.isGranted) {
      _startTracking();
    } else if (result.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      state = state.copyWith(status: ActivityStatus.permissionRequired);
    }
  }

  void _startTracking() {
    // Wczytaj zapisany dzienny czas aktywności (jeśli z dzisiaj).
    final today = _dayKey(DateTime.now());
    if (_prefs.getString(_kActiveDate) == today) {
      _activeSeconds = _prefs.getInt(_kActiveSeconds) ?? 0;
    }

    state = state.copyWith(status: ActivityStatus.tracking);

    _stepSub = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (_) =>
          state = state.copyWith(status: ActivityStatus.unavailable),
      cancelOnError: false,
    );
    _statusSub = Pedometer.pedestrianStatusStream.listen(
      _onPedestrianStatus,
      onError: (_) {},
      cancelOnError: false,
    );
  }

  void _onStepCount(StepCount event) {
    final total = event.steps; // skumulowane od restartu urządzenia
    final today = _dayKey(DateTime.now());
    final baselineDate = _prefs.getString(_kBaselineDate);
    var baseline = _prefs.getInt(_kBaselineValue);

    // Nowy dzień, brak baseline albo restart urządzenia (licznik spadł).
    if (baselineDate != today || baseline == null || total < baseline) {
      baseline = total;
      _prefs.setInt(_kBaselineValue, baseline);
      _prefs.setString(_kBaselineDate, today);
      // Zresetuj dzienny czas aktywności wraz z nowym dniem.
      if (baselineDate != today) {
        _activeSeconds = 0;
        _prefs.setInt(_kActiveSeconds, 0);
        _prefs.setString(_kActiveDate, today);
      }
    }

    _todaySteps = (total - baseline).clamp(0, total);
    _maybeCelebrateGoal();
    _emit();
  }

  /// Wyświetla gratulacje raz dziennie po osiągnięciu celu kroków.
  void _maybeCelebrateGoal() {
    if (_todaySteps < kDailyStepGoal) return;
    final today = _dayKey(DateTime.now());
    if (_prefs.getString('goal_notified_date') == today) return;
    _prefs.setString('goal_notified_date', today);
    ref.read(notificationServiceProvider).showGoalReached();
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    final now = DateTime.now();
    final walking = event.status == 'walking';
    if (walking) {
      _walkingSince ??= now;
    } else if (_walkingSince != null) {
      _activeSeconds += now.difference(_walkingSince!).inSeconds;
      _walkingSince = null;
      _persistActiveSeconds();
    }
    _emit();
  }

  void _persistActiveSeconds() {
    _prefs.setInt(_kActiveSeconds, _activeSeconds);
    _prefs.setString(_kActiveDate, _dayKey(DateTime.now()));
  }

  void _emit() {
    final ongoing = _walkingSince == null
        ? 0
        : DateTime.now().difference(_walkingSince!).inSeconds;
    final activeMinutes = (_activeSeconds + ongoing) ~/ 60;
    final distanceKm = _todaySteps * _strideMeters / 1000;

    state = ActivityState(
      status: ActivityStatus.tracking,
      data: ActivityData(
        steps: _todaySteps,
        distanceKm: distanceKm,
        calories: (_todaySteps * _kcalPerStep).round(),
        activeMinutes: activeMinutes,
        isWalking: _walkingSince != null,
      ),
    );
  }
}
