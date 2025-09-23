import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/category.dart';
import '../controller/categories_controller.dart';
import '../../../courses/ui/controller/course_controller.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../widgets/category_form.dart';
import 'category_tabs_page.dart';
import '../../../groups/ui/controller/group_controller.dart';
import '../../../user_courses/ui/controller/user_course_controller.dart';
import '../../../user_groups/ui/controller/user_group_controller.dart';

class CategoriesPage extends StatefulWidget {
  final String courseId;
  final String? courseName;

  const CategoriesPage({super.key, required this.courseId, this.courseName});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late final CategoriesController controller;
  late final CoursesController coursesController;
  late final AuthenticationController authController;

  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CategoriesController>();
    coursesController = Get.find<CoursesController>();
    authController = Get.find<AuthenticationController>();

    controller.loading.value = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final course = await coursesController.useCases.getCourse(
        widget.courseId,
      );
      final currentUserId = authController.currentUser.value?.id;
      if (course != null && currentUserId != null) {
        setState(() {
          isOwner = course.teacherId == currentUserId;
        });
      }
      await controller.loadCategories(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.loading.value)
          return const Center(child: CircularProgressIndicator());

        if (controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text("Error: ${controller.error}"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadCategories(widget.courseId),
                  child: const Text("Reintentar"),
                ),
              ],
            ),
          );
        }

        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "No hay categorías creadas",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                if (isOwner) ...[
                  const SizedBox(height: 8),
                  const Text(
                    "Crea una categoría para agrupar estudiantes",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final cat = controller.categories[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: cat.groupingMethod == GroupingMethod.random
                      ? Colors.orange[100]
                      : Colors.green[100],
                  child: Icon(
                    cat.groupingMethod == GroupingMethod.random
                        ? Icons.shuffle
                        : Icons.group,
                    color: cat.groupingMethod == GroupingMethod.random
                        ? Colors.orange[800]
                        : Colors.green[800],
                  ),
                ),
                title: Text(
                  cat.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("Tamaño máximo: ${cat.maxGroupSize ?? 'Sin límite'}"),
                    Text(
                      "Método: ${cat.groupingMethod == GroupingMethod.random ? 'Aleatorio' : 'Auto-asignado'}",
                      style: TextStyle(
                        color: cat.groupingMethod == GroupingMethod.random
                            ? Colors.orange[700]
                            : Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: isOwner
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final result = await Get.dialog<Category>(
                                CategoryFormDialog(
                                  courseId: widget.courseId,
                                  category: cat,
                                ),
                              );
                              if (result != null)
                                await controller.updateCategoryInList(result);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await Get.dialog<bool>(
                                AlertDialog(
                                  title: const Text("Eliminar categoría"),
                                  content: Text(
                                    "¿Seguro que deseas eliminar '${cat.name}'?\nEsta acción también eliminará todos los grupos asociados.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: const Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.back(result: true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text("Eliminar"),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true)
                                await controller.deleteCategoryFromList(cat.id);
                            },
                          ),
                        ],
                      )
                    : null,
                onTap: () {
                  if (cat.id != null) {
                    Get.to(
                      () => CategoryTabsPage(
                        categoryId: cat.id!,
                        categoryName: cat.name,
                        defaultGroupCapacity: cat.maxGroupSize ?? 1,
                      ),
                    );
                  } else {
                    print("⚠️ Category sin id!");
                  }
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Get.dialog<Category>(
                  CategoryFormDialog(courseId: widget.courseId),
                );
                if (result == null) return;

                try {
                  // 1. Crear categoría
                  await controller.addCategory(
                    courseId: result.courseId,
                    name: result.name,
                    groupingMethod: result.groupingMethod,
                    maxMembers: result.maxGroupSize ?? 1,
                  );

                  // 2. Categoría recién creada
                  final createdCategory = controller.categories.last;
                  if (createdCategory.id == null) return;

                  final maxGroupSize = result.maxGroupSize ?? 1;

                  // 3. Obtener estudiantes solo si es random
                  final userCourseController = Get.find<UserCourseController>();
                  if (result.groupingMethod == GroupingMethod.random) {
                    await userCourseController.fetchCourseUsers(
                      widget.courseId,
                    );
                  }

                  final totalStudents = userCourseController.courseUsers.length;

                  // 4. Calcular cuántos grupos crear
                  final groupsNeeded = (totalStudents > 0
                      ? (totalStudents / maxGroupSize).ceil()
                      : 1);

                  // 5. Crear los grupos automáticamente
                  final groupController = Get.find<GroupController>();
                  for (int i = 0; i < groupsNeeded; i++) {
                    await groupController.addGroup(
                      createdCategory.id!,
                      maxGroupSize,
                    );
                  }

                  // 6. Asignar estudiantes solo si es random
                  if (result.groupingMethod == GroupingMethod.random &&
                      totalStudents > 0) {
                    final createdGroups = groupController.groups
                        .where((g) => g.categoryId == createdCategory.id!)
                        .toList();
                    final students = userCourseController.courseUsers.toList()
                      ..shuffle();
                    int groupIndex = 0;
                    final userGroupController = Get.find<UserGroupController>();

                    for (final studentId in students) {
                      bool added = false;
                      while (!added) {
                        final group =
                            createdGroups[groupIndex % createdGroups.length];
                        final currentMembers = await userGroupController.useCase
                            .getGroupUsers(group.id);
                        if (currentMembers.length < group.capacity) {
                          await userGroupController.joinGroup(
                            studentId,
                            group.id,
                            createdCategory.id!,
                          );
                          added = true;
                        } else {
                          groupIndex++;
                        }
                      }
                    }
                  }

                  Get.snackbar(
                    "¡Éxito!",
                    "Categoría '${result.name}' creada con sus grupos",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green[100],
                    colorText: Colors.green[800],
                  );
                } catch (e) {
                  Get.snackbar(
                    "Error",
                    e.toString(),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red[100],
                    colorText: Colors.red[800],
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Crear categoría"),
            )
          : null,
    );
  }
}
