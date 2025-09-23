import '../../domain/entities/activity.dart';

abstract class IActivityDataSource {
  Future<Activity?> createActivity(String categoryId, String name);
  Future<List<Activity>> getActivitiesByCategory(String categoryId);
  Future<bool> activateActivity(String activityId);
  Future<bool> updateActivityName(String activityId, String newName);
  Future<bool> deleteActivity(String activityId);
}
