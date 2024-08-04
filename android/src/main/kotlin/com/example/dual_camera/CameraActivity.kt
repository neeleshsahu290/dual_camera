package com.example.camera_native

// CameraActivity.java

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Typeface
import android.media.ExifInterface
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Button
import android.widget.ImageButton
import android.widget.ImageView
import android.widget.RelativeLayout
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.example.dual_camera.R
import io.flutter.embedding.android.FlutterActivity
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.concurrent.ExecutionException


class CameraActivity : FlutterActivity() {
    private var imageCapture: ImageCapture? = null
   private var TIMESTAMPFORMAT= "yyyyMMdd_HHmmss_SSS";

    private  var btnCature:Button?=null
    private  var imageUri:Uri?=null;
    private var lensFacing: Int = CameraSelector.LENS_FACING_BACK
    private  var cameraPathOne:String?=null
    private  var cameraPathSecond:String?=null

    private  var isFirstImageClicked =false;

    private lateinit var imageView :ImageView
    private lateinit var imageViewLayout :RelativeLayout
    private lateinit var progressBar :RelativeLayout

    private lateinit var captureImageLayout :RelativeLayout

    private  var isBothCamera: Boolean =false;

    private  var isGeoTagEnable: Boolean? = false;
    private  var longitude: Double? = null;
    private  var latitude: Double? = null;

    private  var isClicked=false;

    private lateinit var cameraFrame: PreviewView

    override   fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_camera)

        val hashMap: HashMap<String, Any> =intent.getSerializableExtra("arguments") as HashMap<String, Any>

        isBothCamera = hashMap["isBothCamera"] as Boolean
        isGeoTagEnable = hashMap["isGeoTagEnable"] as Boolean?
        longitude = hashMap["latitude"] as Double?
        latitude = hashMap["longitude"] as Double?
