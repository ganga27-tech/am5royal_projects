import 'telecaller_onboarded_vendor_model.dart';

class PaginatedOnboardedVendorsResponseModel {
  final int total;
  final List<TelecallerOnboardedVendorModel> vendors;

  PaginatedOnboardedVendorsResponseModel({
    required this.total,
    required this.vendors,
  });

  factory PaginatedOnboardedVendorsResponseModel.fromJson(Map<String, dynamic> json) {
    return PaginatedOnboardedVendorsResponseModel(
      total: json['total'] ?? 0,
      vendors: (json['vendors'] as List<dynamic>?)
              ?.map((item) => TelecallerOnboardedVendorModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'vendors': vendors.map((item) => item.toJson()).toList(),
    };
  }
}
