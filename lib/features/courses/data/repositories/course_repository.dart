import '../../domain/entities/course.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../datasources/i_course_local_datasource.dart';
import '../models/course_model.dart';

class CourseRepository implements ICourseRepository {
  final ICourseLocalDataSource localDataSource;
  
  CourseRepository(this.localDataSource);

  @override
  Future<Course> create(Course course) async {
    final model = CourseModel(
      id: course.id,
      name: course.name,
      code: course.code,
      teacherId: course.teacherId,
      maxStudents: course.maxStudents,
      createdAt: course.createdAt,
    );
    
    final savedModel = await localDataSource.create(model);
    return savedModel;
  }

  @override
  Future<void> delete(int id) => localDataSource.delete(id);

  @override
  Future<Course?> getById(int id) async {
    final model = await localDataSource.getById(id);
    return model;
  }

  @override
  Future<List<Course>> listByTeacher(int teacherId) async {
    final models = await localDataSource.listByTeacher(teacherId);
    return models;
  }

  @override
  Future<Course> update(Course course) async {
    final model = CourseModel(
      id: course.id,
      name: course.name,
      code: course.code,
      teacherId: course.teacherId,
      maxStudents: course.maxStudents,
      createdAt: course.createdAt,
    );
    
    final updatedModel = await localDataSource.update(model);
    return updatedModel;
  }

  @override
  Future<int> countByTeacher(int teacherId) async {
    return localDataSource.countByTeacher(teacherId);
  }
}