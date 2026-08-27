abstract class SubCategoryEvent {
  const SubCategoryEvent();
}

class FetchSubCategories extends SubCategoryEvent {
  final int categoryId;
  const FetchSubCategories(this.categoryId);
}
