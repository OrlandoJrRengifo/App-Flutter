import '../models/category_model.dart';

abstract class ICategoryLocalDataSource {
  Future<CategoryModel> create(CategoryModel category);
  Future<CategoryModel?> getById(int id);
  Future<List<CategoryModel>> listByCourse(int courseId);
  Future<CategoryModel> update(CategoryModel category);
  Future<void> delete(int id);
}