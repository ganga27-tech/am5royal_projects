enum Environment { dev, prod }

class AppConfig {
  final Environment environment;
  final String baseUrl;
  final String appTitle;

  AppConfig({
    required this.environment,
    required this.baseUrl,
    required this.appTitle,
  });

  static late AppConfig _instance;

  static AppConfig get instance => _instance;

  static void setConfiguration(AppConfig config) {
    _instance = config;
  }
}
