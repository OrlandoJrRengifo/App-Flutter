import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../../../../../core/i_local_preferences.dart';
import '../../domain/entities/group.dart';
import 'i_group_source.dart';

class GroupRobleSource implements IGroupSource {
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database/database_364931dc19";

  GroupRobleSource({http.Client? client})
      : httpClient = client ?? http.Client();

  Future<String?> _getToken() async {
    try {
      final ILocalPreferences prefs = Get.find();
      return await prefs.retrieveData<String>('token');
    } catch (e) {
      print("❌ GroupRobleSource: no pude obtener token: $e");
      return null;
    }
  }

  Group _fromMapFlexible(Map<String, dynamic> m) {
    final id = (m['_id'] ?? m['id'] ?? m['Id'] ?? m['ID'])?.toString() ?? '';
    final categoryId =
        (m['category_id'] ?? m['categoryId'] ?? m['category'])?.toString() ?? '';
    final numerationRaw = m['numeration'] ?? m['number'] ?? 0;
    final capacityRaw = m['capacity'] ?? m['capacidad'] ?? m['max_size'] ?? 0;

    final numeration = numerationRaw is int
        ? numerationRaw
        : int.tryParse(numerationRaw.toString()) ?? 0;
    final capacity = capacityRaw is int
        ? capacityRaw
        : int.tryParse(capacityRaw.toString()) ?? 0;

    return Group(
      id: id,
      categoryId: categoryId,
      numeration: numeration,
      capacity: capacity,
    );
  }

  @override
  Future<List<Group>> getGroupsByCategory(String categoryId) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse("$baseUrl/read").replace(
        queryParameters: {"tableName": "groups", "category_id": categoryId},
      );

      final response = await httpClient.get(
        uri,
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("👉 getGroupsByCategory: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map((e) => _fromMapFlexible(Map<String, dynamic>.from(e)))
              .toList();
        }
      } else {
        print("❌ Error getGroupsByCategory: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Exception getGroupsByCategory: $e");
    }
    return [];
  }

  @override
  Future<Group?> createGroup(Group group) async {
    try {
      final token = await _getToken();

      final body = {
        "tableName": "groups",
        "records": [
          {
            "category_id": group.categoryId,
            "numeration": group.numeration,
            "capacity": group.capacity,
          }
        ]
      };

      print("👉 Creando group: ${jsonEncode(body)}");

      final response = await httpClient.post(
        Uri.parse("$baseUrl/insert"),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("👉 Respuesta createGroup: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data is Map &&
            data['inserted'] is List &&
            data['inserted'].isNotEmpty) {
          return _fromMapFlexible(
              Map<String, dynamic>.from(data['inserted'][0]));
        }
      } else {
        print("❌ createGroup error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Exception createGroup: $e");
    }

    return null;
  }

  @override
  Future<Group?> updateGroupCapacity(String groupId, int capacity) async {
    try {
      final token = await _getToken();

      final body = {
        "tableName": "groups",
        "idColumn": "_id",
        "idValue": groupId,
        "updates": {"capacity": capacity}
      };

      print("👉 updateGroupCapacity body: ${jsonEncode(body)}");

      final response = await httpClient.put(
        Uri.parse("$baseUrl/update"),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("👉 Respuesta updateGroupCapacity: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map && data.isNotEmpty) {
          return _fromMapFlexible(Map<String, dynamic>.from(data));
        }
      } else {
        print("❌ updateGroupCapacity error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Exception updateGroupCapacity: $e");
    }
    return null;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      final token = await _getToken();

      final body = {
        "tableName": "groups",
        "idColumn": "_id",
        "idValue": groupId,
      };

      final response = await httpClient.delete(
        Uri.parse("$baseUrl/delete"),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      print("👉 deleteGroup: ${response.statusCode} ${response.body}");
      if (response.statusCode != 200) {
        throw Exception("❌ Error al eliminar grupo: ${response.body}");
      }
    } catch (e) {
      print("❌ Exception deleteGroup: $e");
      rethrow;
    }
  }
}
