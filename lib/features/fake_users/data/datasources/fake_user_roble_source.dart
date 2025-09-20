import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:get/get.dart';
import '../../../../../core/i_local_preferences.dart';
import '../../domain/entities/fake_user.dart';
import 'i_fake_user_source.dart';

class FakeUserRobleSource implements IFakeUserSource {
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/database_364931dc19";

  FakeUserRobleSource({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<FakeUser?> getUserByAuthId(String authId) async {
    try {
      final ILocalPreferences prefs = Get.find();
      final token = await prefs.retrieveData<String>('token');

      final uri = Uri.parse("$baseUrl/read").replace(
        queryParameters: {"tableName": "fake_users", "auth_id": authId},
      );

      final response = await httpClient.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return FakeUser.fromJson(data[0]);
        }
      } else {
        logError("❌ getUserByAuthId error: ${response.body}");
      }
    } catch (e) {
      logError("❌ Exception in getUserByAuthId: $e");
    }
    return null;
  }

  @override
  Future<FakeUser?> createUser(FakeUser user) async {
    try {
      final ILocalPreferences prefs = Get.find();
      final token = await prefs.retrieveData<String>('token');

      final response = await httpClient.post(
        Uri.parse("$baseUrl/insert"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "tableName": "fake_users",
          "records": [user.toJson()],
        }),
      );

      print("👉 Creando FakeUser con: ${user.toJson()}");
      print("👉 Respuesta Roble: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["inserted"] != null && data["inserted"].isNotEmpty) {
          return FakeUser.fromJson(data["inserted"][0]);
        } else {
          print("❌ No se insertó ningún FakeUser: $data");
        }
      } else {
        print("❌ createUser error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Exception in createUser: $e");
    }
    return null;
  }

  @override
  Future<List<FakeUser>> getUsersByIds(List<String> authIds) async {
    try {
      final ILocalPreferences prefs = Get.find();
      final token = await prefs.retrieveData<String>('token');

      print("📡 DataSource.getUsersByIds con authIds: $authIds, token: $token");

      List<FakeUser> result = [];

      for (final authId in authIds) {
        final uri = Uri.parse("$baseUrl/read").replace(
          queryParameters: {
            "tableName": "fake_users",
            "auth_id": authId, // 👈 ahora buscamos por auth_id
          },
        );

        final response = await httpClient.get(
          uri,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        );

        print("📡 Respuesta Roble.read auth_id=$authId: ${response.body}");

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          final users = data.map((e) => FakeUser.fromJson(e)).toList();
          result.addAll(users);
        } else {
          print("❌ Error HTTP ${response.statusCode} - ${response.body}");
        }
      }

      print("✅ getUsersByIds devolvió: ${result.length} usuarios");
      return result;
    } catch (e) {
      print("❌ Exception en DataSource.getUsersByIds: $e");
    }
    return [];
  }

  @override
  Future<List<FakeUser>> getAllUsers() async {
    try {
      final ILocalPreferences prefs = Get.find();
      final token = await prefs.retrieveData<String>('token');

      final response = await httpClient.post(
        Uri.parse("$baseUrl/find"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"tableName": "fake_users"}),
      );

      print("👉 getAllUsers response: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => FakeUser.fromJson(e)).toList();
      }
    } catch (e) {
      print("❌ Exception in getAllUsers: $e");
    }
    return [];
  }
}
