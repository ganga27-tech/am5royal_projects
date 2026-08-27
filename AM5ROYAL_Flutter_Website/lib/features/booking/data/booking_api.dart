import '../../../core/network/api_client.dart';
import '../../../core/network/app_api_client.dart';
import '../models/booking_models.dart';

class BookingApi {
  BookingApi({ApiClient? client}) : _client = client ?? AppApiClient.instance;

  final ApiClient _client;

  Future<List<String>> getAvailableSlots({
    int? professionId,
    List<int>? serviceIds,
    List<int>? packageIds,
    int? addressId,
    required String serviceDate,
    int? customerId,
  }) async {
    final Map<String, String> params = {
      'serviceDate': serviceDate,
    };
    if (professionId != null) {
      params['professionId'] = professionId.toString();
    }
    if (serviceIds != null && serviceIds.isNotEmpty) {
      params['serviceIds'] = serviceIds.join(',');
    }
    if (packageIds != null && packageIds.isNotEmpty) {
      params['packageIds'] = packageIds.join(',');
    }
    if (addressId != null) {
      params['addressId'] = addressId.toString();
    }
    if (customerId != null) {
      params['customerId'] = customerId.toString();
    }

    final List<dynamic> data = await _client.getList(
      '/orders/availableServiceProviderSlots',
      queryParams: params,
    );
    return data.map((e) => e.toString()).toList();
  }

  Future<Map<String, dynamic>> calculateOrder({
    int? addressId,
    required List<Map<String, dynamic>> packages,
  }) async {
    return _client.post(
      '/orders/order/calculation',
      authenticated: true,
      body: {
        if (addressId != null) 'addressId': addressId,
        'packages': packages,
      },
    );
  }

  Future<BookingConfirmation> createBooking({
    required int addressId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    required DateTime scheduledAt,
    int? vendorProfileId,
    String? couponCode,
  }) async {
    final Map<String, dynamic> data = await _client.post(
      '/orders/',
      authenticated: true,
      body: {
        'address_id': addressId,
        'payment_method': paymentMethod,
        'items': items,
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        if (vendorProfileId != null) 'vendor_profile_id': vendorProfileId,
        if (couponCode != null) 'coupon_code': couponCode,
      },
    );
    return BookingConfirmation.fromJson(data);
  }
}
