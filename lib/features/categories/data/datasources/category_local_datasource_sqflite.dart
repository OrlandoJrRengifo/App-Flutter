import 'package:sqflite/sqflite.dart';
import '../../../../../core/app_database.dart';
import '../models/category_model.dart';
import 'i_category_local_datasource.dart';

class CategoryLocalDataSourceSqflite implements ICategoryLocalDataSource {
  Future<Database> get _db async => await AppDatabase.instance;

  @override
  Future<CategoryModel> create(CategoryModel category) async {
    final db = await _db;
    final newId = await db.insert('categories', category.toMap());
    final inserted = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [newId],
    );
    return CategoryModel.fromMap(inserted.first);
  }

  @override
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<CategoryModel?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }

  @override
  Future<List<CategoryModel>> listByCourse(String courseId) async {
    final db = await _db;
    final maps = await db.query(
      'categories',
      where: 'courseId = ?',
      whereArgs: [courseId],
    );

    return maps.map((m) => CategoryModel.fromMap(m)).toList();
  }

  @override
  Future<CategoryModel> update(CategoryModel category) async {
    final db = await _db;
    final map = category.toMap();
    final id = category.id;

    if (id == null) {
      throw Exception('Se requiere el id de la categoría para actualizar');
    }

    await db.update('categories', map, where: 'id = ?', whereArgs: [id]);

    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return CategoryModel.fromMap(maps.first);
  }
}
