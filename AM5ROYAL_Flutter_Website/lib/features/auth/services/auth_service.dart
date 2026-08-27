import 'package:flutter/foundation.dart';

import '../../../core/network/app_api_client.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../models/auth_models.dart';

class AuthService extends ChangeNotifier {
  AuthService({
    AuthApi? authApi,
    TokenStorage? tokenStorage,
    ApiClient? apiClient,
  })  : _authApi = authApi ?? AuthApi(client: apiClient ?? AppApiClient.instance),
        _tokenStorage = tokenStorage ?? TokenStorage.instance,
        _apiClient = apiClient ?? AppApiClient.instance {
    _apiClient.onTokenExpired = _handleTokenExpired;
  }

  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService();

  final AuthApi _authApi;
  final TokenStorage _tokenStorage;
  final ApiClient _apiClient;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  CustomerProfile? _profile;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  CustomerProfile? get profile => _profile;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        _profile = await _authApi.getProfile();
        _isAuthenticated = true;
      }
    } catch (_) {
      await _tokenStorage.clear();
      _isAuthenticated = false;
      _profile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendOtp({String? mobile, String? email}) async {
    await _authApi.sendOtp(mobile: mobile, email: email);
  }

  Future<bool> verifyOtp({
    String? mobile,
    String? email,
    required String otp,
  }) async {
    final TokenResponse token = await _authApi.verifyOtp(
      mobile: mobile,
      email: email,
      otp: otp,
    );

    await _tokenStorage.saveToken(
      token.accessToken,
      isNewUser: token.isNewUser,
    );

    _profile = await _authApi.getProfile();
    _isAuthenticated = true;
    notifyListeners();
    return token.isNewUser;
  }

  Future<void> updateProfile({String? fullName, String? email}) async {
    _profile = await _authApi.updateProfile(
      fullName: fullName,
      email: email,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _isAuthenticated = false;
    _profile = null;
    notifyListeners();
  }

  void _handleTokenExpired() {
    _tokenStorage.clear();
    _isAuthenticated = false;
    _profile = null;
    notifyListeners();
  }

  String friendlyError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Something went wrong. Please check your connection and try again.';
  }
}
