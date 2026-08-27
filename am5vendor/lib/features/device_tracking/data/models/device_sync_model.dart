import '../../domain/entities/device_info_entity.dart';

class DeviceSyncModel extends DeviceInfoEntity {
  const DeviceSyncModel({
    required super.deviceId,
    super.deviceModel,
    super.osVersion,
    super.appVersion,
    super.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      if (deviceModel != null) 'device_model': deviceModel,
      if (osVersion != null) 'os_version': osVersion,
      if (appVersion != null) 'app_version': appVersion,
      if (fcmToken != null) 'fcm_token': fcmToken,
    };
  }
}
