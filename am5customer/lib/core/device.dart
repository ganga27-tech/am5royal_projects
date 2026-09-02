import 'package:flutter/foundation.dart';
import 'package:am5_core/am5_core.dart';
import 'package:uuid/uuid.dart';

Future<DeviceInfo> resolveDeviceInfo({String name = 'Livora Customer'}) async {
  final id = const Uuid().v4();
  final String platform;
  if (kIsWeb) {
    platform = 'web';
  } else {
    platform = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      _ => 'other',
    };
  }
  return DeviceInfo(deviceId: id, deviceName: name, platform: platform);
}
