import 'package:get/get.dart';
import '../domain/entities/category.dart';
import '../domain/usecases/category_usecases.dart';


class CategoriesController extends GetxController {
  final CategoryUseCases useCases;
  
  CategoriesController({required this.useCases});
  
  final RxList<Category> categories = <Category>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;
  
  Future<void> loadCategories(int courseId) async {
    try {
      loading.value = true;
      error.value = '';
      
      final result = await useCases.listCategories(courseId);
      categories.assignAll(result);
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> addCategory({
    required int courseId,
    required String name,
    required GroupingMethod groupingMethod,
    required int maxMembers,
  }) async {
    try {
      loading.value = true;
      error.value = '';
      
      final newCategory = await useCases.createCategory(
        courseId: courseId,
        name: name,
        groupingMethod: groupingMethod,
        maxMembers: maxMembers,
      );
      
      categories.add(newCategory);
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> updateCategoryInList(Category category) async {
    try {
      loading.value = true;
      error.value = '';
      
      final updated = await useCases.updateCategory(category);
      final index = categories.indexWhere((c) => c.id == updated.id);
      
      if (index != -1) {
        categories[index] = updated;
      }
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
  
  Future<void> deleteCategoryFromList(int? id) async {
    if (id == null) return;
    
    try {
      loading.value = true;
      error.value = '';
      
      await useCases.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
