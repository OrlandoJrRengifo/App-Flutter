import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../core/i_local_preferences.dart';
import 'i_activity_source.dart';
import '../../domain/entities/activity.dart';

class ActivityRobleDataSource implements IActivityDataSource {
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/database_364931dc19";

  ActivityRobleDataSource({http.Client? client})
      : httpClient = client ?? http.Client();

  Future<String?> _getToken() async {
    final ILocalPreferences prefs = Get.find();
    return prefs.retrieveData<String>('token');
  }

  @override
  Future<Activity?> createActivity(String categoryId, String name) async {
    final token = await _getToken();
    if (token == null) {
      print("Token nulo: no se puede crear actividad");
      return null;
    }

    final body = {
      "tableName": "activities",
      "records": [
        {"category_id": categoryId, "name": name, "activated": false}
      ],
    };

    final res = await httpClient.post(
      Uri.parse("$baseUrl/insert"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if ((data["inserted"] as List).isNotEmpty) {
        return Activity.fromMap(data["inserted"][0]);
      } else if ((data["skipped"] as List).isNotEmpty) {
        print("Actividad omitida: ${data["skipped"]}");
      }
    } else {
      print("Error creando actividad: ${res.statusCode}, ${res.body}");
    }

    return null;
  }

  @override
  Future<List<Activity>> getActivitiesByCategory(String categoryId) async {
    final token = await _getToken();
    if (token == null) return [];

    final uri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {
        "tableName": "activities",
        "category_id": categoryId,
      },
    );

    final res = await httpClient.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((e) => Activity.fromMap(e)).toList();
    } else {
      print("Error obteniendo actividades: ${res.statusCode}, ${res.body}");
    }

    return [];
  }

  @override
  Future<bool> activateActivity(String activityId) async {
    final token = await _getToken();
    if (token == null) return false;

    final body = {
      "tableName": "activities",
      "idColumn": "_id",
      "idValue": activityId,
      "updates": {"activated": true}
    };

    final res = await httpClient.put(
      Uri.parse("$baseUrl/update"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      print("Error activando actividad: ${res.statusCode}, ${res.body}");
    }

    return res.statusCode == 200;
  }

  @override
  Future<bool> updateActivityName(String activityId, String newName) async {
    final token = await _getToken();
    if (token == null) return false;

    final body = {
      "tableName": "activities",
      "idColumn": "_id",
      "idValue": activityId,
      "updates": {"name": newName}
    };

    final res = await httpClient.put(
      Uri.parse("$baseUrl/update"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      print("Error actualizando nombre: ${res.statusCode}, ${res.body}");
    }

    return res.statusCode == 200;
  }

  @override
  Future<bool> deleteActivity(String activityId) async {
    final token = await _getToken();
    if (token == null) return false;

    final body = {
      "tableName": "activities",
      "idColumn": "_id",
      "idValue": activityId,
    };

    final res = await httpClient.delete(
      Uri.parse("$baseUrl/delete"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: jsonEncode(body),
    );

    return res.statusCode == 200;
  }
}
