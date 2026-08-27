import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

/// Shared Dio configuration for production (GetIt) and Riverpod auth flows.
Dio createConfiguredDio({
  AuthInterceptor? authInterceptor,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.instance.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 5),
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  if (authInterceptor != null) {
    dio.interceptors.add(authInterceptor);
  }

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ),
    );
  }

  return dio;
}

bool get useMockApiInterceptor =>
    AppConfig.instance.environment == Environment.dev && kDebugMode;
