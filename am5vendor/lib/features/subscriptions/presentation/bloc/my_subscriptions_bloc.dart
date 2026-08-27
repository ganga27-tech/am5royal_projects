import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_my_subscriptions_usecase.dart';
import 'my_subscriptions_event.dart';
import 'my_subscriptions_state.dart';

class MySubscriptionsBloc extends Bloc<MySubscriptionsEvent, MySubscriptionsState> {
  final GetMySubscriptionsUseCase getMySubscriptionsUseCase;

  MySubscriptionsBloc({required this.getMySubscriptionsUseCase}) : super(MySubscriptionsInitial()) {
    on<FetchMySubscriptionsEvent>((event, emit) async {
      emit(MySubscriptionsLoading());
      final result = await getMySubscriptionsUseCase(const NoParams());
      result.fold(
        (failure) => emit(MySubscriptionsError(failure.message)),
        (subscriptions) => emit(MySubscriptionsLoaded(subscriptions)),
      );
    });
  }
}
