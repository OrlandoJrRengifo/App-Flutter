import '../entities/fake_user.dart';

abstract class IFakeUserRepository {
  Future<FakeUser?> getUserByAuthId(String authId);
  Future<FakeUser?> createUser(FakeUser user);
  Future<List<FakeUser>> getUsersByIds(List<String> ids);
  Future<List<FakeUser>> getAllUsers();

}
