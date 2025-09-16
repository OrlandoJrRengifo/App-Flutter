import '../../domain/entities/course.dart';
import '../../domain/repositories/i_course_repository.dart';
//import '../datasources/i_course_local_datasource.dart';
import '../datasources/i_course_roble_datasource.dart';
import '../models/course_model.dart';

class CourseRepository implements ICourseRepository {
  //final ICourseLocalDataSource localDataSource;
  final ICourseRobleDataSource robleDataSource;
  
  CourseRepository(this.robleDataSource);

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
    
    final savedModel = await robleDataSource.create(model);
    return savedModel;
  }

  @override
  Future<void> delete(String id) => robleDataSource.delete(id);

  @override
  Future<Course?> getById(String id) async {
    final model = await robleDataSource.getById(id);
    return model;
  }

  @override
  Future<List<Course>> listByTeacher(String teacherId) async {
    final models = await robleDataSource.listByTeacher(teacherId);
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
    
    final updatedModel = await robleDataSource.update(model);
    return updatedModel;
  }

  @override
  Future<int> countByTeacher(String teacherId) async {
    return robleDataSource.countByTeacher(teacherId);
  }
}