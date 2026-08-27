import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/vendor_business_details_request_model.dart';
import '../repositories/auth_repository.dart';

class SubmitBusinessDetailsUseCase implements UseCase<void, SubmitBusinessDetailsParams> {
  final AuthRepository repository;

  SubmitBusinessDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitBusinessDetailsParams params) async {
    return await repository.submitBusinessDetails(params.request);
  }
}

class SubmitBusinessDetailsParams {
  final VendorBusinessDetailsRequestModel request;

  SubmitBusinessDetailsParams({required this.request});
}
