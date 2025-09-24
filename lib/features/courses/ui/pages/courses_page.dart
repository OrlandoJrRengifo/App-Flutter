import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/course.dart';
import '../controller/course_controller.dart';
import '../../../user_courses/ui/controller/user_course_controller.dart';
import '../../../auth/ui/controller/auth_controller.dart';
import '../../../auth/ui/pages/login_page.dart';
import '../widgets/course_card.dart';
import '../widgets/empty_teaching_state.dart';
import '../widgets/empty_student_state.dart';
import '../widgets/error_state.dart';
import '../widgets/join_course_dialog.dart';
import '../widgets/course_form_dialog.dart';

class CourseDashboard extends StatefulWidget {
  const CourseDashboard({super.key});

  @override
  State<CourseDashboard> createState() => _CourseDashboardState();
}

class _CourseDashboardState extends State<CourseDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final CoursesController courseController;
  late final UserCourseController userCourseController;
  final RxList<Course> _enrolledCourses = <Course>[].obs;
  String? copiedCode;
  String userRole = "teacher";

  @override
  void initState() {
    super.initState();
    courseController = Get.find<CoursesController>();
    userCourseController = Get.find<UserCourseController>();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: userRole == "teacher" ? 0 : 1,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await courseController.loadTeacherCourses();
      final auth = Get.find<AuthenticationController>();
      final userId = auth.currentUser.value?.id;
      if (userId != null) {
        await userCourseController.fetchUserCourses(userId);
        final enrolled = await courseController.loadCoursesByIds(
          userCourseController.userCourses,
        );
        _enrolledCourses.assignAll(enrolled);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createCourse() async {
    if (!await courseController.canCreateMore()) {
      Get.snackbar("Límite alcanzado", "No puedes crear más de 3 cursos");
      return;
    }
    final result = await Get.dialog<Course>(CourseFormDialog());
    if (result != null) {
      await courseController.addCourse(
        name: result.name,
        code: result.code,
        maxStudents: result.maxStudents,
        createdAt:  DateTime.now(),
      );
      Get.snackbar("¡Éxito!", "Curso '${result.name}' creado correctamente");
    }
  }

  Future<void> _editCourse(Course course) async {
    final result = await Get.dialog<Course>(CourseFormDialog(course: course));
    if (result != null) {
      await courseController.updateCourseInList(result);
      Get.snackbar("¡Éxito!", "Curso '${result.name}' actualizado");
    }
  }

  Future<void> _deleteCourse(Course course) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Eliminar curso"),
        content: Text("¿Seguro que deseas eliminar '${course.name}'?"),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Get.back(result: true), child: const Text("Eliminar")),
        ],
      ),
    );
    if (confirm == true) {
      await courseController.deleteCourseFromList(course.id ?? "");
      Get.snackbar("Curso eliminado", "Se eliminó '${course.name}'");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTeachingTab(), _buildEnrolledTab()],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
        title: const Text("JC academy"),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              final auth = Get.find<AuthenticationController>();
              auth.logOut();
              Get.offAll(() => const LoginPage());
            },
            icon: const Icon(Icons.logout, size: 16, color: Colors.red),
            label: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Mis Cursos'),
            Obx(() => Tab(text: 'Cursos Inscritos (${_enrolledCourses.length})')),
          ],
        ),
      );

  Widget _buildTeachingTab() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Mis Cursos', style: TextStyle(fontSize: 20)),
                Obx(() => ElevatedButton.icon(
                      onPressed: courseController.courses.length >= 3
                          ? null
                          : _createCourse,
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Curso'),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (courseController.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (courseController.error.isNotEmpty) {
                  return ErrorState(onRetry: () => courseController.loadTeacherCourses());
                }
                if (courseController.courses.isEmpty) {
                  return EmptyTeachingState(onCreateCourse: _createCourse);
                }
                return ListView.builder(
                  itemCount: courseController.courses.length,
                  itemBuilder: (context, index) => CourseCard(
                    course: courseController.courses[index],
                    onEdit: _editCourse,
                    onDelete: _deleteCourse,
                  ),
                  
                );
              }),
            ),
          ],
        ),
      );

  Widget _buildEnrolledTab() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text('Cursos Inscritos (${_enrolledCourses.length})')),
                OutlinedButton.icon(
                  onPressed: () => Get.dialog(JoinCourseDialog(
                    onJoinSuccess: (courses) => _enrolledCourses.assignAll(courses),
                  )),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Unirse al Curso'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (_enrolledCourses.isEmpty) {
                  return EmptyStudentState();
                }
                return ListView.builder(
                  itemCount: _enrolledCourses.length,
                  itemBuilder: (context, index) => CourseCard(course: _enrolledCourses[index]),
                );
              }),
            ),
          ],
        ),
      );
}
