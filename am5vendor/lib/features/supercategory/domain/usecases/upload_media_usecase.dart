import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import '../../../../core/error/failures.dart';
import '../../data/models/add_service_request_model.dart';
import '../repositories/service_repository.dart';

class UploadMediaUseCase {
  final ServiceRepository repository;

  UploadMediaUseCase(this.repository);

  Future<Either<Failure, MediaItemModel>> call(XFile file) async {
    return await repository.uploadMedia(file);
  }
}
