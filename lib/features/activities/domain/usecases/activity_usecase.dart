import '../entities/activity.dart';
import '../repositories/i_activity_repository.dart';

class ActivityUseCase {
  final IActivityRepository repository;

  ActivityUseCase(this.repository);

  Future<Activity?> createActivity(String categoryId, String name) =>
      repository.createActivity(categoryId, name);

  Future<List<Activity>> getActivitiesByCategory(String categoryId) =>
      repository.getActivitiesByCategory(categoryId);

  Future<bool> activateActivity(String activityId) =>
      repository.activateActivity(activityId);

  Future<bool> updateActivityName(String activityId, String newName) =>
      repository.updateActivityName(activityId, newName);
  
  Future<bool> deleteActivity(String activityId) =>
      repository.deleteActivity(activityId);
}
