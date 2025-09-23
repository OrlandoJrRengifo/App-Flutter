import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import '../../../../core/i_local_preferences.dart';
import 'i_user_group_source.dart';

class UserGroupRobleDataSource implements IUserGroupDataSource {
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/database_364931dc19";

  UserGroupRobleDataSource({http.Client? client})
      : httpClient = client ?? http.Client();

  @override
  Future<bool> joinGroup(String userId, String groupId) async {
    final body = {
      "tableName": "user_groups",
      "records": [
        {"user_id": userId, "group_id": groupId},
      ],
    };

    final ILocalPreferences prefs = Get.find();
    final token = await prefs.retrieveData<String>('token');

    final response = await httpClient.post(
      Uri.parse("$baseUrl/insert"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    logInfo("📡 JoinGroup → ${response.statusCode} ${response.body}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> leaveGroup(String userId, String groupId) async {
    final ILocalPreferences prefs = Get.find();
    final token = await prefs.retrieveData<String>('token');

    // 1️⃣ Buscar el registro user_groups que tenga user_id + group_id
    final queryUri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {
        "tableName": "user_groups",
        "user_id": userId,
        "group_id": groupId,
      },
    );

    final findResponse = await httpClient.get(
      queryUri,
      headers: {"Authorization": "Bearer $token"},
    );

    logInfo("🔎 find user_group → ${findResponse.statusCode} ${findResponse.body}");

    if (findResponse.statusCode != 200) {
      logError("❌ Error buscando user_group: ${findResponse.statusCode}");
      return false;
    }

    final List data = jsonDecode(findResponse.body) as List;
    if (data.isEmpty) {
      logInfo("⚠️ No se encontró relación user=$userId con group=$groupId");
      return false;
    }

    // Extraer id del registro (soporta _id / id / ID)
    final record = data.first as Map<String, dynamic>;
    final recordId = record["_id"] ?? record["id"] ?? record["ID"];
    if (recordId == null) {
      logError("❌ No se encontró _id en el registro user_groups: $record");
      return false;
    }

    final deleteBody = {
      "tableName": "user_groups",
      "idColumn": "_id",
      "idValue": recordId,
    };

    final deleteResponse = await httpClient.delete(
      Uri.parse("$baseUrl/delete"),
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(deleteBody),
    );

    logInfo("🗑️ LeaveGroup DELETE → ${deleteResponse.statusCode} ${deleteResponse.body}");
    return deleteResponse.statusCode == 200;
  }

  @override
  Future<List<String>> getGroupUsers(String groupId) async {
    final uri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {"tableName": "user_groups", "group_id": groupId},
    );

    final ILocalPreferences prefs = Get.find();
    final token = await prefs.retrieveData<String>('token');

    final response = await httpClient.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );

    logInfo("📡 GetGroupUsers → ${response.statusCode} ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => e["user_id"] as String).toList();
    }
    return [];
  }

  @override
Future<String?> getUserGroupInCategory(String userId, String categoryId) async {
  final ILocalPreferences prefs = Get.find();
  final token = await prefs.retrieveData<String>('token');

  // 1) Traer todos los user_groups del usuario
  final userGroupsUri = Uri.parse("$baseUrl/read").replace(
    queryParameters: {
      "tableName": "user_groups",
      "user_id": userId,
    },
  );

  final ugRes = await httpClient.get(
    userGroupsUri,
    headers: {"Authorization": "Bearer $token"},
  );

  logInfo("📡 getUserGroupInCategory.user_groups → ${ugRes.statusCode} ${ugRes.body}");
  if (ugRes.statusCode != 200) return null;

  final ugList = jsonDecode(ugRes.body) as List;
  if (ugList.isEmpty) return null;

  // 2) Iterar cada group_id y revisar categoría
  for (final ug in ugList) {
    final gid = ug["group_id"];
    if (gid == null) continue;

    final groupUri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {
        "tableName": "groups",
        "_id": gid.toString(),
      },
    );

    final gRes = await httpClient.get(
      groupUri,
      headers: {"Authorization": "Bearer $token"},
    );

    if (gRes.statusCode != 200) continue;

    final gList = jsonDecode(gRes.body) as List;
    if (gList.isEmpty) continue;

    final group = gList.first as Map<String, dynamic>;
    if (group["category_id"].toString() == categoryId) {
      // ✅ Usuario ya está en un grupo de esa categoría
      return gid.toString();
    }
  }

  return null;
}

}
