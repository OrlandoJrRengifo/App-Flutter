import '../../domain/entities/assessment.dart';

abstract class IAssessmentDataSource {
  Future<List<Assessment>> getAssessmentsByActivity(String activityId);
  Future<List<Assessment>> getAssessmentsByActivityAndRater(String activityId, String rater);
  Future<List<Assessment>> getAssessmentsByActivityAndToRate(String activityId, String toRate);
  Future<bool> createAssessment(Assessment assessment);
  Future<bool> gradeAssessment(String assessmentId, int punctuality, int contributions, int commitment, int attitude);
  Future<List<Assessment>> getAssessmentsByToRate(String toRate);

}
