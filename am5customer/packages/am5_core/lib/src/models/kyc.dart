import 'package:equatable/equatable.dart';

class KycDocument extends Equatable {
  const KycDocument({
    required this.id,
    required this.professionalId,
    required this.docType,
    required this.fileUrl,
    required this.status,
    required this.createdAt,
    this.fileName,
    this.notes,
    this.rejectionReason,
    this.reviewedAt,
  });

  final String id;
  final String professionalId;
  final String docType;
  final String fileUrl;
  final String? fileName;
  final String status;
  final String? notes;
  final String? rejectionReason;
  final String? reviewedAt;
  final String createdAt;

  factory KycDocument.fromJson(Map<String, dynamic> json) {
    return KycDocument(
      id: json['id'] as String,
      professionalId: json['professional_id'] as String,
      docType: json['doc_type'] as String,
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String?,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      reviewedAt: json['reviewed_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, status, docType];
}

class KycStatus extends Equatable {
  const KycStatus({
    required this.professionalId,
    required this.kycStatus,
    required this.isVerified,
    required this.requiredDocTypes,
    required this.missingDocTypes,
    this.kycSubmittedAt,
    this.kycReviewedAt,
    this.kycRejectionReason,
    this.documents = const [],
  });

  final String professionalId;
  final String kycStatus;
  final bool isVerified;
  final String? kycSubmittedAt;
  final String? kycReviewedAt;
  final String? kycRejectionReason;
  final List<String> requiredDocTypes;
  final List<String> missingDocTypes;
  final List<KycDocument> documents;

  factory KycStatus.fromJson(Map<String, dynamic> json) {
    return KycStatus(
      professionalId: json['professional_id'] as String,
      kycStatus: json['kyc_status'] as String? ?? 'unsubmitted',
      isVerified: json['is_verified'] as bool? ?? false,
      kycSubmittedAt: json['kyc_submitted_at']?.toString(),
      kycReviewedAt: json['kyc_reviewed_at']?.toString(),
      kycRejectionReason: json['kyc_rejection_reason'] as String?,
      requiredDocTypes: (json['required_doc_types'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      missingDocTypes: (json['missing_doc_types'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      documents: (json['documents'] as List<dynamic>? ?? [])
          .map((e) => KycDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [professionalId, kycStatus, documents.length];
}

class TimeOffEntry extends Equatable {
  const TimeOffEntry({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    this.reason,
  });

  final String id;
  final String startsAt;
  final String endsAt;
  final String? reason;

  factory TimeOffEntry.fromJson(Map<String, dynamic> json) {
    return TimeOffEntry(
      id: json['id'] as String,
      startsAt: json['starts_at']?.toString() ?? '',
      endsAt: json['ends_at']?.toString() ?? '',
      reason: json['reason'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, startsAt, endsAt];
}
