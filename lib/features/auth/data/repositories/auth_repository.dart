import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/i_auth_source.dart';

class AuthRepository implements IAuthRepository {
  final IAuthenticationSource authenticationSource;

  AuthRepository(this.authenticationSource);

  @override
  Future<User?> getUser(String userId) async {
    final model = await authenticationSource.getUser(userId);
    return model;
  }

  @override
  Future<User?> login(String email, String password) async {
    return await authenticationSource.login(email, password);
  }

  @override
  Future<bool> signUp(User user) async => await authenticationSource.signUp(user);

  @override
  Future<bool> logOut() async => await authenticationSource.logOut();

    @override
  Future<bool> forgotPassword(String email) async {
    return await authenticationSource.forgotPassword(email);
  }

  @override
  Future<bool> resetPassword(
      String email, String newPassword, String validationCode) async {
    return await authenticationSource.resetPassword(
        email, newPassword, validationCode);
  }
}
