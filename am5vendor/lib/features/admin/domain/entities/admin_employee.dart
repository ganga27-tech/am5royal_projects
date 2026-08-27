class AdminEmployee {
  final int id;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String role;
  final String status;
  final DateTime createdAt;
  final int points;
  final String? firstName;
  final String? lastName;

  AdminEmployee({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.points,
    this.firstName,
    this.lastName,
  });

  String get name {
    if (firstName != null && firstName!.trim().isNotEmpty) {
      return '$firstName ${lastName ?? ''}'.trim();
    }
    if (email.isEmpty) return 'Unknown';
    if (email.contains('@')) {
      final prefix = email.split('@')[0];
      final parts = prefix.split('.');
      return parts
          .map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}')
          .join(' ');
    }
    return email;
  }
}
