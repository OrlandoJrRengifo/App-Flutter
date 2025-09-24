import 'package:flutter/material.dart';

class Assessment {
  final String? id;
  final String activityId;
  final String rater;
  final String toRate;
  final TimeOfDay? timeWin;
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

  Map<String, dynamic> toMap() {
    return {
      "activity_id": activityId,
      "rater": rater,
      "to_rate": toRate,
      "time_win": timeWin != null ? "${timeWin!.hour.toString().padLeft(2,'0')}:${timeWin!.minute.toString().padLeft(2,'0')}" : null,
      "visibility": visibility,
      "punctuality": punctuality,
      "contributions": contributions,
      "commitment": commitment,
      "attitude": attitude,
    };
  }

  factory Assessment.fromMap(Map<String, dynamic> map) {
    TimeOfDay? parsedTime;
    if (map["time_win"] != null) {
      final parts = (map["time_win"] as String).split(":");
      parsedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return Assessment(
      id: map["_id"]?.toString(),
      activityId: map["activity_id"],
      rater: map["rater"],
      toRate: map["to_rate"],
      timeWin: parsedTime,
      visibility: map["visibility"],
      punctuality: map["punctuality"],
      contributions: map["contributions"],
      commitment: map["commitment"],
      attitude: map["attitude"],
    );
  }
}
