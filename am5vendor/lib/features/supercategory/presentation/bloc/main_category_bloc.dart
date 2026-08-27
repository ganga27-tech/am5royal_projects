import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_main_categories_usecase.dart';
import 'main_category_event.dart';
import 'main_category_state.dart';

class MainCategoryBloc extends Bloc<GetMainCategoriesEvent, GetMainCategoriesState> {
  final GetMainCategoriesUseCase getMainCategoriesUseCase;

  MainCategoryBloc({required this.getMainCategoriesUseCase}) : super(const GetMainCategoriesInitial()) {
    on<FetchMainCategories>(_onFetchMainCategories);
  }

  Future<void> _onFetchMainCategories(
    FetchMainCategories event,
    Emitter<GetMainCategoriesState> emit,
  ) async {
    emit(const GetMainCategoriesLoading());
    final result = await getMainCategoriesUseCase();
    result.fold(
      (failure) => emit(GetMainCategoriesError(failure.message)),
      (categories) => emit(GetMainCategoriesSuccess(categories)),
    );
  }
}
