import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'verify_otp_event.dart';
import 'verify_otp_state.dart';

class VerifyOtpBloc extends Bloc<VerifyOtpEvent, VerifyOtpState> {
  final VerifyOtpUseCase verifyOtpUseCase;

  VerifyOtpBloc({required this.verifyOtpUseCase}) : super(const VerifyOtpState.initial()) {
    on<SubmitVerifyOtp>(_onSubmitVerifyOtp);
  }

  Future<void> _onSubmitVerifyOtp(SubmitVerifyOtp event, Emitter<VerifyOtpState> emit) async {
    emit(const VerifyOtpState.loading());
    final result = await verifyOtpUseCase(VerifyOtpParams(
      contact: event.contact,
      otp: event.otp,
    ));
    result.fold(
      (failure) => emit(VerifyOtpState.error(failure.message)),
      (response) => emit(VerifyOtpState.success(response)),
    );
  }
}
