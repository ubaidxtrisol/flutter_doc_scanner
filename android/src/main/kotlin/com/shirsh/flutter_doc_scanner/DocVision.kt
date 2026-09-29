package com.shirsh.flutter_doc_scanner

import android.graphics.BitmapFactory
import org.opencv.core.Core
import org.opencv.core.Mat
import org.opencv.core.MatOfInt
import org.opencv.core.MatOfPoint
import org.opencv.core.MatOfPoint2f
import org.opencv.core.Point
import org.opencv.core.Scalar
import org.opencv.core.Size
import org.opencv.imgcodecs.Imgcodecs
import org.opencv.imgproc.Imgproc
import kotlin.math.atan2
import kotlin.math.hypot
import kotlin.math.max

/**
 * Document edge detection + page rendering. Not thread-safe: the scratch Mats are reused
 * across frames, so use one instance per thread.
 */
internal class DocVision {
    private val small = Mat()
    private val blurred = Mat()
    private val edges = Mat()
    private val tint = Mat()
    private val hierarchy = Mat()
    private val kernel = Imgproc.getStructuringElement(Imgproc.MORPH_RECT, Size(3.0, 3.0))
    private var pixels = ByteArray(0)

    /**
     * Corners of the most likely page in [gray], normalized 0..1, in no particular order.
     * [minArea] is the smallest accepted quad (fraction of frame); [aspect] optionally restricts the
     * long/short side ratio (e.g. ID cards).
     */
    fun detect(
        gray: Mat,
        workSize: Int = 480,
        minArea: Double = 0.15,
        aspect: ClosedFloatingPointRange<Double>? = null,
        chroma: (() -> Mat)? = null,
    ): FloatArray? {
        val scale = workSize.toDouble() / max(gray.cols(), gray.rows())
        if (scale < 1) Imgproc.resize(gray, small, Size(), scale, scale, Imgproc.INTER_AREA) else gray.copyTo(small)
        Imgproc.GaussianBlur(small, blurred, Size(5.0, 5.0), 0.0)
        val med = median(blurred)
        // Normal contrast first, then a low-threshold pass for white paper on light desks.
        for (k in doubleArrayOf(1.0, 0.4)) {
            Imgproc.Canny(blurred, edges, 0.66 * med * k, 1.33 * med * k)
            Imgproc.dilate(edges, edges, kernel)
            findQuad(edges, minArea, aspect)?.let { return it }
        }
        // White on white: brightness barely changes at the page edge, but colour often does (a warm desk vs
        // neutral paper). Only computed when the brightness passes fail. See chromaOf.
        val c = chroma?.invoke() ?: return null
        Imgproc.resize(c, tint, small.size(), 0.0, 0.0, Imgproc.INTER_AREA)
        c.release()
        val m = median(tint)
        tint.convertTo(tint, -1, 12.0, 128 - 12 * m) // stretch small tint differences around the scene's typical tint
        Imgproc.GaussianBlur(tint, tint, Size(5.0, 5.0), 0.0)
        Imgproc.Canny(tint, edges, 30.0, 90.0)
        Imgproc.dilate(edges, edges, kernel)
        return findQuad(edges, minArea, aspect)
    }

    /** Detects on a file (EXIF orientation applied), returns ordered corners TL,TR,BR,BL. */
    fun detectFile(path: String, minArea: Double = 0.15, aspect: ClosedFloatingPointRange<Double>? = null): FloatArray? {
        val bgr = Imgcodecs.imread(path, reducedFlag(path, 1000, gray = false))
        if (bgr.empty()) return null
        val gray = Mat().also { Imgproc.cvtColor(bgr, it, Imgproc.COLOR_BGR2GRAY) }
        val chroma = {
            val yuv = Mat().also { Imgproc.cvtColor(bgr, it, Imgproc.COLOR_BGR2YUV) }
            val planes = ArrayList<Mat>().also { Core.split(yuv, it) }
            chromaOf(planes[1], planes[2])
        }
        return detect(gray, 800, minArea, aspect, chroma)?.let(::order).also {
            gray.release()
            bgr.release()
        }
    }

