import 'package:shared_preferences/shared_preferences.dart';

/// Persists JWT access tokens for authenticated sessions.
class TokenStorage {
  TokenStorage._();
  static final TokenStorage instance = TokenStorage._();

  static const String _tokenKey = 'am5_access_token';
  static const String _isNewUserKey = 'am5_is_new_user';

  Future<void> saveToken(String token, {bool isNewUser = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_isNewUserKey, isNewUser);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> getIsNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isNewUserKey) ?? false;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_isNewUserKey);
  }
}
