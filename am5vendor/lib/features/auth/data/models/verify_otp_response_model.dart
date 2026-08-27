import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/verify_otp_response.dart';

part 'verify_otp_response_model.freezed.dart';
part 'verify_otp_response_model.g.dart';

@freezed
class VerifyOtpResponseModel with _$VerifyOtpResponseModel {
  const VerifyOtpResponseModel._();

  const factory VerifyOtpResponseModel({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    @JsonKey(name: 'is_new_user') required bool isNewUser,
  }) = _VerifyOtpResponseModel;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyOtpResponseModelFromJson(json);

  VerifyOtpResponse toEntity() {
    return VerifyOtpResponse(
      accessToken: accessToken,
      tokenType: tokenType,
      isNewUser: isNewUser,
    );
  }
}
