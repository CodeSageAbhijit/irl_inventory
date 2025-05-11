import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<String> getDeviceArchitecture() async {
  try {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      // Return the primary ABI (first in the list)
      return androidInfo.supportedAbis.isNotEmpty 
          ? androidInfo.supportedAbis[0] 
          : 'armeabi-v7a';
    }
    return 'universal'; // For iOS/other platforms
  } catch (e) {
    print('Error detecting architecture: $e');
    return 'universal';
  }
}