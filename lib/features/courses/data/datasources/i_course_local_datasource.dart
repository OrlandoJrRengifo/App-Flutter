import '../models/course_model.dart';

abstract class ICourseLocalDataSource {
  Future<CourseModel> create(CourseModel course);
  Future<CourseModel?> getById(int id);
  Future<CourseModel?> getByCode(String code);
  Future<List<CourseModel>> listByTeacher(int teacherId);
  Future<CourseModel> update(CourseModel course);
  Future<void> delete(int id);
  Future<int> countByTeacher(int teacherId);
}