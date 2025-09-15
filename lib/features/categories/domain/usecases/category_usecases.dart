import 'dart:math';
import '../entities/category.dart';
import '../repositories/category_repository.dart';

class CategoryUseCases {
  final CategoryRepository repository;
  
  CategoryUseCases(this.repository);

  Future<Category> createCategory({
    required int courseId,
    required String name,
    required GroupingMethod groupingMethod,
    required int maxMembers,
  }) async {
    return repository.create(
      Category(
        courseId: courseId,
        name: name,
        groupingMethod: groupingMethod,
        maxGroupSize: maxMembers,
      ),
    );
  }

  Future<void> deleteCategory(int id) => repository.delete(id);
  
  Future<Category?> getCategory(int id) => repository.getById(id);
  
  Future<List<Category>> listCategories(int courseId) => repository.listByCourse(courseId);
  
  Future<Category> updateCategory(Category category) => repository.update(category);

  Future<List<List<int>>> formRandomGroups(
    int categoryId,
    List<int> students,
  ) async {
    final cat = await repository.getById(categoryId);
    if (cat == null) return [];

    final rng = Random();
    final shuffled = List<int>.from(students)..shuffle(rng);
    final groups = <List<int>>[];
    final int max = cat.maxGroupSize ?? 1;

    int i = 0;
    while (i < shuffled.length) {
      final end = (i + max).clamp(0, shuffled.length);
      groups.add(shuffled.sublist(i, end));
      i = end;
    }

    return groups;
  }
}