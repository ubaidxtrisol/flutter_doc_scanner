package com.shirsh.flutter_doc_scanner

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Size
import androidx.annotation.OptIn
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageCapture
import androidx.camera.core.ImageCaptureException
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.core.resolutionselector.AspectRatioStrategy
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.view.TextureRegistry
import com.google.mlkit.vision.common.InputImage
import org.opencv.android.OpenCVLoader
import org.opencv.core.CvType
import org.opencv.core.Mat
import java.io.File
import java.util.concurrent.Executors

/** Camera + detection engine. Contract: docs/SCANNER_PHASES.md §1.2. */
class FlutterDocScannerPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler, PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var events: EventChannel
    private lateinit var textures: TextureRegistry
    private lateinit var context: Context
    private var binding: ActivityPluginBinding? = null
    private var sink: EventChannel.EventSink? = null
    private var onPermission: ((Boolean) -> Unit)? = null

    private val main = Handler(Looper.getMainLooper())
    private val analysisThread = Executors.newSingleThreadExecutor()
    private val workers = Executors.newFixedThreadPool(2)
    private val liveVision by lazy { DocVision() } // analysisThread only

    private var provider: ProcessCameraProvider? = null
    private var camera: Camera? = null
    private var producer: TextureRegistry.SurfaceProducer? = null
    private var imageCapture: ImageCapture? = null
    @Volatile private var mode = "document"

    override fun onAttachedToEngine(b: FlutterPlugin.FlutterPluginBinding) {
        OpenCVLoader.initLocal()
        context = b.applicationContext
        textures = b.textureRegistry
        channel = MethodChannel(b.binaryMessenger, "flutter_doc_scanner").also { it.setMethodCallHandler(this) }
        events = EventChannel(b.binaryMessenger, "flutter_doc_scanner/detections").also { it.setStreamHandler(this) }
    }

    override fun onDetachedFromEngine(b: FlutterPlugin.FlutterPluginBinding) {
        stop()
        channel.setMethodCallHandler(null)
        events.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "start" -> {
                call.argument<String>("mode")?.let { mode = it }
                withPermission(result) { start(result) }
            }
            "setMode" -> {
                mode = call.argument<String>("mode") ?: mode
                result.success(null)
            }
            "setTorch" -> {
                camera?.cameraControl?.enableTorch(call.argument<Boolean>("on") == true)
                result.success(null)
            }
            "capture" -> capture(result)
            "analyze" -> inBackground(result) {
                analyzeFile(call.argument<String>("path")!!, call.argument<String>("mode") ?: "document")
            }
            "process" -> inBackground(result) {
                DocVision.process(
                    path = call.argument<String>("path")!!,
                    corners = call.argument<List<Double>>("corners"),
                    rotation = call.argument<Int>("rotation") ?: 0,
                    filter = call.argument<String>("filter") ?: "original",
                    outPath = call.argument<String>("outPath")!!,
                    maxSize = call.argument<Int>("maxSize"),
                )
            }
            "stop" -> {
                stop()
                result.success(null)
            }
            "openSettings" -> {
                context.startActivity(
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", context.packageName, null))
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                )
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun start(result: Result) {
        val owner = binding?.activity as? LifecycleOwner
            ?: return result.error("NO_ACTIVITY", "Scanner needs a foreground FlutterActivity", null)
        val future = ProcessCameraProvider.getInstance(context)
        future.addListener({
            try {
                val provider = future.get().also { provider = it }
                provider.unbindAll()
                producer?.release()
                val producer = textures.createSurfaceProducer().also { producer = it }

                // Same 4:3 ratio everywhere so preview, analysis and photo see the same field of view.
                val ratio = AspectRatioStrategy.RATIO_4_3_FALLBACK_AUTO_STRATEGY
                val full = ResolutionSelector.Builder().setAspectRatioStrategy(ratio).build()
                val preview = Preview.Builder().setResolutionSelector(full).build()
                preview.setSurfaceProvider { request ->
                    producer.setCallback(object : TextureRegistry.SurfaceProducer.Callback {
                        override fun onSurfaceAvailable() {}
                        override fun onSurfaceCleanup() = request.invalidate().let {}
                    })
                    producer.setSize(request.resolution.width, request.resolution.height)
                    val surface = producer.forcedNewSurface
                    request.provideSurface(surface, workers) { surface.release() }
                }
                val analysis = ImageAnalysis.Builder()
                    .setResolutionSelector(
                        ResolutionSelector.Builder()
                            .setAspectRatioStrategy(ratio)
                            .setResolutionStrategy(
                                // Big enough for MRZ text; the page detector downsizes internally.
                                ResolutionStrategy(Size(1280, 960), ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER),
                            ).build(),
                    )
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .build()
                analysis.setAnalyzer(analysisThread, ::analyze)
                val capture = ImageCapture.Builder()
                    .setResolutionSelector(full)
                    .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                    .build()
                imageCapture = capture
                val cam = provider.bindToLifecycle(owner, CameraSelector.DEFAULT_BACK_CAMERA, preview, analysis, capture)
                camera = cam

                val res = preview.resolutionInfo?.resolution ?: Size(1440, 1080)
                val sensor = cam.cameraInfo.sensorRotationDegrees
                val sideways = sensor % 180 != 0
                result.success(
                    mapOf(
                        "textureId" to producer.id(),
                        // Portrait size of the preview.
                        "width" to if (sideways) res.height else res.width,
                        "height" to if (sideways) res.width else res.height,
                        // Rotation Dart must apply to the raw texture (0 if the engine already does it).
                        "quarterTurns" to if (producer.handlesCropAndRotation()) 0 else sensor / 90,
                    ),
                )
            } catch (e: Exception) {
                result.error("CAMERA_FAILED", e.message, null)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    @OptIn(ExperimentalGetImage::class)
    private fun analyze(image: ImageProxy) {
        image.use {
            val m = mode
            if (sink == null) return
            val rot = image.imageInfo.rotationDegrees
            val event = runCatching {
                when (m) {
                    "document", "book", "idCard" -> {
                        val y = image.planes[0]
                        val gray = Mat(image.height, image.width, CvType.CV_8UC1, y.buffer, y.rowStride.toLong())
                        val chroma = { DocVision.chromaOf(plane(image.planes[1], image.width / 2, image.height / 2), plane(image.planes[2], image.width / 2, image.height / 2)) }
                        val quad = if (m == "idCard") {
                            liveVision.detect(gray, minArea = CARD_MIN_AREA, aspect = CARD_ASPECT, chroma = chroma)
                        } else {
                            liveVision.detect(gray, chroma = chroma)
                        }
                        gray.release()
                        mapOf("corners" to quad?.let { DocVision.order(DocVision.rotate(it, rot)) }?.toList())
                    }
                    "qr", "passport", "math" -> {
                        val input = InputImage.fromMediaImage(image.image ?: return, rot)
                        val (w, h) = if (rot % 180 == 0) image.width to image.height else image.height to image.width
                        if (m == "qr") mapOf("codes" to Readers.codes(input, w, h))
                        else mapOf("lines" to Readers.lines(input, w, h, mrzOnly = m == "passport"))
                    }
                    else -> return
                }
            }.getOrElse { return }
            main.post { sink?.success(event + ("mode" to m)) }
        }
    }

    /** Copies a subsampled U or V plane (pixel stride 1 or 2) into a compact Mat. */
    private fun plane(p: ImageProxy.PlaneProxy, w: Int, h: Int): Mat {
        val buf = p.buffer
        val out = ByteArray(w * h)
        for (y in 0 until h) {
            val row = y * p.rowStride
            for (x in 0 until w) out[y * w + x] = buf.get(row + x * p.pixelStride)
        }
        return Mat(h, w, CvType.CV_8UC1).apply { put(0, 0, out) }
    }

    /** Same result shape as a live detection event, for an image file (gallery import). */
    private fun analyzeFile(path: String, m: String): Map<String, Any?> = when (m) {
        "qr", "passport", "math" -> {
            val input = InputImage.fromFilePath(context, Uri.fromFile(File(path)))
            if (m == "qr") mapOf("codes" to Readers.codes(input, input.width, input.height))
            else mapOf("lines" to Readers.lines(input, input.width, input.height, mrzOnly = m == "passport"))
        }
        else -> mapOf("corners" to detectFile(path, m)?.toList())
    } + ("mode" to m)

    private fun detectFile(path: String, m: String) =
        if (m == "idCard") DocVision().detectFile(path, CARD_MIN_AREA, CARD_ASPECT) else DocVision().detectFile(path)

    private fun capture(result: Result) {
        val cap = imageCapture ?: return result.error("NOT_STARTED", "Call start first", null)
        val dir = File(context.cacheDir, "scans").apply { mkdirs() }
        val file = File(dir, "cap_${System.currentTimeMillis()}.jpg")
        cap.takePicture(
            ImageCapture.OutputFileOptions.Builder(file).build(),
            workers,
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    // Re-detect on the real photo: sharper and more accurate than the 640px preview frame.
                    val corners = runCatching { detectFile(file.path, mode) }.getOrNull()
                    main.post { result.success(mapOf("path" to file.path, "corners" to corners?.toList())) }
                }

                override fun onError(e: ImageCaptureException) {
                    main.post { result.error("CAPTURE_FAILED", e.message, null) }
                }
            },
        )
    }

    private fun stop() {
        provider?.unbindAll()
        producer?.release()
        producer = null
        camera = null
        imageCapture = null
    }

    private fun inBackground(result: Result, block: () -> Any?) = workers.execute {
        try {
            val value = block()
            main.post { result.success(value) }
        } catch (e: Exception) {
            main.post { result.error("FAILED", e.message, null) }
        }
    }

    private fun withPermission(result: Result, granted: () -> Unit) {
        val activity = binding?.activity
            ?: return result.error("NO_ACTIVITY", "Scanner needs a foreground activity", null)
        if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            return granted()
        }
        if (onPermission != null) return result.error("PERMISSION_PENDING", "Permission request in progress", null)
        onPermission = { ok -> if (ok) granted() else result.error("PERMISSION_DENIED", "Camera permission denied", null) }
        ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.CAMERA), PERMISSION_REQUEST)
    }

    override fun onRequestPermissionsResult(code: Int, permissions: Array<out String>, results: IntArray): Boolean {
        if (code != PERMISSION_REQUEST) return false
        onPermission?.invoke(results.firstOrNull() == PackageManager.PERMISSION_GRANTED)
        onPermission = null
        return true
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        sink = events
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    override fun onAttachedToActivity(b: ActivityPluginBinding) {
        binding = b
        b.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        stop()
        binding?.removeRequestPermissionsResultListener(this)
        binding = null
    }

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()
    override fun onReattachedToActivityForConfigChanges(b: ActivityPluginBinding) = onAttachedToActivity(b)

    private companion object {
        const val PERMISSION_REQUEST = 7301

        // ID-1 cards are 85.6 × 54 mm (1.586). The range absorbs perspective tilt but starts above A4 (1.414),
        // so a sheet of paper held square-on isn't taken for a card. Cards sit smaller in frame than pages.
        val CARD_ASPECT = 1.45..1.85
        const val CARD_MIN_AREA = 0.06
    }
}
