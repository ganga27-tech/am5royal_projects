import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/vendor_availability.dart';
import '../repositories/vendor_availability_repository.dart';

class GetVendorAvailabilityUseCase {
  final VendorAvailabilityRepository repository;

  GetVendorAvailabilityUseCase(this.repository);

  Future<Either<Failure, List<VendorAvailability>>> call() {
    return repository.getVendorAvailability();
  }
}
