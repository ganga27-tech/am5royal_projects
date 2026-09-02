abstract final class AuthValidators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Include an uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Include a lowercase letter';
    if (!RegExp(r'\d').hasMatch(value)) return 'Include a number';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().length < 2) return 'Enter your full name';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    final cleaned = value.trim().replaceAll(RegExp(r'[^\d]'), '');
    final phone10 = cleaned.length >= 10 ? cleaned.substring(cleaned.length - 10) : cleaned;
    if (phone10.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(phone10)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  static String? phoneE164(String? value) => phone(value);

  static String? otp(String? value) {
    if (value == null || value.length < 4) return 'Enter the OTP code';
    if (!RegExp(r'^\d+$').hasMatch(value)) return 'OTP must be numeric';
    return null;
  }
}
