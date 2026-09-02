import 'package:equatable/equatable.dart';

import 'user.dart';

class AuthTokens extends Equatable {
  const AuthTokens({
    required this.accessToken,
    required this.user,
    this.refreshToken = '',
    this.expiresIn = 0,
    this.tokenType = 'bearer',
    this.isNewUser = false,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final LivoraUser user;
  final bool isNewUser;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final expires = json['expires_in'];
    final userJson = json['user'];
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresIn: expires is int ? expires : (expires is num ? expires.toInt() : 0),
      user: userJson is Map<String, dynamic>
          ? LivoraUser.fromJson(userJson)
          : const LivoraUser(
              id: '',
              fullName: 'Customer',
              status: 'active',
              roles: ['customer'],
              isEmailVerified: true,
              isPhoneVerified: true,
              preferredLocale: 'en',
            ),
      isNewUser: json['is_new_user'] as bool? ?? false,
    );
  }

  AuthTokens copyWithUser(LivoraUser user) {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      user: user,
      isNewUser: isNewUser,
    );
  }

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresIn, user, isNewUser];
}
