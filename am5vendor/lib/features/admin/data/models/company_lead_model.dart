class CompanyLeadModel {
  final int id;
  final String businessName;
  final String firstName;
  final String lastName;
  final String city;
  final DateTime? createdAt;
  final String? phoneNumber;
  final String? feedback;
  final String? paymentInfo;
  final String? status;
  final String? leadSource;
  final String? assignedTelecallerName;

  CompanyLeadModel({
    required this.id,
    required this.businessName,
    required this.firstName,
    required this.lastName,
    required this.city,
    this.createdAt,
    this.phoneNumber,
    this.feedback,
    this.paymentInfo,
    this.status,
    this.leadSource,
    this.assignedTelecallerName,
  });

  factory CompanyLeadModel.fromJson(Map<String, dynamic> json) {
    return CompanyLeadModel(
      id: json['id'] ?? 0,
      businessName: json['business_name'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      city: json['city'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      phoneNumber: json['phone_number'],
      feedback: json['feedback'],
      paymentInfo: json['payment_info'],
      status: json['status'],
      leadSource: json['lead_source'],
      assignedTelecallerName: json['assigned_telecaller_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'first_name': firstName,
      'last_name': lastName,
      'city': city,
      'created_at': createdAt?.toIso8601String(),
      'phone_number': phoneNumber,
      'feedback': feedback,
      'payment_info': paymentInfo,
      'status': status,
      'lead_source': leadSource,
      'assigned_telecaller_name': assignedTelecallerName,
    };
  }
}

class LeadAssignResultModel {
  final int assignedCount;
  final int telecallersCount;

  LeadAssignResultModel({
    required this.assignedCount,
    required this.telecallersCount,
  });

  factory LeadAssignResultModel.fromJson(Map<String, dynamic> json) {
    return LeadAssignResultModel(
      assignedCount: json['assigned_count'] ?? 0,
      telecallersCount: json['telecallers_count'] ?? 0,
    );
  }
}

class CompanyLeadsPaginatedResponseModel {
  final List<CompanyLeadModel> leads;
  final int total;

  CompanyLeadsPaginatedResponseModel({
    required this.leads,
    required this.total,
  });

  factory CompanyLeadsPaginatedResponseModel.fromJson(
      Map<String, dynamic> json) {
    final list = (json['leads'] as List?)
            ?.map((e) => CompanyLeadModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return CompanyLeadsPaginatedResponseModel(
      leads: list,
      total: json['total'] ?? 0,
    );
  }
}
