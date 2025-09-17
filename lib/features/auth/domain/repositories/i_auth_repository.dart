import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User?> getUser(String userId);
  Future<User?> login(String email, String password);
  Future<bool> signUp(User user);
  Future<bool> logOut();
  Future<bool> forgotPassword(String email);
  Future<bool> resetPassword(String email, String newPassword, String validationCode);
}