import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Category> create(Category category);
  Future<Category?> getById(int id);
  Future<List<Category>> listByCourse(int courseId);
  Future<Category> update(Category category);
  Future<void> delete(int id);
}
