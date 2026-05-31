import 'package:flutter/foundation.dart';

/// Zapisany trening w historii.
@immutable
class WorkoutRecord {
  const WorkoutRecord({
    required this.timestampMs,
    required this.distanceKm,
    required this.durationSeconds,
    required this.points,
  });

  /// Czas zakończenia treningu (epoch, ms).
  final int timestampMs;
  final double distanceKm;
  final int durationSeconds;
  final int points;

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(timestampMs);
  Duration get duration => Duration(seconds: durationSeconds);

  Map<String, dynamic> toJson() => {
        't': timestampMs,
        'd': distanceKm,
        's': durationSeconds,
        'p': points,
      };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => WorkoutRecord(
        timestampMs: (json['t'] as num).toInt(),
        distanceKm: (json['d'] as num).toDouble(),
        durationSeconds: (json['s'] as num).toInt(),
        points: (json['p'] as num).toInt(),
      );
}
