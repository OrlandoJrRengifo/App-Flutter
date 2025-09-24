import '../entities/assessment.dart';
import '../repositories/i_assessment_repository.dart';

class AssessmentUseCase {
  final IAssessmentRepository repository;
  AssessmentUseCase(this.repository);

  Future<List<Assessment>> getAssessmentsByActivity(String activityId) => repository.getAssessmentsByActivity(activityId);

  Future<List<Assessment>> getAssessmentsByActivityAndRater(String activityId, String rater) =>
      repository.getAssessmentsByActivityAndRater(activityId, rater);

  Future<List<Assessment>> getAssessmentsByActivityAndToRate(String activityId, String toRate) =>
      repository.getAssessmentsByActivityAndToRate(activityId, toRate);

  Future<bool> createAssessment(Assessment assessment) => repository.createAssessment(assessment);

  Future<bool> gradeAssessment(String assessmentId, int punctuality, int contributions, int commitment, int attitude) =>
      repository.gradeAssessment(assessmentId, punctuality, contributions, commitment, attitude);
}
