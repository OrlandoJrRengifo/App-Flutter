import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/i_category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final ICategoryLocalDataSource localDataSource;
  
  CategoryRepositoryImpl(this.localDataSource);

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
    
    final savedModel = await localDataSource.create(model);
    return savedModel;
  }

  @override
  Future<void> delete(int id) => localDataSource.delete(id);

  @override
  Future<Category?> getById(int id) async {
    final model = await localDataSource.getById(id);
    return model;
  }

  @override
  Future<List<Category>> listByCourse(int courseId) async {
    final models = await localDataSource.listByCourse(courseId);
    return models;
  }

  @override
  Future<Category> update(Category category) async {
    final model = CategoryModel(
      id: category.id,
      courseId: category.courseId,
      name: category.name,
      groupingMethod: category.groupingMethod,
      maxGroupSize: category.maxGroupSize,
      createdAt: category.createdAt,
    );
    
    final updatedModel = await localDataSource.update(model);
    return updatedModel;
  }
}