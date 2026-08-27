class VendorAvailability {
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  VendorAvailability({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });
}
