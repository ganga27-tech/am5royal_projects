/// AM5 Royal API configuration.
class AppConfig {
  /// Override with: flutter run --dart-define=API_BASE_URL=https://...
  static const _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');

  static const _defaultBaseUrl = 'https://api.am5royal.com/api/v1';

  static String get apiBaseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    return _defaultBaseUrl;
  }

  static const String platform = 'mobile';
}
