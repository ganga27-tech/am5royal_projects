import '../../domain/entities/main_category.dart';

abstract class GetMainCategoriesState {
  const GetMainCategoriesState();
}

class GetMainCategoriesInitial extends GetMainCategoriesState {
  const GetMainCategoriesInitial();
}

class GetMainCategoriesLoading extends GetMainCategoriesState {
  const GetMainCategoriesLoading();
}

class GetMainCategoriesSuccess extends GetMainCategoriesState {
  final List<MainCategory> categories;
  const GetMainCategoriesSuccess(this.categories);
}

class GetMainCategoriesError extends GetMainCategoriesState {
  final String message;
  const GetMainCategoriesError(this.message);
}
