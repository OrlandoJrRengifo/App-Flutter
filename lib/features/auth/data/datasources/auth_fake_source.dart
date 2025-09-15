import '../../domain/entities/user.dart';
import 'i_auth_source.dart';

class AuthFakeSource implements IAuthenticationSource {
  final Map<String, dynamic> _jsonDb = {
    "users": [
      {
        "id": 1,
        "name": "Amanda Álvarez",
        "email": "a@a.com",
        "password": "123456"
      },
      {
        "id": 2,
        "name": "Brayan Aguirre",
        "email": "b@a.com",
        "password": "123456"
      },
      {
        "id": 3,
        "name": "Carlos Acevedo",
        "email": "c@a.com",
        "password": "123456"
      }
    ]
  };

  List<Map<String, dynamic>> get _users =>
      List<Map<String, dynamic>>.from(_jsonDb["users"]);
  
  @override
  Future<User?> getUser(int userId) {
    // TODO: implement getUser
    throw UnimplementedError();
  }

  @override
  Future<User?> login(String email, String password) async {
    final found = _users.firstWhere(
        (u) => u["email"] == email && u["password"] == password,
        orElse: () => {});
    if (found.isEmpty) return null;
    return User.fromJson(found);
  }

  @override
  Future<bool> signUp(User user) async {
    final exists = _users.any((u) => u["email"] == user.email);
    if (exists) return false;

    final newUser = {
      "id": _users.isEmpty
          ? 1
          : (_users.map((u) => u["id"] as int).reduce((a, b) => a > b ? a : b) + 1),
      "name": user.name,
      "email": user.email,
      "password": user.password,
    };
    _users.add(newUser);
    return true;
  }


  @override
  Future<bool> logOut() async => Future.value(true);
}
