import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/main_category_api_service.dart';
import '../models/add_service_response_model.dart';
import '../models/add_service_request_model.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final MainCategoryApiService apiService;

  ServiceRepositoryImpl({required this.apiService});

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    required int mainCategoryId,
    int? subCategoryId,
  }) async {
    try {
      final models = await apiService.getServices(
        mainCategoryId: mainCategoryId,
        subCategoryId: subCategoryId,
      );
      return Right(models);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AddServiceResponseModel>> addService({
    required int serviceId,
    required double amount,
    required bool isNegotiable,
    List<MediaItemModel> media = const [],
  }) async {
    try {
      final model = await apiService.addService(
        serviceId: serviceId,
        amount: amount,
        isNegotiable: isNegotiable,
        media: media,
      );
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeService(int serviceId) async {
    try {
      await apiService.removeService(serviceId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeSubCategory(int subCategoryId) async {
    try {
      await apiService.removeSubCategory(subCategoryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MediaItemModel>> uploadMedia(XFile file) async {
    try {
      final model = await apiService.uploadMedia(file);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
