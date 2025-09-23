import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/activity.dart';
import '../controller/activity_controller.dart';
import '../../../categories/ui/controller/categories_controller.dart';
import '../../../courses/ui/controller/course_controller.dart';

class ActivitiesPage extends StatefulWidget {
  final String categoryId;
  final String? categoryName;

  const ActivitiesPage({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late final ActivityController controller;
  final isOwner = false.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ActivityController>();
    controller.loadActivities(widget.categoryId);
    _checkOwnership();
  }

  Future<void> _checkOwnership() async {
    final categoriesController = Get.find<CategoriesController>();
    final coursesController = Get.find<CoursesController>();

    final category = await categoriesController.useCases.getCategory(widget.categoryId);
    if (category == null) return;

    final owner = await coursesController.isOwnerOfCourse(category.courseId);
    isOwner.value = owner;
  }

  void _showCreateDialog() async {
    final nameController = TextEditingController();

    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text("Crear actividad"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nombre"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancelar")),
          TextButton(onPressed: () => Get.back(result: nameController.text.trim()), child: const Text("Crear")),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await controller.createActivity(widget.categoryId, result);
      Get.snackbar("¡Éxito!", "Actividad '$result' creada", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showEditDialog(Activity activity) async {
    final nameController = TextEditingController(text: activity.name);

    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text("Editar actividad"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Nombre"),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancelar")),
          TextButton(onPressed: () => Get.back(result: nameController.text.trim()), child: const Text("Actualizar")),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != activity.name) {
      await controller.updateActivityName(activity.id!, result);
      Get.snackbar("¡Éxito!", "Nombre actualizado a '$result'", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _activateActivity(Activity activity) async {
    if (!activity.activated) {
      await controller.activateActivity(activity.id!);
      Get.snackbar("¡Éxito!", "Actividad '${activity.name}' activada", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _deleteActivity(Activity activity) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Eliminar actividad"),
        content: Text("¿Deseas eliminar '${activity.name}'?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false),child: const Text("Cancelar"),),
          TextButton(onPressed: () => Get.back(result: true),child: const Text("Eliminar"),),
        ],
      ),
    );

    if (confirm == true) {
      final success = await controller.deleteActivity(activity.id!);
      if (success) {
        Get.snackbar("¡Éxito!", "Actividad '${activity.name}' eliminada", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Widget _buildActionButtons(Activity activity) {
    if (isOwner.value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(activity)),
          IconButton(
            icon: Icon(Icons.check_circle, color: activity.activated ? Colors.green : Colors.grey),
            onPressed: () => _activateActivity(activity),
          ),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteActivity(activity)),
        ],
      );
    } else {
      // Los estudiantes solo ven el icono de activación deshabilitado
      return Icon(Icons.check_circle, color: activity.activated ? Colors.green : Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.loading.value) return const Center(child: CircularProgressIndicator());
        if (controller.activities.isEmpty) return const Center(child: Text("No hay actividades creadas"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.activities.length,
          itemBuilder: (context, index) {
            final activity = controller.activities[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(activity.name),
                subtitle: Text(activity.activated ? "Activada" : "Inactiva"),
                trailing: Obx(() => _buildActionButtons(activity)),
              ),
            );
          },
        );
      }),
      floatingActionButton: Obx(
        () => isOwner.value ? FloatingActionButton(onPressed: _showCreateDialog, child: const Icon(Icons.add)) : const SizedBox.shrink(),
      ),
    );
  }
}
