import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/device_sync_model.dart';

abstract class DeviceTrackingLocalDataSource {
  Future<DeviceSyncModel> getDeviceSyncModel();
}

class DeviceTrackingLocalDataSourceImpl implements DeviceTrackingLocalDataSource {
  final SharedPreferences sharedPreferences;
  final DeviceInfoPlugin deviceInfoPlugin;

  DeviceTrackingLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.deviceInfoPlugin,
  });

  @override
  Future<DeviceSyncModel> getDeviceSyncModel() async {
    String? deviceId = sharedPreferences.getString('am5_device_id');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await sharedPreferences.setString('am5_device_id', deviceId);
    }

    String? deviceModel;
    String? osVersion;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
        osVersion = 'Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceModel = iosInfo.utsname.machine;
        osVersion = '${iosInfo.systemName} ${iosInfo.systemVersion}';
      }
    } catch (_) {
      // Ignored if platform checks fail on web/desktop
    }

    String? appVersion;
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (_) {
      // Ignored if package info fails
    }

    String? fcmToken = sharedPreferences.getString('fcm_token');

    return DeviceSyncModel(
      deviceId: deviceId,
      deviceModel: deviceModel,
      osVersion: osVersion,
      appVersion: appVersion,
      fcmToken: fcmToken,
    );
  }
}
