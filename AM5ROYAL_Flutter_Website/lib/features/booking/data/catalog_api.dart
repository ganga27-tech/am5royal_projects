import '../../../core/network/api_client.dart';
import '../../../core/network/app_api_client.dart';
import '../models/booking_models.dart';

class CatalogApi {
  CatalogApi({ApiClient? client}) : _client = client ?? AppApiClient.instance;

  final ApiClient _client;

  Future<List<ServiceCategory>> getCategories() async {
    final List<dynamic> data =
        await _client.getList('/catalog/categories');
    return data
        .map((e) => ServiceCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceSubcategory>> getSubcategories({
    int? categoryId,
  }) async {
    final Map<String, String> params = {};
    if (categoryId != null) {
      params['category_id'] = categoryId.toString();
    }
    final List<dynamic> data = await _client.getList(
      '/catalog/subcategories',
      queryParams: params.isEmpty ? null : params,
    );
    return data
        .map((e) => ServiceSubcategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServicePackage>> getPackages({
    int? subcategoryId,
    int? categoryId,
  }) async {
    final Map<String, String> params = {};
    if (subcategoryId != null) {
      params['subcategory_id'] = subcategoryId.toString();
    }
    if (categoryId != null) {
      params['category_id'] = categoryId.toString();
    }
    final List<dynamic> data = await _client.getList(
      '/catalog/packages',
      queryParams: params.isEmpty ? null : params,
    );
    return data
        .map((e) => ServicePackage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CatalogServiceItem>> getServices({
    int? categoryId,
    int? subcategoryId,
  }) async {
    final Map<String, String> params = {};
    if (categoryId != null) {
      params['main_category_id'] = categoryId.toString();
    }
    if (subcategoryId != null) {
      params['subcategory_id'] = subcategoryId.toString();
    }
    final List<dynamic> data = await _client.getList(
      '/catalog/services',
      queryParams: params.isEmpty ? null : params,
    );
    return data
        .map((e) => CatalogServiceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<VendorInfo>> getVendors({
    int? categoryId,
    int? subcategoryId,
    int? serviceId,
    String? pincode,
    double? latitude,
    double? longitude,
  }) async {
    final Map<String, String> params = {};
    if (categoryId != null) {
      params['category_id'] = categoryId.toString();
    }
    if (subcategoryId != null) {
      params['subcategory_id'] = subcategoryId.toString();
    }
    if (serviceId != null) {
      params['service_id'] = serviceId.toString();
    }
    if (pincode != null && pincode.isNotEmpty) {
      params['pincode'] = pincode;
    }
    if (latitude != null) {
      params['latitude'] = latitude.toString();
    }
    if (longitude != null) {
      params['longitude'] = longitude.toString();
    }
    final List<dynamic> data = await _client.getList(
      '/catalog/vendors',
      queryParams: params,
    );
    return data
        .map((e) => VendorInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getVendorProfileId(int vendorId) async {
    try {
      final Map<String, dynamic> data = await _client.get(
        '/catalog/vendors/$vendorId/profile-id',
      );
      return data['vendor_profile_id'] as int;
    } catch (_) {
      // Fallback: vendors.id is used directly in the current backend schema.
      return vendorId;
    }
  }

  Future<List<VendorServiceOffering>> getVendorServices({
    required int vendorId,
    int? categoryId,
    int? subcategoryId,
  }) async {
    final Map<String, String> params = {};
    if (categoryId != null) {
      params['category_id'] = categoryId.toString();
    }
    if (subcategoryId != null) {
      params['subcategory_id'] = subcategoryId.toString();
    }
    final List<dynamic> data = await _client.getList(
      '/catalog/vendors/$vendorId/services',
      queryParams: params.isEmpty ? null : params,
    );
    return data
        .map((e) => VendorServiceOffering.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
