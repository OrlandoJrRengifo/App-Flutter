import '../repositories/i_user_course_repository.dart';

class UserCourseUseCase {
  final IUserCourseRepository repository;

  UserCourseUseCase(this.repository);

  Future<bool> enrollUser(String userId, String courseId) =>
      repository.enrollUser(userId, courseId);

  Future<List<String>> getUserCourses(String userId) =>
      repository.getUserCourses(userId);

  Future<List<String>> getCourseUsers(String courseId) =>
      repository.getCourseUsers(courseId);
}
