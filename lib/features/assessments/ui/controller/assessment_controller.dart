import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/assessment.dart';
import '../../domain/usecases/assessment_usecase.dart';
import '../../../user_groups/ui/controller/user_group_controller.dart';

class AssessmentController extends GetxController {
  final AssessmentUseCase useCase;
  AssessmentController(this.useCase);

  final RxList<Assessment> assessments = <Assessment>[].obs;

  Future<void> createAssessmentsForActivity({
    required String activityId,
    required List<String> groupIds,
    required TimeOfDay? timeWin,
    required String visibility,
  }) async {
    final userGroupController = Get.find<UserGroupController>();

    for (final groupId in groupIds) {
      final users = await userGroupController.getGroupUsers(groupId);

      for (var i = 0; i < users.length; i++) {
        for (var j = 0; j < users.length; j++) {
          if (i == j) continue;
          final assessment = Assessment(
            activityId: activityId,
            rater: users[i],
            toRate: users[j],
            timeWin: timeWin,
            visibility: visibility,
          );
          await useCase.createAssessment(assessment);
        }
      }
    }
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
          String activityId, String rater) =>
      useCase.getAssessmentsByActivityAndRater(activityId, rater);

  Future<List<Assessment>> getAssessmentsByActivityAndToRate(
          String activityId, String toRate) =>
      useCase.getAssessmentsByActivityAndToRate(activityId, toRate);

  Future<Map<String, double>> getAverageRatings(
      String activityId, String rater) async {
    final list = await getAssessmentsByActivityAndRater(activityId, rater);

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

    double general = (avgPunctuality + avgContributions + avgCommitment + avgAttitude) / 4;

    return {
      "punctuality": avgPunctuality,
      "contributions": avgContributions,
      "commitment": avgCommitment,
      "attitude": avgAttitude,
      "general": general,
    };
  }
}
