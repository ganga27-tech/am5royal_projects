/// API configuration for AM5 ROYAL backend integration.
abstract final class ApiConfig {
  ApiConfig._();

  /// Production API base URL.
  /// Override via: `--dart-define=API_BASE_URL=https://...`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.am5royal.com/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String platform = 'web';
}
