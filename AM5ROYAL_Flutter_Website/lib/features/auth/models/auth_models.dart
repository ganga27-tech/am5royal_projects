class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    required this.isNewUser,
    this.tokenType = 'bearer',
  });

  final String accessToken;
  final bool isNewUser;
  final String tokenType;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      isNewUser: json['is_new_user'] as bool? ?? false,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}

class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
  });

  final int id;
  final String fullName;
  final String phone;
  final String? email;

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: json['id'] as int,
      fullName: json['full_name'] as String? ?? 'Customer',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
    );
  }
}
