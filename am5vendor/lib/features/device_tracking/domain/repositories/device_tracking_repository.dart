import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class DeviceTrackingRepository {
  Future<Either<Failure, void>> syncDevice();
}
