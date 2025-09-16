import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/app_database.dart';

// Categorias
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/categories/domain/usecases/category_usecases.dart';
import 'features/categories/data/datasources/i_category_local_datasource.dart';
import 'features/categories/data/datasources/category_local_datasource_sqflite.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/controllers/categories_controller.dart';
// Cursos
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/usecases/course_usecases.dart';
import 'features/courses/data/datasources/i_course_local_datasource.dart';
import 'features/courses/data/datasources/course_local_datasource_sqflite.dart';
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/presentation/controller/course_controller.dart'; 
// Inscripciones
import 'features/RegToCourse/domain/repositories/i_user_course_repository.dart';
import 'features/RegToCourse/domain/usecases/user_course_usecase.dart';
import 'features/RegToCourse/data/datasources/i_user_course_source.dart';
import 'features/RegToCourse/data/datasources/user_course_sqflite_source.dart';
import 'features/RegToCourse/data/repositories/user_course_repository.dart';
import 'features/RegToCourse/presentation/controller/user_course_controller.dart';
// ==================== Autenticación ====================
import 'features/auth/data/datasources/auth_sqflite_source.dart';
import 'features/auth/data/datasources/i_auth_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecase.dart';
import 'features/auth/presentation/controller/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance;

  // ==================== Autenticación ====================
  // Registrar primero todo lo relacionado con auth
  Get.put<IAuthenticationSource>(AuthSqfliteSource(), permanent: true);
  Get.put(AuthRepository(Get.find<IAuthenticationSource>()), permanent: true);
  Get.put(AuthenticationUseCase(Get.find<AuthRepository>()), permanent: true);
  Get.put(AuthenticationController(Get.find<AuthenticationUseCase>()), permanent: true);

  // Ahora que AuthenticationController existe, se puede registrar CoursesController
  

  // ==================== Categorías ====================
  Get.lazyPut<ICategoryLocalDataSource>(() => CategoryLocalDataSourceSqflite(), fenix: true);
  Get.lazyPut<CategoryRepository>(() => CategoryRepositoryImpl(Get.find()), fenix: true);
  Get.lazyPut(() => CategoryUseCases(Get.find()), fenix: true);
  Get.put(CategoriesController(useCases: Get.find()), permanent: true);

  // ==================== Cursos ====================
  Get.lazyPut<ICourseLocalDataSource>(() => CourseLocalDataSourceSqflite(), fenix: true);
  Get.lazyPut<ICourseRepository>(() => CourseRepository(Get.find()), fenix: true);
  Get.lazyPut(() => CourseUseCases(Get.find()), fenix: true);
  Get.put(CoursesController(useCases: Get.find()), permanent: true);

  // ==================== Inscripciones ====================
  Get.lazyPut<IUserCourseSource>(() => UserCourseSqfliteSource(), fenix: true);
  Get.lazyPut<IUserCourseRepository>(() => UserCourseRepository(Get.find()), fenix: true);
  Get.lazyPut(() => UserCourseUseCase(Get.find()), fenix: true);
  Get.put(UserCourseController(Get.find()), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sistema de Cursos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}
