import 'package:dio/dio.dart';
import 'package:am5_core/am5_core.dart';

import '../client/api_client.dart';

class AddressApi {
  AddressApi(this._client);

  final ApiClient _client;

  Future<List<UserAddress>> listAddresses() async {
    try {
      final response = await _client.dio.get('/location/addresses');
      final list = response.data as List<dynamic>;
      return list.map((e) => UserAddress.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<UserAddress> createAddress(Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.post(
        '/location/addresses',
        data: _toAm5Body(body),
      );
      return UserAddress.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<UserAddress> updateAddress(String id, Map<String, dynamic> body) async {
    try {
      final response = await _client.dio.put(
        '/location/addresses/$id',
        data: _toAm5Body(body),
      );
      return UserAddress.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      await _client.dio.delete('/location/addresses/$id');
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<UserAddress> setDefault(String id) async {
    final addresses = await listAddresses();
    final current = addresses.firstWhere((a) => a.id == id);
    return updateAddress(id, {
      ...current.toCreateJson(),
      'is_default': true,
    });
  }

  Future<List<ServiceArea>> listServiceAreas({String? country}) async {
    try {
      final response = await _client.dio.get('/location/cities');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => ServiceArea.fromAm5City(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _client.mapDioError(e);
    }
  }

  Future<ServiceabilityResult> checkServiceability({
    String? city,
    String? postalCode,
    double? latitude,
    double? longitude,
    String country = 'IN',
  }) async {
    // AM5 does not expose a dedicated serviceability endpoint yet.
    final serviceable = (postalCode != null && postalCode.length >= 6) ||
        (city != null && city.isNotEmpty);
    return ServiceabilityResult(
      serviceable: serviceable,
      message: serviceable
          ? 'Service may be available in this area'
          : 'Enter a valid pincode to check availability',
    );
  }

  Map<String, dynamic> _toAm5Body(Map<String, dynamic> body) {
    String label = (body['label'] as String? ?? 'home').toUpperCase();
    if (!{'HOME', 'OFFICE', 'OTHER'}.contains(label)) {
      label = 'OTHER';
    }

    return {
      'label': label,
      'address_line1': body['line1'] ?? body['address_line1'],
      if (body['line2'] != null || body['address_line2'] != null)
        'address_line2': body['line2'] ?? body['address_line2'],
      'city': body['city'],
      'state': body['state'],
      'pincode': body['postal_code'] ?? body['pincode'],
      if (body['latitude'] != null) 'latitude': body['latitude'],
      if (body['longitude'] != null) 'longitude': body['longitude'],
      'is_default': body['is_default'] ?? false,
    };
  }
}
