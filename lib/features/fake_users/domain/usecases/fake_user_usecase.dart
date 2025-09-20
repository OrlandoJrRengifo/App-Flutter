import '../entities/fake_user.dart';
import '../repositories/i_fake_user_repository.dart';

class FakeUserUseCase {
  final IFakeUserRepository repository;

  FakeUserUseCase(this.repository);

  Future<FakeUser?> getUserByAuthId(String authId) =>
      repository.getUserByAuthId(authId);

  Future<FakeUser?> createUser(FakeUser user) => repository.createUser(user);

  Future<List<FakeUser>> getUsersByIds(List<String> ids) async {
  print("📡 UseCase.getUsersByIds con $ids");
  return await repository.getUsersByIds(ids);
}

  Future<List<FakeUser>> getAllUsers() {
  return repository.getAllUsers();
}

}
