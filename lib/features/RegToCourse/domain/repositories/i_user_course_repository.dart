abstract class IUserCourseRepository {
  Future<void> enrollUser(int userId, int courseId);
  Future<List<int>> getUserCourses(int userId);
  Future<List<int>> getCourseUsers(int courseId);
}