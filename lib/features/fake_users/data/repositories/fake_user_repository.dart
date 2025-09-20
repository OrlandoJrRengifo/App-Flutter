import '../../domain/entities/fake_user.dart';
import '../../domain/repositories/i_fake_user_repository.dart';
import '../datasources/i_fake_user_source.dart';

class FakeUserRepository implements IFakeUserRepository {
  final IFakeUserSource userSource;

  FakeUserRepository(this.userSource);

  @override
  Future<FakeUser?> getUserByAuthId(String authId) =>
      userSource.getUserByAuthId(authId);

  @override
  Future<FakeUser?> createUser(FakeUser user) => userSource.createUser(user);

  @override
Future<List<FakeUser>> getUsersByIds(List<String> ids) async {
  print("📡 Repository.getUsersByIds con $ids");
  return await userSource.getUsersByIds(ids);
}

  @override
  Future<List<FakeUser>> getAllUsers() {
    return userSource.getAllUsers();
  }
}
