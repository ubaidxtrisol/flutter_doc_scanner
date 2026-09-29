import CoreImage
import ImageIO
import Vision

/// Document edge detection (Vision) + page rendering (Core Image). Mirrors Android's DocVision.kt.
enum DocVision {
    static let context = CIContext()

    /// Corners TL, TR, BR, BL normalized with a top-left origin, or nil. [size] is the image size in pixels
    /// (for the aspect check); [minArea] is a fraction of the frame; [aspect] limits long/short side ratio.
    static func detect(_ handler: VNImageRequestHandler, size: CGSize, minArea: Double = 0.15, aspect: ClosedRange<Double>? = nil) -> [Double]? {
        let quad = { (o: VNRectangleObservation) in Self.quad(o, size: size, minArea: minArea, aspect: aspect) }
        let segmentation = VNDetectDocumentSegmentationRequest()
        try? handler.perform([segmentation])
        if let o = segmentation.results?.first, o.confidence >= 0.6, let q = quad(o) { return q }

        let rectangles = VNDetectRectanglesRequest()
        rectangles.minimumSize = Float(min(0.2, minArea.squareRoot()))
        rectangles.minimumAspectRatio = 0.3
        rectangles.quadratureTolerance = 20
        rectangles.minimumConfidence = 0.6
        rectangles.maximumObservations = 1
        try? handler.perform([rectangles])
        return rectangles.results?.first.flatMap(quad)
    }

    static func detect(path: String, minArea: Double = 0.15, aspect: ClosedRange<Double>? = nil) -> [Double]? {
        guard let image = load(path, maxSize: 1000) else { return nil }
        return detect(VNImageRequestHandler(ciImage: image), size: image.extent.size, minArea: minArea, aspect: aspect)
    }

    private static func quad(_ o: VNRectangleObservation, size: CGSize, minArea: Double, aspect: ClosedRange<Double>?) -> [Double]? {
        // Vision uses a bottom-left origin.
        let p = [o.topLeft, o.topRight, o.bottomRight, o.bottomLeft].flatMap { [Double($0.x), Double(1 - $0.y)] }
        let area = abs((0..<4).reduce(0.0) { s, i in
            let j = (i + 1) % 4
            return s + p[2 * i] * p[2 * j + 1] - p[2 * j] * p[2 * i + 1]
        }) / 2
        guard area > minArea, area < 0.98 else { return nil }
        if let aspect {
            func side(_ i: Int, _ j: Int) -> Double { hypot((p[2 * i] - p[2 * j]) * size.width, (p[2 * i + 1] - p[2 * j + 1]) * size.height) }
            let a = (side(0, 1) + side(3, 2)) / 2, b = (side(0, 3) + side(1, 2)) / 2
            guard aspect.contains(max(a, b) / min(a, b)) else { return nil }
        }
        return order(p)
    }

    /// Orders 4 normalized points clockwise from top-left (same rule as Android).
    static func order(_ p: [Double]) -> [Double] {
        let cx = (p[0] + p[2] + p[4] + p[6]) / 4
        let cy = (p[1] + p[3] + p[5] + p[7]) / 4
        let byAngle = (0..<4).sorted { atan2(p[2 * $0 + 1] - cy, p[2 * $0] - cx) < atan2(p[2 * $1 + 1] - cy, p[2 * $1] - cx) }
        let tl = byAngle.min { p[2 * $0] + p[2 * $0 + 1] < p[2 * $1] + p[2 * $1 + 1] }!
        let start = byAngle.firstIndex(of: tl)!
        return (0..<4).flatMap { k -> [Double] in
            let i = byAngle[(start + k) % 4]
            return [p[2 * i], p[2 * i + 1]]
        }
    }

    /// Upright image (EXIF applied). With [maxSize], decodes a cheap thumbnail instead of the full photo.
    static func load(_ path: String, maxSize: Int?) -> CIImage? {
        let url = URL(fileURLWithPath: path)
        if let maxSize,
           let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           let thumb = CGImageSourceCreateThumbnailAtIndex(source, 0, [
               kCGImageSourceCreateThumbnailFromImageAlways: true,
               kCGImageSourceCreateThumbnailWithTransform: true,
               // A crop is a sub-region, so keep some headroom.
               kCGImageSourceThumbnailMaxPixelSize: maxSize * 2,
           ] as CFDictionary) {
            return CIImage(cgImage: thumb)
        }
        return CIImage(contentsOf: url, options: [.applyOrientationProperty: true])
    }

