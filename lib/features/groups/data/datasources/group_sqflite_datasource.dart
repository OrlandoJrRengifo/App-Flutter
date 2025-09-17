import 'package:sqflite/sqflite.dart';
import '../../../../core/app_database.dart';
import 'i_group_datasource.dart';

class GroupSqfliteDataSource implements IGroupDataSource {
  Future<Database> get db async => await AppDatabase.instance;

  @override
  Future<void> createGroup(int categoryId, int identifierNumber, int maxMembers) async {
    final database = await db;
    await database.insert('groups', {
      'category_id': categoryId,
      'identifier_number': identifierNumber,
      'max_members': maxMembers,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<Map<String, dynamic>?> getGroupById(int id) async {
    final database = await db;
    final result =
        await database.query('groups', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  @override
  Future<List<Map<String, dynamic>>> getGroupsByCategory(int categoryId) async {
    final database = await db;
    return await database
        .query('groups', where: 'category_id = ?', whereArgs: [categoryId]);
  }

  @override
  Future<void> updateGroup(int id, int maxMembers) async {
    final database = await db;
    await database.update(
      'groups',
      {'max_members': maxMembers},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteGroup(int id) async {
    final database = await db;
    await database.delete('groups', where: 'id = ?', whereArgs: [id]);
  }
}
