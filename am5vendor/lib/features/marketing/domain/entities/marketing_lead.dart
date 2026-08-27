class MarketingLead {
  final int id;
  final String shopName;
  final String contactPerson;
  final String phoneNumber;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? shopImageUrl;
  final String? notes;
  final String status;
  final int createdByEmployeeId;
  final int? assignedToEmployeeId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MarketingLead({
    required this.id,
    required this.shopName,
    required this.contactPerson,
    required this.phoneNumber,
    required this.address,
    this.latitude,
    this.longitude,
    this.shopImageUrl,
    this.notes,
    required this.status,
    required this.createdByEmployeeId,
    this.assignedToEmployeeId,
    required this.createdAt,
    required this.updatedAt,
  });
}
