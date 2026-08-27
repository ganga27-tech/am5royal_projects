import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/verify_otp_response.dart';

part 'register_vendor_state.freezed.dart';

@freezed
class RegisterVendorState with _$RegisterVendorState {
  const factory RegisterVendorState.initial() = RegisterVendorInitial;
  const factory RegisterVendorState.loading() = RegisterVendorLoading;
  const factory RegisterVendorState.success(VerifyOtpResponse response) = RegisterVendorSuccess;
  const factory RegisterVendorState.error(String message) = RegisterVendorError;
  const factory RegisterVendorState.validationError(String message) = RegisterVendorValidationError;
}
