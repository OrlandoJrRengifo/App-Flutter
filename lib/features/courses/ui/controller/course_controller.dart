import 'package:get/get.dart';
import '../../domain/entities/course.dart';
import '../../domain/usecases/course_usecases.dart';
import '../../../auth/ui/controller/auth_controller.dart';

class CoursesController extends GetxController {
  final CourseUseCases useCases;
  late final AuthenticationController _authController;

  CoursesController({required this.useCases}) {
    _authController = Get.find<AuthenticationController>();
  }

  final RxList<Course> courses = <Course>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Se ejecuta cada vez que cambia el usuario logueado
    ever(_authController.currentUser, (user) {
      if (user != null) {
        loadTeacherCourses(); // Cargar cursos automáticamente
      } else {
        courses.clear(); // Limpiar lista si no hay usuario
      }
    });

    // Cargar cursos si ya hay usuario logueado al iniciar
    if (_authController.currentUser.value != null) {
      loadTeacherCourses();
    }
  }

  /// Carga los cursos dictados por usuario logueado
  Future<void> loadTeacherCourses() async {
    final user = _authController.currentUser.value;
    if (user == null) {
      error.value = "Usuario no logueado";
      return;
    }

    try {
      loading.value = true;
      error.value = '';

      final result = await useCases.listCoursesByTeacher(user.id!);
      courses.assignAll(result);

      print(
        "✅ Cursos cargados para el usuario ${user.name}: ${courses.map((c) => c.name).toList()}",
      );
    } catch (e) {
      error.value = e.toString();
      print("❌ Error al cargar cursos: $e");
    } finally {
      loading.value = false;
    }
  }

  Future<List<Course>> loadCoursesByIds(List<String> courseIds) async {
    try {
      loading.value = true;
      error.value = '';

      final List<Course> result = [];
      for (final id in courseIds) {
        final course = await useCases.getCourse(id);
        if (course != null) {
          result.add(course);
        }
      }

      return result;
    } catch (e) {
      error.value = e.toString();
      print("❌ Error al cargar cursos por IDs: $e");
      return [];
    } finally {
      loading.value = false;
    }
  }

  Future<void> addCourse({
    required String name,
    required String code,
    required int maxStudents,
    DateTime? createdAt,
  }) async {
    final userId = _authController.currentUser.value?.id;
    if (userId == null) {
      error.value = "Usuario no logueado";
      return;
    }

    try {
      loading.value = true;
      error.value = '';

      final newCourse = await useCases.createCourse(
        name: name,
        code: code,
        teacherId: userId,
        maxStudents: maxStudents,
        createdAt: createdAt,
      );

      print("➕ Creado curso: ${newCourse.name} | maxStudents=${newCourse.maxStudents}");

      courses.add(newCourse);
      print("✅ Curso agregado: ${newCourse.name}");
    } catch (e) {
      error.value = e.toString();
      print("❌ Error al agregar curso: $e");
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateCourseInList(Course course) async {
    try {
      loading.value = true;
      error.value = '';

      final updated = await useCases.updateCourse(course);
      final index = courses.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        courses[index] = updated;
      }

      print("✅ Curso actualizado: ${updated.name}");
    } catch (e) {
      error.value = e.toString();
      print("❌ Error al actualizar curso: $e");
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteCourseFromList(String id) async {
    print("Curso ID en funcion: $id");
    if (id.isEmpty) {
      error.value = "ID de curso inválido";
      return;
    }

    try {
      loading.value = true;
      error.value = '';

      await useCases.deleteCourse(id);
      courses.removeWhere((c) => c.id == id);

      print("✅ Curso eliminado con id=$id");
    } catch (e) {
      error.value = e.toString();
      print("❌ Error al eliminar curso: $e");
    } finally {
      loading.value = false;
    }
  }

  Future<bool> canCreateMore() async {
    final userId = _authController.currentUser.value?.id;
    print(_authController.currentUser.value?.id);
    if (userId == null) return false;

    try {
      return await useCases.canCreateMore(userId);
    } catch (e) {
      print("❌ Error al verificar si puede crear más cursos: $e");
      return false;
    }
  }

  Future<String?> getCourseIdByCode(String code) async {
    try {
      loading.value = true;
      error.value = '';

      final course = await useCases.getCourseByCode(code);

      if (course != null) {
        print("✅ Curso encontrado por code=$code → id=${course.id}");
        return course.id;
      } else {
        print("⚠️ No se encontró curso con code=$code");
        return null;
      }
    } catch (e) {
      error.value = e.toString();
      print("❌ Error al buscar curso por code=$code → $e");
      return null;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> isOwnerOfCourse(String courseId) async {
    final user = _authController.currentUser.value;
    if (user == null) return false;

    final exists = courses.any(
      (c) => c.id == courseId && c.teacherId == user.id,
    );
    if (exists) return true;

    final course = await useCases.getCourse(courseId);
    return course?.teacherId == user.id;
  }

  Future<bool> canJoinCourse(String courseId) async {
  final user = _authController.currentUser.value;
  if (user == null) return false;

  final course = await useCases.getCourse(courseId);
  if (course == null) return false;

  // ❌ Si el usuario es dueño (teacher_id == user.id) → no puede inscribirse
  return course.teacherId != user.id;
}

}
