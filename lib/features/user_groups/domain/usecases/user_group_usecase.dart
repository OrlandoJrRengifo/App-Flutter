import '../repositories/i_user_group_repository.dart';

class UserGroupUseCase {
  final IUserGroupRepository repository;

  UserGroupUseCase(this.repository);

  Future<bool> joinGroup(String userId, String groupId) =>
      repository.joinGroup(userId, groupId);

  Future<bool> leaveGroup(String userId, String groupId) =>
      repository.leaveGroup(userId, groupId);

  Future<List<String>> getGroupUsers(String groupId) =>
      repository.getGroupUsers(groupId);

  Future<String?> getUserGroupInCategory(String userId, String categoryId) =>
      repository.getUserGroupInCategory(userId, categoryId);
}
