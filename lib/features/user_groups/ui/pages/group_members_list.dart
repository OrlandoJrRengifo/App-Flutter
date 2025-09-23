import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../controller/user_group_controller.dart';
import '../../../fake_users/ui/controller/fake_user_controller.dart';
import '../../../fake_users/domain/entities/fake_user.dart';

class GroupMembersList extends StatefulWidget {
  final String groupId;
  final String categoryId;

  const GroupMembersList({
    super.key,
    required this.groupId,
    required this.categoryId,
  });

  @override
  State<GroupMembersList> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupMembersList> {
  late final UserGroupController userGroupController;
  late final FakeUserController fakeUserController;
  late final String currentUserId;

  /// Lista de usuarios con datos completos (name, email)
  final RxList<FakeUser> groupUserDetails = <FakeUser>[].obs;
  final RxBool inCategory = false.obs;

  @override
  void initState() {
    super.initState();
    userGroupController = Get.find<UserGroupController>();
    fakeUserController = Get.find<FakeUserController>();

    final authController = Get.find<AuthenticationController>();
    currentUserId = authController.currentUser.value?.id ?? "";

    _loadState();
  }

  Future<void> _loadState() async {
    await _loadGroupUsers();
    inCategory.value = await userGroupController.isUserInCategory(
      currentUserId,
      widget.categoryId,
    );
  }

  Future<void> _loadGroupUsers() async {
    await userGroupController.fetchGroupUsers(widget.groupId);
    final ids = userGroupController.groupUsers.toList();
    final users = await fakeUserController.getUsersByIds(ids);
    groupUserDetails.assignAll(users);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles del grupo")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (groupUserDetails.isEmpty) {
                return const Center(child: Text("No hay integrantes aún"));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: groupUserDetails.length,
                itemBuilder: (_, index) {
                  final user = groupUserDetails[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                  );
                },
              );
            }),
          ),
          const Divider(),
          Obx(() {
            final isMember =
                userGroupController.groupUsers.contains(currentUserId);

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
                        currentUserId, widget.groupId);
                    if (!ok) {
                      Get.snackbar("Error", "No se pudo salir del grupo",
                          snackPosition: SnackPosition.BOTTOM);
                    }
                    await _loadState();
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
                    await _loadState();
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
      ),
    );
  }
}
