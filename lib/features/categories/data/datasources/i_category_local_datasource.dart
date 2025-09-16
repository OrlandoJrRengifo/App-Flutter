import '../models/category_model.dart';

abstract class ICategoryLocalDataSource {
  Future<CategoryModel> create(CategoryModel category);
  Future<CategoryModel?> getById(String id);
  Future<List<CategoryModel>> listByCourse(String courseId);
  Future<CategoryModel> update(CategoryModel category);
  Future<void> delete(String id);
}