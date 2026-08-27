import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/subscription_plan_model.dart';
import '../models/my_subscription_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans();
  Future<List<MySubscriptionModel>> getMySubscriptions();
  Future<Map<String, dynamic>> purchasePlan(int planId);
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required int planId,
  });
  Future<Map<String, dynamic>> recoverPayment({
    required String razorpayOrderId,
    required int planId,
  });
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final ApiClient apiClient;

  SubscriptionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      final response = await apiClient.dio.get('/subscriptions/');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => SubscriptionPlanModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch subscription plans');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Failed to fetch subscription plans');
      } else {
        throw ServerException('Network error occurred');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MySubscriptionModel>> getMySubscriptions() async {
    try {
      final response = await apiClient.dio.get('/subscriptions/me');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => MySubscriptionModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to fetch my subscriptions');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Failed to fetch my subscriptions');
      } else {
        throw ServerException('Network error occurred');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> purchasePlan(int planId) async {
    try {
      final response = await apiClient.dio.post(
        '/subscriptions/purchase',
        data: {'plan_id': planId},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw ServerException('Failed to initiate purchase');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Failed to initiate purchase');
      } else {
        throw ServerException('Network error occurred');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required int planId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/subscriptions/verify-payment',
        data: {
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': razorpaySignature,
          'plan_id': planId,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw ServerException('Failed to verify payment');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(e.response?.data['detail'] ?? 'Failed to verify payment');
      } else {
        throw ServerException('Network error occurred');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> recoverPayment({
    required String razorpayOrderId,
    required int planId,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/subscriptions/recover-payment',
        data: {
          'razorpay_order_id': razorpayOrderId,
          'plan_id': planId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw ServerException('Failed to recover payment');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final detail = e.response?.data['detail'];
        throw ServerException(
          detail is String ? detail : 'Failed to recover payment',
        );
      } else {
        throw ServerException('Network error occurred');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
