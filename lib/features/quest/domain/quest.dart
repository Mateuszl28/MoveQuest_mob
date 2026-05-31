import 'package:flutter/foundation.dart';

/// Rodzaje questów w terenie (stabilne identyfikatory używane do zapisu).
enum QuestKind { parkTreasure, viewpoint, riversideRun }

/// Quest w terenie: rodzaj, nagroda w punktach i stan ukończenia.
@immutable
class Quest {
  const Quest({
    required this.kind,
    required this.reward,
    this.completed = false,
  });

  final QuestKind kind;
  final int reward;
  final bool completed;

  Quest copyWith({bool? completed}) => Quest(
        kind: kind,
        reward: reward,
        completed: completed ?? this.completed,
      );
}
