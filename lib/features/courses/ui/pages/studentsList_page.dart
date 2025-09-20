import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../reg_to_course/ui/controller/user_course_controller.dart';
import '../../../fake_users/ui/controller/fake_user_controller.dart';

class StudentslistPage extends StatefulWidget {
  final String courseId;

  const StudentslistPage({
    super.key,
    required this.courseId,
  });

  @override
  State<StudentslistPage> createState() => _StudentslistPageState();
}

class _StudentslistPageState extends State<StudentslistPage> {
  final userCourseController = Get.find<UserCourseController>();
  final fakeUserController = Get.find<FakeUserController>();

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

    // 1. Traemos los IDs de los estudiantes inscritos
    await userCourseController.fetchCourseUsers(widget.courseId);
    final ids = userCourseController.courseUsers.toList();

    print("🟢 IDs de estudiantes inscritos: $ids");

    if (ids.isEmpty) {
      print("⚠️ No hay estudiantes inscritos en el curso ${widget.courseId}");
      students.clear();
      return;
    }

    // 2. Obtenemos los usuarios desde FakeUserController
    final fetchedUsers = await fakeUserController.getUsersByIds(ids);
    print("🟢 Usuarios traídos por IDs ($ids): $fetchedUsers");

    // 3. Mapearlos a Map<String, dynamic> para mostrarlos en la lista
    final mapped = fetchedUsers.map((u) => {
          "id": u.id,
          "name": u.name,
          "email": u.email,
        }).toList();

    print("🟢 Mapeados para UI: $mapped");

    students.assignAll(mapped);
  } catch (e) {
    print("❌ Error en _loadStudents: $e");
    _showError("❌ Error cargando estudiantes: $e");
  } finally {
    loading.value = false;
  }
}


  void _showError(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
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
            leading: CircleAvatar(
              child: Text(student['name']?.isNotEmpty == true
                  ? student['name'][0].toUpperCase()
                  : "?"),
            ),
            title: Text(student['name'] ?? "Sin nombre"),
            subtitle: Text(student['email'] ?? "Sin correo"),
          );
        },
      );
    });
  }
}
