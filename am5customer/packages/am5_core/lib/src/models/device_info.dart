import 'package:equatable/equatable.dart';

class DeviceInfo extends Equatable {
  const DeviceInfo({
    required this.deviceId,
    this.deviceName,
    this.platform,
  });

  final String deviceId;
  final String? deviceName;
  final String? platform;

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'device_name': deviceName,
        'platform': platform,
      };

  @override
  List<Object?> get props => [deviceId, deviceName, platform];
}
