import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import 'send_otp_event.dart';
import 'send_otp_state.dart';

class SendOtpBloc extends Bloc<SendOtpEvent, SendOtpState> {
  final SendOtpUseCase sendOtpUseCase;

  SendOtpBloc({required this.sendOtpUseCase}) : super(const SendOtpState.initial()) {
    on<Submit>(_onSubmit);
  }

  Future<void> _onSubmit(Submit event, Emitter<SendOtpState> emit) async {
    emit(const SendOtpState.loading());
    final result = await sendOtpUseCase(SendOtpParams(contact: event.contact));
    result.fold(
      (failure) => emit(SendOtpState.error(failure.message)),
      (response) => emit(SendOtpState.success(response)),
    );
  }
}
