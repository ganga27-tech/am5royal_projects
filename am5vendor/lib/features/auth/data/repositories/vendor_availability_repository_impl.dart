import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/vendor_availability.dart';
import '../../domain/repositories/vendor_availability_repository.dart';
import '../datasources/vendor_availability_remote_data_source.dart';
import '../models/vendor_availability_model.dart';

class VendorAvailabilityRepositoryImpl implements VendorAvailabilityRepository {
  final VendorAvailabilityRemoteDataSource remoteDataSource;

  VendorAvailabilityRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<VendorAvailability>>> getVendorAvailability() async {
    try {
      final remoteData = await remoteDataSource.getVendorAvailability();
      final List<VendorAvailability> entities = remoteData.map((e) => VendorAvailability(
        dayOfWeek: e.dayOfWeek,
        startTime: e.startTime,
        endTime: e.endTime,
        isAvailable: e.isAvailable,
      )).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VendorAvailability>>> updateVendorAvailability(
      List<VendorAvailability> availabilities) async {
    try {
      final models = availabilities.map((e) => VendorAvailabilityModel(
        dayOfWeek: e.dayOfWeek,
        startTime: e.startTime,
        endTime: e.endTime,
        isAvailable: e.isAvailable,
      )).toList();
      
      final remoteData = await remoteDataSource.updateVendorAvailability(models);
      
      final List<VendorAvailability> entities = remoteData.map((e) => VendorAvailability(
        dayOfWeek: e.dayOfWeek,
        startTime: e.startTime,
        endTime: e.endTime,
        isAvailable: e.isAvailable,
      )).toList();
      
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
