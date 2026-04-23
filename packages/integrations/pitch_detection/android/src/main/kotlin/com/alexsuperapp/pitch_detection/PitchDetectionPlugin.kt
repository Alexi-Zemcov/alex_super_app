package com.alexsuperapp.pitch_detection

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import be.tarsos.dsp.pitch.PitchDetector
import be.tarsos.dsp.pitch.PitchProcessor
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.max
import kotlin.math.sqrt

class PitchDetectionPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {
    private lateinit var applicationContext: Context
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var activity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var permissionResult: MethodChannel.Result? = null

    private var audioRecord: AudioRecord? = null
    private var detectionExecutor: ExecutorService? = null
    private val isDetecting = AtomicBoolean(false)

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        methodChannel =
            MethodChannel(
                binding.binaryMessenger,
                "com.alexsuperapp/pitch_detection/methods",
            )
        eventChannel =
            EventChannel(
                binding.binaryMessenger,
                "com.alexsuperapp/pitch_detection/frames",
            )
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopDetection()
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        activityBinding = binding
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        detachActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        detachActivity()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        stopDetection()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestMicrophonePermission" -> requestMicrophonePermission(result)
            "startDetection" -> {
                val config = DetectionConfig.fromArguments(call.arguments)
                if (config == null) {
                    result.error("nativeFailure", "Invalid detection config.", null)
                    return
                }
                startDetection(config, result)
            }
            "stop" -> {
                stopDetection()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != microphonePermissionRequestCode) {
            return false
        }

        val pendingResult = permissionResult ?: return false
        permissionResult = null

        val granted =
            grantResults.isNotEmpty() && grantResults.first() == PackageManager.PERMISSION_GRANTED
        if (granted) {
            pendingResult.success("granted")
            return true
        }

