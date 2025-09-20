import 'package:get/get.dart';
import '../../domain/entities/fake_user.dart';
import '../../domain/usecases/fake_user_usecase.dart';

class FakeUserController extends GetxController {
  final FakeUserUseCase _fakeUserUseCase;

  FakeUserController(this._fakeUserUseCase);

  final RxList<FakeUser> users = <FakeUser>[].obs;

  /// 🔹 Verifica si existe por authId, si no lo crea
  Future<FakeUser?> createUserIfNotExists({
    required String authId,
    required String email,
    required String name,
  }) async {
    final existing = await _fakeUserUseCase.getUserByAuthId(authId);
    if (existing != null) return existing;

    final newUser = FakeUser(
      id: "", // lo genera Roble
      authId: authId,
      email: email,
      name: name,
    );

    final created = await _fakeUserUseCase.createUser(newUser);
    return created; // puede ser null si la API falla
  }

  /// 🔹 Obtener usuarios por lista de IDs
  Future<List<FakeUser>> getUsersByIds(List<String> ids) async {
  print("👉 getUsersByIds recibió: $ids");

  if (ids.isEmpty) {
    print("⚠️ Lista vacía, retorno []");
    return [];
  }

  final fetched = await _fakeUserUseCase.getUsersByIds(ids);
  print("👉 getUsersByIds devolvió: $fetched");

  return fetched;
}


  /// 🔹 (Opcional) traer todos los usuarios y mantenerlos en memoria
  Future<List<FakeUser>> fetchUsers() async {
    final fetched = await _fakeUserUseCase.getAllUsers(); // ⚡ nuevo caso de uso
    users.assignAll(fetched);
    return users;
  }
}
