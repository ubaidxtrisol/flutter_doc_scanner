package com.shirsh.flutter_doc_scanner

import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions

/** ML Kit barcode + text reading (bundled models, offline). Blocking: call off the main thread. */
internal object Readers {
    private val barcodes by lazy { BarcodeScanning.getClient() }
    private val text by lazy { TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS) }

    /** Decoded codes; corners normalized to the upright [w]×[h] image. */
    fun codes(image: InputImage, w: Int, h: Int): List<Map<String, Any?>> =
        Tasks.await(barcodes.process(image)).mapNotNull { b ->
            val value = b.rawValue ?: return@mapNotNull null
            mapOf(
                "value" to value,
                "corners" to b.cornerPoints?.flatMap { listOf(it.x.toDouble() / w, it.y.toDouble() / h) },
            )
        }

    /**
     * Recognized text lines with boxes normalized to [w]×[h]. With [mrzOnly], only lines that look like MRZ
     * (≥25 chars, ≥90% A-Z 0-9 <) are returned, so names/addresses in normal print never reach Dart.
     */
    fun lines(image: InputImage, w: Int, h: Int, mrzOnly: Boolean): List<Map<String, Any?>> =
        Tasks.await(text.process(image)).textBlocks.flatMap { it.lines }.mapNotNull { line ->
            val box = line.boundingBox ?: return@mapNotNull null
            val t = if (mrzOnly) line.text.replace(" ", "").uppercase() else line.text
            if (mrzOnly) {
                val mrz = t.count { it in 'A'..'Z' || it in '0'..'9' || it == '<' || it == '«' }
                if (t.length < 25 || mrz < 0.9 * t.length) return@mapNotNull null
            }
            mapOf(
                "text" to t,
                "box" to listOf(box.left.toDouble() / w, box.top.toDouble() / h, box.right.toDouble() / w, box.bottom.toDouble() / h),
            )
        }
}
