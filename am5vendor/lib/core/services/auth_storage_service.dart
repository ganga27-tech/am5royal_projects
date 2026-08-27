import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  final SharedPreferences sharedPreferences;

  AuthStorageService(this.sharedPreferences);

  static const _tokenKey = 'access_token';
  static const _tokenTypeKey = 'token_type';
  static const _roleKey = 'user_role';
  static const _loginContactKey = 'login_contact';

  /// Save access token and token type to secure storage (SharedPreferences)
  Future<void> saveAccessToken(String token, {String? tokenType}) async {
    await sharedPreferences.setString(_tokenKey, token);
    if (tokenType != null) {
      await sharedPreferences.setString(_tokenTypeKey, tokenType);
    }
  }

  /// Get cached access token
  String? getAccessToken() {
    return sharedPreferences.getString(_tokenKey);
  }

  /// Get cached token type
  String? getTokenType() {
    return sharedPreferences.getString(_tokenTypeKey);
  }

  /// Save user role to secure storage (SharedPreferences)
  Future<void> saveUserRole(String role) async {
    await sharedPreferences.setString(_roleKey, role);
  }

  /// Get cached user role
  String? getUserRole() {
    return sharedPreferences.getString(_roleKey);
  }

  Future<void> saveLoginContact(String contact) async {
    await sharedPreferences.setString(_loginContactKey, contact.trim());
  }

  String? getLoginContact() {
    return sharedPreferences.getString(_loginContactKey);
  }

  /// Clear all cached authentication credentials
  Future<void> clearAccessToken() async {
    await sharedPreferences.remove(_tokenKey);
    await sharedPreferences.remove(_tokenTypeKey);
    await sharedPreferences.remove(_roleKey);
    await sharedPreferences.remove(_loginContactKey);
  }

  /// Check whether the user is logged in
  bool isLoggedIn() {
    final token = getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
