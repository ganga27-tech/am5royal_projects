import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import 'token_storage.dart';

typedef SessionExpiredCallback = void Function();

class ApiClient {
  ApiClient({
    required this.baseUrl,
    TokenStorage? initialTokenStorage,
    Dio? dio,
    this.onSessionExpired,
    this.maxRetries = 2,
  })  : tokenStorage = initialTokenStorage ?? TokenStorage(),
        dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await this.tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final isAuthCall = error.requestOptions.path.contains('/auth/customer/');

          if (status == 401 && !isAuthCall) {
            await this.tokenStorage.clear();
            onSessionExpired?.call();
            return handler.next(error);
          }

          final retryCount = error.requestOptions.extra['retryCount'] as int? ?? 0;
          final retriable = error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
          if (retriable && retryCount < maxRetries) {
            error.requestOptions.extra['retryCount'] = retryCount + 1;
            await Future<void>.delayed(Duration(milliseconds: 300 * (retryCount + 1)));
            try {
              final clone = await this.dio.fetch(error.requestOptions);
              return handler.resolve(clone);
            } catch (_) {
              return handler.next(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  final String baseUrl;
  final Dio dio;
  final TokenStorage tokenStorage;
  final SessionExpiredCallback? onSessionExpired;
  final int maxRetries;

  Failure mapDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String && detail.isNotEmpty) {
        return Failure(detail, code: data['code'] as String?);
      }
      final message = data['message'] as String? ?? 'Request failed';
      final code = data['code'] as String?;
      return Failure(message, code: code);
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const Failure('Connection timed out. Pull to retry.', code: 'timeout');
    }
    if (error.type == DioExceptionType.connectionError) {
      return const Failure(
        'You appear to be offline. Check your connection and retry.',
        code: 'offline',
      );
    }
    return Failure(error.message ?? 'Unexpected error', code: 'unknown');
  }
}
