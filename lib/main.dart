import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ==================== Categorías ====================
import 'features/categories/domain/repositories/category_repository.dart';
import 'features/categories/domain/usecases/category_usecases.dart';
import 'features/categories/data/datasources/i_category_Roble_datasource.dart';
import 'features/categories/data/datasources/category_Roble_datasource.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/ui/controller/categories_controller.dart';

// ==================== Cursos ====================
import 'features/courses/domain/repositories/i_course_repository.dart';
import 'features/courses/domain/usecases/course_usecases.dart';
import 'features/courses/data/datasources/i_course_roble_datasource.dart';
import 'features/courses/data/datasources/course_roble_datasource.dart';
import 'features/courses/data/repositories/course_repository.dart';
import 'features/courses/ui/controller/course_controller.dart';

// ==================== Inscripciones ====================
import 'features/user_courses/domain/repositories/i_user_course_repository.dart';
import 'features/user_courses/domain/usecases/user_course_usecase.dart';
import 'features/user_courses/data/datasources/i_user_course_roble_datasource.dart';
import 'features/user_courses/data/datasources/user_course_roble_datasource.dart';
import 'features/user_courses/data/repositories/user_course_repository.dart';
import 'features/user_courses/ui/controller/user_course_controller.dart';

// ==================== Autenticación ====================
import 'features/auth/data/datasources/auth_roble_datasource.dart';
import 'features/auth/data/datasources/i_auth_source.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_usecase.dart';
import 'features/auth/ui/controller/auth_controller.dart';
import 'features/auth/ui/pages/login_page.dart';

// ==================== FakeUser ====================
import 'features/fake_users/data/datasources/fake_user_roble_source.dart';
import 'features/fake_users/data/datasources/i_fake_user_source.dart';
import 'features/fake_users/data/repositories/fake_user_repository.dart';
import 'features/fake_users/domain/repositories/i_fake_user_repository.dart';
import 'features/fake_users/domain/usecases/fake_user_usecase.dart';
import 'features/fake_users/ui/controller/fake_user_controller.dart';

// ==================== Grupos ====================
import 'features/groups/data/datasources/group_roble_source.dart';
import 'features/groups/data/datasources/i_group_source.dart';
import 'features/groups/domain/repositories/i_group_repository.dart';
import 'features/groups/data/repositories/group_repository.dart';
import 'features/groups/domain/usecases/group_usecase.dart';
import 'features/groups/ui/controller/group_controller.dart';

// ==================== User Groups ====================
import 'features/user_groups/data/datasources/user_group_roble_source.dart';
import 'features/user_groups/data/datasources/i_user_group_source.dart';
import 'features/user_groups/data/repositories/user_group_repository.dart';
import 'features/user_groups/domain/repositories/i_user_group_repository.dart';
import 'features/user_groups/domain/usecases/user_group_usecase.dart';
import 'features/user_groups/ui/controller/user_group_controller.dart';

import 'core/i_local_preferences.dart';
import 'core/local_preferences_shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // implementación SharedPreferences para el token
  Get.put<ILocalPreferences>(LocalPreferencesShared(), permanent: true);

  // ==================== Autenticación ====================
  Get.put<IAuthenticationSource>(AuthRobleSource(), permanent: true);
  Get.put(AuthRepository(Get.find<IAuthenticationSource>()), permanent: true);
  Get.put(AuthenticationUseCase(Get.find<AuthRepository>()), permanent: true);
  Get.put(AuthenticationController(Get.find<AuthenticationUseCase>()),permanent: true,);

  // ==================== FakeUser ====================
  Get.put<IFakeUserSource>(FakeUserRobleSource(), permanent: true);
  Get.put<IFakeUserRepository>(FakeUserRepository(Get.find<IFakeUserSource>()),permanent: true,);
  Get.put(FakeUserUseCase(Get.find<IFakeUserRepository>()), permanent: true);
  Get.put(FakeUserController(Get.find<FakeUserUseCase>()), permanent: true);

  // ==================== Categorías ====================
  Get.lazyPut<ICategoryRobleDataSource>(() => CategoryRobleDataSource(),fenix: true,);
  Get.lazyPut<CategoryRepository>(() => CategoryRepositoryImpl(Get.find()),fenix: true,);
  Get.lazyPut(() => CategoryUseCases(Get.find()), fenix: true);
  Get.put(CategoriesController(useCases: Get.find()), permanent: true);

  // ==================== Cursos ====================
  Get.lazyPut<ICourseRobleDataSource>(() => CourseRobleDataSource(),fenix: true,);
  Get.lazyPut<ICourseRepository>(() => CourseRepository(Get.find()),fenix: true,);
  Get.lazyPut(() => CourseUseCases(Get.find()), fenix: true);
  Get.put(CoursesController(useCases: Get.find()), permanent: true);

  // ==================== Inscripciones ====================
  Get.lazyPut<IUserCourseRobleDataSource>(() => UserCourseRobleDataSource(),fenix: true,);
  Get.lazyPut<IUserCourseRepository>(() => UserCourseRepository(Get.find()),fenix: true,);
  Get.lazyPut(() => UserCourseUseCase(Get.find()), fenix: true);
  Get.put(UserCourseController(Get.find()), permanent: true);

  // ==================== Grupos ====================
  Get.put<IGroupSource>(GroupRobleSource(), permanent: true);
  Get.put<IGroupRepository>(GroupRepository(Get.find()), permanent: true);
  Get.put(GroupUseCase(Get.find()), permanent: true);  
  Get.put(GroupController(Get.find()), permanent: true);

  // ==================== User Groups ====================
  Get.put<IUserGroupDataSource>(UserGroupRobleDataSource(), permanent: true);
  Get.put<IUserGroupRepository>(UserGroupRepository(Get.find()), permanent: true);
  Get.put(UserGroupUseCase(Get.find()), permanent: true);
  Get.put(UserGroupController(Get.find()), permanent: true);

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
