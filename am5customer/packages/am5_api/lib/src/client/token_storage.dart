import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token storage with secure storage primary and SharedPreferences fallback.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _accessKey = 'am5_access_token';
  static const _refreshKey = 'am5_refresh_token';
  bool _usePrefs = false;

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    if (_usePrefs) {
      await _savePrefs(accessToken, refreshToken ?? '');
      return;
    }
    try {
      await _storage.write(key: _accessKey, value: accessToken);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storage.write(key: _refreshKey, value: refreshToken);
      }
    } catch (e) {
      debugPrint('TokenStorage secure write failed, falling back to prefs: $e');
      _usePrefs = true;
      await _savePrefs(accessToken, refreshToken ?? '');
    }
  }

  Future<String?> readAccessToken() async {
    if (_usePrefs) return _readPrefs(_accessKey);
    try {
      return await _storage.read(key: _accessKey);
    } catch (_) {
      _usePrefs = true;
      return _readPrefs(_accessKey);
    }
  }

  Future<String?> readRefreshToken() async {
    if (_usePrefs) return _readPrefs(_refreshKey);
    try {
      return await _storage.read(key: _refreshKey);
    } catch (_) {
      _usePrefs = true;
      return _readPrefs(_refreshKey);
    }
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  Future<void> _savePrefs(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    if (refresh.isNotEmpty) {
      await prefs.setString(_refreshKey, refresh);
    }
  }

  Future<String?> _readPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
