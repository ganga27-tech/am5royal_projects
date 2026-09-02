import 'package:equatable/equatable.dart';

class VerificationSummary extends Equatable {
  const VerificationSummary({
    required this.kycPendingCount,
    required this.kycDocsPendingCount,
    required this.withdrawalsPendingCount,
    required this.openEscalationsCount,
    required this.dispatchPendingCount,
  });

  final int kycPendingCount;
  final int kycDocsPendingCount;
  final int withdrawalsPendingCount;
  final int openEscalationsCount;
  final int dispatchPendingCount;

  factory VerificationSummary.fromJson(Map<String, dynamic> json) {
    return VerificationSummary(
      kycPendingCount: json['kyc_pending_count'] as int? ?? 0,
      kycDocsPendingCount: json['kyc_docs_pending_count'] as int? ?? 0,
      withdrawalsPendingCount: json['withdrawals_pending_count'] as int? ?? 0,
      openEscalationsCount: json['open_escalations_count'] as int? ?? 0,
      dispatchPendingCount: json['dispatch_pending_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [kycPendingCount, dispatchPendingCount, openEscalationsCount];
}

class AssignmentCandidate extends Equatable {
  const AssignmentCandidate({
    required this.professionalId,
    required this.displayName,
    required this.ratingAvg,
    required this.jobsCompleted,
    required this.isVerified,
    this.city,
  });

  final String professionalId;
  final String displayName;
  final double ratingAvg;
  final int jobsCompleted;
  final String? city;
  final bool isVerified;

  factory AssignmentCandidate.fromJson(Map<String, dynamic> json) {
    final r = json['rating_avg'];
    return AssignmentCandidate(
      professionalId: json['professional_id'] as String,
      displayName: json['display_name'] as String? ?? '',
      ratingAvg: r is num ? r.toDouble() : double.parse('$r'),
      jobsCompleted: json['jobs_completed'] as int? ?? 0,
      city: json['city'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [professionalId, displayName];
}

class OpsEscalation extends Equatable {
  const OpsEscalation({
    required this.id,
    required this.escalationCode,
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.description,
    this.bookingId,
    this.resolutionNotes,
  });

  final String id;
  final String escalationCode;
  final String title;
  final String? description;
  final String category;
  final String priority;
  final String status;
  final String? bookingId;
  final String? resolutionNotes;
  final String createdAt;

  factory OpsEscalation.fromJson(Map<String, dynamic> json) {
    return OpsEscalation(
      id: json['id'] as String,
      escalationCode: json['escalation_code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'booking',
      priority: json['priority'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'open',
      bookingId: json['booking_id'] as String?,
      resolutionNotes: json['resolution_notes'] as String?,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, status, priority];
}

class PartnerWithdrawalOps extends Equatable {
  const PartnerWithdrawalOps({
    required this.id,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.payoutMethod,
  });

  final String id;
  final double amount;
  final String status;
  final String? payoutMethod;
  final String createdAt;

  factory PartnerWithdrawalOps.fromJson(Map<String, dynamic> json) {
    final amt = json['amount'];
    return PartnerWithdrawalOps(
      id: json['id'] as String,
      amount: amt is num ? amt.toDouble() : double.parse('$amt'),
      status: json['status'] as String? ?? 'pending',
      payoutMethod: json['payout_method'] as String?,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, status, amount];
}
