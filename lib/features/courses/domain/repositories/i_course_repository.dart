import '../entities/course.dart';

abstract class ICourseRepository {
  Future<Course> create(Course course);
  Future<Course?> getById(String id);
  Future<Course?> getByCode(String code);
  Future<List<Course>> listByTeacher(String teacherId);
  Future<Course> update(Course course);
  Future<void> delete(String id);
  Future<int> countByTeacher(String teacherId);
}
