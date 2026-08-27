import 'package:url_launcher/url_launcher.dart';

/// Navigation helpers for the AM5 ROYAL customer mobile app.
abstract final class CustomerNavigation {
  CustomerNavigation._();

  static const String _playStoreUrl = String.fromEnvironment(
    'CUSTOMER_APP_URL',
    defaultValue:
        'https://play.google.com/store/apps/details?id=com.am5royal.am5royal',
  );

  static const String _appScheme = String.fromEnvironment(
    'CUSTOMER_APP_SCHEME',
    defaultValue: 'am5royal://services',
  );

  /// Opens the customer app services page if installed, otherwise Play Store.
  static Future<void> openBookService() async {
    final Uri deepLink = Uri.parse(_appScheme);
    try {
      final bool opened = await launchUrl(
        deepLink,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        await _openPlayStore();
      }
    } catch (_) {
      await _openPlayStore();
    }
  }

  static Future<void> _openPlayStore() async {
    final Uri storeUri = Uri.parse(_playStoreUrl);
    await launchUrl(storeUri, mode: LaunchMode.externalApplication);
  }
}
