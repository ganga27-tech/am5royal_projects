import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_subcategories_usecase.dart';
import 'subcategory_event.dart';
import 'subcategory_state.dart';

class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  final GetSubCategoriesUseCase getSubCategoriesUseCase;

  SubCategoryBloc({required this.getSubCategoriesUseCase}) : super(const SubCategoryInitial()) {
    on<FetchSubCategories>(_onFetchSubCategories);
  }

  Future<void> _onFetchSubCategories(
    FetchSubCategories event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(const SubCategoryLoading());
    final result = await getSubCategoriesUseCase(event.categoryId);
    result.fold(
      (failure) => emit(SubCategoryError(failure.message)),
      (subcategories) {
        if (subcategories.isEmpty) {
          emit(const SubCategoryEmpty());
        } else {
          emit(SubCategorySuccess(subcategories));
        }
      },
    );
  }
}
