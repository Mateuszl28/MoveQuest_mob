import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/locale/locale_controller.dart';
import '../quest/application/quest_controller.dart';

/// Punkty bonusowe zdobyte poza questami (np. za treningi GPS).
final bonusPointsProvider =
    NotifierProvider<BonusPointsController, int>(BonusPointsController.new);

/// Łączna liczba punktów użytkownika: questy + bonusy.
final totalPointsProvider = Provider<int>((ref) {
  return ref.watch(questPointsProvider) + ref.watch(bonusPointsProvider);
});

/// Przechowuje i utrwala punkty bonusowe (z treningów itp.).
class BonusPointsController extends Notifier<int> {
  static const _prefsKey = 'bonus_points';

  late SharedPreferences _prefs;

  @override
  int build() {
    _prefs = ref.read(sharedPreferencesProvider);
    return _prefs.getInt(_prefsKey) ?? 0;
  }

  /// Dodaje punkty i zapisuje nowy stan.
  Future<void> add(int points) async {
    if (points <= 0) return;
    state = state + points;
    await _prefs.setInt(_prefsKey, state);
  }
}
