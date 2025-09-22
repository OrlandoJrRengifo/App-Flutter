import 'package:get/get.dart';
import '../../domain/entities/group.dart';
import '../../domain/usecases/group_usecase.dart';

class GroupController extends GetxController {
  final GroupUseCase useCases;

  GroupController(this.useCases);

  var groups = <Group>[].obs;
  var loading = false.obs;

  Future<void> loadGroups(String categoryId) async {
    loading.value = true;
    try {
      groups.value = await useCases.getGroupsByCategory(categoryId);
    } finally {
      loading.value = false;
    }
  }

  Future<void> addGroup(String categoryId, int capacity) async {
    final numeration =
        groups.isEmpty ? 1 : (groups.map((g) => g.numeration).reduce((a, b) => a > b ? a : b) + 1);

    final newGroup =
        await useCases.createGroup(categoryId: categoryId, numeration: numeration, capacity: capacity);

    groups.add(newGroup);
  }

  Future<void> updateCapacity(String groupId, int capacity) async {
    final updated = await useCases.updateCapacity(groupId, capacity);
    groups[groups.indexWhere((g) => g.id == groupId)] = updated;
  }

  Future<void> deleteGroup(String groupId) async {
    await useCases.deleteGroup(groupId);
    groups.removeWhere((g) => g.id == groupId);
  }
}
