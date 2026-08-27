import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<void> startService(String orderId, String startOtp);
  Future<void> completeService(String orderId, String endOtp);
  Future<void> acceptBooking(String orderId);
  Future<void> rejectBooking(String orderId, {String? reason});
  Future<List<OrderModel>> getVendorOrders({String? statusFilter});
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient client;

  OrdersRemoteDataSourceImpl(this.client);

  @override
  Future<void> startService(String orderId, String startOtp) async {
    try {
      final response = await client.dio.post(
        '/orders/start',
        data: {'order_id': orderId, 'start_otp': startOtp},
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to start service');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> completeService(String orderId, String endOtp) async {
    try {
      final response = await client.dio.post(
        '/orders/complete',
        data: {'order_id': orderId, 'end_otp': endOtp},
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to complete service');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> acceptBooking(String orderId) async {
    try {
      final response = await client.dio.put('/orders/$orderId/accept');
      if (response.statusCode != 200) {
        throw ServerException('Failed to accept booking');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> rejectBooking(String orderId, {String? reason}) async {
    try {
      final response = await client.dio.put(
        '/orders/$orderId/reject',
        data: {if (reason != null && reason.isNotEmpty) 'reason': reason},
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to reject booking');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<OrderModel>> getVendorOrders({String? statusFilter}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (statusFilter != null) {
        queryParams['status_filter'] = statusFilter;
      }
      
      final response = await client.dio.get(
        '/orders/vendor/me',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => OrderModel.fromJson(json))
            .toList();
      } else {
        throw ServerException('Failed to fetch orders');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
