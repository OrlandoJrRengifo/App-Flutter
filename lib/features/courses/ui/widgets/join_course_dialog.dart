import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../controller/course_controller.dart';
import '../../../user_courses/ui/controller/user_course_controller.dart';
import '../../domain/entities/course.dart';

class JoinCourseDialog extends StatelessWidget {
  final void Function(List<Course>) onJoinSuccess;

  const JoinCourseDialog({super.key, required this.onJoinSuccess});

  @override
  Widget build(BuildContext context) {
    final codeController = TextEditingController();
    final courseController = Get.find<CoursesController>();
    final userCourseController = Get.find<UserCourseController>();
    final auth = Get.find<AuthenticationController>();

    return AlertDialog(
      title: const Text("Unirse al Curso"),
      content: TextField(
        controller: codeController,
        decoration: const InputDecoration(labelText: "Código"),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancelar")),
        ElevatedButton(
          onPressed: () async {
            final code = codeController.text.trim();
            if (code.isEmpty) {
              Get.snackbar(
                "Código requerido",
                "Debes ingresar un código de curso",
              );
              return;
            }

            final courseId = await courseController.getCourseIdByCode(code);

            if (courseId != null && auth.currentUser.value?.id != null) {
              final userId = auth.currentUser.value!.id!;

              // 🚫 Validar que el usuario no sea el creador del curso
              final isOwner = await courseController.isOwnerOfCourse(courseId);
              if (isOwner) {
                Get.snackbar(
                  "Acceso denegado",
                  "No puedes inscribirte a tu propio curso",
                );
                return;
              }
              final alreadyEnrolled = await userCourseController.isUserInCourse(
                userId,
                courseId,
              );

              if (alreadyEnrolled) {
                Get.snackbar(
                  "Acceso denegado",
                  "Ya estás inscrito en este curso",
                );
                return;
              }

              final success = await userCourseController.enrollUser(
                userId,
                courseId,
              );
              if (success) {
                await userCourseController.fetchUserCourses(userId);
                final enrolled = await courseController.loadCoursesByIds(
                  userCourseController.userCourses,
                );
                onJoinSuccess(enrolled);
                Get.back();
                Get.snackbar(
                  "¡Éxito!",
                  "Te has inscrito al curso correctamente",
                );
              } else {
                Get.snackbar("Error", "Ya no quedan cupos para este curso");
              }
            } else {
              Get.snackbar("Error", "Código inválido o sesión no válida");
            }
          },
          child: const Text("Unirse"),
        ),
      ],
    );
  }
}
