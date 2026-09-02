import 'package:equatable/equatable.dart';

class TrackingSnapshot extends Equatable {
  const TrackingSnapshot({
    required this.bookingId,
    required this.bookingCode,
    required this.bookingStatus,
    required this.trackingStatus,
    required this.isLive,
    this.sessionId,
    this.destinationLatitude,
    this.destinationLongitude,
    this.destinationLabel,
    this.professionalLatitude,
    this.professionalLongitude,
    this.professionalHeading,
    this.professionalSpeedKmh,
    this.lastPingAt,
    this.distanceKm,
    this.etaMinutes,
    this.bearingDegrees,
    this.startedAt,
    this.arrivedAt,
    this.endedAt,
  });

  final String bookingId;
  final String bookingCode;
  final String bookingStatus;
  final String? sessionId;
  final String trackingStatus;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String? destinationLabel;
  final double? professionalLatitude;
  final double? professionalLongitude;
  final double? professionalHeading;
  final double? professionalSpeedKmh;
  final String? lastPingAt;
  final double? distanceKm;
  final int? etaMinutes;
  final double? bearingDegrees;
  final String? startedAt;
  final String? arrivedAt;
  final String? endedAt;
  final bool isLive;

  bool get hasDestination =>
      destinationLatitude != null && destinationLongitude != null;

  bool get hasProfessional =>
      professionalLatitude != null && professionalLongitude != null;

  factory TrackingSnapshot.fromJson(Map<String, dynamic> json) {
    double? d(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? i(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return TrackingSnapshot(
      bookingId: json['booking_id'] as String,
      bookingCode: json['booking_code'] as String? ?? '',
      bookingStatus: json['booking_status'] as String? ?? '',
      sessionId: json['session_id'] as String?,
      trackingStatus: json['tracking_status'] as String? ?? 'unavailable',
      destinationLatitude: d(json['destination_latitude']),
      destinationLongitude: d(json['destination_longitude']),
      destinationLabel: json['destination_label'] as String?,
      professionalLatitude: d(json['professional_latitude']),
      professionalLongitude: d(json['professional_longitude']),
      professionalHeading: d(json['professional_heading']),
      professionalSpeedKmh: d(json['professional_speed_kmh']),
      lastPingAt: json['last_ping_at']?.toString(),
      distanceKm: d(json['distance_km']),
      etaMinutes: i(json['eta_minutes']),
      bearingDegrees: d(json['bearing_degrees']),
      startedAt: json['started_at']?.toString(),
      arrivedAt: json['arrived_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
      isLive: json['is_live'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [bookingId, trackingStatus, lastPingAt, professionalLatitude];
}

class LocationPing extends Equatable {
  const LocationPing({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.source,
    this.accuracyM,
    this.heading,
    this.speedKmh,
  });

  final String id;
  final double latitude;
  final double longitude;
  final double? accuracyM;
  final double? heading;
  final double? speedKmh;
  final String recordedAt;
  final String source;

  factory LocationPing.fromJson(Map<String, dynamic> json) {
    double numVal(dynamic v) => v is num ? v.toDouble() : double.parse(v.toString());
    double? opt(dynamic v) => v == null ? null : numVal(v);
    return LocationPing(
      id: json['id'] as String,
      latitude: numVal(json['latitude']),
      longitude: numVal(json['longitude']),
      accuracyM: opt(json['accuracy_m']),
      heading: opt(json['heading']),
      speedKmh: opt(json['speed_kmh']),
      recordedAt: json['recorded_at']?.toString() ?? '',
      source: json['source'] as String? ?? 'gps',
    );
  }

  @override
  List<Object?> get props => [id, latitude, longitude];
}

class RouteEstimate extends Equatable {
  const RouteEstimate({
    required this.distanceKm,
    required this.etaMinutes,
    required this.bearingDegrees,
    this.provider = 'haversine',
  });

  final double distanceKm;
  final int etaMinutes;
  final double bearingDegrees;
  final String provider;

  factory RouteEstimate.fromJson(Map<String, dynamic> json) {
    double numVal(dynamic v) => v is num ? v.toDouble() : double.parse(v.toString());
    return RouteEstimate(
      distanceKm: numVal(json['distance_km']),
      etaMinutes: json['eta_minutes'] is int
          ? json['eta_minutes'] as int
          : int.parse(json['eta_minutes'].toString()),
      bearingDegrees: numVal(json['bearing_degrees']),
      provider: json['provider'] as String? ?? 'haversine',
    );
  }

  @override
  List<Object?> get props => [distanceKm, etaMinutes];
}
