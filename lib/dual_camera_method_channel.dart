import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dual_camera_platform_interface.dart';

/// An implementation of [DualCameraPlatform] that uses method channels.
class MethodChannelDualCamera extends DualCameraPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('dual_camera');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
Future<String?> captureImage({bool isBothCamera = false, bool isGeoTagEnable = false, Double? latitude, Double? longitude}) async {
  

    try {
      final Map result =
          await methodChannel.invokeMethod('captureImage', <String, dynamic>{
        "isBothCamera": isBothCamera,
        "isGeoTagEnable": isGeoTagEnable,
        "latitude": latitude??0.0,
        "longitude": longitude??0.0
      });
      return result['resultPath'];
    } catch (e) {
      log('Error calling native method: $e');
    }
    return null;
   //return super.captureImage( isBothCamera, isGeoTagEnable, latitude, longitude);
  }

  //   captureImage() async {
  //   try {
  //     final Map result =
  //         await methodChannel.invokeMethod('captureImage', <String, dynamic>{
  //       "isBothCamera": true,
  //       "isGeoTagEnable": true,
  //       "latitude": 1.0256,
  //       "longitude": 12223.4455
  //     });
  //     return result['resultPath'];

  //   } catch (e) {
  //     log('Error calling native method: $e');
  //   }
  //   return null;
  // }
}
