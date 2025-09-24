import '../../domain/entities/assessment.dart';
import '../../domain/repositories/i_assessment_repository.dart';
import '../datasources/i_assessment_source.dart';

class AssessmentRepository implements IAssessmentRepository {
  final IAssessmentDataSource dataSource;
  AssessmentRepository(this.dataSource);

  @override
  Future<List<Assessment>> getAssessmentsByActivity(String activityId) => dataSource.getAssessmentsByActivity(activityId);

  @override
  Future<List<Assessment>> getAssessmentsByActivityAndRater(String activityId, String rater) =>
      dataSource.getAssessmentsByActivityAndRater(activityId, rater);

  @override
  Future<List<Assessment>> getAssessmentsByActivityAndToRate(String activityId, String toRate) =>
      dataSource.getAssessmentsByActivityAndToRate(activityId, toRate);

  @override
  Future<bool> createAssessment(Assessment assessment) => dataSource.createAssessment(assessment);

  @override
  Future<bool> gradeAssessment(String assessmentId, int punctuality, int contributions, int commitment, int attitude) =>
      dataSource.gradeAssessment(assessmentId, punctuality, contributions, commitment, attitude);
}
