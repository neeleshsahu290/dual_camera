import 'dart:ffi';

import 'dual_camera_platform_interface.dart';

class DualCamera {
  Future<String?> getPlatformVersion() {
    return DualCameraPlatform.instance.getPlatformVersion();
  }

  Future<String?> captureImage(
      {bool isBothCamera = false,
      bool isGeoTagEnable = false,
      Double? latitude,
      Double? longitude}) async {
    return await DualCameraPlatform.instance.captureImage(
        isBothCamera: isBothCamera,
        isGeoTagEnable: isGeoTagEnable,
        latitude: latitude,
        longitude: longitude);
  }
}
