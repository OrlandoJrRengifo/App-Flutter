import '../../domain/repositories/i_user_course_repository.dart';
import '../datasources/i_user_course_source.dart';

class UserCourseRepository implements IUserCourseRepository {
  final IUserCourseSource localDataSource;

  UserCourseRepository(this.localDataSource);

  @override
  Future<void> enrollUser(int userId, int courseId) =>
      localDataSource.enrollUser(userId, courseId);

  @override
  Future<List<int>> getUserCourses(int userId) =>
      localDataSource.getUserCourses(userId);

  @override
  Future<List<int>> getCourseUsers(int courseId) =>
      localDataSource.getCourseUsers(courseId);
}
