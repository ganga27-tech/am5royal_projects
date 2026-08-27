import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/device_sync_model.dart';

abstract class DeviceTrackingRemoteDataSource {
  Future<void> syncDevice(DeviceSyncModel model);
}

class DeviceTrackingRemoteDataSourceImpl
    implements DeviceTrackingRemoteDataSource {
  final ApiClient apiClient;

  DeviceTrackingRemoteDataSourceImpl(this.apiClient);

  @override
  Future<void> syncDevice(DeviceSyncModel model) async {
    try {
      await apiClient.dio.post(
        '/devices/sync',
        data: model.toJson(),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException(
            e.response?.data['detail'] ?? 'Failed to sync device');
      } else {
        throw ServerException('Network error occurred');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
