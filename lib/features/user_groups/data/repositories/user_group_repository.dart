import '../../domain/repositories/i_user_group_repository.dart';
import '../datasources/i_user_group_source.dart';

class UserGroupRepository implements IUserGroupRepository {
  final IUserGroupDataSource robleDataSource;

  UserGroupRepository(this.robleDataSource);

  @override
  Future<bool> joinGroup(String userId, String groupId) =>
      robleDataSource.joinGroup(userId, groupId);

  @override
  Future<bool> leaveGroup(String userId, String groupId) =>
      robleDataSource.leaveGroup(userId, groupId);

  @override
  Future<List<String>> getGroupUsers(String groupId) =>
      robleDataSource.getGroupUsers(groupId);

  @override
  Future<String?> getUserGroupInCategory(String userId, String categoryId) =>
      robleDataSource.getUserGroupInCategory(userId, categoryId);
  
  @override
  Future<Map<String, dynamic>?> getCategory(String id) =>
      robleDataSource.getCategory(id);
}
