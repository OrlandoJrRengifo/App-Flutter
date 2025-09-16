import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import '../../../RegToCourse/presentation/controller/user_course_controller.dart';

class StudentslistPage extends StatefulWidget {
  final int courseId;

  const StudentslistPage({
    super.key,
    required this.courseId,
  });

  @override
  State<StudentslistPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<StudentslistPage> {
  final userCourseController = Get.find<UserCourseController>();
  final authController = Get.find<AuthenticationController>();

  final RxBool loading = false.obs;
  final RxList<Map<String, dynamic>> students = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      loading.value = true;

      // 🔹 1. Traemos los IDs de los estudiantes inscritos
      await userCourseController.fetchCourseUsers(widget.courseId);
      final ids = userCourseController.courseUsers.toList();

      // 🔹 2. Obtenemos la info básica de cada usuario
      final basicUsers = await authController.getUsers(ids);

      students.assignAll(basicUsers);
    } catch (e) {
      print("❌ Error cargando estudiantes: $e");
    } finally {
      loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (loading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (students.isEmpty) {
        return const Center(child: Text("No hay estudiantes inscritos"));
      }

      return ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return ListTile(
            leading: CircleAvatar(child: Text(student['name'][0])),
            title: Text(student['name']),
            subtitle: Text("ID: ${student['id']}"),
          );
        },
      );
    });
  }
}
