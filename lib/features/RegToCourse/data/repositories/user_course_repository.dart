import '../../domain/repositories/i_user_course_repository.dart';
import '../datasources/i_user_course_roble_datasource.dart';

class UserCourseRepository implements IUserCourseRepository {
  final IUserCourseRobleDataSource robleDataSource;

  UserCourseRepository(this.robleDataSource);

  @override
  Future<bool> enrollUser(String userId, String courseId) =>
      robleDataSource.enrollUser(userId, courseId);

  @override
  Future<List<String>> getUserCourses(String userId) =>
      robleDataSource.getUserCourses(userId);

  @override
  Future<List<String>> getCourseUsers(String courseId) =>
      robleDataSource.getCourseUsers(courseId);
}
