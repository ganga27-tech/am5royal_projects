import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import '../../../../supercategory/domain/usecases/upload_media_usecase.dart';
import '../../../data/models/vendor_business_details_request_model.dart';
import '../../../domain/usecases/submit_business_details_usecase.dart';
import 'business_registration_event.dart';
import 'business_registration_state.dart';

class BusinessRegistrationBloc
    extends Bloc<BusinessRegistrationEvent, BusinessRegistrationState> {
  final UploadMediaUseCase uploadMediaUseCase;
  final SubmitBusinessDetailsUseCase submitBusinessDetailsUseCase;

  BusinessRegistrationBloc({
    required this.uploadMediaUseCase,
    required this.submitBusinessDetailsUseCase,
  }) : super(BusinessRegistrationInitial()) {
    on<SubmitBusinessDetailsEvent>(_onSubmitBusinessDetails);
  }

  Future<void> _onSubmitBusinessDetails(
    SubmitBusinessDetailsEvent event,
    Emitter<BusinessRegistrationState> emit,
  ) async {
    debugPrint('BusinessRegistrationBloc: Received SubmitBusinessDetailsEvent');
    debugPrint('gst: ${event.gstNumber}, pan: ${event.panNumber}, aadhaar: ${event.aadhaarNumber}, usc: ${event.uscNumber}');
    debugPrint('files: aadharFront=${event.aadharFrontPath}, aadharBack=${event.aadharBackPath}, panFront=${event.panFrontPath}, panBack=${event.panBackPath}, faceVideo=${event.faceVideoPath}');

    emit(BusinessRegistrationLoading());
    debugPrint('BusinessRegistrationBloc: Emitted BusinessRegistrationLoading');

    try {
      final List<VendorDocumentItemModel> documents = [];

      final uploadTasks = <Future<void>>[];

      void queueUpload(String? path, String type) {
        if (path != null && path.isNotEmpty) {
          uploadTasks.add(Future(() async {
            debugPrint('BusinessRegistrationBloc: Uploading $type from path: $path');
            final uploadResult = await uploadMediaUseCase(XFile(path));
            uploadResult.fold(
              (failure) {
                debugPrint('BusinessRegistrationBloc: Upload failed for $type: ${failure.message}');
                throw Exception(failure.message);
              },
              (mediaItem) {
                debugPrint('BusinessRegistrationBloc: Uploaded $type successfully. URL: ${mediaItem.mediaUrl}');
                documents.add(
                  VendorDocumentItemModel(documentType: type, documentUrl: mediaItem.mediaUrl),
                );
              },
            );
          }));
        } else if (event.existingDocumentUrls[type]?.isNotEmpty == true) {
          documents.add(
            VendorDocumentItemModel(
              documentType: type,
              documentUrl: event.existingDocumentUrls[type]!,
            ),
          );
        }
      }

      queueUpload(event.aadharFrontPath, 'aadhar_front');
      queueUpload(event.aadharBackPath, 'aadhar_back');
      queueUpload(event.panFrontPath, 'pan_front');
      queueUpload(event.panBackPath, 'pan_back');
      queueUpload(event.faceVideoPath, 'face_video');
      queueUpload(event.addressProofPath, 'address_proof');
      queueUpload(event.businessDocPath, 'business_document');
      queueUpload(event.msmeDocPath, 'msme_document');
      queueUpload(event.govtAuthDocPath, 'govt_auth_document');
      queueUpload(event.currentBillDocPath, 'current_bill_document');

      if (uploadTasks.isNotEmpty) {
        await Future.wait(uploadTasks);
      }

      final request = VendorBusinessDetailsRequestModel(
        gstNumber: event.gstNumber != null && event.gstNumber!.trim().isNotEmpty ? event.gstNumber!.trim() : null,
        panNumber: event.panNumber != null && event.panNumber!.trim().isNotEmpty ? event.panNumber!.trim() : null,
        uscNumber: event.uscNumber != null && event.uscNumber!.trim().isNotEmpty ? event.uscNumber!.trim() : null,
        aadhaarNumber: event.aadhaarNumber != null && event.aadhaarNumber!.trim().isNotEmpty ? event.aadhaarNumber!.trim() : null,
        msmeNumber: event.msmeNumber != null && event.msmeNumber!.trim().isNotEmpty ? event.msmeNumber!.trim() : null,
        govtAuthDocNumber: event.govtAuthDocNumber != null && event.govtAuthDocNumber!.trim().isNotEmpty ? event.govtAuthDocNumber!.trim() : null,
        currentBillNumber: event.currentBillNumber != null && event.currentBillNumber!.trim().isNotEmpty ? event.currentBillNumber!.trim() : null,
        documents: documents.isNotEmpty ? documents : null,
      );

      debugPrint('BusinessRegistrationBloc: Submitting details. Documents count: ${documents.length}');
      final result = await submitBusinessDetailsUseCase(
        SubmitBusinessDetailsParams(request: request),
      );

      result.fold(
        (failure) {
          debugPrint('BusinessRegistrationBloc: Submit failed: ${failure.message}');
          emit(BusinessRegistrationFailure(message: failure.message));
        },
        (_) {
          debugPrint('BusinessRegistrationBloc: Submit success!');
          emit(BusinessRegistrationSuccess());
        },
      );
    } catch (e, stack) {
      debugPrint('BusinessRegistrationBloc: Exception in submit details: $e');
      debugPrint('Stack trace: $stack');
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      emit(BusinessRegistrationFailure(message: msg));
    }
  }
}
