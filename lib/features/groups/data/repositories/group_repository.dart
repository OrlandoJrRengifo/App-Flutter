import '../../domain/entities/group.dart';
import '../../domain/repositories/i_group_repository.dart';
import '../datasources/i_group_source.dart';

class GroupRepository implements IGroupRepository {
  final IGroupSource source;
  GroupRepository(this.source);

  @override
  Future<List<Group>> getGroupsByCategory(String categoryId) async {
    return await source.getGroupsByCategory(categoryId);
  }

  @override
  Future<Group> createGroup(String categoryId, int numeration, int capacity) async {
    final tmp = Group(id: "", categoryId: categoryId, numeration: numeration, capacity: capacity);
    final created = await source.createGroup(tmp);
    if (created == null) {
      throw Exception("No se pudo crear el grupo");
    }
    return created;
  }

  @override
  Future<Group> updateGroupCapacity(String groupId, int capacity) async {
    final updated = await source.updateGroupCapacity(groupId, capacity);
    if (updated == null) {
      throw Exception("No se pudo actualizar la capacidad");
    }
    return updated;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await source.deleteGroup(groupId);
  }
}
