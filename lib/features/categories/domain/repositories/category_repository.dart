import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Category> create(Category category);
  Future<Category?> getById(String id);
  Future<List<Category>> listByCourse(String courseId);
  Future<Category> update(Category category);
  Future<void> delete(String id);
}
