import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/main_category_api_service.dart';
import '../../data/datasources/main_category_remote_data_source.dart';
import '../../data/repositories/main_category_repository_impl.dart';
import '../../domain/repositories/main_category_repository.dart';
import '../../domain/usecases/get_main_categories_usecase.dart';
import '../../domain/usecases/get_subcategories_usecase.dart';
import '../bloc/main_category_bloc.dart';
import '../bloc/main_category_event.dart';
import '../bloc/subcategory_bloc.dart';

// Provide Api Service
final mainCategoryApiServiceProvider = Provider<MainCategoryApiService>((ref) {
  return MainCategoryApiService(ref.watch(dioProvider));
});

// Provide Remote Data Source
final mainCategoryRemoteDataSourceProvider = Provider<MainCategoryRemoteDataSource>((ref) {
  return MainCategoryRemoteDataSourceImpl(
    apiService: ref.watch(mainCategoryApiServiceProvider),
  );
});

// Provide Repository
final mainCategoryRepositoryProvider = Provider<MainCategoryRepository>((ref) {
  return MainCategoryRepositoryImpl(
    remoteDataSource: ref.watch(mainCategoryRemoteDataSourceProvider),
  );
});

// Provide Use Cases
final getMainCategoriesUseCaseProvider = Provider<GetMainCategoriesUseCase>((ref) {
  return GetMainCategoriesUseCase(ref.watch(mainCategoryRepositoryProvider));
});

final getSubCategoriesUseCaseProvider = Provider<GetSubCategoriesUseCase>((ref) {
  return GetSubCategoriesUseCase(ref.watch(mainCategoryRepositoryProvider));
});

// Provide BLoCs
final mainCategoryBlocProvider = Provider.autoDispose<MainCategoryBloc>((ref) {
  final bloc = MainCategoryBloc(
    getMainCategoriesUseCase: ref.watch(getMainCategoriesUseCaseProvider),
  );
  bloc.add(const FetchMainCategories());
  ref.onDispose(() => bloc.close());
  return bloc;
});

final subCategoryBlocProvider = Provider.autoDispose<SubCategoryBloc>((ref) {
  final bloc = SubCategoryBloc(
    getSubCategoriesUseCase: ref.watch(getSubCategoriesUseCaseProvider),
  );
  ref.onDispose(() => bloc.close());
  return bloc;
});
