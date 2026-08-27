import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart' show XFile;

abstract class AddServiceEvent extends Equatable {
  const AddServiceEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAddService extends AddServiceEvent {
  final int serviceId;
  final double amount;
  final bool isNegotiable;
  final List<XFile> imageFiles;
  final XFile? videoFile;

  const SubmitAddService({
    required this.serviceId,
    required this.amount,
    required this.isNegotiable,
    this.imageFiles = const [],
    this.videoFile,
  });

  @override
  List<Object?> get props => [serviceId, amount, isNegotiable, imageFiles, videoFile];
}

class SubmitRemoveService extends AddServiceEvent {
  final int serviceId;

  const SubmitRemoveService(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}
