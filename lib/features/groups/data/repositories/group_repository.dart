import '../../domain/repositories/i_group_repository.dart';
import '../datasources/i_group_datasource.dart';

class GroupRepository implements IGroupRepository {
  final IGroupDataSource localDataSource;

  GroupRepository(this.localDataSource);

  @override
  Future<void> createGroup(int categoryId, int identifierNumber, int maxMembers) {
    return localDataSource.createGroup(categoryId, identifierNumber, maxMembers);
  }

  @override
  Future<Map<String, dynamic>?> getGroupById(int id) =>
      localDataSource.getGroupById(id);

  @override
  Future<List<Map<String, dynamic>>> getGroupsByCategory(int categoryId) =>
      localDataSource.getGroupsByCategory(categoryId);

  @override
  Future<void> updateGroup(int id, int maxMembers) {
    return localDataSource.updateGroup(id, maxMembers);
  }

  @override
  Future<void> deleteGroup(int id) => localDataSource.deleteGroup(id);
}
