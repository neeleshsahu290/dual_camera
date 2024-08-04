import 'dart:ffi';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dual_camera_method_channel.dart';

abstract class DualCameraPlatform extends PlatformInterface {
  /// Constructs a DualCameraPlatform.
  DualCameraPlatform() : super(token: _token);

  static final Object _token = Object();

  static DualCameraPlatform _instance = MethodChannelDualCamera();

  /// The default instance of [DualCameraPlatform] to use.
  ///
  /// Defaults to [MethodChannelDualCamera].
  static DualCameraPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DualCameraPlatform] when
  /// they register themselves.
  static set instance(DualCameraPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {


    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?>  captureImage({bool isBothCamera = false,
        bool isGeoTagEnable =false,
        Double? latitude,
        Double? longitude } ) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
