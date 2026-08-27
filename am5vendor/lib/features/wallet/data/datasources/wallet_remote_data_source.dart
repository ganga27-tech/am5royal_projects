import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<WalletModel> getWalletDetails();
  Future<Map<String, dynamic>> topUpWallet(double amount);
  Future<double> verifyTopup(
      String paymentId, String orderId, String signature, double amount);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient client;

  WalletRemoteDataSourceImpl({required this.client});

  @override
  Future<WalletModel> getWalletDetails() async {
    try {
      final response = await client.dio.get('/wallet/details');
      if (response.statusCode == 200) {
        return WalletModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to fetch wallet details');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> topUpWallet(double amount) async {
    try {
      final response = await client.dio.post(
        '/wallet/topup',
        data: {'amount': amount},
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException('Failed to initiate topup');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<double> verifyTopup(
      String paymentId, String orderId, String signature, double amount) async {
    try {
      final response = await client.dio.post(
        '/wallet/verify-topup',
        data: {
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
          'amount': amount,
        },
      );
      if (response.statusCode == 200) {
        final newBalance = response.data['new_balance'];
        if (newBalance is String) {
          return double.tryParse(newBalance) ?? 0.0;
        } else if (newBalance is num) {
          return newBalance.toDouble();
        }
        return 0.0;
      } else {
        throw ServerException('Failed to verify topup');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
