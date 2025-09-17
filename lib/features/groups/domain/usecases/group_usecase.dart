import '../repositories/i_group_repository.dart';

class GroupUseCase {
  final IGroupRepository repository;

  GroupUseCase(this.repository);

  Future<void> createGroup(int categoryId, int identifierNumber, int maxMembers) {
    return repository.createGroup(categoryId, identifierNumber, maxMembers);
  }

  Future<Map<String, dynamic>?> getGroupById(int id) =>
      repository.getGroupById(id);

  Future<List<Map<String, dynamic>>> getGroupsByCategory(int categoryId) =>
      repository.getGroupsByCategory(categoryId);

  Future<void> updateGroup(int id, int maxMembers) {
    return repository.updateGroup(id, maxMembers);
  }

  Future<void> deleteGroup(int id) => repository.deleteGroup(id);
}
