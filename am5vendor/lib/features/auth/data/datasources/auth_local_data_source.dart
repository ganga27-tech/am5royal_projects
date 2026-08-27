import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthLocalDataSource {
  Future<AuthModel> getLastAuth();
  Future<void> cacheAuth(AuthModel authToCache);
  Future<void> clearAuth();
}

const cachedAuthKey = 'CACHED_AUTH';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AuthModel> getLastAuth() {
    final jsonString = sharedPreferences.getString(cachedAuthKey);
    if (jsonString != null) {
      try {
        return Future.value(AuthModel.fromJson(json.decode(jsonString) as Map<String, dynamic>));
      } catch (e) {
        throw CacheException('Corrupted cache data.');
      }
    } else {
      throw CacheException('No cached session found.');
    }
  }

  @override
  Future<void> cacheAuth(AuthModel authToCache) {
    return sharedPreferences.setString(
      cachedAuthKey,
      json.encode(authToCache.toJson()),
    );
  }

  @override
  Future<void> clearAuth() {
    return sharedPreferences.remove(cachedAuthKey);
  }
}
