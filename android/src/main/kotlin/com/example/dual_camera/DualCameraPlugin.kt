package com.example.dual_camera

import android.app.Activity
import android.content.Context
import android.content.Intent
import androidx.activity.result.ActivityResultLauncher
import com.example.camera_native.CameraActivity
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** DualCameraPlugin */
class DualCameraPlugin: FlutterPlugin, MethodCallHandler , ActivityAware{

  private val REQUEST_IMAGE_CAPTURE = 1
  lateinit var returnResult: MethodChannel.Result


  private  var arguments: HashMap<String, Any>? =null

  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private lateinit var context: Context
  //private lateinit var activityResultLauncher: ActivityResultLauncher<Intent>

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "dual_camera")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext

  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "captureImage") {
      arguments = call.arguments as HashMap<String, Any>
      startCameraActivity(result)
      returnResult  = result;
    } else {
      result.notImplemented()
    }
  }



  private fun startCameraActivity(result: Result) {
    activity?.let {
      val intent = Intent(it, CameraActivity::class.java)
      intent.putExtra("arguments", arguments)
      returnResult = result
      it.startActivityForResult(intent, REQUEST_IMAGE_CAPTURE)
    } ?: result.error("ACTIVITY_NOT_AVAILABLE", "Activity is not available.", null)
  }

   private fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == Activity.RESULT_OK) {
      val resultPath = data?.getStringExtra("resultPath")
      val maps = mapOf("resultPath" to resultPath)
      returnResult.success(maps)
    } else {
      returnResult.error("ACTIVITY_RESULT_ERROR", "Activity result error.", null)
    }
  }
  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addActivityResultListener { requestCode, resultCode, data ->
      onActivityResult(requestCode, resultCode, data)
      true
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}
