import '../models/course_model.dart';

abstract class ICourseRobleDataSource {
  Future<CourseModel> create(CourseModel course);
  Future<CourseModel?> getById(String id);
  Future<List<CourseModel>> listByTeacher(String teacherId);
  Future<CourseModel> update(CourseModel course);
  Future<int> countByTeacher(String teacherId);
  Future<void> delete(String id);
}
