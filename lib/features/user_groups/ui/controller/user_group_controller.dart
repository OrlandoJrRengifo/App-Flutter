import 'package:get/get.dart';
import '../../domain/usecases/user_group_usecase.dart';

class UserGroupController extends GetxController {
  final UserGroupUseCase useCase;

  UserGroupController(this.useCase);

  final RxList<String> groupUsers = <String>[].obs;

  /// retorna true si el join fue exitoso; evita join si ya está en la categoría
  Future<bool> joinGroup(
    String userId,
    String groupId,
    String categoryId,
  ) async {
    // comprobar por el repo si ya pertenece a un grupo de la categoría
    final alreadyInCategory = await useCase.getUserGroupInCategory(userId, categoryId);

    if (alreadyInCategory != null) {
      print("⚠️ joinGroup abortado: usuario $userId ya en grupo ${alreadyInCategory} de la categoría $categoryId");
      return false;
    }

    final success = await useCase.joinGroup(userId, groupId);
    if (success) {
      groupUsers.add(userId);
    }
    return success;
  }

  /// devuelve true si salió correctamente
  Future<bool> leaveGroup(String userId, String groupId) async {
    final success = await useCase.leaveGroup(userId, groupId);
    if (success) {
      groupUsers.remove(userId);
    }
    return success;
  }

  Future<void> fetchGroupUsers(String groupId) async {
    final users = await useCase.getGroupUsers(groupId);
    groupUsers.assignAll(users);
  }

  /// Comprueba si existe un group_id para userId en esa category (true = ya está)
  Future<bool> isUserInCategory(String userId, String categoryId) async {
    final groupId = await useCase.getUserGroupInCategory(userId, categoryId);
    return groupId != null;
  }
}
