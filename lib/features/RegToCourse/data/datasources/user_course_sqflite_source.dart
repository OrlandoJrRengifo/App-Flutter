import 'package:sqflite/sqflite.dart';
import '../../../../core/app_database.dart';
import 'i_user_course_source.dart';

class UserCourseSqfliteSource implements IUserCourseSource {
  Future<Database> get db async => await AppDatabase.instance;

  @override
  Future<void> enrollUser(int userId, int courseId) async {
    final database = await db;
    await database.insert(
      'user_courses',
      {'user_id': userId, 'course_id': courseId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  Future<List<int>> getUserCourses(int userId) async {
    final database = await db;
    final result = await database.query(
      'user_courses',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.map((e) => e['course_id'] as int).toList();
  }

  @override
  Future<List<int>> getCourseUsers(int courseId) async {
    final database = await db;
    final result = await database.query(
      'user_courses',
      where: 'course_id = ?',
      whereArgs: [courseId],
    );
    return result.map((e) => e['user_id'] as int).toList();
  }
}