        val currentActivity = activity
        val isPermanentlyDenied =
            currentActivity != null &&
                !ActivityCompat.shouldShowRequestPermissionRationale(
                    currentActivity,
                    Manifest.permission.RECORD_AUDIO,
                )
        pendingResult.success(if (isPermanentlyDenied) "permanentlyDenied" else "denied")
        return true
    }

    private fun requestMicrophonePermission(result: MethodChannel.Result) {
        if (hasMicrophonePermission()) {
            result.success("granted")
            return
        }

        val currentActivity = activity
        if (currentActivity == null) {
            result.success("denied")
            return
        }

        if (permissionResult != null) {
            result.error("nativeFailure", "A permission request is already active.", null)
            return
        }

        permissionResult = result
        ActivityCompat.requestPermissions(
            currentActivity,
            arrayOf(Manifest.permission.RECORD_AUDIO),
            microphonePermissionRequestCode,
        )
    }

    private fun startDetection(config: DetectionConfig, result: MethodChannel.Result) {
        if (!hasMicrophonePermission()) {
            result.error("permissionDenied", "Microphone permission denied.", null)
            return
        }
        if (eventSink == null) {
            result.error("nativeFailure", "Pitch frame listener is not attached.", null)
            return
        }
        if (!isDetecting.compareAndSet(false, true)) {
            result.error("alreadyListening", "Pitch detection session is already active.", null)
            return
        }

        val minBufferSize =
            AudioRecord.getMinBufferSize(
                config.sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
            )
        if (minBufferSize == AudioRecord.ERROR || minBufferSize == AudioRecord.ERROR_BAD_VALUE) {
            isDetecting.set(false)
            result.error("nativeFailure", "Unable to determine AudioRecord buffer size.", null)
            return
        }

        val recordBufferSize = max(minBufferSize, config.bufferSize * 2)
        val recorder =
            AudioRecord(
                MediaRecorder.AudioSource.MIC,
                config.sampleRate,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                recordBufferSize,
            )
        if (recorder.state != AudioRecord.STATE_INITIALIZED) {
            recorder.release()
            isDetecting.set(false)
            result.error("nativeFailure", "Unable to initialize AudioRecord.", null)
            return
        }

        audioRecord = recorder
        detectionExecutor = Executors.newSingleThreadExecutor()
        detectionExecutor?.execute { detectOnBackgroundThread(recorder, config) }
        result.success(null)
    }

    private fun detectOnBackgroundThread(recorder: AudioRecord, config: DetectionConfig) {
        try {
            val detector =
                PitchProcessor.PitchEstimationAlgorithm.YIN.getDetector(
                    config.sampleRate.toFloat(),
                    config.bufferSize,
                )
            val hopSize = config.bufferSize - config.bufferOverlap
            val frameBuffer = FloatArray(config.bufferSize)
            val initialBuffer = ShortArray(config.bufferSize)
            val stepBuffer = ShortArray(hopSize)

            recorder.startRecording()

            val initialRead = readIntoBuffer(recorder, initialBuffer)
            if (initialRead <= 0) {
                throw IllegalStateException("AudioRecord returned no samples.")
            }
            copyPcmToFloat(initialBuffer, frameBuffer, initialRead)
            if (initialRead < config.bufferSize) {
                zeroFloatRange(frameBuffer, initialRead, config.bufferSize)
            }
            emitFrame(detector, frameBuffer, config)

            while (isDetecting.get()) {
                if (config.bufferOverlap > 0) {
                    System.arraycopy(frameBuffer, hopSize, frameBuffer, 0, config.bufferOverlap)
                }

                val stepRead = readIntoBuffer(recorder, stepBuffer)
                if (stepRead <= 0) {
                    break
                }
                copyPcmToFloat(stepBuffer, frameBuffer, stepRead, config.bufferOverlap)
                if (stepRead < hopSize) {
                    zeroFloatRange(
                        frameBuffer,
                        config.bufferOverlap + stepRead,
                        config.bufferSize,
                    )
                }
                emitFrame(detector, frameBuffer, config)
            }
        } catch (error: Exception) {
            mainHandler.post {
                eventSink?.error("nativeFailure", error.message ?: "Pitch detection failed.", null)
            }
        } finally {
            stopDetection()
        }
    }

    private fun emitFrame(
        detector: PitchDetector,
        frameBuffer: FloatArray,
        config: DetectionConfig,
    ) {
        val result = detector.getPitch(frameBuffer.copyOf())
        val pitch = result.pitch.toDouble().coerceAtLeast(0.0)
        val amplitude = calculateAmplitude(frameBuffer)
        val confidence = result.probability.toDouble().coerceIn(0.0, 1.0)
        val isPitched =
            result.isPitched &&
                pitch in config.minFrequencyHz..config.maxFrequencyHz &&
                amplitude >= config.minAmplitude &&
                confidence >= config.minConfidence

        val payload =
            mapOf(
                "frequencyHz" to pitch,
                "amplitude" to amplitude,
                "confidence" to confidence,
                "isPitched" to isPitched,
                "timestampMillis" to System.currentTimeMillis(),
            )
        mainHandler.post {
            eventSink?.success(payload)
        }
    }

    private fun stopDetection() {
        isDetecting.set(false)

        val recorder = audioRecord
        audioRecord = null

        try {
            recorder?.stop()
        } catch (_: IllegalStateException) {
        }
        recorder?.release()

        detectionExecutor?.shutdownNow()
        detectionExecutor = null
    }

    private fun detachActivity() {
        activityBinding?.removeRequestPermissionsResultListener(this)
        activityBinding = null
        activity = null
        permissionResult = null
    }

    private fun hasMicrophonePermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            applicationContext,
            Manifest.permission.RECORD_AUDIO,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun readIntoBuffer(recorder: AudioRecord, buffer: ShortArray): Int {
        var totalRead = 0
        while (isDetecting.get() && totalRead < buffer.size) {
            val read =
                recorder.read(
                    buffer,
                    totalRead,
                    buffer.size - totalRead,
                    AudioRecord.READ_BLOCKING,
                )
            if (read <= 0) {
                return if (totalRead > 0) totalRead else read
            }
            totalRead += read
        }
        return totalRead
    }

    private fun copyPcmToFloat(
        source: ShortArray,
        target: FloatArray,
        sampleCount: Int,
        targetOffset: Int = 0,
    ) {
        for (index in 0 until sampleCount) {
            target[targetOffset + index] = source[index] / Short.MAX_VALUE.toFloat()
        }
    }

    private fun zeroFloatRange(buffer: FloatArray, fromIndex: Int, untilIndex: Int) {
        for (index in fromIndex until untilIndex) {
            buffer[index] = 0f
        }
    }

    private fun calculateAmplitude(buffer: FloatArray): Double {
        var sum = 0.0
        for (sample in buffer) {
            sum += sample * sample
        }
        return sqrt(sum / buffer.size)
    }

    private data class DetectionConfig(
        val sampleRate: Int,
        val bufferSize: Int,
        val bufferOverlap: Int,
        val minFrequencyHz: Double,
        val maxFrequencyHz: Double,
        val minAmplitude: Double,
        val minConfidence: Double,
    ) {
        companion object {
            fun fromArguments(arguments: Any?): DetectionConfig? {
                val map = arguments as? Map<*, *> ?: return null
                return DetectionConfig(
                    sampleRate = (map["sampleRate"] as? Number)?.toInt() ?: 44100,
                    bufferSize = (map["bufferSize"] as? Number)?.toInt() ?: 4096,
                    bufferOverlap = (map["bufferOverlap"] as? Number)?.toInt() ?: 2048,
                    minFrequencyHz = (map["minFrequencyHz"] as? Number)?.toDouble() ?: 70.0,
                    maxFrequencyHz = (map["maxFrequencyHz"] as? Number)?.toDouble() ?: 1100.0,
                    minAmplitude = (map["minAmplitude"] as? Number)?.toDouble() ?: 0.01,
                    minConfidence = (map["minConfidence"] as? Number)?.toDouble() ?: 0.75,
                )
            }
        }
    }

    private companion object {
        const val microphonePermissionRequestCode = 9103
    }
}
