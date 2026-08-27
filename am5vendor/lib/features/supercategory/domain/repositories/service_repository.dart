import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import '../../../../core/error/failures.dart';
import '../entities/service_entity.dart';
import '../../data/models/add_service_response_model.dart';
import '../../data/models/add_service_request_model.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    required int mainCategoryId,
    int? subCategoryId,
  });

  Future<Either<Failure, AddServiceResponseModel>> addService({
    required int serviceId,
    required double amount,
    required bool isNegotiable,
    List<MediaItemModel> media = const [],
  });

  Future<Either<Failure, void>> removeService(int serviceId);

  Future<Either<Failure, void>> removeSubCategory(int subCategoryId);

  Future<Either<Failure, MediaItemModel>> uploadMedia(XFile file);
}
