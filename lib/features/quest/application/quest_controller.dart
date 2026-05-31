import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/locale/locale_controller.dart';
import '../../notifications/notification_service.dart';
import '../domain/quest.dart';

/// Promień (w metrach), w którym można ukończyć quest.
const double kQuestCompletionRadiusMeters = 50;

/// Lista questów wraz ze stanem ukończenia (utrwalanym lokalnie).
final questProvider =
    NotifierProvider<QuestController, List<Quest>>(QuestController.new);

/// Liczba punktów zdobytych za ukończone questy.
final questPointsProvider = Provider<int>((ref) {
  return ref
      .watch(questProvider)
      .where((q) => q.completed)
      .fold(0, (sum, q) => sum + q.reward);
});

/// Liczba ukończonych questów.
final completedQuestCountProvider = Provider<int>(
  (ref) => ref.watch(questProvider).where((q) => q.completed).length,
);

/// Zarządza questami i utrwala ukończone w [SharedPreferences].
class QuestController extends Notifier<List<Quest>> {
  static const _prefsKey = 'completed_quests';

  static const List<Quest> _initial = [
    Quest(kind: QuestKind.parkTreasure, reward: 200),
    Quest(kind: QuestKind.viewpoint, reward: 150),
    Quest(kind: QuestKind.riversideRun, reward: 300),
  ];

  late SharedPreferences _prefs;

  @override
  List<Quest> build() {
    _prefs = ref.read(sharedPreferencesProvider);
    final done = _prefs.getStringList(_prefsKey)?.toSet() ?? <String>{};
    return [
      for (final q in _initial) q.copyWith(completed: done.contains(q.kind.name)),
    ];
  }

  /// Oznacza quest jako ukończony i zapisuje stan.
  Future<void> complete(QuestKind kind) async {
    if (state.any((q) => q.kind == kind && q.completed)) return;
    state = [
      for (final q in state)
        if (q.kind == kind) q.copyWith(completed: true) else q,
    ];
    final done =
        state.where((q) => q.completed).map((q) => q.kind.name).toList();
    await _prefs.setStringList(_prefsKey, done);

    final reward = state.firstWhere((q) => q.kind == kind).reward;
    await ref.read(notificationServiceProvider).showQuestCompleted(reward);
  }
}
