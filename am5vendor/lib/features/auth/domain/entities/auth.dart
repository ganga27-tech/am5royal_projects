import 'package:equatable/equatable.dart';

class Auth extends Equatable {
  final String id;
  final String contact;
  final String token;
  final String? name;
  final String? email;
  final String? profilePhoto;

  const Auth({
    required this.id,
    required this.contact,
    required this.token,
    this.name,
    this.email,
    this.profilePhoto,
  });

  @override
  List<Object?> get props => [id, contact, token, name, email, profilePhoto];
}

class AuthValidator {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  static bool isValidMobile(String mobile) {
    // Check if it's 10-12 digits starting with 6, 7, 8, or 9 (with optional + prefix)
    final mobileRegex = RegExp(r'^\+?[6-9][0-9]{9,11}$');
    return mobileRegex.hasMatch(mobile.trim());
  }

  static bool isEmailInput(String input) {
    final trimmed = input.trim();
    return trimmed.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(trimmed);
  }

  static bool isValidContact(String contact) {
    final trimmed = contact.trim();
    if (isEmailInput(trimmed)) {
      return isValidEmail(trimmed);
    }
    return isValidMobile(trimmed);
  }

  static bool isValidOtp(String otp) {
    final otpRegex = RegExp(r'^[0-9]{5}$');
    return otpRegex.hasMatch(otp.trim());
  }
}