    private fun findQuad(bin: Mat, minArea: Double, aspect: ClosedFloatingPointRange<Double>?): FloatArray? {
        val contours = ArrayList<MatOfPoint>()
        Imgproc.findContours(bin, contours, hierarchy, Imgproc.RETR_LIST, Imgproc.CHAIN_APPROX_SIMPLE)
        val frame = bin.rows() * bin.cols().toDouble()
        val candidates = contours
            .map { it to Imgproc.contourArea(it) }
            .filter { it.second > 0.66 * minArea * frame }
            .sortedByDescending { it.second }
            .take(6)
        val approx = MatOfPoint2f()
        for ((contour, area) in candidates) {
            // Hull first: fingers or glare breaking the outline don't break the page shape.
            val hullIdx = MatOfInt()
            Imgproc.convexHull(contour, hullIdx)
            val pts = contour.toArray()
            val hull = MatOfPoint2f(*hullIdx.toArray().map { pts[it] }.toTypedArray())
            val hullArea = Imgproc.contourArea(hull)
            if (area / hullArea < 0.8) continue // ragged blob, not a page
            val peri = Imgproc.arcLength(hull, true)
            for (eps in doubleArrayOf(0.02, 0.03, 0.045)) {
                Imgproc.approxPolyDP(hull, approx, eps * peri, true)
                if (approx.rows() <= 4) break
            }
            if (approx.rows() != 4) continue
            val quadArea = Imgproc.contourArea(approx)
            if (quadArea < minArea * frame || quadArea > 0.98 * frame) continue
            val p = approx.toArray()
            if (aspect != null) {
                // approxPolyDP keeps contour order, so p0-p1 / p2-p3 and p1-p2 / p3-p0 are opposite sides.
                val a = (dist(p[0], p[1]) + dist(p[2], p[3])) / 2
                val b = (dist(p[1], p[2]) + dist(p[3], p[0])) / 2
                if (max(a, b) / minOf(a, b) !in aspect) continue
            }
            return FloatArray(8) { i -> if (i % 2 == 0) (p[i / 2].x / bin.cols()).toFloat() else (p[i / 2].y / bin.rows()).toFloat() }
        }
        return null
    }

    private fun median(m: Mat): Double {
        val n = m.total().toInt()
        if (pixels.size != n) pixels = ByteArray(n)
        m.get(0, 0, pixels)
        val counts = IntArray(256)
        for (b in pixels) counts[b.toInt() and 0xFF]++
        var acc = 0
        for (i in 0..255) {
            acc += counts[i]
            if (acc >= n / 2) return i.toDouble()
        }
        return 127.0
    }

