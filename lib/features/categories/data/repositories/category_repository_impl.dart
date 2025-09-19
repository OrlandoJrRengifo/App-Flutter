import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/i_category_Roble_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final ICategoryRobleDataSource robleDataSource;
  
  CategoryRepositoryImpl(this.robleDataSource);

  @override
  Future<Category> create(Category category) async {
    final model = CategoryModel(
      id: category.id,
      courseId: category.courseId,
      name: category.name,
      groupingMethod: category.groupingMethod,
      maxGroupSize: category.maxGroupSize,
      createdAt: category.createdAt,
    );
    
    final savedModel = await robleDataSource.create(model);
    return savedModel;
  }

  @override
  Future<void> delete(String id) => robleDataSource.delete(id);

  @override
  Future<Category?> getById(String id) async {
    final model = await robleDataSource.getById(id);
    return model;
  }

  @override
  Future<List<Category>> listByCourse(String courseId) async {
    final models = await robleDataSource.listByCourse(courseId);
    return models;
  }

  @override
  Future<Category> update(Category category) async {
    print("entro a update datasource repository: ${category.id}");
    final model = CategoryModel(
      id: category.id,
      courseId: category.courseId,
      name: category.name,
      groupingMethod: category.groupingMethod,
      maxGroupSize: category.maxGroupSize,
      createdAt: category.createdAt,
    );
    
    final updatedModel = await robleDataSource.update(model);
    return updatedModel;
  }
}