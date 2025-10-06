// features/user_groups/ui/pages/group_members_list.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../controller/user_group_controller.dart';
import '../../../fake_users/ui/controller/fake_user_controller.dart';
//import '../../../fake_users/domain/entities/fake_user.dart';
import '../../../courses/ui/controller/course_controller.dart';
import '../../../categories/ui/controller/categories_controller.dart';
import '../../../assessments/ui/controller/assessment_controller.dart';

class GroupMembersList extends StatefulWidget {
  final String groupId;
  final String categoryId;

  const GroupMembersList({
    super.key,
    required this.groupId,
    required this.categoryId,
  });

  @override
  State<GroupMembersList> createState() => _GroupMembersListState();
}

class _GroupMembersListState extends State<GroupMembersList> {
  late final UserGroupController userGroupController;
  late final FakeUserController fakeUserController;
  late final AssessmentController assessmentController;
  late final String currentUserId;

  final RxList<_UserStats> groupStats = <_UserStats>[].obs;
  final RxBool inCategory = false.obs;
  final RxBool stateLoaded = false.obs;
  final RxBool isTeacher = false.obs;

  @override
  void initState() {
    super.initState();
    userGroupController = Get.find<UserGroupController>();
    fakeUserController = Get.find<FakeUserController>();
    assessmentController = Get.find<AssessmentController>();

    final authController = Get.find<AuthenticationController>();
    currentUserId = authController.currentUser.value?.id ?? "";

    _initialize();
  }

  /// Carga usuarios y calcula sus promedios agregados en paralelo
  Future<void> _initialize() async {
    stateLoaded.value = false;

    final categoryController = Get.find<CategoriesController>();
    final coursesController = Get.find<CoursesController>();

    // Carga de curso y verificación de teacher
    final courseIdFuture = categoryController.getCourseId(widget.categoryId);
    final groupUsersFuture = userGroupController.fetchGroupUsers(
      widget.groupId,
    );
    final inCategoryFuture = userGroupController.isUserInCategory(
      currentUserId,
      widget.categoryId,
    );

    final courseId = await courseIdFuture;
    isTeacher.value =
        courseId != null &&
        coursesController.courses.any(
          (c) => c.id == courseId && c.teacherId == currentUserId,
        );

    await groupUsersFuture;
    inCategory.value = await inCategoryFuture;

    // Carga de detalles completos de los usuarios
    final ids = userGroupController.groupUsers.toList();
    final users = await fakeUserController.getUsersByIds(ids);

    // Para cada usuario pedimos sus promedios agregados
    final futures = users.map((u) async {
      final avg = await assessmentController
          .getAverageRatingsAcrossAllActivities(u.authId);
      return _UserStats(
        userId: u.authId,
        userName: u.name,
        email: u.email,
        punctuality: avg["punctuality"] ?? 0,
        contributions: avg["contributions"] ?? 0,
        commitment: avg["commitment"] ?? 0,
        attitude: avg["attitude"] ?? 0,
        general: avg["general"] ?? 0,
      );
    }).toList();

    final statsResults = await Future.wait(futures);
    groupStats.assignAll(statsResults);

    stateLoaded.value = true;
  }

  double get overallAverage {
    if (groupStats.isEmpty) return 0;
    final sum = groupStats.map((s) => s.general).reduce((a, b) => a + b);
    return sum / groupStats.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles del grupo")),
      body: Obx(() {
        if (!stateLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Header con promedio general del grupo
            if (isTeacher.value)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 14,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Promedio del grupo",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Promedio general de los estudiantes de este grupo",
                              ),
                            ],
                          ),
                        ),
                        Text(
                          overallAverage.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Lista de estudiantes con sus promedios
            Expanded(
              child: Obx(() {
                if (groupStats.isEmpty) {
                  return const Center(child: Text("No hay integrantes aún"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: groupStats.length,
                  itemBuilder: (_, index) {
                    final s = groupStats[index];
                    if (!isTeacher.value) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(s.userName),
                          subtitle: Text(s.email ?? '-'),
                        ),
                      );
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    s.userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Correo: ${s.email ?? '-'}",
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Punctuality: ${s.punctuality.toStringAsFixed(2)}",
                            ),
                            Text(
                              "Contributions: ${s.contributions.toStringAsFixed(2)}",
                            ),
                            Text(
                              "Commitment: ${s.commitment.toStringAsFixed(2)}",
                            ),
                            Text("Attitude: ${s.attitude.toStringAsFixed(2)}"),
                            const Divider(),
                            Text(
                              "Promedio general: ${s.general.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            const Divider(),

            Obx(() {
              final isMember = userGroupController.groupUsers.contains(
                currentUserId,
              );

              if (isTeacher.value) return const SizedBox.shrink();

              if (isMember) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      final ok = await userGroupController.leaveGroup(
                        currentUserId,
                        widget.groupId,
                      );
                      if (!ok) {
                        Get.snackbar(
                          "Error",
                          "No se pudo salir del grupo",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                      await _initialize();
                    },
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text("Salir del grupo"),
                  ),
                );
              }

              if (inCategory.value) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "⚠️ Ya perteneces a un grupo en esta categoría",
                    style: TextStyle(color: Colors.orange, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () async {
                    final success = await userGroupController.joinGroup(
                      currentUserId,
                      widget.groupId,
                      widget.categoryId,
                    );

                    if (success) {
                      await _initialize();
                    } else {
                      Get.snackbar(
                        "Ya perteneces a un grupo",
                        "No puedes unirte a otro grupo en esta categoría",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orange,
                        colorText: Colors.white,
                      );
                    }
                  },
                  icon: const Icon(Icons.group_add),
                  label: const Text("Unirme al grupo"),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

class _UserStats {
  final String userId;
  final String userName;
  final String? email;
  final double punctuality;
  final double contributions;
  final double commitment;
  final double attitude;
  final double general;

  _UserStats({
    required this.userId,
    required this.userName,
    this.email,
    required this.punctuality,
    required this.contributions,
    required this.commitment,
    required this.attitude,
    required this.general,
  });
}
