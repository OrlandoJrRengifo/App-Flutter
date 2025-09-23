abstract class IUserGroupDataSource {
  Future<bool> joinGroup(String userId, String groupId);
  Future<bool> leaveGroup(String userId, String groupId);
  Future<List<String>> getGroupUsers(String groupId);
  Future<String?> getUserGroupInCategory(String userId, String categoryId);
}
