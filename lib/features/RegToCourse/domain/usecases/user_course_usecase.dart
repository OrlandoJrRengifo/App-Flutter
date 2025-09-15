import '../repositories/i_user_course_repository.dart';

class UserCourseUseCase {
  final IUserCourseRepository repository;

  UserCourseUseCase(this.repository);

  Future<void> enrollUser(int userId, int courseId) =>
      repository.enrollUser(userId, courseId);

  Future<List<int>> getUserCourses(int userId) =>
      repository.getUserCourses(userId);

  Future<List<int>> getCourseUsers(int courseId) =>
      repository.getCourseUsers(courseId);
}