    /// Perspective crop → rotate → filter → JPEG. Corners normalized TL, TR, BR, BL (nil = whole image).
    static func process(path: String, corners: [Double]?, rotation: Int, filter: String, outPath: String, maxSize: Int?) throws -> [String: Any] {
        guard var img = load(path, maxSize: maxSize) else {
            throw NSError(domain: "flutter_doc_scanner", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot read \(path)"])
        }
        if let c = corners, c.count == 8 {
            let e = img.extent
            func point(_ i: Int) -> CIVector {
                CIVector(x: e.minX + c[2 * i] * e.width, y: e.minY + (1 - c[2 * i + 1]) * e.height)
            }
            img = img.applyingFilter("CIPerspectiveCorrection", parameters: [
                "inputTopLeft": point(0), "inputTopRight": point(1),
                "inputBottomRight": point(2), "inputBottomLeft": point(3),
            ])
        }
        if let maxSize {
            let s = CGFloat(maxSize) / max(img.extent.width, img.extent.height)
            if s < 1 {
                img = img.applyingFilter("CILanczosScaleTransform", parameters: [kCIInputScaleKey: s, kCIInputAspectRatioKey: 1])
            }
        }
        switch ((rotation % 360) + 360) % 360 {
        case 90: img = img.oriented(.right)
        case 180: img = img.oriented(.down)
        case 270: img = img.oriented(.left)
        default: break
        }
        img = applyFilter(img, filter)
        img = img.transformed(by: CGAffineTransform(translationX: -img.extent.minX, y: -img.extent.minY))

        try context.writeJPEGRepresentation(
            of: img,
            to: URL(fileURLWithPath: outPath),
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
            options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 0.9]
        )
        return ["path": outPath, "width": Int(img.extent.width), "height": Int(img.extent.height)]
    }

    private static func applyFilter(_ img: CIImage, _ filter: String) -> CIImage {
        switch filter {
        case "magic": return flatten(img)
        case "gray": return gray(img)
        case "bw": return flatten(gray(img)).applyingFilter("CIColorThreshold", parameters: ["inputThreshold": 0.78])
        default: return img
        }
    }

    private static func gray(_ img: CIImage) -> CIImage {
        img.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0])
    }

    /// Removes shadows / uneven light: divide by an estimate of the bare paper, then deepen ink.
    private static func flatten(_ img: CIImage) -> CIImage {
        let e = img.extent
        let s = 512 / max(e.width, e.height)
        // Ink is darker than paper, so a max filter wipes it out and leaves the paper tone.
        let paper = img
            .transformed(by: CGAffineTransform(scaleX: s, y: s))
            .clampedToExtent()
            .applyingFilter("CIMorphologyMaximum", parameters: [kCIInputRadiusKey: 7])
            .applyingFilter("CIGaussianBlur", parameters: [kCIInputRadiusKey: 10])
            .transformed(by: CGAffineTransform(scaleX: 1 / s, y: 1 / s))
            .cropped(to: e)
        // Divide blend: background / input, i.e. page / paper estimate.
        let divided = paper.applyingFilter("CIDivideBlendMode", parameters: [kCIInputBackgroundImageKey: img])
        return divided
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: 1.3, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 1.3, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1.3, w: 0),
                "inputBiasVector": CIVector(x: -0.3, y: -0.3, z: -0.3, w: 0),
            ])
            .applyingFilter("CIColorClamp")
            .cropped(to: e)
    }

    // MARK: - Barcodes and MRZ text (same result shapes as Android's Readers.kt)

    static func codes(_ handler: VNImageRequestHandler) -> [[String: Any]] {
        let request = VNDetectBarcodesRequest()
        try? handler.perform([request])
        return (request.results ?? []).compactMap { o in
            guard let value = o.payloadStringValue else { return nil }
            let corners = [o.topLeft, o.topRight, o.bottomRight, o.bottomLeft].flatMap { [Double($0.x), Double(1 - $0.y)] }
            return ["value": value, "corners": corners]
        }
    }

    /// Text lines with boxes. With [mrzOnly], only MRZ-looking lines (≥25 chars, ≥90% A-Z 0-9 <) leave native code.
    static func lines(_ handler: VNImageRequestHandler, accurate: Bool, mrzOnly: Bool) -> [[String: Any]] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = accurate ? .accurate : .fast
        request.usesLanguageCorrection = false
        try? handler.perform([request])
        return (request.results ?? []).compactMap { o in
            guard let raw = o.topCandidates(1).first?.string else { return nil }
            let text = mrzOnly ? raw.replacingOccurrences(of: " ", with: "").uppercased() : raw
            if mrzOnly {
                let mrz = text.filter { $0.isASCII && ($0.isUppercase || $0.isNumber || $0 == "<") || $0 == "«" }.count
                guard text.count >= 25, Double(mrz) >= 0.9 * Double(text.count) else { return nil }
            }
            let b = o.boundingBox
            return ["text": text, "box": [Double(b.minX), Double(1 - b.maxY), Double(b.maxX), Double(1 - b.minY)]]
        }
    }
}
