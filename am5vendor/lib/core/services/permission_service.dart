import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request all required permissions sequentially for a clean UX flow
  static Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final Map<Permission, PermissionStatus> statuses = {};

    // 1. Request Notification Permission
    statuses[Permission.notification] = await Permission.notification.request();

    // 2. Request Location Permission
    statuses[Permission.locationWhenInUse] = await Permission.locationWhenInUse.request();

    // 3. Request SMS Permission (Only applicable to Android)
    if (defaultTargetPlatform == TargetPlatform.android) {
      statuses[Permission.sms] = await Permission.sms.request();
    } else {
      statuses[Permission.sms] = PermissionStatus.granted; // Mock grant on iOS/Web
    }

    // 4. Request Contacts Permission
    statuses[Permission.contacts] = await Permission.contacts.request();

    return statuses;
  }

  /// Checks if all core required permissions have been granted by the user
  static Future<bool> hasAllPermissionsGranted() async {
    final notification = await Permission.notification.isGranted;
    final location = await Permission.locationWhenInUse.isGranted;
    final contacts = await Permission.contacts.isGranted;

    bool smsGranted = true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      smsGranted = await Permission.sms.isGranted;
    }

    return notification && location && contacts && smsGranted;
  }
}
