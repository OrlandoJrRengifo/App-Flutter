import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/category.dart';
import '../controller/categories_controller.dart';
import '../../../courses/ui/controller/course_controller.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../widgets/category_form.dart';

class CategoriesPage extends StatefulWidget {
  final String courseId;
  final String? courseName; 
  
  const CategoriesPage({
    super.key,
    required this.courseId,
    this.courseName,
  });

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // verificar si el usuario actual es el dueño del curso
      final course = await coursesController.useCases.getCourse(widget.courseId);
      final currentUserId = authController.currentUser.value?.id;
      if (course != null && currentUserId != null) {
        setState(() {
          isOwner = course.teacherId == currentUserId;
        });
      }

      controller.loadCategories(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

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
                Text(
                  "No hay categorías creadas",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                if (isOwner) ...[
                  const SizedBox(height: 8),
                  const Text(
                    "Crea una categoría para agrupar estudiantes",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ]
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
                              if (result != null) {
                                await controller.updateCategoryInList(result);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await Get.dialog<bool>(
                                AlertDialog(
                                  title: const Text("Eliminar categoría"),
                                  content: Text(
                                    "¿Seguro que deseas eliminar '${cat.name}'?\n\n"
                                    "Esta acción también eliminará todos los grupos asociados.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Get.back(result: false),
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

                              if (confirm == true) {
                                await controller.deleteCategoryFromList(cat.id);
                              }
                            },
                          ),
                        ],
                      )
                    : null,
                onTap: () {
                  Get.snackbar(
                    "Información",
                    "Tap en '${cat.name}' - ID: ${cat.id}",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            );
          },
        );
      }),

      // FAB solo para el dueño del curso
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Get.dialog<Category>(
                  CategoryFormDialog(courseId: widget.courseId),
                );

                if (result != null) {
                  try {
                    await controller.addCategory(
                      courseId: result.courseId,
                      name: result.name,
                      groupingMethod: result.groupingMethod,
                      maxMembers: result.maxGroupSize ?? 1,
                    );

                    Get.snackbar(
                      "¡Éxito!",
                      "Categoría '${result.name}' creada correctamente",
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
                }
              },
              icon: const Icon(Icons.add),
              label: const Text("Crear categoría"),
            )
          : null,
    );
  }
}
