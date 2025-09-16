import 'package:get/get.dart';
import 'package:loggy/loggy.dart';
import '../../domain/usecases/auth_usecase.dart';
import '../../domain/entities/user.dart';

class AuthenticationController extends GetxController {
  final AuthenticationUseCase _authUseCase;

  AuthenticationController(this._authUseCase);

  final Rxn<User> currentUser = Rxn<User>();
  bool get isLoggedIn => currentUser.value != null;

  @override
  Future<void> onInit() async {
    super.onInit();
    logInfo('AuthenticationController initialized');
  }

  Future<List<Map<String, dynamic>>> getUsers(List<String> userIds) async {
    final List<Map<String, dynamic>> result = [];

    for (final id in userIds) {
      final user = await _authUseCase.getUser(id);
      if (user != null) {
        result.add({"id": user.id, "name": user.name});
      }
    }

    return result;
  }

  Future<bool> login(String email, String password) async {
    final user = await _authUseCase.login(email, password);
    if (user != null) {
      currentUser.value = user;
      return true;
    }
    return false;
  }

  Future<bool> signUp(String email, String name, String password) async {
    logInfo('AuthenticationController: Sign Up $email');

    final user = await _authUseCase.signUp(email, name, password);

    if (user != null) {
      currentUser.value = user; // ahora sí contiene el id de Roble
      return true;
    }
    return false;
  }

  Future<void> logOut() async {
    await _authUseCase.logOut();
    currentUser.value = null;
  }
}
