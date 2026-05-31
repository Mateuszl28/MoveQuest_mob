import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/account_controller.dart';
import '../../points/points_controller.dart';

/// Wpis w rankingu. `isMe` oznacza zalogowanego użytkownika.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.points,
    this.isMe = false,
  });

  /// Dla użytkownika może być `null` (UI pokaże zlokalizowane „Ty").
  final String? name;
  final int points;
  final bool isMe;
}

/// Przykładowi znajomi (do czasu podpięcia prawdziwego backendu).
const List<LeaderboardEntry> _sampleFriends = [
  LeaderboardEntry(name: 'Ola K.', points: 3120),
  LeaderboardEntry(name: 'Marek W.', points: 2870),
  LeaderboardEntry(name: 'Kasia P.', points: 2210),
  LeaderboardEntry(name: 'Tomek L.', points: 1980),
];

/// Ranking łączący znajomych z użytkownikiem; sortowany malejąco po punktach.
///
/// Punkty użytkownika pochodzą z realnego portfela (questy + treningi), więc
/// pozycja zmienia się na żywo wraz z postępami. Struktura pozwala w przyszłości
/// podmienić źródło danych na prawdziwy backend bez zmian w UI.
final leaderboardProvider = Provider<List<LeaderboardEntry>>((ref) {
  final myPoints = ref.watch(totalPointsProvider);
  final myName = ref.watch(profileNameProvider);

  final entries = [
    ..._sampleFriends,
    LeaderboardEntry(name: myName, points: myPoints, isMe: true),
  ]..sort((a, b) => b.points.compareTo(a.points));

  return entries;
});
