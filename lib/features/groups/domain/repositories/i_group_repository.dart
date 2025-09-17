abstract class IGroupRepository {
  Future<void> createGroup(int categoryId, int identifierNumber, int maxMembers);

  Future<Map<String, dynamic>?> getGroupById(int id);

  Future<List<Map<String, dynamic>>> getGroupsByCategory(int categoryId);

  Future<void> updateGroup(int id, int maxMembers);

  Future<void> deleteGroup(int id);
}
