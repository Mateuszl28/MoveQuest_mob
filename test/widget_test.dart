// Podstawowy smoke test aplikacji MoveQuest.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movequest_mob/app.dart';
import 'package:movequest_mob/core/locale/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Aplikacja startuje po angielsku na ekranie „Today"',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
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
