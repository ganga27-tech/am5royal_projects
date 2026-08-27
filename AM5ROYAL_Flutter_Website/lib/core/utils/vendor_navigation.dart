import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper utility for navigating from the am5royalwebsite to the
/// AM5ROYAL Vendor app on the Google Play Store.
abstract final class VendorNavigation {
  VendorNavigation._();

  /// AM5ROYAL Vendor app on Google Play Store.
  /// Can be overridden via `--dart-define=VENDOR_LOGIN_URL=https://...`
  static const String _defaultVendorUrl = String.fromEnvironment(
    'VENDOR_LOGIN_URL',
    defaultValue: 'https://vendor.am5royal.com/login',
  );

  /// Launches the AM5ROYAL Vendor app / Play Store page.
  ///
  /// On Android, if the AM5ROYAL Vendor app is installed, the OS will
  /// typically offer to open it directly in the app instead of the browser.
  /// If it's not installed (or on desktop), the Play Store page opens.
  static Future<void> openVendorLogin({String? customUrl}) async {
    final String urlString = customUrl ?? _defaultVendorUrl;
    final Uri uri = Uri.parse(urlString);

    try {
      final bool launched = await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('Could not launch vendor URL: $urlString');
      }
    } catch (e) {
      debugPrint('Error launching vendor login URL ($urlString): $e');
    }
  }
}
