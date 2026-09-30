import ARKit
import AVFoundation
import Flutter
import UIKit
import Vision

/// Camera + detection engine. Contract: docs/SCANNER_PHASES.md §1.2.
public class SwiftFlutterDocScannerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private let textures: FlutterTextureRegistry
    private let work = DispatchQueue(label: "flutter_doc_scanner.work", qos: .userInitiated, attributes: .concurrent)
    private var sink: FlutterEventSink?
    private var camera: CameraEngine?
    private static let arEvents = ArEvents()

    init(textures: FlutterTextureRegistry) {
        self.textures = textures
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftFlutterDocScannerPlugin(textures: registrar.textures())
        registrar.addMethodCallDelegate(instance, channel: FlutterMethodChannel(name: "flutter_doc_scanner", binaryMessenger: registrar.messenger()))
        FlutterEventChannel(name: "flutter_doc_scanner/detections", binaryMessenger: registrar.messenger()).setStreamHandler(instance)
        FlutterEventChannel(name: "flutter_doc_scanner/ar", binaryMessenger: registrar.messenger()).setStreamHandler(arEvents)
        registrar.register(ArMeasureFactory(), withId: "flutter_doc_scanner/ar")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any] ?? [:]
        switch call.method {
        case "start":
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    guard granted else {
                        return result(FlutterError(code: "PERMISSION_DENIED", message: "Camera permission denied", details: nil))
                    }
                    self.start(mode: args["mode"] as? String ?? "document", result: result)
                }
            }
        case "setMode":
            camera?.mode = args["mode"] as? String ?? "document"
            result(nil)
        case "setTorch":
            camera?.setTorch(args["on"] as? Bool ?? false)
            result(nil)
        case "capture":
            guard let camera else { return result(FlutterError(code: "NOT_STARTED", message: "Call start first", details: nil)) }
            camera.capture { outcome in
                switch outcome {
                case .success(let url):
                    // Re-detect on the real photo: sharper and more accurate than the preview frame.
                    let corners = Self.detectFile(url.path, mode: camera.mode)
                    DispatchQueue.main.async { result(["path": url.path, "corners": corners as Any]) }
                case .failure(let error):
                    DispatchQueue.main.async { result(FlutterError(code: "CAPTURE_FAILED", message: error.localizedDescription, details: nil)) }
                }
            }
        case "analyze":
            let path = args["path"] as? String ?? ""
            let mode = args["mode"] as? String ?? "document"
            work.async {
                var out: [String: Any] = ["mode": mode]
                switch mode {
                case "qr", "passport", "math":
                    if let image = DocVision.load(path, maxSize: nil) {
                        let handler = VNImageRequestHandler(ciImage: image)
                        if mode == "qr" { out["codes"] = DocVision.codes(handler) }
                        else { out["lines"] = DocVision.lines(handler, accurate: true, mrzOnly: mode == "passport") }
                    }
                default:
                    out["corners"] = Self.detectFile(path, mode: mode) as Any
                }
                DispatchQueue.main.async { result(out) }
            }
        case "process":
            work.async {
                do {
                    let out = try DocVision.process(
                        path: args["path"] as? String ?? "",
                        corners: args["corners"] as? [Double],
                        rotation: args["rotation"] as? Int ?? 0,
                        filter: args["filter"] as? String ?? "original",
                        outPath: args["outPath"] as? String ?? "",
                        maxSize: args["maxSize"] as? Int,
                        brightness: args["brightness"] as? Double ?? 0,
                        contrast: args["contrast"] as? Double ?? 0
                    )
                    DispatchQueue.main.async { result(out) }
                } catch {
                    DispatchQueue.main.async { result(FlutterError(code: "FAILED", message: error.localizedDescription, details: nil)) }
                }
            }
        case "recognizeText":
            let path = args["path"] as? String ?? ""
            let script = args["script"] as? String ?? "latin"
            work.async {
                guard let image = DocVision.load(path, maxSize: nil) else {
                    return DispatchQueue.main.async { result(FlutterError(code: "FAILED", message: "Cannot read \(path)", details: nil)) }
                }
                let blocks = DocVision.blocks(VNImageRequestHandler(ciImage: image), script: script)
                DispatchQueue.main.async {
                    if let blocks { result(blocks) } else {
                        result(FlutterError(code: "UNSUPPORTED_SCRIPT", message: "\(script) text isn't supported on this iOS version", details: nil))
                    }
                }
            }
        case "stop":
            stop()
            result(nil)
        case "arStart":
            guard ARWorldTrackingConfiguration.isSupported else {
                return result(FlutterError(code: "AR_UNSUPPORTED", message: "ARKit world tracking unsupported", details: nil))
            }
            stop() // ARKit needs the camera to itself; the session starts when Flutter creates the view
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    granted ? result(["textureId": NSNull()])
                        : result(FlutterError(code: "PERMISSION_DENIED", message: "Camera permission denied", details: nil))
                }
            }
        case "arAdd":
            result(ArMeasureView.current?.add(at: args["at"] as? [Double]) ?? false)
        case "arMove":
            ArMeasureView.current?.move(args["index"] as? Int ?? -1, to: args["at"] as? [Double] ?? [])
            result(nil)
        case "arUndo":
            ArMeasureView.current?.undo()
            result(nil)
        case "arClear":
            ArMeasureView.current?.clear()
            result(nil)
        case "arTorch":
            ArMeasureView.setTorch(args["on"] as? Bool ?? false)
            result(nil)
        case "arStop":
            ArMeasureView.current?.stop()
            result(nil)
        case "openSettings":
            if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // ID-1 cards are 85.6 × 54 mm (1.586). The range absorbs perspective tilt but starts above A4 (1.414),
    // so a sheet of paper held square-on isn't taken for a card. Cards sit smaller in frame than pages.
    static let cardAspect = 1.45...1.85
    static let cardMinArea = 0.06

    static func detectFile(_ path: String, mode: String) -> [Double]? {
        mode == "idCard" ? DocVision.detect(path: path, minArea: cardMinArea, aspect: cardAspect) : DocVision.detect(path: path)
    }

    private func start(mode: String, result: @escaping FlutterResult) {
        stop()
        let engine = CameraEngine(registry: textures)
        engine.mode = mode
        engine.onDetection = { [weak self] event in
            self?.sink?(event)
        }
        camera = engine
        engine.start { outcome in
            switch outcome {
            case .success(let size):
                result(["textureId": engine.textureId, "width": Int(size.width), "height": Int(size.height), "quarterTurns": 0])
            case .failure(let error):
                result(FlutterError(code: "CAMERA_FAILED", message: error.localizedDescription, details: nil))
            }
        }
    }

    private func stop() {
        camera?.stop()
        camera = nil
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}