//        longitude =1.0;
//        latitude = 2.0;

        imageView = findViewById<ImageView>(R.id.camera_image)
        imageViewLayout = findViewById(R.id.viewimage_layout)
        captureImageLayout = findViewById(R.id.liner_layout)

        progressBar = findViewById(R.id.progress_circular)

        cameraFrame = findViewById(R.id.camera_frame)

        btnCature = findViewById(R.id.capture_btn)

        btnCature?.setOnClickListener(){
            if (!isClicked) {
                isClicked=true
                progressBar.visibility=View.VISIBLE
                btnCature?.visibility = View.INVISIBLE
                takePhoto();
            }
        }
        findViewById<Button>(R.id.cancel_btn).setOnClickListener(){
            cameraPathOne=null;
            cameraPathSecond=null;
            this@CameraActivity.finish(); }
       findViewById<ImageButton>(R.id.camera_toggle).setOnClickListener(){
           toggleLensSwitch()
        }
        findViewById<ImageButton>(R.id.btn_ok).setOnClickListener(){
            this@CameraActivity.finish();
        }
        findViewById<ImageButton>(R.id.btn_clear).setOnClickListener(){
            reCapture()
        }
       startCamera()
    }

    private  fun toggleLensSwitch( ){
        if(lensFacing==CameraSelector.LENS_FACING_BACK){
            this.lensFacing = CameraSelector.LENS_FACING_FRONT
        }else{
            lensFacing = CameraSelector.LENS_FACING_BACK
        }
        startCamera()
    }


    private  fun startCamera( ){
        try {

        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            try {
                val cameraProvider = cameraProviderFuture.get()
                bindPreview(cameraProvider)
            } catch (e: ExecutionException) {
                // Handle errors
            } catch (_: InterruptedException) {
            }
        }, ContextCompat.getMainExecutor(this))
        }catch (e: ExecutionException){
            print(e);
        }

    }
    private fun bindPreview(cameraProvider: ProcessCameraProvider ) {
        val preview = Preview.Builder().build()
        val cameraSelector = CameraSelector.Builder()
            .requireLensFacing(lensFacing)
            .build()
        imageCapture = ImageCapture.Builder().build()
        if(!isFirstImageClicked){
            preview.setSurfaceProvider( cameraFrame.surfaceProvider)
        }
        try {
            cameraProvider.unbindAll()
            cameraProvider.bindToLifecycle(
                (this as LifecycleOwner),
                cameraSelector,
                preview,
                imageCapture
            )
        } catch (e: Exception) {
            Log.e(TAG, "Use case binding failed", e)
        }
        if(isFirstImageClicked){
        takePhoto()
        }
    }


    private fun  onCaptureDone(){
        if(isBothCamera || isGeoTagEnable == true){
        addGeotagToImage(cameraPathOne) }
        cameraFrame.visibility =View.GONE;
        captureImageLayout.visibility =View.GONE;
        imageView.setImageURI(imageUri)
        imageView.visibility =View.VISIBLE;
        imageViewLayout.visibility=View.VISIBLE
        progressBar.visibility=View.GONE
        btnCature?.visibility = View.VISIBLE
        isClicked=false
        if(isBothCamera){
            isFirstImageClicked=false
            toggleLensSwitch()
            }

    }

    private fun  reCapture(){
        cameraFrame.visibility =View.VISIBLE;
        captureImageLayout.visibility =View.VISIBLE
        imageView.setImageURI(null);
        imageUri=null
        imageView.visibility =View.INVISIBLE;
        imageViewLayout.visibility=View.GONE
    }

    private fun takePhoto() {
        val photoFile = File(
            externalMediaDirs.firstOrNull(),
            SimpleDateFormat(TIMESTAMPFORMAT, Locale.US).format(System.currentTimeMillis()) + ".jpg"
        )

        val outputOptions = ImageCapture.OutputFileOptions.Builder(photoFile).build()

        imageCapture?.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(this),
            object : ImageCapture.OnImageSavedCallback {
                override fun onError(exc: ImageCaptureException) {
                    Log.e(TAG, "Photo capture failed: ${exc.message}", exc)
                }
                override fun
                        onImageSaved(output: ImageCapture.OutputFileResults){
                    val savedUri: Uri = Uri.fromFile(photoFile)

                    if(isBothCamera){
                        if(isFirstImageClicked ){
                            cameraPathSecond = savedUri.path
                            onCaptureDone();
                        }else{
                            imageUri =savedUri;
                            cameraPathOne   = savedUri.path
                            isFirstImageClicked =true
                            toggleLensSwitch();
                        }
                    }else{
                        imageUri =savedUri;
                        cameraPathOne   = savedUri.path
                        onCaptureDone();

                    }
                }
            }
        )


    }

    private fun addGeotagToImage(imagePath: String?) {
        var bitmap = BitmapFactory.decodeFile(imagePath)
        bitmap = imagePath?.let { rotateImageIfRequired(bitmap, it) }
        val mutableBitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true)
        val canvas = Canvas(mutableBitmap)
        val paint = Paint()
        if(isGeoTagEnable == true){
            paint.color = Color.WHITE
            paint.textSize = 80f
            paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD); // Set the text to bold
            val geoTag = "Lat: $latitude, Long: $longitude"
            canvas.drawText(geoTag, 80f, (mutableBitmap.height - 80).toFloat(), paint)
        }

        if(isBothCamera){
            var newBitmap = BitmapFactory.decodeFile(cameraPathSecond)
            newBitmap = imagePath?.let { rotateImageIfRequired(newBitmap, it, true) }
            val matrix = Matrix()
            matrix.preScale(-1.0f, 1.0f)
            newBitmap = Bitmap.createBitmap(newBitmap, 0, 0, newBitmap.width, newBitmap.height, matrix, true)
            newBitmap = Bitmap.createScaledBitmap(newBitmap, newBitmap.width/3, newBitmap.height/3,true)
            canvas.drawBitmap(newBitmap,80f, ( 80f).toFloat(), paint)
        }
        try {
          FileOutputStream(imagePath).use { out ->
                mutableBitmap.compress(
                    Bitmap.CompressFormat.JPEG,
                    60,
                    out
                )
            }
        } catch (e: IOException) {
            e.printStackTrace() 
        }
    }
    @Throws(IOException::class)
    private fun rotateImageIfRequired(img: Bitmap, imagePath: String, isSecondImage:Boolean =false): Bitmap? {
        val ei = ExifInterface(imagePath)
        val orientation =
            ei.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_UNDEFINED)
        return when (orientation) {
            ExifInterface.ORIENTATION_ROTATE_90 -> rotateImage(img, 90F, isSecondImage)
            ExifInterface.ORIENTATION_ROTATE_180 -> rotateImage(img, 180F,isSecondImage)
            ExifInterface.ORIENTATION_ROTATE_270 -> rotateImage(img, 270F,isSecondImage)
            ExifInterface.ORIENTATION_NORMAL ->{
                if (isSecondImage){
                  return  rotateImage(img, 0F,isSecondImage)
                }
                return  img
            }
            else -> img
        }
    }
    private fun rotateImage(img: Bitmap, degree: Float, isSecondImage:Boolean): Bitmap? {
        val matrix = Matrix()
        if(isSecondImage){
            matrix.postRotate(degree+180F)

        }else{
            matrix.postRotate(degree)

        }
        return Bitmap.createBitmap(img, 0, 0, img.width, img.height, matrix, true)
    }

    override fun finish() {
        val intent = Intent()
        intent.putExtra("resultPath", cameraPathOne)
        setResult(RESULT_OK, intent)
        super.finish()
    }
    companion object {
        private const val TAG = "CameraXBasic"
    }
}