import 'package:flutter/material.dart';

class Assessment {
  final String? id; // corresponde a _id
  final String activityId;
  final String rater; // uuid
  final String toRate; // uuid
  final TimeOfDay? timeWin; // se maneja como TimeOfDay en Flutter
  final String visibility;
  int? punctuality;
  int? contributions;
  int? commitment;
  int? attitude;

  Assessment({
    this.id,
    required this.activityId,
    required this.rater,
    required this.toRate,
    this.timeWin,
    required this.visibility,
    this.punctuality,
    this.contributions,
    this.commitment,
    this.attitude,
  });

  /// Convierte TimeOfDay -> String "HH:mm:ss" (24h)
  static String? formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final hour = time.hour.toString().padLeft(2, '0');   // 0-23
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute:00"; // Roble usa TIME
  }

  /// Convierte String "HH:mm[:ss]" -> TimeOfDay
  static TimeOfDay? parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final parts = value.split(":");
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  /// Para enviar a Roble (columnas válidas exactas)
  Map<String, dynamic> toMap() {
    return {
      "_id": id,
      "activity_id": activityId,
      "rater": rater,
      "to_rate": toRate,
      "time_win": formatTime(timeWin), // <-- TIME (24h)
      "visibility": visibility,
      "punctuality": punctuality,
      "contributions": contributions,
      "commitment": commitment,
      "attitude": attitude,
    };
  }

  /// Para reconstruir desde Roble
  factory Assessment.fromMap(Map<String, dynamic> map) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return Assessment(
      id: map["_id"]?.toString(),
      activityId: map["activity_id"] ?? "",
      rater: map["rater"] ?? "",
      toRate: map["to_rate"] ?? "",
      timeWin: parseTime(map["time_win"]?.toString()),
      visibility: map["visibility"] ?? "",
      punctuality: parseInt(map["punctuality"]),
      contributions: parseInt(map["contributions"]),
      commitment: parseInt(map["commitment"]),
      attitude: parseInt(map["attitude"]),
    );
  }
}
