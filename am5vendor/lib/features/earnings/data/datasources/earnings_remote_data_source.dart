import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/earnings_model.dart';

abstract class EarningsRemoteDataSource {
  Future<EarningsModel> getMyEarnings();
}

class EarningsRemoteDataSourceImpl implements EarningsRemoteDataSource {
  final ApiClient client;

  EarningsRemoteDataSourceImpl({required this.client});

  @override
  Future<EarningsModel> getMyEarnings() async {
    try {
      final response = await client.dio.get('/wallet/earnings');
      if (response.statusCode == 200) {
        return EarningsModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to fetch earnings details');
      }
    } on DioException catch (e) {
      throw ServerException(e.response?.data['detail'] ?? 'Network error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
