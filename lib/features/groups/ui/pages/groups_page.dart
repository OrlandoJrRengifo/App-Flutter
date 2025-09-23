import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/group_controller.dart';
import '../../../categories/ui/controller/categories_controller.dart';
import '../../../courses/ui/controller/course_controller.dart';
import '../../../user_groups/ui/pages/group_members_list.dart';

class GroupsPage extends StatefulWidget {
  final String categoryId;
  final int defaultCapacity;

  const GroupsPage({
    super.key,
    required this.categoryId,
    required this.defaultCapacity,
  });

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late final GroupController controller;
  final isOwner = false.obs; // 👈 observable para permisos

  @override
  void initState() {
    super.initState();
    controller = Get.find<GroupController>();
    controller.loadGroups(widget.categoryId);

    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    final categoriesController = Get.find<CategoriesController>();
    final coursesController = Get.find<CoursesController>();

    final category = await categoriesController.useCases.getCategory(
      widget.categoryId,
    );
    if (category == null) return;

    final owner = await coursesController.isOwnerOfCourse(category.courseId);
    isOwner.value = owner;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Grupos")),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.groups.isEmpty) {
          return const Center(child: Text("No hay grupos aún"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.groups.length,
          itemBuilder: (_, index) {
            final group = controller.groups[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Obx(
                () => ListTile(
                  title: Text("Grupo ${group.numeration}"),
                  subtitle: Text("Capacidad: ${group.capacity}"),
                  trailing: isOwner.value
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final newCap = await _showCapacityDialog(
                                  context,
                                  group.capacity,
                                );
                                if (newCap != null) {
                                  await controller.updateCapacity(
                                    group.id,
                                    newCap,
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await _showDeleteDialog(
                                  context,
                                );
                                if (confirm == true) {
                                  await controller.deleteGroup(group.id);
                                }
                              },
                            ),
                          ],
                        )
                      : null,

                  // 👇 AQUÍ LE AGREGAS EL onTap
                  onTap: () {
                    Get.to(
                      () => GroupMembersList(
                        groupId: group.id,
                        categoryId: widget.categoryId,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: Obx(
        () => isOwner.value
            ? FloatingActionButton(
                onPressed: () async {
                  await controller.addGroup(
                    widget.categoryId,
                    widget.defaultCapacity,
                  );
                },
                child: const Icon(Icons.add),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Future<int?> _showCapacityDialog(BuildContext context, int current) async {
    final controller = TextEditingController(text: current.toString());
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar capacidad"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Capacidad"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar grupo"),
        content: const Text("¿Seguro que quieres eliminar este grupo?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}
