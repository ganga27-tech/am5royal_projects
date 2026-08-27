import '../models/vendor_availability_model.dart';
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

abstract class VendorAvailabilityRemoteDataSource {
  Future<List<VendorAvailabilityModel>> getVendorAvailability();
  Future<List<VendorAvailabilityModel>> updateVendorAvailability(List<VendorAvailabilityModel> availabilities);
}

class VendorAvailabilityRemoteDataSourceImpl implements VendorAvailabilityRemoteDataSource {
  final ApiClient apiClient;

  VendorAvailabilityRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<VendorAvailabilityModel>> getVendorAvailability() async {
    try {
      final response = await apiClient.dio.get('/vendors/me/availability');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['availabilities'];
        return data.map((e) => VendorAvailabilityModel.fromJson(e)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<VendorAvailabilityModel>> updateVendorAvailability(
      List<VendorAvailabilityModel> availabilities) async {
    try {
      final dataList = availabilities.map((e) => e.toJson()).toList();
      final response = await apiClient.dio.put(
        '/vendors/me/availability',
        data: dataList,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['availabilities'];
        return data.map((e) => VendorAvailabilityModel.fromJson(e)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
