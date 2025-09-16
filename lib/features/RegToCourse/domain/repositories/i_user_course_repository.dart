abstract class IUserCourseRepository {
  Future<void> enrollUser(String userId, String courseId);
  Future<List<String>> getUserCourses(String userId);
  Future<List<String>> getCourseUsers(String courseId);
}