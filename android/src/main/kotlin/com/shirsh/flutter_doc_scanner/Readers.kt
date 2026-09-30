package com.shirsh.flutter_doc_scanner

import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.TextRecognizer
import com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
import com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
import com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
import com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import java.util.concurrent.ConcurrentHashMap

/** ML Kit barcode + text reading (bundled models, offline). Blocking: call off the main thread. */
internal object Readers {
    private val barcodes by lazy { BarcodeScanning.getClient() }
    private val text by lazy { TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS) }
    private val scripted = ConcurrentHashMap<String, TextRecognizer>()

    val SCRIPTS = setOf("latin", "chinese", "devanagari", "japanese", "korean")

    private fun recognizer(script: String): TextRecognizer = if (script == "latin") text else scripted.getOrPut(script) {
        TextRecognition.getClient(
            when (script) {
                "chinese" -> ChineseTextRecognizerOptions.Builder().build()
                "devanagari" -> DevanagariTextRecognizerOptions.Builder().build()
                "japanese" -> JapaneseTextRecognizerOptions.Builder().build()
                else -> KoreanTextRecognizerOptions.Builder().build()
            },
        )
    }

    private fun norm(r: android.graphics.Rect, w: Int, h: Int) =
        listOf(r.left.toDouble() / w, r.top.toDouble() / h, r.right.toDouble() / w, r.bottom.toDouble() / h)

    /** All text as blocks → lines, boxes normalized to the upright [w]×[h] image (recognizeText). */
    fun blocks(image: InputImage, w: Int, h: Int, script: String): List<Map<String, Any?>> =
        Tasks.await(recognizer(script).process(image)).textBlocks.mapNotNull { b ->
            val box = b.boundingBox ?: return@mapNotNull null
            mapOf(
                "text" to b.text,
                "box" to norm(box, w, h),
                "lines" to b.lines.mapNotNull { l -> l.boundingBox?.let { mapOf("text" to l.text, "box" to norm(it, w, h)) } },
            )
        }

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
                "box" to norm(box, w, h),
            )
        }
}
