import 'package:dio/dio.dart';
import '../services/auth_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final AuthStorageService authStorageService;

  AuthInterceptor(this.authStorageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = authStorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }
}
