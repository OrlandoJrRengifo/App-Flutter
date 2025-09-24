import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import '../../../../core/i_local_preferences.dart';
import 'i_user_course_roble_datasource.dart';
import '../../../courses/data/datasources/course_roble_datasource.dart';

class UserCourseRobleDataSource implements IUserCourseRobleDataSource {
  final http.Client httpClient;

  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/database_364931dc19";

  UserCourseRobleDataSource({http.Client? client})
    : httpClient = client ?? http.Client();
  final courseDs = CourseRobleDataSource();

  @override
  Future<bool> enrollUser(String userId, String courseId) async {
    // 1. Verificar cupos
    final availableSlots = await courseDs.getAvailableSlots(courseId);
    if (availableSlots <= 0) {
      logInfo("❌ No hay cupos disponibles en el curso $courseId");
      return false;
    }

    final body = {
      "tableName": "user_courses",
      "records": [
        {"user_id": userId, "course_id": courseId},
      ],
    };

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.post(
      Uri.parse("$baseUrl/insert"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      return false;
    }
    return true;
  }

  @override
  Future<List<String>> getUserCourses(String userId) async {
    print("entro a getusercouse userId: $userId");
    final uri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {"tableName": "user_courses", "user_id": userId},
    );

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    logInfo("📡 GetUserCourses → status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => e["course_id"] as String).toList();
    }
    return [];
  }

  @override
  Future<List<String>> getCourseUsers(String courseId) async {
    final uri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {"tableName": "user_courses", "course_id": courseId},
    );

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    logInfo("📡 GetCourseUsers → status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => e["user_id"] as String).toList();
    }
    return [];
  }

  Future<bool> isUserInCourse(String userId, String courseId) async {
    final ILocalPreferences prefs = Get.find();
    final token = await prefs.retrieveData<String>('token');

    final uri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {
        "tableName": "user_courses",
        "user_id": userId,
        "course_id": courseId,
      },
    );

    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("❌ Error al verificar inscripción: ${response.body}");
    }

    final data = jsonDecode(response.body) as List;
    return data.isNotEmpty; // true si ya está inscrito
  }
}
