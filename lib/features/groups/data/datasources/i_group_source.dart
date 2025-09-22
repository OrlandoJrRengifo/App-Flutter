import '../../domain/entities/group.dart';

abstract class IGroupSource {
  Future<List<Group>> getGroupsByCategory(String categoryId);
  Future<Group?> createGroup(Group group);
  Future<Group?> updateGroupCapacity(String groupId, int capacity);
  Future<void> deleteGroup(String groupId);
}
