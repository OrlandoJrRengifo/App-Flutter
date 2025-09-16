import 'package:sqflite/sqflite.dart';
import '../../../../core/app_database.dart';
import '../models/course_model.dart';
import 'i_course_local_datasource.dart';

class CourseLocalDataSourceSqflite implements ICourseLocalDataSource {
  Future<Database> get _db async => await AppDatabase.instance;

  @override
  Future<CourseModel> create(CourseModel course) async {
    final db = await _db;

    print("📌 Insertando curso: ${course.toMap()}");

    final newId = await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final inserted = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [newId],
      limit: 1,
    );

    print("✅ Curso insertado: $inserted");
    return CourseModel.fromMap(inserted.first);
  }

  @override
  Future<void> delete(int id) async {
    final db = await _db;
    final count = await db.delete('courses', where: 'id = ?', whereArgs: [id]);
    print("🗑️ Cursos eliminados: $count (id=$id)");
  }

  @override
  Future<CourseModel?> getById(int id) async {
    final db = await _db;
    final maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      print("⚠️ No se encontró curso con id=$id");
      return null;
    }

    print("📌 Curso encontrado: ${maps.first}");
    return CourseModel.fromMap(maps.first);
  }

  @override
  Future<List<CourseModel>> listByTeacher(String teacherId) async {
    final db = await _db;
    final maps = await db.query(
      'courses',
      where: 'teacherId = ?',
      whereArgs: [teacherId],
      orderBy: 'createdAt DESC',
    );

    print("📌 Cursos del teacherId=$teacherId → ${maps.length} encontrados");
    return maps.map((m) => CourseModel.fromMap(m)).toList();
  }

  @override
  Future<CourseModel> update(CourseModel course) async {
    final db = await _db;

    if (course.id == null) {
      throw Exception('❌ Se requiere el id del curso para actualizar');
    }

    final count = await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );

    print("♻️ Cursos actualizados: $count (id=${course.id})");

    final maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [course.id],
      limit: 1,
    );

    return CourseModel.fromMap(maps.first);
  }

  @override
  Future<int> countByTeacher(String teacherId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM courses WHERE teacherId = ?',
      [teacherId],
    );

    final count = result.first['count'] as int;
    print("📊 Total cursos del teacherId=$teacherId → $count");
    return count;
  }
}
