import 'package:equatable/equatable.dart';

class SendOtpResponse extends Equatable {
  final String message;
  final String identifier;

  const SendOtpResponse({
    required this.message,
    required this.identifier,
  });

  @override
  List<Object?> get props => [message, identifier];
}
