import ARKit
import AVFoundation
import Flutter
import UIKit

/// ARKit measuring view (Phase 5, Figma 7.6). Mirrors ArMeasure.kt: per frame it streams the placed points and the
/// screen-center hit in world meters plus the view-projection matrix; Flutter draws everything else.
final class ArMeasureFactory: NSObject, FlutterPlatformViewFactory {
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        ArMeasureView(frame: frame)
    }
}

final class ArMeasureView: NSObject, FlutterPlatformView, ARSessionDelegate {
    static weak var current: ArMeasureView?
    static var sink: FlutterEventSink?

    private let scene: ARSCNView
    private var anchors: [ARAnchor] = []
    private var lastHit: simd_float4x4?
    private var lastKind: String?

    init(frame: CGRect) {
        scene = ARSCNView(frame: frame)
        super.init()
        scene.automaticallyUpdatesLighting = false
        scene.session.delegate = self
        let coaching = ARCoachingOverlayView()
        coaching.session = scene.session
        coaching.goal = .anyPlane
        coaching.frame = scene.bounds
        coaching.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scene.addSubview(coaching)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        // LiDAR: raycasts hit the reconstructed mesh, which is what makes ±3% possible.
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) { config.sceneReconstruction = .mesh }
        scene.session.run(config)
        Self.current = self
    }

    func view() -> UIView { scene }

    deinit { scene.session.pause() }

    /// Anchors at [at] (world meters, snapped by Dart onto the locked surface), else at the center hit.
    func add(at: [Double]?) -> Bool {
        var transform = matrix_identity_float4x4
        if let at, at.count == 3 {
            transform.columns.3 = SIMD4(Float(at[0]), Float(at[1]), Float(at[2]), 1)
        } else if let hit = lastHit {
            transform = hit
        } else {
            return false
        }
        let anchor = ARAnchor(transform: transform)
        scene.session.add(anchor: anchor)
        anchors.append(anchor)
        return true
    }

    /// Moves point [index] to [at] (a dragged corner).
    func move(_ index: Int, to at: [Double]) {
        guard anchors.indices.contains(index), at.count == 3 else { return }
        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4(Float(at[0]), Float(at[1]), Float(at[2]), 1)
        let anchor = ARAnchor(transform: transform)
        scene.session.remove(anchor: anchors[index])
        scene.session.add(anchor: anchor)
        anchors[index] = anchor
    }

    func undo() {
        if let last = anchors.popLast() { scene.session.remove(anchor: last) }
    }

    func clear() {
        anchors.forEach { scene.session.remove(anchor: $0) }
        anchors.removeAll()
    }

    func stop() { scene.session.pause() }

    // Delegate runs on the main queue (no delegateQueue set), so touching the view here is safe.
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let size = scene.bounds.size
        guard size.width > 0, let sink = Self.sink else { return }
        let camera = frame.camera
        var tracking = "paused", reason = "none"
        switch camera.trackingState {
        case .normal: tracking = "tracking"
        case .notAvailable: tracking = "stopped"
        case .limited(.excessiveMotion): reason = "excessive_motion"
        case .limited(.insufficientFeatures): reason = "insufficient_features"
        case .limited: break
        }

        lastHit = nil
        lastKind = nil
        if tracking == "tracking" {
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            for target in [ARRaycastQuery.Target.existingPlaneGeometry, .estimatedPlane] {
                if let query = scene.raycastQuery(from: center, allowing: target, alignment: .any),
                   let hit = session.raycast(query).first {
                    lastHit = hit.worldTransform
                    lastKind = target == .existingPlaneGeometry ? "plane" : "depth"
                    break
                }
            }
        }

        // ARKit refines anchors as it learns the room; read their latest poses.
        let live = Dictionary(frame.anchors.map { ($0.identifier, $0) }, uniquingKeysWith: { a, _ in a })
        let points = anchors.flatMap { a -> [Double] in
            let t = (live[a.identifier] ?? a).transform.columns.3
            return [Double(t.x), Double(t.y), Double(t.z)]
        }
        let vp = camera.projectionMatrix(for: .portrait, viewportSize: size, zNear: 0.05, zFar: 100)
            * camera.viewMatrix(for: .portrait)
        let columns = [vp.columns.0, vp.columns.1, vp.columns.2, vp.columns.3]
        sink([
            "tracking": tracking,
            "reason": reason,
            "hit": lastHit.map { [Double($0.columns.3.x), Double($0.columns.3.y), Double($0.columns.3.z)] } as Any,
            // Raycast results put the surface normal on +Y.
            "normal": lastHit.map { [Double($0.columns.1.x), Double($0.columns.1.y), Double($0.columns.1.z)] } as Any,
            "kind": lastKind as Any,
            "points": points,
            "vp": columns.flatMap { [Double($0.x), Double($0.y), Double($0.z), Double($0.w)] },
        ])
    }

    static func setTorch(_ on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch,
              (try? device.lockForConfiguration()) != nil else { return }
        device.torchMode = on ? .on : .off
        device.unlockForConfiguration()
    }
}

final class ArEvents: NSObject, FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        ArMeasureView.sink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        ArMeasureView.sink = nil
        return nil
    }
}
