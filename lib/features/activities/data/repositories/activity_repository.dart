import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activity_repository.dart';
import '../datasources/i_activity_source.dart';

class ActivityRepository implements IActivityRepository {
  final IActivityDataSource dataSource;

  ActivityRepository(this.dataSource);

  @override
  Future<Activity?> createActivity(String categoryId, String name) {
    return dataSource.createActivity(categoryId, name);
  }

  @override
  Future<List<Activity>> getActivitiesByCategory(String categoryId) {
    return dataSource.getActivitiesByCategory(categoryId);
  }

  @override
  Future<bool> activateActivity(String activityId) {
    return dataSource.activateActivity(activityId);
  }

  @override
  Future<bool> updateActivityName(String activityId, String newName) {
    return dataSource.updateActivityName(activityId, newName);
  }

  @override
  Future<bool> deleteActivity(String activityId) {
    return dataSource.deleteActivity(activityId);
  }
}
