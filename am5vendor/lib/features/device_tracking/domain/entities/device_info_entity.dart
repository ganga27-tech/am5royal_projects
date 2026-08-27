class DeviceInfoEntity {
  final String deviceId;
  final String? deviceModel;
  final String? osVersion;
  final String? appVersion;
  final String? fcmToken;

  const DeviceInfoEntity({
    required this.deviceId,
    this.deviceModel,
    this.osVersion,
    this.appVersion,
    this.fcmToken,
  });
}
