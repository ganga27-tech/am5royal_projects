import 'package:equatable/equatable.dart';

class VerifyOtpResponse extends Equatable {
  final String accessToken;
  final String tokenType;
  final bool isNewUser;

  const VerifyOtpResponse({
    required this.accessToken,
    required this.tokenType,
    required this.isNewUser,
  });

  @override
  List<Object?> get props => [accessToken, tokenType, isNewUser];
}
