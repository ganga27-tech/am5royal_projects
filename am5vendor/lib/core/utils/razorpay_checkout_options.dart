import '../di/injection_container.dart' as di;
import '../services/auth_storage_service.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/profile/data/repositories/profile_repository.dart';

/// Builds Razorpay checkout options — opens UPI directly with hidden contact
/// so Android does not show Google's phone-number hint picker.
class RazorpayCheckoutOptions {
  RazorpayCheckoutOptions._();

  static const _defaultEmail = 'vendor@am5royal.com';

  static String formatContact(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    if (digits.length == 10) return '+91$digits';
    if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
    if (raw.trim().startsWith('+')) return raw.trim();
    return '+91$digits';
  }

  static Future<({String contact, String email, String name})>
      loadCustomerDetails() async {
    var contact = '';
    var email = '';
    var name = 'AM5 Royal Vendor';

    final loginContact = di.sl<AuthStorageService>().getLoginContact();
    if (loginContact != null && loginContact.isNotEmpty) {
      contact = formatContact(loginContact);
    }

    try {
      final authData = await di.sl<AuthLocalDataSource>().getLastAuth();
      if (contact.isEmpty) {
        contact = formatContact(authData.contact);
      }
      email = authData.email?.trim() ?? '';
      if (authData.name != null && authData.name!.trim().isNotEmpty) {
        name = authData.name!.trim();
      }
    } catch (_) {}

    if (contact.isEmpty) {
      try {
        final profileResult = await di.sl<ProfileRepository>().getProfile();
        profileResult.fold((_) {}, (profile) {
          final mobile = profile.mobile?.trim() ?? '';
          if (mobile.isNotEmpty) {
            contact = formatContact(mobile);
            di.sl<AuthStorageService>().saveLoginContact(mobile);
          }
          if (email.isEmpty) {
            email = profile.email?.trim() ?? '';
          }
          if (profile.businessName != null &&
              profile.businessName!.trim().isNotEmpty) {
            name = profile.businessName!.trim();
          }
        });
      } catch (_) {}
    }

    if (email.isEmpty) {
      email = _defaultEmail;
    }

    return (contact: contact, email: email, name: name);
  }

  static Future<Map<String, dynamic>> build({
    required String razorpayKey,
    required int amount,
    required String orderId,
    required String description,
    String currency = 'INR',
    String businessName = 'AM5 Royal Vendor',
  }) async {
    final customer = await loadCustomerDetails();

    // readonly/hidden must come after prefill — Razorpay Android SDK is order-sensitive.
    return {
      'key': razorpayKey,
      'amount': amount,
      'currency': currency,
      'name': businessName,
      'order_id': orderId,
      'description': description,
      'retry': {'enabled': true, 'max_count': 1},
      'prefill': {
        'contact': customer.contact,
        'email': customer.email,
        'name': customer.name,
        'method': 'upi',
      },
      'config': {
        'display': {
          'hide': [
            {'method': 'paylater'},
            {'method': 'emi'},
            {'method': 'card'},
            {'method': 'netbanking'},
            {'method': 'wallet'},
          ],
        },
      },
      'readonly': {
        'contact': true,
        'email': true,
      },
      'hidden': {
        'contact': true,
        'email': true,
      },
    };
  }
}
