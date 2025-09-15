import 'package:get/get.dart';
import '../../domain/usecases/user_course_usecase.dart';

class UserCourseController extends GetxController {
  final UserCourseUseCase useCase;

  UserCourseController(this.useCase);

  final RxList<int> userCourses = <int>[].obs;
  final RxList<int> courseUsers = <int>[].obs;

  Future<void> enrollUser(int userId, int courseId) async {
    await useCase.enrollUser(userId, courseId);
  }

  Future<void> fetchUserCourses(int userId) async {
    final courses = await useCase.getUserCourses(userId);
    userCourses.assignAll(courses);
  }

  Future<void> fetchCourseUsers(int courseId) async {
    final users = await useCase.getCourseUsers(courseId);
    courseUsers.assignAll(users);
  }
}
