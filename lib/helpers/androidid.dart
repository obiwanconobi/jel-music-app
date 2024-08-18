import 'dart:io';

import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';


/// The plugin class for retrieving the Android ID.
class AndroidId {
  const AndroidId();

  /// The method channel used to interact with the native platform.
  static const _methodChannel = MethodChannel('android_id');

  /// Calls the native method to retrieve the Android ID.
  Future<String> getDeviceId() async {
    String? deviceId = "";
   
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      // For iOS, you can use iosInfo to get the unique identifier
      // For example: deviceId = iosInfo.identifierForVendor;
      // Note: Using identifierForVendor might not be suitable for some use cases as it can change if the app is reinstalled or if the device is reset.
    }
    
      // Hashing the deviceId to reach the desired length
  if (deviceId.length < 168) {
    // If deviceId is shorter than 168 characters, hash it
   // deviceId = md5.convert(utf8.encode(deviceId)).toString();
  } else if (deviceId.length > 168) {
    // If deviceId is longer than 168 characters, truncate it
    deviceId = deviceId.substring(0, 168);
  }
  
  // Padding with zeros if necessary
  deviceId = deviceId.padRight(168, '0');
  
  return deviceId;
  }
}
