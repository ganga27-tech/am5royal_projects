import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/device_tracking_repository.dart';
import '../datasources/device_tracking_local_data_source.dart';
import '../datasources/device_tracking_remote_data_source.dart';

class DeviceTrackingRepositoryImpl implements DeviceTrackingRepository {
  final DeviceTrackingRemoteDataSource remoteDataSource;
  final DeviceTrackingLocalDataSource localDataSource;

  DeviceTrackingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, void>> syncDevice() async {
    try {
      final deviceModel = await localDataSource.getDeviceSyncModel();
      await remoteDataSource.syncDevice(deviceModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure( e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
