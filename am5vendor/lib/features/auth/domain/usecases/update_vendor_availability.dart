import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vendor_availability.dart';
import '../repositories/vendor_availability_repository.dart';

class UpdateVendorAvailabilityUseCase {
  final VendorAvailabilityRepository repository;

  UpdateVendorAvailabilityUseCase(this.repository);

  Future<Either<Failure, List<VendorAvailability>>> call(List<VendorAvailability> availabilities) async {
    return await repository.updateVendorAvailability(availabilities);
  }
}