    companion object {
        /**
         * Distance from neutral grey, |U-128| + |V-128|: high on tinted surfaces, near 0 on white/grey paper.
         * Consumes (releases) [u] and [v].
         */
        fun chromaOf(u: Mat, v: Mat): Mat {
            val out = Mat()
            Core.absdiff(u, Scalar(128.0), u)
            Core.absdiff(v, Scalar(128.0), v)
            Core.add(u, v, out)
            u.release()
            v.release()
            return out
        }

        /** Orders 4 normalized points clockwise starting at top-left. */
        fun order(p: FloatArray): FloatArray {
            val cx = (p[0] + p[2] + p[4] + p[6]) / 4
            val cy = (p[1] + p[3] + p[5] + p[7]) / 4
            val byAngle = (0 until 4).sortedBy { atan2(p[2 * it + 1] - cy, p[2 * it] - cx) }
            val start = byAngle.indexOf(byAngle.minBy { p[2 * it] + p[2 * it + 1] })
            return FloatArray(8) { i -> p[2 * byAngle[(start + i / 2) % 4] + i % 2] }
        }

        /** Rotates normalized points clockwise by [degrees] (multiple of 90). */
        fun rotate(p: FloatArray, degrees: Int): FloatArray = FloatArray(8) { i ->
            val x = p[i - i % 2]
            val y = p[i - i % 2 + 1]
            val even = i % 2 == 0
            when (degrees) {
                90 -> if (even) 1 - y else x
                180 -> if (even) 1 - x else 1 - y
                270 -> if (even) y else 1 - x
                else -> if (even) x else y
            }
        }

        /**
         * Perspective crop → rotate → filter → JPEG. [corners] are normalized TL,TR,BR,BL
         * (null = whole image). [maxSize] caps the long side for fast previews.
         */
        fun process(
            path: String,
            corners: List<Double>?,
            rotation: Int,
            filter: String,
            outPath: String,
            maxSize: Int?,
        ): Map<String, Any> {
            val src = Imgcodecs.imread(path, if (maxSize == null) Imgcodecs.IMREAD_COLOR else reducedFlag(path, maxSize, gray = false))
            require(!src.empty()) { "Cannot read $path" }
            var img = src
            if (corners != null && corners.size == 8) {
                val p = List(4) { Point(corners[2 * it] * src.cols(), corners[2 * it + 1] * src.rows()) }
                val w = max(dist(p[0], p[1]), dist(p[3], p[2]))
                val h = max(dist(p[0], p[3]), dist(p[1], p[2]))
                val m = Imgproc.getPerspectiveTransform(
                    MatOfPoint2f(*p.toTypedArray()),
                    MatOfPoint2f(Point(0.0, 0.0), Point(w, 0.0), Point(w, h), Point(0.0, h)),
                )
                img = Mat()
                Imgproc.warpPerspective(src, img, m, Size(w, h), Imgproc.INTER_CUBIC)
                src.release()
            }
            if (maxSize != null && max(img.cols(), img.rows()) > maxSize) {
                val s = maxSize.toDouble() / max(img.cols(), img.rows())
                Imgproc.resize(img, img, Size(), s, s, Imgproc.INTER_AREA)
            }
            when (((rotation % 360) + 360) % 360) {
                90 -> Core.rotate(img, img, Core.ROTATE_90_CLOCKWISE)
                180 -> Core.rotate(img, img, Core.ROTATE_180)
                270 -> Core.rotate(img, img, Core.ROTATE_90_COUNTERCLOCKWISE)
            }
            val out = applyFilter(img, filter)
            Imgcodecs.imwrite(outPath, out, MatOfInt(Imgcodecs.IMWRITE_JPEG_QUALITY, 90))
            return mapOf("path" to outPath, "width" to out.cols(), "height" to out.rows())
        }

        private fun applyFilter(img: Mat, filter: String): Mat = when (filter) {
            "magic" -> flatten(img)
            "gray" -> gray(img)
            "bw" -> {
                val g = flatten(gray(img))
                val block = (max(g.cols(), g.rows()) / 50) or 1
                Imgproc.adaptiveThreshold(
                    g, g, 255.0, Imgproc.ADAPTIVE_THRESH_GAUSSIAN_C, Imgproc.THRESH_BINARY, max(block, 11), 12.0,
                )
                g
            }
            else -> img
        }

        private fun gray(img: Mat): Mat {
            if (img.channels() == 1) return img
            return Mat().also { Imgproc.cvtColor(img, it, Imgproc.COLOR_BGR2GRAY) }
        }

        /** Removes shadows / uneven light: divide by an estimate of the bare paper, then deepen ink. */
        private fun flatten(img: Mat): Mat {
            val s = 512.0 / max(img.cols(), img.rows())
            val bg = Mat()
            Imgproc.resize(img, bg, Size(), s, s, Imgproc.INTER_AREA)
            // Ink is darker than paper, so a max filter wipes it out and leaves the paper tone.
            Imgproc.dilate(bg, bg, Imgproc.getStructuringElement(Imgproc.MORPH_ELLIPSE, Size(15.0, 15.0)))
            Imgproc.medianBlur(bg, bg, 21)
            Imgproc.resize(bg, bg, img.size(), 0.0, 0.0, Imgproc.INTER_LINEAR)
            val out = Mat()
            Core.divide(img, bg, out, 255.0)
            // Paper sits at ~255 now; stretch below it so text gets crisp and dark.
            out.convertTo(out, -1, 1.3, 255 - 1.3 * 255)
            bg.release()
            return out
        }

        /** Picks the cheapest JPEG decode (1/2, 1/4, 1/8) that still gives >= [target] on the long side. */
        private fun reducedFlag(path: String, target: Int, gray: Boolean): Int {
            val o = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(path, o)
            val long = max(o.outWidth, o.outHeight)
            return when {
                long / 8 >= target -> if (gray) Imgcodecs.IMREAD_REDUCED_GRAYSCALE_8 else Imgcodecs.IMREAD_REDUCED_COLOR_8
                long / 4 >= target -> if (gray) Imgcodecs.IMREAD_REDUCED_GRAYSCALE_4 else Imgcodecs.IMREAD_REDUCED_COLOR_4
                long / 2 >= target -> if (gray) Imgcodecs.IMREAD_REDUCED_GRAYSCALE_2 else Imgcodecs.IMREAD_REDUCED_COLOR_2
                else -> if (gray) Imgcodecs.IMREAD_GRAYSCALE else Imgcodecs.IMREAD_COLOR
            }
        }

        private fun dist(a: Point, b: Point) = hypot(a.x - b.x, a.y - b.y)
    }
}
