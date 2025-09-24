import '../entities/course.dart';
import '../repositories/i_course_repository.dart';

class CourseUseCases {
  final ICourseRepository repository;
  
  CourseUseCases(this.repository);

  Future<Course> createCourse({
    required String name,
    required String code,
    required String teacherId,
    required int maxStudents,
    DateTime? createdAt,
  }) async {
    // Limite de 3 cursos por usuario
    final currentCount = await repository.countByTeacher(teacherId);
    if (currentCount >= 3) {
      throw Exception('No es posible crear más de 3 cursos');
    }

    return repository.create(
      Course(
        name: name,
        code: code,
        teacherId: teacherId,
        maxStudents: maxStudents,
        createdAt: createdAt,
      ),
    );
  }

  Future<void> deleteCourse(String id) => repository.delete(id);
  
  Future<Course?> getCourse(String id) => repository.getById(id);

  Future<Course?> getCourseByCode(String code) => repository.getByCode(code);
  
  Future<List<Course>> listCoursesByTeacher(String teacherId) => 
      repository.listByTeacher(teacherId);
  
  Future<Course> updateCourse(Course course) => repository.update(course);

  Future<bool> canCreateMore(String teacherId) async {
    final count = await repository.countByTeacher(teacherId);
    return count < 3;
  }
}
