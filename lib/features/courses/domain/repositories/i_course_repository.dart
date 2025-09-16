import '../entities/course.dart';

abstract class ICourseRepository {
  Future<Course> create(Course course);
  Future<Course?> getById(int id);
  Future<Course?> getByCode(String code);
  Future<List<Course>> listByTeacher(int teacherId);
  Future<Course> update(Course course);
  Future<void> delete(int id);
  Future<int> countByTeacher(int teacherId);
}
