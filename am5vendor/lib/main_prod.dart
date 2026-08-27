import 'core/config/app_config.dart';
import 'main.dart' as app;

void main() async {
  AppConfig.setConfiguration(AppConfig(
    environment: Environment.prod,
    baseUrl: 'https://api.am5royal.com/api/v1',
    appTitle: 'AM5 ROYAL',
  ));
  app.main();
}
