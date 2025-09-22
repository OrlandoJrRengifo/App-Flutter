import '../entities/group.dart';

abstract class IGroupRepository {
  Future<List<Group>> getGroupsByCategory(String categoryId);
  Future<Group> createGroup(String categoryId, int numeration, int capacity);
  Future<Group> updateGroupCapacity(String groupId, int capacity);
  Future<void> deleteGroup(String groupId);
}
