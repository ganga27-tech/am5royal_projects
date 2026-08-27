import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_wallet_details_usecase.dart';
import '../../domain/usecases/topup_wallet_usecase.dart';
import '../../domain/usecases/verify_topup_usecase.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletDetailsUseCase getWalletDetailsUseCase;
  final TopUpWalletUseCase topUpWalletUseCase;
  final VerifyTopupUseCase verifyTopupUseCase;

  WalletBloc({
    required this.getWalletDetailsUseCase,
    required this.topUpWalletUseCase,
    required this.verifyTopupUseCase,
  }) : super(WalletInitial()) {
    on<FetchWalletDetailsEvent>((event, emit) async {
      emit(WalletLoading());
      final result = await getWalletDetailsUseCase(NoParams());
      result.fold(
        (failure) => emit(WalletError(message: _mapFailureToMessage(failure))),
        (details) => emit(WalletLoaded(walletDetails: details)),
      );
    });

    on<TopupWalletEvent>((event, emit) async {
      emit(WalletLoading());
      final result = await topUpWalletUseCase(TopupWalletParams(amount: event.amount));
      result.fold(
        (failure) => emit(WalletError(message: _mapFailureToMessage(failure))),
        (response) => emit(WalletTopupInitiated(topupResponse: response)),
      );
    });

    on<VerifyTopupEvent>((event, emit) async {
      emit(WalletLoading());
      final result = await verifyTopupUseCase(VerifyTopupParams(
        paymentId: event.paymentId,
        orderId: event.orderId,
        signature: event.signature,
        amount: event.amount,
      ));
      result.fold(
        (failure) => emit(WalletError(message: _mapFailureToMessage(failure))),
        (newBalance) => emit(WalletTopupSuccess(newBalance: newBalance)),
      );
    });
  }

  String _mapFailureToMessage(dynamic failure) {
    return 'An unexpected error occurred'; // Handle proper failure mapping
  }
}
