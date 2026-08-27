class AdminStats {
  final int totalEmployees;
  final int activeEmployees;
  final int totalVendors;
  final int activeVendors;
  final int pendingVendors;
  final double totalSales;
  final List<dynamic> monthlyGrowth;

  AdminStats({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.totalVendors,
    required this.activeVendors,
    required this.pendingVendors,
    required this.totalSales,
    required this.monthlyGrowth,
  });
}
