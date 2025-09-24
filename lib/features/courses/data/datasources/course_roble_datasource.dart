import 'dart:convert';
import 'package:get/get.dart';
import '../../../../core/i_local_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';

import '../models/course_model.dart';
import 'i_course_roble_datasource.dart';

class CourseRobleDataSource implements ICourseRobleDataSource {
  final http.Client httpClient;

  // Url de Roble
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/database/database_364931dc19';

  CourseRobleDataSource({http.Client? client})
    : httpClient = client ?? http.Client();

  @override
  Future<CourseModel> create(CourseModel course) async {
    print(
      "Creando curso: ${course.name}, Teacher ID: ${course.teacherId}, Max Students: ${course.maxStudents}",
    );
    final body = {
      "tableName": "courses",
      "records": [
        {
          "name": course.name,
          "code": course.code,
          "teacher_id": course.teacherId,
          "created_at": course.createdAt?.toIso8601String(),
          "max_students": course.maxStudents,
        },
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
    //print("Respuesta: ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final inserted = (data['inserted'] as List).first;
      return CourseModel.fromMap(inserted);
    } else {
      throw Exception("❌ Error creando curso: ${response.body}");
    }
  }

  @override
  Future<CourseModel?> getById(String id) async {
    print(  "Obteniendo curso por ID: $id");
    final uri = Uri.parse(
      "$baseUrl/read",
    ).replace(queryParameters: {"tableName": "courses", "_id": id});

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        return CourseModel.fromMap(data.first);
      }
    }
    return null;
  }

  @override
  Future<List<CourseModel>> listByTeacher(String teacherId) async {
    final uri = Uri.parse("$baseUrl/read").replace(
      queryParameters: {"tableName": "courses", "teacher_id": teacherId},
    );

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    logInfo("📡 ListByTeacher → status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((m) => CourseModel.fromMap(m)).toList();
    }
    return [];
  }

  @override
  Future<CourseModel> update(CourseModel course) async {
    
    if (course.id == null) {
      throw Exception("❌ Se requiere ID para actualizar");
    }

    final body = {
      "tableName": "courses",
      "idColumn": "_id",
      "idValue": course.id,
      "updates": {
        "name": course.name,
        "code": course.code,
        "teacher_id": course.teacherId,
        "max_students": course.maxStudents,
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

    logInfo("📡 Update curso → status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CourseModel.fromMap(data);
    } else {
      throw Exception("❌ Error actualizando curso: ${response.body}");
    }
  }

  /// Cuenta cursos por profesor (teacher_id) → usamos query y length
  @override
  Future<int> countByTeacher(String teacherId) async {
    final uri = Uri.parse('$baseUrl/read').replace(
      queryParameters: {'tableName': 'courses', 'teacher_id': teacherId},
    );
    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');
    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      logInfo("✅ Cursos encontrados: ${data.length}");
      return data.length;
    } else {
      throw Exception("❌ Error contando cursos: ${response.body}");
    }
  }

  /// Elimina curso por ID usando `/delete`
  @override
  Future<void> delete(String id) async {
    final body = {"tableName": "courses", "idColumn": "_id", "idValue": id};
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

    logInfo("📡 Eliminar curso → status: ${response.statusCode}");
    if (response.statusCode != 200) {
      throw Exception("❌ Error eliminando curso: course ${response.body}");
    }
  }

  @override
  Future<CourseModel?> getByCode(String code) async {
    final uri = Uri.parse(
      "$baseUrl/read",
    ).replace(queryParameters: {"tableName": "courses", "code": code});

    final ILocalPreferences sharedPreferences = Get.find();
    final token = await sharedPreferences.retrieveData<String>('token');

    final response = await httpClient.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    logInfo("📡 GetByCode → status: ${response.statusCode}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        logInfo("📌 Curso encontrado por code=$code → ${data.first}");
        return CourseModel.fromMap(data.first);
      } else {
        logWarning("⚠️ No se encontró curso con code=$code");
      }
    } else {
      logError("❌ Error en GetByCode: ${response.body}");
    }
    return null;
  }
}
