  import '../entities/group.dart';
import '../repositories/i_group_repository.dart';

class GroupUseCase {
  final IGroupRepository repo;
  GroupUseCase(this.repo);

  Future<List<Group>> getGroupsByCategory(String categoryId) =>
      repo.getGroupsByCategory(categoryId);

  Future<Group> createGroup({
    required String categoryId,
    required int numeration,
    required int capacity,
  }) =>
      repo.createGroup(categoryId, numeration, capacity);

  Future<Group> updateCapacity(String groupId, int capacity) =>
      repo.updateGroupCapacity(groupId, capacity);

  Future<void> deleteGroup(String groupId) => repo.deleteGroup(groupId);
}
