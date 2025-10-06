import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/usecases/assessment_usecase.dart';
import '../../../user_groups/ui/controller/user_group_controller.dart';

class AssessmentController extends GetxController {
  final AssessmentUseCase useCase;
  AssessmentController(this.useCase);

  final RxList<Assessment> assessments = <Assessment>[].obs;

  /// Crea assessments para una actividad (múltiples)
  Future<void> createAssessmentsForActivity({
    required String activityId,
    required List<String> groupIds,
    required TimeOfDay? timeWin,
    required String visibility,
  }) async {
    final userGroupController = Get.find<UserGroupController>();
    final List<Assessment> toCreate = [];

    for (final groupId in groupIds) {
      final users = await userGroupController.getGroupUsers(groupId);

      // Generar todas las combinaciones de rater y toRate
      for (var i = 0; i < users.length; i++) {
        for (var j = 0; j < users.length; j++) {
          if (i == j) continue;
          toCreate.add(
            Assessment(
              activityId: activityId,
              rater: users[i],
              toRate: users[j],
              timeWin: timeWin, // ✅ se pasa tal cual
              visibility: visibility,
            ),
          );
        }
      }
    }

    for (final assessment in toCreate) {
      final ok = await useCase.createAssessment(assessment);
      if (!ok) {
        print(
          "Warning: createAssessment returned false for ${assessment.toMap()}",
        );
      }
    }
  }

  /// Crea solo 1 assessment
  Future<bool> createAssessment({
    required String activityId,
    required String rater,
    required String toRate,
    required TimeOfDay? timeWin,
    required String visibility,
  }) async {
    final a = Assessment(
      activityId: activityId,
      rater: rater,
      toRate: toRate,
      timeWin: timeWin, // ✅ se pasa tal cual
      visibility: visibility,
    );

    print("AssessmentController.createAssessment -> ${a.toMap()}");
    final res = await useCase.createAssessment(a);
    print("AssessmentController.createAssessment result -> $res");
    return res;
  }

  Future<bool> gradeAssessment(
    String assessmentId,
    int punctuality,
    int contributions,
    int commitment,
    int attitude,
  ) async {
    if (![2, 3, 4, 5].contains(punctuality) ||
        ![2, 3, 4, 5].contains(contributions) ||
        ![2, 3, 4, 5].contains(commitment) ||
        ![2, 3, 4, 5].contains(attitude)) {
      return false;
    }
    return useCase.gradeAssessment(
      assessmentId,
      punctuality,
      contributions,
      commitment,
      attitude,
    );
  }

  Future<List<Assessment>> getAssessmentsByActivity(String activityId) =>
      useCase.getAssessmentsByActivity(activityId);

  Future<List<Assessment>> getAssessmentsByActivityAndRater(
    String activityId,
    String rater,
  ) => useCase.getAssessmentsByActivityAndRater(activityId, rater);

  Future<List<Assessment>> getAssessmentsByActivityAndToRate(
    String activityId,
    String toRate,
  ) => useCase.getAssessmentsByActivityAndToRate(activityId, toRate);

  Future<Map<String, double>> getAverageRatings(
    String activityId,
    String userId,
  ) async {
    final list = await getAssessmentsByActivityAndToRate(activityId, userId);

    if (list.isEmpty) {
      return {
        "punctuality": 0,
        "contributions": 0,
        "commitment": 0,
        "attitude": 0,
        "general": 0,
      };
    }

    final rated = list.where((a) => a.punctuality != null).toList();

    if (rated.isEmpty) {
      return {
        "punctuality": 0,
        "contributions": 0,
        "commitment": 0,
        "attitude": 0,
        "general": 0,
      };
    }

    double avgPunctuality =
        rated.map((a) => a.punctuality!).reduce((a, b) => a + b) / rated.length;
    double avgContributions =
        rated.map((a) => a.contributions!).reduce((a, b) => a + b) /
        rated.length;
    double avgCommitment =
        rated.map((a) => a.commitment!).reduce((a, b) => a + b) / rated.length;
    double avgAttitude =
        rated.map((a) => a.attitude!).reduce((a, b) => a + b) / rated.length;

    double general =
        (avgPunctuality + avgContributions + avgCommitment + avgAttitude) / 4;

    return {
      "punctuality": avgPunctuality,
      "contributions": avgContributions,
      "commitment": avgCommitment,
      "attitude": avgAttitude,
      "general": general,
    };
  }
Future<Map<String, double>> getAverageRatingsAcrossAllActivities(String userId) async {
    final list = await useCase.getAssessmentsByToRate(userId);

    if (list.isEmpty) {
      return {
        "punctuality": 0,
        "contributions": 0,
        "commitment": 0,
        "attitude": 0,
        "general": 0,
      };
    }

    final rated = list.where((a) => a.punctuality != null).toList();
    if (rated.isEmpty) {
      return {
        "punctuality": 0,
        "contributions": 0,
        "commitment": 0,
        "attitude": 0,
        "general": 0,
      };
    }

    double avgPunctuality =
        rated.map((a) => a.punctuality!).reduce((a, b) => a + b) / rated.length;
    double avgContributions =
        rated.map((a) => a.contributions!).reduce((a, b) => a + b) / rated.length;
    double avgCommitment =
        rated.map((a) => a.commitment!).reduce((a, b) => a + b) / rated.length;
    double avgAttitude =
        rated.map((a) => a.attitude!).reduce((a, b) => a + b) / rated.length;

    double general =
        (avgPunctuality + avgContributions + avgCommitment + avgAttitude) / 4;

    return {
      "punctuality": avgPunctuality,
      "contributions": avgContributions,
      "commitment": avgCommitment,
      "attitude": avgAttitude,
      "general": general,
    };
  }
}
