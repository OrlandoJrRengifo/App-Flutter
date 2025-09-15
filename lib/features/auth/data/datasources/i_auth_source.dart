import '../../domain/entities/user.dart';

abstract class IAuthenticationSource {
  Future<User?> getUser(int userId);
  Future<User?> login(String email, String password);
  Future<bool> signUp(User user);
  Future<bool> logOut();
}
