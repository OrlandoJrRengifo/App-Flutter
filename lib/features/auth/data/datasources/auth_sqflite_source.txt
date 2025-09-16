import 'package:sqflite/sqflite.dart';
import '../../../../core/app_database.dart';
import '../../domain/entities/user.dart';
import 'i_auth_source.dart';

class AuthSqfliteSource implements IAuthenticationSource {
  Future<Database> get _db async => await AppDatabase.instance;

  @override
  Future<User?> getUser(int userId) async {
    final db = await _db;

    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<User?> login(String email, String password) async {
    final db = await AppDatabase.instance;
    final maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<bool> signUp(User user) async {
    final db = await _db;
    try {
      await db.insert('users', user.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> logOut() async => true;
}
