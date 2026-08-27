import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/add_service_response_model.dart';
import '../../data/models/add_service_request_model.dart';
import '../repositories/service_repository.dart';

class AddServiceUseCase {
  final ServiceRepository repository;

  AddServiceUseCase(this.repository);

  Future<Either<Failure, AddServiceResponseModel>> call({
    required int serviceId,
    required double amount,
    required bool isNegotiable,
    List<MediaItemModel> media = const [],
  }) async {
    return await repository.addService(
      serviceId: serviceId,
      amount: amount,
      isNegotiable: isNegotiable,
      media: media,
    );
  }
}
