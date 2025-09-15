import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import '../controller/user_course_controller.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/usecases/course_usecases.dart';


class UserCoursesPage extends StatelessWidget {
  const UserCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthenticationController>();
    final userCourseController = Get.find<UserCourseController>();
    final courseUseCases = Get.find<CourseUseCases>();

    // Cargar cursos del usuario al abrir la página
    if (authController.currentUser.value != null) {
      userCourseController
          .fetchUserCourses(authController.currentUser.value!.id!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Cursos")),
      body: Obx(() {
        final courseIds = userCourseController.userCourses;
        if (courseIds.isEmpty) {
          return const Center(child: Text("No estás inscrito en ningún curso"));
        }

        return FutureBuilder<List<Course>>(
          future: Future.wait(
            courseIds.map((id) async {
              final c = await courseUseCases.getCourse(id);
              if (c == null) return Course(id: id, name: "Desconocido", code: "-", maxStudents: 0, teacherId: 0); 
              return c;
              }),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No se encontraron cursos"));
            }

            final courses = snapshot.data!;
            return ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  title: Text(course.name),
                  subtitle: Text("Código: ${course.code}"),
                  trailing: Text("0/${course.maxStudents}"),
                );
              },
            );
          },
        );
      }),
    );
  }
}
// Nota: Asegúrate de que los controladores y casos de uso estén correctamente inyectados en GetX