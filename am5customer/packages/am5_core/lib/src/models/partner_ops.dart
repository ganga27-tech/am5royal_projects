import 'package:equatable/equatable.dart';

class PartnerWallet extends Equatable {
  const PartnerWallet({
    required this.id,
    required this.professionalId,
    required this.balance,
    required this.currency,
    required this.status,
  });

  final String id;
  final String professionalId;
  final double balance;
  final String currency;
  final String status;

  factory PartnerWallet.fromJson(Map<String, dynamic> json) {
    final bal = json['balance'];
    return PartnerWallet(
      id: json['id'] as String,
      professionalId: json['professional_id'] as String,
      balance: bal is num ? bal.toDouble() : double.parse('$bal'),
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'active',
    );
  }

  @override
  List<Object?> get props => [id, balance, status];
}

class PartnerLedgerEntry extends Equatable {
  const PartnerLedgerEntry({
    required this.id,
    required this.direction,
    required this.amount,
    required this.reason,
    required this.balanceAfter,
    required this.createdAt,
    this.bookingId,
  });

  final String id;
  final String direction;
  final double amount;
  final String reason;
  final double balanceAfter;
  final String? bookingId;
  final String createdAt;

  factory PartnerLedgerEntry.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) => v is num ? v.toDouble() : double.parse('$v');
    return PartnerLedgerEntry(
      id: json['id'] as String,
      direction: json['direction'] as String,
      amount: n(json['amount']),
      reason: json['reason'] as String? ?? '',
      balanceAfter: n(json['balance_after']),
      bookingId: json['booking_id'] as String?,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, direction, amount];
}

class PartnerWithdrawal extends Equatable {
  const PartnerWithdrawal({
    required this.id,
    required this.amount,
    required this.status,
    required this.payoutMethod,
    required this.createdAt,
    this.payoutDetails,
    this.rejectionReason,
  });

  final String id;
  final double amount;
  final String status;
  final String payoutMethod;
  final String? payoutDetails;
  final String? rejectionReason;
  final String createdAt;

  factory PartnerWithdrawal.fromJson(Map<String, dynamic> json) {
    final amt = json['amount'];
    return PartnerWithdrawal(
      id: json['id'] as String,
      amount: amt is num ? amt.toDouble() : double.parse('$amt'),
      status: json['status'] as String? ?? 'pending',
      payoutMethod: json['payout_method'] as String? ?? 'bank_transfer',
      payoutDetails: json['payout_details'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, status, amount];
}

class PartnerAttendance extends Equatable {
  const PartnerAttendance({
    required this.id,
    required this.workDate,
    required this.status,
    this.checkInAt,
    this.checkOutAt,
    this.notes,
  });

  final String id;
  final String workDate;
  final String? checkInAt;
  final String? checkOutAt;
  final String status;
  final String? notes;

  factory PartnerAttendance.fromJson(Map<String, dynamic> json) {
    return PartnerAttendance(
      id: json['id'] as String,
      workDate: json['work_date']?.toString() ?? '',
      checkInAt: json['check_in_at']?.toString(),
      checkOutAt: json['check_out_at']?.toString(),
      status: json['status'] as String? ?? 'open',
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, workDate, status];
}

class PartnerPerformance extends Equatable {
  const PartnerPerformance({
    required this.professionalId,
    required this.displayName,
    required this.jobsCompleted,
    required this.ratingAvg,
    required this.ratingCount,
    required this.walletBalance,
    required this.attendanceDays30,
    required this.earnings30Days,
    this.onTimeRatePercent,
  });

  final String professionalId;
  final String displayName;
  final int jobsCompleted;
  final double ratingAvg;
  final int ratingCount;
  final double walletBalance;
  final int attendanceDays30;
  final double? onTimeRatePercent;
  final double earnings30Days;

  factory PartnerPerformance.fromJson(Map<String, dynamic> json) {
    double n(dynamic v) {
      if (v == null) return 0;
      return v is num ? v.toDouble() : double.parse('$v');
    }

    return PartnerPerformance(
      professionalId: json['professional_id'] as String,
      displayName: json['display_name'] as String? ?? '',
      jobsCompleted: json['jobs_completed'] as int? ?? 0,
      ratingAvg: n(json['rating_avg']),
      ratingCount: json['rating_count'] as int? ?? 0,
      walletBalance: n(json['wallet_balance']),
      attendanceDays30: json['attendance_days_30'] as int? ?? 0,
      onTimeRatePercent: json['on_time_rate_percent'] == null
          ? null
          : n(json['on_time_rate_percent']),
      earnings30Days: n(json['earnings_30_days']),
    );
  }

  @override
  List<Object?> get props => [professionalId, jobsCompleted, walletBalance];
}
