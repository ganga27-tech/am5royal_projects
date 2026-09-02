import 'package:equatable/equatable.dart';

class UserAddress extends Equatable {
  const UserAddress({
    required this.id,
    required this.label,
    required this.line1,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
    required this.isServiceable,
    this.labelCustom,
    this.line2,
    this.landmark,
    this.latitude,
    this.longitude,
    this.notes,
  });

  final String id;
  final String label;
  final String? labelCustom;
  final String line1;
  final String? line2;
  final String? landmark;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final String? notes;
  final bool isServiceable;

  String get displayLabel {
    if (label == 'other' && (labelCustom?.isNotEmpty ?? false)) {
      return labelCustom!;
    }
    return label[0].toUpperCase() + label.substring(1);
  }

  String get summaryLine => '$line1, $city $postalCode';

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    double? coord(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final labelRaw = (json['label'] as String? ?? 'HOME').toLowerCase();

    return UserAddress(
      id: json['id']?.toString() ?? '',
      label: labelRaw,
      labelCustom: json['label_custom'] as String?,
      line1: (json['line1'] ?? json['address_line1']) as String? ?? '',
      line2: (json['line2'] ?? json['address_line2']) as String?,
      landmark: json['landmark'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      postalCode: (json['postal_code'] ?? json['pincode']) as String? ?? '',
      country: json['country'] as String? ?? 'IN',
      latitude: coord(json['latitude']),
      longitude: coord(json['longitude']),
      isDefault: json['is_default'] as bool? ?? false,
      notes: json['notes'] as String?,
      isServiceable: json['is_serviceable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'label': label,
        if (labelCustom != null) 'label_custom': labelCustom,
        'line1': line1,
        if (line2 != null) 'line2': line2,
        if (landmark != null) 'landmark': landmark,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'is_default': isDefault,
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [id, label, postalCode, isDefault];
}

class ServiceArea extends Equatable {
  const ServiceArea({
    required this.id,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusKm,
    required this.isActive,
    this.postalCodePrefix,
  });

  final String id;
  final String name;
  final String city;
  final String state;
  final String country;
  final String? postalCodePrefix;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusKm;
  final bool isActive;

  factory ServiceArea.fromJson(Map<String, dynamic> json) {
    double numVal(dynamic v) => v is num ? v.toDouble() : double.parse(v.toString());
    return ServiceArea(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String? ?? 'IN',
      postalCodePrefix: json['postal_code_prefix'] as String?,
      centerLatitude: numVal(json['center_latitude']),
      centerLongitude: numVal(json['center_longitude']),
      radiusKm: numVal(json['radius_km']),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  factory ServiceArea.fromAm5City(Map<String, dynamic> json) {
    double? coord(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return ServiceArea(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      city: json['name'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? 'IN',
      centerLatitude: coord(json['latitude']) ?? 0,
      centerLongitude: coord(json['longitude']) ?? 0,
      radiusKm: 25,
      isActive: json['active'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, city, name];
}

class ServiceabilityResult extends Equatable {
  const ServiceabilityResult({
    required this.serviceable,
    required this.message,
    this.matchedAreas = const [],
  });

  final bool serviceable;
  final String message;
  final List<ServiceArea> matchedAreas;

  factory ServiceabilityResult.fromJson(Map<String, dynamic> json) {
    return ServiceabilityResult(
      serviceable: json['serviceable'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      matchedAreas: (json['matched_areas'] as List<dynamic>? ?? [])
          .map((e) => ServiceArea.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [serviceable, message, matchedAreas];
}
