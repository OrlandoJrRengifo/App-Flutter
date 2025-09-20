import '../../domain/entities/fake_user.dart';

abstract class IFakeUserSource {
  Future<FakeUser?> getUserByAuthId(String authId);
  Future<FakeUser?> createUser(FakeUser user);
  Future<List<FakeUser>> getUsersByIds(List<String> ids);
  Future<List<FakeUser>> getAllUsers();

}