/// AVCaptureSession feeding a Flutter texture (portrait BGRA frames), live Vision analysis and photo capture.
final class CameraEngine: NSObject, FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "flutter_doc_scanner.session")
    private let videoQueue = DispatchQueue(label: "flutter_doc_scanner.video")
    private let analysisQueue = DispatchQueue(label: "flutter_doc_scanner.analysis", qos: .userInitiated)
    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private let lock = NSLock()
    private weak var registry: FlutterTextureRegistry?
    private var device: AVCaptureDevice?
    private var latest: CVPixelBuffer?
    private var analyzing = false // videoQueue only
    private var photoDone: ((Result<URL, Error>) -> Void)?

    private(set) var textureId: Int64 = 0
    var mode = "document"
    var onDetection: (([String: Any]) -> Void)?

    init(registry: FlutterTextureRegistry) {
        self.registry = registry
        super.init()
        textureId = registry.register(self)
    }

    /// Configures and starts the session; completes on the main queue with the portrait preview size.
    func start(_ done: @escaping (Result<CGSize, Error>) -> Void) {
        sessionQueue.async {
            do {
                let size = try self.configure()
                self.session.startRunning()
                DispatchQueue.main.async { done(.success(size)) }
            } catch {
                DispatchQueue.main.async { done(.failure(error)) }
            }
        }
    }

    private func configure() throws -> CGSize {
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        session.sessionPreset = .photo // 4:3, same field of view for preview, analysis and photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw NSError(domain: "flutter_doc_scanner", code: 2, userInfo: [NSLocalizedDescriptionKey: "No back camera"])
        }
        self.device = device
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input), session.canAddOutput(videoOutput), session.canAddOutput(photoOutput) else {
            throw NSError(domain: "flutter_doc_scanner", code: 3, userInfo: [NSLocalizedDescriptionKey: "Camera configuration failed"])
        }
        session.addInput(input)

        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        session.addOutput(videoOutput)
        session.addOutput(photoOutput)
        photoOutput.maxPhotoQualityPrioritization = .balanced
        for connection in [videoOutput.connection(with: .video), photoOutput.connection(with: .video)] {
            if connection?.isVideoOrientationSupported == true { connection?.videoOrientation = .portrait }
        }

        try device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) { device.focusMode = .continuousAutoFocus }
        if device.isExposureModeSupported(.continuousAutoExposure) { device.exposureMode = .continuousAutoExposure }
        device.unlockForConfiguration()

        let dims = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
        return CGSize(width: Int(min(dims.width, dims.height)), height: Int(max(dims.width, dims.height)))
    }

    func stop() {
        registry?.unregisterTexture(textureId)
        sessionQueue.async {
            if self.session.isRunning { self.session.stopRunning() }
        }
    }

    func setTorch(_ on: Bool) {
        guard let device, device.hasTorch, (try? device.lockForConfiguration()) != nil else { return }
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }

    func capture(_ done: @escaping (Result<URL, Error>) -> Void) {
        photoDone = done
        let settings = photoOutput.availablePhotoCodecTypes.contains(.jpeg)
            ? AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            : AVCapturePhotoSettings()
        settings.photoQualityPrioritization = .balanced
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let done = photoDone
        photoDone = nil
        if let error { return done?(.failure(error)) ?? () }
        do {
            guard let data = photo.fileDataRepresentation() else {
                throw NSError(domain: "flutter_doc_scanner", code: 4, userInfo: [NSLocalizedDescriptionKey: "Empty photo"])
            }
            let dir = FileManager.default.temporaryDirectory.appendingPathComponent("scans", isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let url = dir.appendingPathComponent("cap_\(Int(Date().timeIntervalSince1970 * 1000)).jpg")
            try data.write(to: url)
            DispatchQueue.global(qos: .userInitiated).async { done?(.success(url)) }
        } catch {
            done?(.failure(error))
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        lock.lock()
        latest = buffer
        lock.unlock()
        registry?.textureFrameAvailable(textureId)

        let mode = self.mode
        guard !analyzing, ["document", "book", "idCard", "qr", "passport", "math"].contains(mode) else { return }
        analyzing = true
        analysisQueue.async {
            let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .up)
            let size = CGSize(width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            var event: [String: Any] = ["mode": mode]
            switch mode {
            case "qr": event["codes"] = DocVision.codes(handler)
            case "passport", "math": event["lines"] = DocVision.lines(handler, accurate: false, mrzOnly: mode == "passport")
            case "idCard":
                event["corners"] = DocVision.detect(handler, size: size, minArea: SwiftFlutterDocScannerPlugin.cardMinArea,
                                                    aspect: SwiftFlutterDocScannerPlugin.cardAspect) as Any
            default: event["corners"] = DocVision.detect(handler, size: size) as Any
            }
            self.videoQueue.async { self.analyzing = false }
            DispatchQueue.main.async { self.onDetection?(event) }
        }
    }

    func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
        lock.lock()
        defer { lock.unlock() }
        return latest.map { Unmanaged.passRetained($0) }
    }
}
