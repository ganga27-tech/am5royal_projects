import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../client/api_client.dart';

class ProfileApi {
  ProfileApi(this._client);

  final ApiClient _client;

  Future<UserProfile> getMe() async {
    try {
      final response = await _client.dio.get('/auth/customer/me');
      return UserProfile.fromAm5CustomerProfile(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<UserProfile> updateMe(Map<String, dynamic> patch) async {
    try {
      final body = <String, dynamic>{};
      if (patch.containsKey('full_name')) {
        body['full_name'] = patch['full_name'];
      }
      if (patch.containsKey('email')) {
        body['email'] = patch['email'];
      }
      final response = await _client.dio.put('/auth/customer/profile', data: body);
      return UserProfile.fromAm5CustomerProfile(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    throw const Failure('Password login is not available. Use OTP sign-in.');
  }

  Future<void> deleteAccount() async {
    throw const Failure('Account deletion is not available yet.');
  }
}

class SettingsApi {
  SettingsApi(this._prefs);

  final SharedPreferences _prefs;

  static const _localeKey = 'livora_locale';
  static const _themeKey = 'livora_theme_mode';
  static const _pushKey = 'livora_notifications_push';
  static const _emailKey = 'livora_notifications_email';
  static const _smsKey = 'livora_notifications_sms';
  static const _marketingKey = 'livora_marketing_opt_in';

  UserPreferences _readLocal() {
    return UserPreferences(
      locale: _prefs.getString(_localeKey) ?? 'en',
      themeMode: _prefs.getString(_themeKey) ?? 'system',
      notificationsPush: _prefs.getBool(_pushKey) ?? true,
      notificationsEmail: _prefs.getBool(_emailKey) ?? true,
      notificationsSms: _prefs.getBool(_smsKey) ?? false,
      marketingOptIn: _prefs.getBool(_marketingKey) ?? false,
    );
  }

  Future<void> _writeLocal(UserPreferences prefs) async {
    await _prefs.setString(_localeKey, prefs.locale);
    await _prefs.setString(_themeKey, prefs.themeMode);
    await _prefs.setBool(_pushKey, prefs.notificationsPush);
    await _prefs.setBool(_emailKey, prefs.notificationsEmail);
    await _prefs.setBool(_smsKey, prefs.notificationsSms);
    await _prefs.setBool(_marketingKey, prefs.marketingOptIn);
  }

  Future<UserPreferences> getPreferences() async {
    return _readLocal();
  }

  Future<UserPreferences> updatePreferences(Map<String, dynamic> patch) async {
    final current = _readLocal();
    final updated = current.copyWith(
      locale: patch['locale'] as String? ?? current.locale,
      themeMode: patch['theme_mode'] as String? ?? current.themeMode,
      notificationsPush: patch['notifications_push'] as bool? ?? current.notificationsPush,
      notificationsEmail: patch['notifications_email'] as bool? ?? current.notificationsEmail,
      notificationsSms: patch['notifications_sms'] as bool? ?? current.notificationsSms,
      marketingOptIn: patch['marketing_opt_in'] as bool? ?? current.marketingOptIn,
    );
    await _writeLocal(updated);
    return updated;
  }
}
