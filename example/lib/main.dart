import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:dual_camera/dual_camera.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _dualCameraPlugin = DualCamera();

  @override
  void initState() {
    super.initState();
    // initPlatformState();
  }

  requestPerission(BuildContext context) async {
    if (await Permission.camera.request().isGranted) {
      initPlatformState(context);
      return;
    }

    await Permission.camera.onDeniedCallback(() {
      requestPerission(context);
      // Your code
    }).onGrantedCallback(() {
      initPlatformState(context);
      // Your code
    }).onPermanentlyDeniedCallback(() {
      // Your code
    }).onRestrictedCallback(() {
      // Your code
    }).onLimitedCallback(() {
      // Your code
    }).onProvisionalCallback(() {
      // Your code
    }).request();
    ;
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState(BuildContext context) async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      String platformVersion =
          await _dualCameraPlugin.captureImage(isBothCamera: true,isGeoTagEnable: true) ?? 'Unknown platform version';

      log("platform_image_path " + platformVersion);
    } catch (e) {
      log(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
              onPressed: () {
                requestPerission(context);
              },
              child: Text("click here")),
        ),
      ),
    );
  }
}
