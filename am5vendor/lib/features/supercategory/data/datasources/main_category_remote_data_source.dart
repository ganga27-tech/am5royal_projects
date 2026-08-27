import '../models/main_category_model.dart';
import '../models/subcategory_model.dart';
import 'main_category_api_service.dart';

abstract class MainCategoryRemoteDataSource {
  Future<List<MainCategoryModel>> getMainCategories();
  Future<List<SubCategoryModel>> getSubCategories(int categoryId);
}

class MainCategoryRemoteDataSourceImpl implements MainCategoryRemoteDataSource {
  final MainCategoryApiService apiService;

  MainCategoryRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<MainCategoryModel>> getMainCategories() async {
    return await apiService.getMainCategories();
  }

  @override
  Future<List<SubCategoryModel>> getSubCategories(int categoryId) async {
    return await apiService.getSubCategories(categoryId);
  }
}
