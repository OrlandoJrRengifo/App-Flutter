import 'dart:convert';
import 'package:get/get.dart';
import '../../../../core/i_local_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import '../models/category_model.dart';
import 'i_category_local_datasource.dart';
import '../../domain/entities/category.dart';

class CategoryRobleDataSource implements ICategoryLocalDataSource {
  final http.Client httpClient;
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/database/database_364931dc19';

  CategoryRobleDataSource({http.Client? client})
      : httpClient = client ?? http.Client();

  @override
  Future<CategoryModel> create(CategoryModel category) async {
    final body = {
      "tableName": "categories",
      "records": [
        {
          "course_id": category.courseId,
          "name": category.name,
          "grouping_method": category.groupingMethod == GroupingMethod.random
              ? "random"
              : "self_assigned",
          "max_group_size": category.maxGroupSize,
          "created_at": category.createdAt?.toIso8601String(),
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final inserted = (data['inserted'] as List).first;
      return CategoryModel.fromMap(inserted);
    } else {
      throw Exception("❌ Error al crear categoría: ${response.body}");
    }
  }

  @override
  Future<CategoryModel?> getById(String id) async {
    final uri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {"tableName": "categories", "_id": id},
    );

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        return CategoryModel.fromMap(data.first);
      }
    }
    return null;
  }

  @override
  Future<List<CategoryModel>> listByCourse(String courseId) async {
    final uri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {"tableName": "categories", "course_id": courseId},
    );

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    logInfo("📡 ListByCourse categorías → status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((m) => CategoryModel.fromMap(m)).toList();
    } else {
      throw Exception("❌ Error listando categorías: ${response.body}");
    }
  }

  @override
  Future<CategoryModel> update(CategoryModel category) async {
    if (category.id == null) {
      throw Exception("❌ Se requiere ID para actualizar categoría");
    }

    final body = {
      "tableName": "categories",
      "idColumn": "_id",
      "idValue": category.id,
      "updates": {
        "course_id": category.courseId,
        "name": category.name,
        "grouping_method": category.groupingMethod == GroupingMethod.random
            ? "random"
            : "self_assigned",
        "max_group_size": category.maxGroupSize,
      },
    };

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.put(
      Uri.parse("$baseUrl/update"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CategoryModel.fromMap(data);
    } else {
      throw Exception("❌ Error al actualizar categoría: ${response.body}");
    }
  }

  @override
  Future<void> delete(String id) async {
    final body = {
      "tableName": "categories",
      "idColumn": "_id",
      "idValue": id,
    };

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.delete(
      Uri.parse("$baseUrl/delete"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    logInfo("📡 Eliminar categoría → status: ${response.statusCode}");
    if (response.statusCode != 200) {
      throw Exception("❌ Error al eliminar categoría: ${response.body}");
    }
  }
}
