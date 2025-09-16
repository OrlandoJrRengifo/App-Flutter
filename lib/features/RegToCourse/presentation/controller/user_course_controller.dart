import 'package:get/get.dart';
import '../../domain/usecases/user_course_usecase.dart';

class UserCourseController extends GetxController {
  final UserCourseUseCase useCase;

  UserCourseController(this.useCase);

  final RxList<String> userCourses = <String>[].obs;
  final RxList<String> courseUsers = <String>[].obs;

  Future<void> enrollUser(String userId, String courseId) async {
    await useCase.enrollUser(userId, courseId);
  }

  Future<void> fetchUserCourses(String userId) async {
    final courses = await useCase.getUserCourses(userId);
    userCourses.assignAll(courses);
  }

  Future<void> fetchCourseUsers(String courseId) async {
    final users = await useCase.getCourseUsers(courseId);
    courseUsers.assignAll(users);
  }
}
