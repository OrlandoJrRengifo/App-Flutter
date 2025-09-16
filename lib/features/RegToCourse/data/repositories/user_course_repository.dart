import '../../domain/repositories/i_user_course_repository.dart';
import '../datasources/i_user_course_source.dart';

class UserCourseRepository implements IUserCourseRepository {
  final IUserCourseSource localDataSource;

  UserCourseRepository(this.localDataSource);

  @override
  Future<void> enrollUser(String userId, String courseId) =>
      localDataSource.enrollUser(userId, courseId);

  @override
  Future<List<String>> getUserCourses(String userId) =>
      localDataSource.getUserCourses(userId);

  @override
  Future<List<String>> getCourseUsers(String courseId) =>
      localDataSource.getCourseUsers(courseId);
}
