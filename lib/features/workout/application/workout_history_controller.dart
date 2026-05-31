import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../domain/workout_record.dart';

/// Historia treningów (najnowsze na górze), utrwalana w [SharedPreferences].
final workoutHistoryProvider =
    NotifierProvider<WorkoutHistoryController, List<WorkoutRecord>>(
  WorkoutHistoryController.new,
);

class WorkoutHistoryController extends Notifier<List<WorkoutRecord>> {
  static const _prefsKey = 'workout_history';

  late SharedPreferences _prefs;

  @override
  List<WorkoutRecord> build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final raw = _prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => WorkoutRecord.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.timestampMs.compareTo(a.timestampMs));
      return list;
    } catch (_) {
      return const [];
    }
  }

  /// Dodaje trening do historii i zapisuje.
  Future<void> add(WorkoutRecord record) async {
    state = [record, ...state];
    await _prefs.setString(
      _prefsKey,
      jsonEncode(state.map((r) => r.toJson()).toList()),
    );
  }
}
