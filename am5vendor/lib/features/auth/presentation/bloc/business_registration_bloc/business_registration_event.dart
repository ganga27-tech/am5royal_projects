import 'package:equatable/equatable.dart';

abstract class BusinessRegistrationEvent extends Equatable {
  const BusinessRegistrationEvent();

  @override
  List<Object?> get props => [];
}

class SubmitBusinessDetailsEvent extends BusinessRegistrationEvent {
  final String? gstNumber;
  final String? panNumber;
  final String? uscNumber;
  final String? aadhaarNumber;
  final String? msmeNumber;
  final String? govtAuthDocNumber;
  final String? currentBillNumber;

  final String? aadharFrontPath;
  final String? aadharBackPath;
  final String? panFrontPath;
  final String? panBackPath;
  final String? faceVideoPath;
  final String? addressProofPath;
  final String? businessDocPath;
  final String? msmeDocPath;
  final String? govtAuthDocPath;
  final String? currentBillDocPath;
  final Map<String, String> existingDocumentUrls;

  const SubmitBusinessDetailsEvent({
    this.gstNumber,
    this.panNumber,
    this.uscNumber,
    this.aadhaarNumber,
    this.msmeNumber,
    this.govtAuthDocNumber,
    this.currentBillNumber,
    this.aadharFrontPath,
    this.aadharBackPath,
    this.panFrontPath,
    this.panBackPath,
    this.faceVideoPath,
    this.addressProofPath,
    this.businessDocPath,
    this.msmeDocPath,
    this.govtAuthDocPath,
    this.currentBillDocPath,
    this.existingDocumentUrls = const {},
  });

  @override
  List<Object?> get props => [
        gstNumber,
        panNumber,
        uscNumber,
        aadhaarNumber,
        msmeNumber,
        govtAuthDocNumber,
        currentBillNumber,
        aadharFrontPath,
        aadharBackPath,
        panFrontPath,
        panBackPath,
        faceVideoPath,
        addressProofPath,
        businessDocPath,
        msmeDocPath,
        govtAuthDocPath,
        currentBillDocPath,
        existingDocumentUrls,
      ];
}
