import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import '../../../../core/i_local_preferences.dart';
import 'i_user_course_roble_datasource.dart';

class UserCourseRobleDataSource implements IUserCourseRobleDataSource {
  final http.Client httpClient;

  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/database_364931dc19";

  UserCourseRobleDataSource({http.Client? client})
      : httpClient = client ?? http.Client();

  @override
  Future<bool> enrollUser(String userId, String courseId) async {
    final body = {
      "tableName": "user_courses",
      "records": [
        {
          "user_id": userId,
          "course_id": courseId,
        }
      ]
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
      queryParameters: {
        "tableName": "user_courses",
        "user_id": userId,
      },
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
      queryParameters: {
        "tableName": "user_courses",
        "course_id": courseId,
      },
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
}
