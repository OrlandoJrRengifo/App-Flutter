import '../models/course_model.dart';

abstract class ICourseLocalDataSource {
  Future<CourseModel> create(CourseModel course);
  Future<CourseModel?> getById(int id);
  Future<List<CourseModel>> listByTeacher(String teacherId);
  Future<CourseModel> update(CourseModel course);
  Future<void> delete(int id);
  Future<int> countByTeacher(String teacherId);
}