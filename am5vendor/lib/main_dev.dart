import 'core/config/app_config.dart';
import 'main.dart' as app;

void main() async {
  AppConfig.setConfiguration(AppConfig(
    environment: Environment.dev,
    baseUrl: 'https://api.am5royal.com/dev/api/v1',
    appTitle: 'AM5 ROYAL (DEV)',
  ));
  app.main();
}
