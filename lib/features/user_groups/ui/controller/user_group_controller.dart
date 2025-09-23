import 'package:get/get.dart';
import '../../domain/usecases/user_group_usecase.dart';
import '../../../categories/ui/controller/categories_controller.dart';
import '../../../courses/ui/controller/course_controller.dart';

class UserGroupController extends GetxController {
  final UserGroupUseCase useCase;

  UserGroupController(this.useCase);

  final RxList<String> groupUsers = <String>[].obs;

  Future<bool> joinGroup(
    String userId,
    String groupId,
    String categoryId, {
    int? maxGroupSize, // nuevo parámetro opcional
  }) async {
    // 1️⃣ verificar si ya pertenece a un grupo en esa categoría
    final alreadyInCategory = await useCase.getUserGroupInCategory(
      userId,
      categoryId,
    );

    if (alreadyInCategory != null) {
      print(
        "⚠️ joinGroup abortado: user=$userId ya en grupo $alreadyInCategory de la categoría $categoryId",
      );
      return false;
    }

    // 2️⃣ revisar si el grupo tiene capacidad
    if (maxGroupSize != null) {
      final currentCount = await useCase.getGroupUsers(groupId);
      if (currentCount.length >= maxGroupSize) {
        print(
          "⚠️ joinGroup abortado: grupo $groupId ya alcanzó su capacidad máxima",
        );
        return false;
      }
    }

    // 3️⃣ traer el courseId desde CategoriesController
    final categoriesController = Get.find<CategoriesController>();
    final courseId = await categoriesController.getCourseId(categoryId);
    if (courseId == null) {
      print("❌ joinGroup abortado: categoría $categoryId no tiene course_id");
      return false;
    }

    // 4️⃣ revisar si el usuario dicta ese curso
    final coursesController = Get.find<CoursesController>();
    final teaches = coursesController.courses.any(
      (c) => c.id == courseId && c.teacherId == userId,
    );

    if (teaches) {
      print("🚫 joinGroup abortado: user=$userId es profe del curso $courseId");
      return false;
    }

    // 5️⃣ unir al grupo
    final success = await useCase.joinGroup(userId, groupId);
    if (success) {
      groupUsers.add(userId);
    }
    return success;
  }

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

  Future<bool> isUserInCategory(String userId, String categoryId) async {
    final groupId = await useCase.getUserGroupInCategory(userId, categoryId);
    return groupId != null;
  }

  Future<void> assignStudentsRandomly({
    required List<String> students,
    required List<String> groupIds,
    required int maxGroupSize,
    required String categoryId,
  }) async {
    final shuffledStudents = List<String>.from(students)..shuffle();
    int groupIndex = 0;

    for (final student in shuffledStudents) {
      bool added = false;

      // Intentar agregar en un grupo mientras no exceda la capacidad
      while (!added && groupIndex < groupIds.length) {
        final groupId = groupIds[groupIndex];
        added = await joinGroup(
          student,
          groupId,
          categoryId,
          maxGroupSize: maxGroupSize,
        );

        // Si el grupo está lleno, pasar al siguiente
        if (!added) groupIndex++;
        if (groupIndex >= groupIds.length)
          groupIndex = 0; // reiniciar si quedan estudiantes
      }
    }
  }
}
