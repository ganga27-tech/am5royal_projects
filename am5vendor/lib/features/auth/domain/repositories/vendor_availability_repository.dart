import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vendor_availability.dart';

abstract class VendorAvailabilityRepository {
  Future<Either<Failure, List<VendorAvailability>>> getVendorAvailability();
  Future<Either<Failure, List<VendorAvailability>>> updateVendorAvailability(
    List<VendorAvailability> availabilities,
  );
}
