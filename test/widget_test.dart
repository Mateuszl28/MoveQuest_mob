// Podstawowy smoke test aplikacji MoveQuest.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movequest_mob/app.dart';
import 'package:movequest_mob/core/locale/locale_controller.dart';
import 'package:movequest_mob/features/activity/application/activity_controller.dart';
import 'package:movequest_mob/features/activity/domain/activity_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Atrapa kontrolera aktywności – pomija wywołania czujnika/uprawnień,
/// które nie są dostępne w środowisku testowym.
class _FakeActivityController extends ActivityController {
  @override
  ActivityState build() => const ActivityState(
        status: ActivityStatus.tracking,
        data: ActivityData(
          steps: 5000,
          distanceKm: 3.8,
          calories: 200,
          activeMinutes: 40,
        ),
      );
}

void main() {
  testWidgets('Aplikacja startuje po angielsku z danymi na żywo',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          activityProvider.overrideWith(_FakeActivityController.new),
        ],
        child: const MoveQuestApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Domyślny język to angielski – powitanie na pulpicie.
    expect(find.text('Hi, Traveler!'), findsOneWidget);

    // Dolna nawigacja z czterema zakładkami (po angielsku).
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Challenges'), findsWidgets);
    expect(find.text('Profile'), findsOneWidget);
  });
}
