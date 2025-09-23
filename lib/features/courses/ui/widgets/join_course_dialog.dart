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
      content: TextField(controller: codeController, decoration: const InputDecoration(labelText: "Código")),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancelar")),
        ElevatedButton(
          onPressed: () async {
            final code = codeController.text.trim();
            final courseId = await courseController.getCourseIdByCode(code);
            if (courseId != null && auth.currentUser.value?.id != null) {
              final success = await userCourseController.enrollUser(auth.currentUser.value!.id!, courseId);
              if (success) {
                await userCourseController.fetchUserCourses(auth.currentUser.value!.id!);
                final enrolled = await courseController.loadCoursesByIds(userCourseController.userCourses);
                onJoinSuccess(enrolled);
                Get.back();
              }
            }
          },
          child: const Text("Unirse"),
        ),
      ],
    );
  }
}
