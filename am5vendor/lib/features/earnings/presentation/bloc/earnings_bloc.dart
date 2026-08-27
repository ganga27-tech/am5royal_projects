import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_my_earnings_usecase.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final GetMyEarningsUseCase getMyEarningsUseCase;

  EarningsBloc({required this.getMyEarningsUseCase}) : super(EarningsInitial()) {
    on<FetchMyEarningsEvent>((event, emit) async {
      emit(EarningsLoading());
      final result = await getMyEarningsUseCase(const NoParams());
      result.fold(
        (failure) => emit(EarningsError(failure.message)),
        (earnings) => emit(EarningsLoaded(earnings)),
      );
    });
  }
}
