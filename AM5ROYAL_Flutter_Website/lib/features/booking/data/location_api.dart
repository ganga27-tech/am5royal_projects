import '../../../core/network/api_client.dart';
import '../../../core/network/app_api_client.dart';
import '../models/booking_models.dart';

class LocationApi {
  LocationApi({ApiClient? client}) : _client = client ?? AppApiClient.instance;

  final ApiClient _client;

  Future<List<CustomerAddress>> getAddresses() async {
    final List<dynamic> data = await _client.getList(
      '/location/addresses',
      authenticated: true,
    );
    return data
        .map((e) => CustomerAddress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerAddress> createAddress({
    required String label,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String pincode,
    bool isDefault = true,
  }) async {
    final Map<String, dynamic> data = await _client.post(
      '/location/addresses',
      authenticated: true,
      body: {
        'label': label.toUpperCase(),
        'address_line1': addressLine1,
        if (addressLine2 != null) 'address_line2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'is_default': isDefault,
      },
    );
    return CustomerAddress.fromJson(data);
  }
}
