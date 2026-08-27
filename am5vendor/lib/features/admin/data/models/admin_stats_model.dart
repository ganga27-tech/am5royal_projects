import '../../domain/entities/admin_stats.dart';

class AdminStatsModel extends AdminStats {
  AdminStatsModel({
    required super.totalEmployees,
    required super.activeEmployees,
    required super.totalVendors,
    required super.activeVendors,
    required super.pendingVendors,
    required super.totalSales,
    required super.monthlyGrowth,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalEmployees: json['total_employees'] ?? 0,
      activeEmployees: json['active_employees'] ?? 0,
      totalVendors: json['total_vendors'] ?? 0,
      activeVendors: json['active_vendors'] ?? 0,
      pendingVendors: json['pending_vendors'] ?? 0,
      totalSales: (json['total_sales'] ?? 0.0).toDouble(),
      monthlyGrowth: json['monthly_growth'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_employees': totalEmployees,
      'active_employees': activeEmployees,
      'total_vendors': totalVendors,
      'active_vendors': activeVendors,
      'pending_vendors': pendingVendors,
      'total_sales': totalSales,
      'monthly_growth': monthlyGrowth,
    };
  }
}
