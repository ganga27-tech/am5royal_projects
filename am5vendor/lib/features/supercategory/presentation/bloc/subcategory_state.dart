import '../../domain/entities/subcategory_entity.dart';

abstract class SubCategoryState {
  const SubCategoryState();
}

class SubCategoryInitial extends SubCategoryState {
  const SubCategoryInitial();
}

class SubCategoryLoading extends SubCategoryState {
  const SubCategoryLoading();
}

class SubCategorySuccess extends SubCategoryState {
  final List<SubCategoryEntity> subcategories;
  const SubCategorySuccess(this.subcategories);
}

class SubCategoryEmpty extends SubCategoryState {
  const SubCategoryEmpty();
}

class SubCategoryError extends SubCategoryState {
  final String message;
  const SubCategoryError(this.message);
}
