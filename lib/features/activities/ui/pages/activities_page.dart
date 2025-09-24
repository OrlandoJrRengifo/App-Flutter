import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/ui/controller/auth_controller.dart';
import 'package:get/get.dart';
import '../../domain/entities/activity.dart';
import '../controller/activity_controller.dart';
import '../../../categories/ui/controller/categories_controller.dart';
import '../../../courses/ui/controller/course_controller.dart';
import '../../../groups/ui/controller/group_controller.dart';
import '../../../assessments/ui/controller/assessment_controller.dart';
import '../../../user_groups/ui/controller/user_group_controller.dart';
import '../../../assessments/ui/pages/assessment_list_page.dart';

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

    final category = await categoriesController.useCases.getCategory(
      widget.categoryId,
    );
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Get.back(result: nameController.text.trim()),
            child: const Text("Crear"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await controller.createActivity(widget.categoryId, result);
      Get.snackbar(
        "¡Éxito!",
        "Actividad '$result' creada",
        snackPosition: SnackPosition.BOTTOM,
      );
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
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Get.back(result: nameController.text.trim()),
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != activity.name) {
      await controller.updateActivityName(activity.id!, result);
      Get.snackbar(
        "¡Éxito!",
        "Nombre actualizado a '$result'",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _activateActivity(Activity activity) async {
    if (activity.activated) return; // ya está activa

    if (!isOwner.value) {
      Get.snackbar(
        "Acceso denegado",
        "Solo el dueño puede activar",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    TimeOfDay? selectedTime;
    String visibility = "public";

    final result = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Configurar actividad"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    selectedTime == null
                        ? "Seleccionar hora límite"
                        : "Hora: ${selectedTime!.format(context)}",
                  ),
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 12, minute: 0),
                    );
                    if (picked != null) {
                      setState(() => selectedTime = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                RadioListTile<String>(
                  value: "public",
                  groupValue: visibility,
                  title: const Text("Public"),
                  onChanged: (value) => setState(() => visibility = value!),
                ),
                RadioListTile<String>(
                  value: "private",
                  groupValue: visibility,
                  title: const Text("Private"),
                  onChanged: (value) => setState(() => visibility = value!),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text("Activar"),
              ),
            ],
          );
        },
      ),
    );

    if (result == true) {
      final activated = await controller.activateActivity(activity.id!);
      if (!activated) {
        Get.snackbar(
          "Error",
          "No se pudo activar la actividad",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Crear assessments con el controller centralizado
      final assessmentController = Get.find<AssessmentController>();
      final groupController = Get.find<GroupController>();
      final userGroupController = Get.find<UserGroupController>();

      await groupController.loadGroups(widget.categoryId);
      final groups = groupController.groups.toList();

      for (final g in groups) {
        final users = await userGroupController.getGroupUsers(g.id);
        for (final raterId in users) {
          for (final toRateId in users) {
            if (raterId == toRateId) continue;
            final ok = await assessmentController.createAssessment(
              activityId: activity.id!,
              rater: raterId,
              toRate: toRateId,
              timeWin: selectedTime,
              visibility: visibility,
            );
            if (!ok) {
              print(
                "❌ Failed to create assessment: activity=${activity.id}, rater=$raterId, toRate=$toRateId",
              );
            }
          }
        }
      }

      Get.snackbar(
        "¡Éxito!",
        "Actividad activada y assessments creados",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _deleteActivity(Activity activity) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Eliminar actividad"),
        content: Text("¿Deseas eliminar '${activity.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await controller.deleteActivity(activity.id!);
      if (success) {
        Get.snackbar(
          "¡Éxito!",
          "Actividad '${activity.name}' eliminada",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Widget _buildActionButtons(Activity activity) {
    if (isOwner.value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showEditDialog(activity),
          ),
          IconButton(
            icon: Icon(
              Icons.check_circle,
              color: activity.activated ? Colors.green : Colors.grey,
            ),
            onPressed: () => _activateActivity(activity),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteActivity(activity),
          ),
        ],
      );
    } else {
      return Icon(
        Icons.check_circle,
        color: activity.activated ? Colors.green : Colors.grey,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.activities.isEmpty) {
          return const Center(child: Text("No hay actividades creadas"));
        }

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
                trailing: _buildActionButtons(activity),
                onTap: () {
                  if (!isOwner.value && activity.activated) {
                    final currentUserId =
                        Get.find<AuthenticationController>().currentUser.value!.id!;
                    Get.to(
                      () => AssessmentListPage(
                        activityId: activity.id!,
                        currentUserId: currentUserId,
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: Obx(
        () => isOwner.value
            ? FloatingActionButton(
                onPressed: _showCreateDialog,
                child: const Icon(Icons.add),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
