import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

bool shouldRequestNotificationPermission({
  required bool isAndroid,
  required int sdkInt,
}) {
  return isAndroid && sdkInt >= 33;
}

Future<void> requestNotificationPermissionIfNeeded() async {
  if (!Platform.isAndroid) return;

  final sdkInt = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
  if (!shouldRequestNotificationPermission(
    isAndroid: Platform.isAndroid,
    sdkInt: sdkInt,
  )) {
    return;
  }

  await Permission.notification.request();
}
