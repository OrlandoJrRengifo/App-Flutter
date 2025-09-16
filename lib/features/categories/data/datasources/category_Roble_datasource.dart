import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import 'i_category_local_datasource.dart';

class CategoryRobleDataSource implements ICategoryLocalDataSource {
  final http.Client httpClient;
  final String baseUrl =
      "https://roble-api.openlab.uninorte.edu.co/database_364931dc19";
      // cambiar por la que tira Roble

  CategoryRobleDataSource({http.Client? client})
      : httpClient = client ?? http.Client();

  @override
  Future<CategoryModel> create(CategoryModel category) async {
    // todo depende de como lo reciba roble, en todas las llamadas
    final response = await httpClient.post(
      Uri.parse("$baseUrl/categories"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toMap()),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CategoryModel.fromMap(data);
    } else {
      throw Exception("Error al crear categoría: ${response.body}");
    }
  }

  @override
  Future<void> delete(String id) async {
    final response =
        await httpClient.delete(Uri.parse("$baseUrl/categories/$id"));

    if (response.statusCode != 204) {
      throw Exception("Error al eliminar categoría: ${response.body}");
    }
  }

  @override
  Future<CategoryModel?> getById(String id) async {
    final response =
        await httpClient.get(Uri.parse("$baseUrl/categories/$id"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CategoryModel.fromMap(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception("Error al obtener categoría: ${response.body}");
    }
  }

  @override
  Future<List<CategoryModel>> listByCourse(String courseId) async {
    final response =
        await httpClient.get(Uri.parse("$baseUrl/courses/$courseId/categories"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((m) => CategoryModel.fromMap(m)).toList();
    } else {
      throw Exception("Error al listar categorías: ${response.body}");
    }
  }

  @override
  Future<CategoryModel> update(CategoryModel category) async {
    if (category.id == null) {
      throw Exception("Se requiere el id de la categoría para actualizar");
    }

    final response = await httpClient.put(
      Uri.parse("$baseUrl/categories/${category.id}"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toMap()),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CategoryModel.fromMap(data);
    } else {
      throw Exception("Error al actualizar categoría: ${response.body}");
    }
  }
}
