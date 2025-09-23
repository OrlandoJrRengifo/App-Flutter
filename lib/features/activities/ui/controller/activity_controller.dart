import 'package:get/get.dart';
import '../../domain/entities/activity.dart';
import '../../domain/usecases/activity_usecase.dart';

class ActivityController extends GetxController {
  final ActivityUseCase useCase;

  ActivityController(this.useCase);

  final RxList<Activity> activities = <Activity>[].obs;
  final RxBool loading = false.obs;

  Future<void> loadActivities(String categoryId) async {
    loading.value = true;
    try {
      final result = await useCase.getActivitiesByCategory(categoryId);
      activities.assignAll(result);
    } finally {
      loading.value = false;
    }
  }

  Future<void> createActivity(String categoryId, String name) async {
    final activity = await useCase.createActivity(categoryId, name);
    if (activity != null) {
      activities.add(activity);
    } else {
      Get.snackbar(
        "Error",
        "No se pudo crear la actividad. Revisa la consola.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> activateActivity(String activityId) async {
    final success = await useCase.activateActivity(activityId);
    if (success) {
      final index = activities.indexWhere((a) => a.id == activityId);
      if (index != -1) activities[index].activated = true;
      activities.refresh();
    }
    return success;
  }

  Future<bool> updateActivityName(String activityId, String newName) async {
    final success = await useCase.updateActivityName(activityId, newName);
    if (success) {
      final index = activities.indexWhere((a) => a.id == activityId);
      if (index != -1) activities[index].name = newName;
      activities.refresh();
    }
    return success;
  }

  Future<bool> deleteActivity(String activityId) async {
    final success = await useCase.deleteActivity(activityId);
    if (success) {
      activities.removeWhere((a) => a.id == activityId);
    }
    return success;
  }
}
