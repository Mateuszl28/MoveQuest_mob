// Podstawowy smoke test aplikacji MoveQuest.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movequest_mob/app.dart';

void main() {
  testWidgets('Aplikacja startuje na ekranie „Dziś"', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MoveQuestApp()),
    );
    await tester.pumpAndSettle();

    // Powitanie na pulpicie dziennym.
    expect(find.text('Cześć, Podróżniku!'), findsOneWidget);

    // Dolna nawigacja z czterema zakładkami.
    expect(find.text('Dziś'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Wyzwania'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
