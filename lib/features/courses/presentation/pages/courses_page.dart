import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../domain/entities/course.dart';
import '../widgets/course_form_dialog.dart';
import '../controller/course_controller.dart';
import '../../../RegToCourse/presentation/controller/user_course_controller.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import '../../../auth/presentation/pages/login_page.dart';
import 'courseDetail_page.dart';

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
  String? copiedCode;
  final RxList<Course> _enrolledCourses = <Course>[].obs;
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
      // Cargar cursos que enseña
      await courseController.loadTeacherCourses();

      // 🔹 Aquí asumimos que el controlador de auth ya tiene el userId
      final auth = Get.find<AuthenticationController>();
      final userId = auth.currentUser.value?.id;
      if (userId != null) {
        // Cargar IDs de cursos inscritos
        print("entro a initstate userId: $userId");
        await userCourseController.fetchUserCourses(userId);

        // 🔹 Ahora traemos los cursos completos con esos IDs
        final enrolled = await courseController.loadCoursesByIds(
          userCourseController.userCourses,
        );

        // Guardamos los cursos inscritos en un observable local
        _enrolledCourses.assignAll(enrolled);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _generateInviteCode(Course course) {
    // Generar código de invitación basado en el código del curso
    return course.code;
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    setState(() {
      copiedCode = code;
    });

    Get.snackbar(
      "Código copiado",
      code,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green[100],
      colorText: Colors.green[800],
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          copiedCode = null;
        });
      }
    });
  }

  void _showJoinCourseDialog() {
    final codeController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Unirse al Curso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa el código de invitación proporcionado por tu profesor.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Código de Invitación',
                hintText: 'ej. WEB401-2024',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final enteredCode = codeController.text.trim();

              if (enteredCode.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Debes ingresar un código válido",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                );
                return;
              }

              // 1️⃣ Buscar el ID del curso por código
              final courseId = await courseController.getCourseIdByCode(
                enteredCode,
              );

              if (courseId == null) {
                Get.snackbar(
                  "No encontrado",
                  "No existe un curso con ese código",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                );
                return;
              }

              // 2️⃣ Obtener usuario actual
              final auth = Get.find<AuthenticationController>();
              final userId = auth.currentUser.value?.id;

              if (userId == null) {
                Get.snackbar(
                  "Error",
                  "Debes iniciar sesión para unirte",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                );
                return;
              }

              try {
                // 3️⃣ Inscribir usuario en el curso
                print("entro a meter el usuario: $userId en curso: $courseId");
                await userCourseController.enrollUser(userId, courseId);

                // 4️⃣ Refrescar cursos inscritos
                await userCourseController.fetchUserCourses(userId);
                final enrolled = await courseController.loadCoursesByIds(
                  userCourseController.userCourses,
                );
                _enrolledCourses.assignAll(enrolled);

                Get.back();
                Get.snackbar(
                  "¡Éxito!",
                  "Te has inscrito en el curso",
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
            },
            child: const Text('Unirse al Curso'),
          ),
        ],
      ),
    );
  }

  Future<void> _createCourse() async {
    final canCreate = await courseController.canCreateMore();
    if (!canCreate) {
      Get.snackbar(
        "Límite alcanzado",
        "No puedes crear más de 3 cursos",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[800],
      );
      return;
    }

    final result = await Get.dialog<Course>(CourseFormDialog());

    if (result != null) {
      try {
        await courseController.addCourse(
          name: result.name,
          code: result.code,
          maxStudents: result.maxStudents,
        );

        Get.snackbar(
          "¡Éxito!",
          "Curso '${result.name}' creado correctamente",
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
  }

  Future<void> _editCourse(Course course) async {
    final result = await Get.dialog<Course>(CourseFormDialog(course: course));

    if (result != null) {
      try {
        await courseController.updateCourseInList(result);

        Get.snackbar(
          "¡Éxito!",
          "Curso '${result.name}' actualizado correctamente",
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
  }

  Future<void> _deleteCourse(Course course) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Eliminar curso"),
        content: Text(
          "¿Seguro que deseas eliminar '${course.name}'?\n\n"
          "Esta acción también eliminará todas las categorías asociadas.",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await courseController.deleteCourseFromList(course.id ?? "");

      Get.snackbar(
        "Curso eliminado",
        "El curso '${course.name}' ha sido eliminado",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Proyecto Flutter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Home',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              final auth = Get.find<AuthenticationController>();
              auth.logOut();

              // 🔹 Redirige al Login limpiando navegación previa
              Get.offAll(() => const LoginPage());
            },
            icon: const Icon(Icons.logout, size: 16, color: Colors.red),
            label: const Text(
              'Salir',
              style: TextStyle(color: Colors.red),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
          ),

          const SizedBox(width: 16),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Mis Cursos'), // 👨‍🏫 Profesor
            Obx(
              () => Tab(
                // 👨‍🎓 Alumno
                text: 'Inscrito (${_enrolledCourses.length})',
              ),
            ),
          ],
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTeachingTab(), _buildEnrolledTab()],
      ),
    );
  }

  Widget _buildTeachingTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Cursos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Obx(
                () => ElevatedButton.icon(
                  onPressed: courseController.courses.length >= 3
                      ? null
                      : _createCourse,
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Curso'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (courseController.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (courseController.error.isNotEmpty) {
                return _buildErrorState();
              }

              if (courseController.courses.isEmpty) {
                return _buildEmptyTeachingState();
              }

              return _buildCoursesGrid();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrolledTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cursos Inscritos (${_enrolledCourses.length})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _showJoinCourseDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Unirse al Curso'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (_enrolledCourses.isEmpty) {
                return _buildEmptyStudentState();
              }

              return _buildEnrolledCoursesGrid();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrolledCoursesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 600) crossAxisCount = 2;
        if (constraints.maxWidth > 900) crossAxisCount = 3;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: _enrolledCourses.length,
          itemBuilder: (context, index) {
            return _buildCourseCard(_enrolledCourses[index]);
          },
        );
      },
    );
  }

  Widget _buildCoursesGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }
        if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: courseController.courses.length,
          itemBuilder: (context, index) {
            return _buildCourseCard(courseController.courses[index]);
          },
        );
      },
    );
  }

  Widget _buildCourseCard(Course course) {
    final inviteCode = _generateInviteCode(course);
    final formattedDate = course.createdAt != null
        ? "${course.createdAt!.day}/${course.createdAt!.month}/${course.createdAt!.year}"
        : "Sin fecha";

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Get.to(
            () =>
                CourseDetailPage(courseId: course.id ?? "", courseName: course.name),
            transition: Transition.rightToLeft,
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y menú
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            course.code,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                        onTap: () => Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _editCourse(course),
                        ),
                      ),
                      PopupMenuItem(
                        child: const Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                        onTap: () => Future.delayed(
                          const Duration(milliseconds: 100),
                          () => _deleteCourse(course),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Información adicional del curso
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cupos máximos:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${course.maxStudents}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Creado:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Estadísticas simuladas
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '0', //  Implementar conteo real de estudiantes de un curso
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600],
                          ),
                        ),
                        const Text(
                          'Estudiantes',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '0', // Implementar conteo real de categorias de un curso
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[600],
                          ),
                        ),
                        const Text(
                          'Categorias',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '0', // Implementar conteo real de actividades de un curso
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple[600],
                          ),
                        ),
                        const Text(
                          'Actividades',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Codigo de invitacion
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.share, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        inviteCode,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _copyInviteCode(inviteCode),
                      icon: Icon(
                        copiedCode == inviteCode ? Icons.check : Icons.copy,
                        size: 16,
                        color: copiedCode == inviteCode
                            ? Colors.green
                            : Colors.grey,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text("Error: ${courseController.error}"),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => courseController.loadTeacherCourses(),
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTeachingState() {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.book, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Aún no tienes cursos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crea tu primer curso para comenzar a gestionar actividades colaborativas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _createCourse,
                icon: const Icon(Icons.add),
                label: const Text('Crear tu Primer Curso'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStudentState() {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.group, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No estás inscrito en cursos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pide a tu profesor un código de invitación para unirte a un curso.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _showJoinCourseDialog,
                icon: const Icon(Icons.person_add),
                label: const Text('Unirse al Curso'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
