import 'package:get/get.dart';
import '../../domain/usecases/group_usecase.dart';

class GroupController extends GetxController {
  final GroupUseCase useCase;

  GroupController(this.useCase);

  final RxList<Map<String, dynamic>> groups = <Map<String, dynamic>>[].obs;
  final Rx<Map<String, dynamic>?> selectedGroup = Rx<Map<String, dynamic>?>(null);

  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  Future<void> createGroup(int categoryId, int identifierNumber, int maxMembers) async {
    try {
      loading.value = true;
      await useCase.createGroup(categoryId, identifierNumber, maxMembers);
      await fetchGroupsByCategory(categoryId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchGroupById(int id) async {
    try {
      loading.value = true;
      final group = await useCase.getGroupById(id);
      selectedGroup.value = group;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchGroupsByCategory(int categoryId) async {
    try {
      loading.value = true;
      final list = await useCase.getGroupsByCategory(categoryId);
      groups.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateGroup(int id, int maxMembers) async {
    try {
      loading.value = true;
      await useCase.updateGroup(id, maxMembers);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteGroup(int id, int categoryId) async {
    try {
      loading.value = true;
      await useCase.deleteGroup(id);
      await fetchGroupsByCategory(categoryId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
