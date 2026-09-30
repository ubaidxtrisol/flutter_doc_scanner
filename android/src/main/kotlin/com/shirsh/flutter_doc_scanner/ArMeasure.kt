package com.shirsh.flutter_doc_scanner

import android.app.Activity
import android.opengl.EGL14
import android.opengl.EGLConfig
import android.opengl.EGLContext
import android.opengl.EGLDisplay
import android.opengl.EGLSurface
import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.opengl.Matrix
import android.os.Handler
import android.os.HandlerThread
import android.view.Surface
import com.google.ar.core.Anchor
import com.google.ar.core.Config
import com.google.ar.core.Coordinates2d
import com.google.ar.core.DepthPoint
import com.google.ar.core.HitResult
import com.google.ar.core.Plane
import com.google.ar.core.Point
import com.google.ar.core.Pose
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import io.flutter.view.TextureRegistry
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import java.util.concurrent.CountDownLatch

/**
 * ARCore measuring session (Phase 5, Figma 7.6). Draws the camera into a Flutter texture on its own GL thread and
 * streams, per camera frame, the placed points and the screen-center hit in world meters plus the view-projection
 * matrix. Dart projects and draws everything else, so styling and math stay in one place.
 */
internal class ArMeasure(
    activity: Activity,
    private val producer: TextureRegistry.SurfaceProducer,
    private val width: Int,
    private val height: Int,
    private val emit: (Map<String, Any?>) -> Unit, // called on the GL thread
) {
    private val session = Session(activity)
    private val config = Config(session).apply {
        planeFindingMode = Config.PlaneFindingMode.HORIZONTAL_AND_VERTICAL
        focusMode = Config.FocusMode.AUTO
        lightEstimationMode = Config.LightEstimationMode.DISABLED
        // Depth lets the reticle land on surfaces before a plane is found (and on plain floors that never get one).
        if (session.isDepthModeSupported(Config.DepthMode.AUTOMATIC)) depthMode = Config.DepthMode.AUTOMATIC
    }
    private val thread = HandlerThread("ar-measure").apply { start() }
    private val gl = Handler(thread.looper)
    private val anchors = mutableListOf<Anchor>()
    private var lastHit: HitResult? = null
    private var lockPlane: Plane? = null // the detected plane the first point was placed on
    @Volatile private var running = true
    private var resumed = false

    private var display: EGLDisplay = EGL14.EGL_NO_DISPLAY
    private var eglConfig: EGLConfig? = null
    private var context: EGLContext = EGL14.EGL_NO_CONTEXT
    private var surface: EGLSurface = EGL14.EGL_NO_SURFACE
    private var program = 0
    private var cameraTexture = 0
    private val quad = floats(-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f)
    private val uv = floats(0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f)

    init {
        session.configure(config)
        producer.setSize(width, height)
        producer.setCallback(object : TextureRegistry.SurfaceProducer.Callback {
            override fun onSurfaceAvailable() {
                gl.post { attachSurface() }
            }

            override fun onSurfaceCleanup() = onGl { detachSurface() }
        })
        gl.post {
            initGl()
            session.setCameraTextureNames(intArrayOf(cameraTexture))
            session.setDisplayGeometry(Surface.ROTATION_0, width, height)
            gl.post(::frame)
        }
    }

    /**
     * Anchors a point at [at] (world meters; Dart snaps it onto the locked surface), else at the current
     * screen-center hit. Replies false when there is nothing to anchor.
     */
    fun add(at: List<Double>?, done: (Boolean) -> Unit) = gl.post {
        val hit = lastHit
        if (anchors.isEmpty()) lockPlane = hit?.trackable as? Plane
        val anchor = runCatching { if (at != null) anchorAt(at) else hit?.trackable?.createAnchor(hit.hitPose) }.getOrNull()
        if (anchor != null) anchors += anchor
        done(anchor != null)
    }

    /** Moves point [index] to [at] (a dragged corner). Replies once the new anchor is in place. */
    fun move(index: Int, at: List<Double>, done: () -> Unit) = gl.post {
        val anchor = runCatching { anchorAt(at) }.getOrNull()
        if (anchor != null && index in anchors.indices) {
            anchors[index].detach()
            anchors[index] = anchor
        } else {
            anchor?.detach()
        }
        done()
    }

    /**
     * Anchor at [at], attached to the surface it lies on when we know one: the locked plane, or the trackable
     * just hit there. Attached anchors ride along when ARCore corrects its map; free world anchors drift.
     */
    private fun anchorAt(at: List<Double>): Anchor {
        val pose = Pose.makeTranslation(at[0].toFloat(), at[1].toFloat(), at[2].toFloat())
        val plane = lockPlane?.let { generateSequence(it) { p -> p.subsumedBy }.last() } // merged planes live on
            ?.takeIf { it.trackingState == TrackingState.TRACKING }
        val hit = lastHit?.takeIf { h ->
            val p = h.hitPose
            val d = floatArrayOf(p.tx() - pose.tx(), p.ty() - pose.ty(), p.tz() - pose.tz())
            d[0] * d[0] + d[1] * d[1] + d[2] * d[2] < SAME_SPOT * SAME_SPOT
        }?.trackable?.takeIf { it.trackingState == TrackingState.TRACKING }
        return (plane ?: hit)?.createAnchor(pose) ?: session.createAnchor(pose)
    }

    fun undo() = gl.post {
        anchors.removeLastOrNull()?.detach()
        if (anchors.isEmpty()) lockPlane = null
    }

    fun clear() = gl.post {
        anchors.forEach { it.detach() }
        anchors.clear()
        lockPlane = null
    }

    fun setTorch(on: Boolean) = gl.post {
        config.flashMode = if (on) Config.FlashMode.TORCH else Config.FlashMode.OFF
        runCatching { session.configure(config) }
    }

    fun stop() {
        running = false
        onGl {
            session.pause()
            session.close()
            detachSurface()
            GLES20.glDeleteProgram(program)
            EGL14.eglDestroyContext(display, context)
            EGL14.eglTerminate(display)
        }
        thread.quitSafely()
        producer.release()
    }

    private fun frame() {
        if (!running) return
        if (surface == EGL14.EGL_NO_SURFACE) {
            gl.postDelayed(::frame, 50)
            return
        }
        try {
            if (!resumed) {
                session.resume() // throws CameraNotAvailableException while the scanner camera is still closing
                resumed = true
            }
            // Blocks until the next camera image, so this loop runs at camera rate.
            val frame = session.update()
            if (frame.hasDisplayGeometryChanged()) {
                frame.transformCoordinates2d(
                    Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES, quad.apply { rewind() },
                    Coordinates2d.TEXTURE_NORMALIZED, uv.apply { rewind() },
                )
            }
            if (frame.timestamp != 0L) {
                drawBackground()
                EGL14.eglSwapBuffers(display, surface)
            }
            val camera = frame.camera
            val tracking = camera.trackingState == TrackingState.TRACKING
            lastHit = if (tracking) frame.hitTest(width / 2f, height / 2f).firstOrNull { it.onSurface() } else null

            val view = FloatArray(16)
            val proj = FloatArray(16)
            val vp = FloatArray(16)
            camera.getViewMatrix(view, 0)
            camera.getProjectionMatrix(proj, 0, 0.05f, 100f)
            Matrix.multiplyMM(vp, 0, proj, 0, view, 0)
            emit(
                mapOf(
                    "tracking" to camera.trackingState.name.lowercase(),
                    "reason" to camera.trackingFailureReason.name.lowercase(),
                    "hit" to lastHit?.hitPose?.let { doubleArrayOf(it.tx().toDouble(), it.ty().toDouble(), it.tz().toDouble()) },
                    // The hit pose's +Y is the surface normal: exact for planes, estimated for depth / feature points.
                    "normal" to lastHit?.hitPose?.yAxis?.map { it.toDouble() }?.toDoubleArray(),
                    "kind" to when (lastHit?.trackable) {
                        null -> null
                        is Plane -> "plane"
                        else -> "depth"
                    },
                    "points" to anchors.flatMap { a -> a.pose.let { listOf(it.tx(), it.ty(), it.tz()) } }
                        .map { it.toDouble() }.toDoubleArray(),
                    "vp" to vp.map { it.toDouble() }.toDoubleArray(),
                ),
            )
        } catch (e: Exception) {
            emit(mapOf("error" to (e.message ?: e.javaClass.simpleName)))
            gl.postDelayed(::frame, 100)
            return
        }
        gl.post(::frame)
    }

    private fun HitResult.onSurface() = when (val t = trackable) {
        is Plane -> t.trackingState == TrackingState.TRACKING && t.isPoseInPolygon(hitPose)
        is DepthPoint -> true
        is Point -> t.orientationMode == Point.OrientationMode.ESTIMATED_SURFACE_NORMAL
        else -> false
    }

    private fun initGl() {
        display = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY)
        EGL14.eglInitialize(display, IntArray(2), 0, IntArray(2), 1)
        val configs = arrayOfNulls<EGLConfig>(1)
        EGL14.eglChooseConfig(
            display,
            intArrayOf(
                EGL14.EGL_RED_SIZE, 8, EGL14.EGL_GREEN_SIZE, 8, EGL14.EGL_BLUE_SIZE, 8, EGL14.EGL_ALPHA_SIZE, 8,
                EGL14.EGL_RENDERABLE_TYPE, EGL14.EGL_OPENGL_ES2_BIT, EGL14.EGL_SURFACE_TYPE, EGL14.EGL_WINDOW_BIT,
                EGL14.EGL_NONE,
            ),
            0, configs, 0, 1, IntArray(1), 0,
        )
        eglConfig = configs[0]
        context = EGL14.eglCreateContext(
            display, eglConfig, EGL14.EGL_NO_CONTEXT, intArrayOf(EGL14.EGL_CONTEXT_CLIENT_VERSION, 2, EGL14.EGL_NONE), 0,
        )
        attachSurface()

        val tex = IntArray(1)
        GLES20.glGenTextures(1, tex, 0)
        cameraTexture = tex[0]
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, cameraTexture)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)

        program = GLES20.glCreateProgram().also {
            GLES20.glAttachShader(it, shader(GLES20.GL_VERTEX_SHADER, VERTEX))
            GLES20.glAttachShader(it, shader(GLES20.GL_FRAGMENT_SHADER, FRAGMENT))
            GLES20.glLinkProgram(it)
        }
    }

    private fun attachSurface() {
        if (surface != EGL14.EGL_NO_SURFACE || !running) return
        surface = EGL14.eglCreateWindowSurface(display, eglConfig, producer.surface, intArrayOf(EGL14.EGL_NONE), 0)
        EGL14.eglMakeCurrent(display, surface, surface, context)
        GLES20.glViewport(0, 0, width, height)
    }

    private fun detachSurface() {
        if (surface == EGL14.EGL_NO_SURFACE) return
        EGL14.eglMakeCurrent(display, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, context)
        EGL14.eglDestroySurface(display, surface)
        surface = EGL14.EGL_NO_SURFACE
    }

    private fun drawBackground() {
        GLES20.glUseProgram(program)
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, cameraTexture)
        val pos = GLES20.glGetAttribLocation(program, "a_Position")
        val tex = GLES20.glGetAttribLocation(program, "a_TexCoord")
        GLES20.glVertexAttribPointer(pos, 2, GLES20.GL_FLOAT, false, 0, quad.apply { rewind() })
        GLES20.glVertexAttribPointer(tex, 2, GLES20.GL_FLOAT, false, 0, uv.apply { rewind() })
        GLES20.glEnableVertexAttribArray(pos)
        GLES20.glEnableVertexAttribArray(tex)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
    }

    /** Runs [block] on the GL thread and waits for it (surface teardown must finish before we return). */
    private fun onGl(block: () -> Unit) {
        val done = CountDownLatch(1)
        if (!gl.post { runCatching(block); done.countDown() }) return
        done.await()
    }

    private companion object {
        const val SAME_SPOT = 0.03f // m: a hit this close to a point is the surface under it
        const val VERTEX = """
            attribute vec4 a_Position;
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            void main() { gl_Position = a_Position; v_TexCoord = a_TexCoord; }
        """
        const val FRAGMENT = """
            #extension GL_OES_EGL_image_external : require
            precision mediump float;
            varying vec2 v_TexCoord;
            uniform samplerExternalOES u_Texture;
            void main() { gl_FragColor = texture2D(u_Texture, v_TexCoord); }
        """

        fun shader(type: Int, source: String) = GLES20.glCreateShader(type).also {
            GLES20.glShaderSource(it, source.trimIndent())
            GLES20.glCompileShader(it)
        }

        fun floats(vararg v: Float): FloatBuffer =
            ByteBuffer.allocateDirect(v.size * 4).order(ByteOrder.nativeOrder()).asFloatBuffer().apply { put(v).rewind() }
    }
}
