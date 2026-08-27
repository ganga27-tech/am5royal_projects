class AdminVendor {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? fssaiLicenseNumber;
  final String? panCardNumber;
  final String? gstNumber;
  final String? aadhaarNumber;
  final String? city;
  final String? businessName;
  final String? firstName;
  final String? lastName;
  final String status;
  final DateTime createdAt;
  final int employeeId;
  final String? onboardedByEmployeeName;
  final bool documentsUploaded;
  final bool hasPayment;

  AdminVendor({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.fssaiLicenseNumber,
    this.panCardNumber,
    this.gstNumber,
    this.aadhaarNumber,
    this.city,
    this.businessName,
    this.firstName,
    this.lastName,
    required this.status,
    required this.createdAt,
    required this.employeeId,
    this.onboardedByEmployeeName,
    this.documentsUploaded = false,
    this.hasPayment = false,
  });
}
