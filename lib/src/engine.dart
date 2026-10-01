import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart';

/// Live camera modes the native engine understands.
/// `count` has no live analyzer (it counts a still photo in Dart); the camera just keeps running.
enum ScanMode { document, idCard, passport, book, qr, math, count }

/// Page filters applied by [DocScanner.process], in the order the Enhance screen shows them.
/// `noShadow` = shadow removal only (tones kept); `magic` = shadow removal + deeper ink; `color` = saturation boost.
enum PageFilter { original, magic, bw, gray, noShadow, color }

/// Started camera preview. [size] is the portrait preview size in pixels.
class ScannerPreview {
  const ScannerPreview(this.textureId, this.size, this.quarterTurns);
  final int textureId;
  final Size size;
  final int quarterTurns;
}

/// One analyzed frame (or file). All geometry is normalized 0..1 in the upright image.
class Detection {
  const Detection(this.mode, {this.corners, this.codes = const [], this.lines = const []});

  final String mode;

  /// Page / card / spread quad, TL, TR, BR, BL (document, idCard, book).
  final List<Offset>? corners;

  /// Decoded barcodes (qr).
  final List<ScannedCode> codes;

  /// MRZ-looking text lines only (passport); other text never leaves native code.
  final List<TextLine> lines;

  factory Detection.fromMap(Map m) => Detection(
    m['mode'] as String,
    corners: DocScanner._points(m['corners']),
    codes: [
      for (final c in (m['codes'] as List?) ?? const [])
        ScannedCode((c as Map)['value'] as String, DocScanner._points(c['corners'])),
    ],
    lines: [for (final l in (m['lines'] as List?) ?? const []) TextLine.fromMap(l as Map)],
  );
}

Rect _rect(List b) => Rect.fromLTRB(
  (b[0] as num).toDouble(),
  (b[1] as num).toDouble(),
  (b[2] as num).toDouble(),
  (b[3] as num).toDouble(),
);

class ScannedCode {
  const ScannedCode(this.value, this.corners);
  final String value;
  final List<Offset>? corners;
}

class TextLine {
  const TextLine(this.text, this.box);
  final String text;

  /// Normalized 0..1 in the upright image.
  final Rect box;

  factory TextLine.fromMap(Map m) => TextLine(m['text'] as String, _rect(m['box'] as List));
}

/// A paragraph-like block from [DocScanner.recognizeText]. On iOS every block is a single line (Vision reports
/// lines only).
class TextBlock {
  const TextBlock(this.text, this.box, this.lines);
  final String text;

  /// Normalized 0..1 in the upright image.
  final Rect box;
  final List<TextLine> lines;

  factory TextBlock.fromMap(Map m) => TextBlock(m['text'] as String, _rect(m['box'] as List), [
    for (final l in (m['lines'] as List?) ?? const []) TextLine.fromMap(l as Map),
  ]);
}

/// A photo from [DocScanner.capture]. [corners] are detected on the full-res photo.
class Capture {
  const Capture(this.path, this.corners);
  final String path;
  final List<Offset>? corners;
}

/// Native camera + detection engine (see docs/SCANNER_PHASES.md §1.2).
abstract final class DocScanner {
  static const _channel = MethodChannel('flutter_doc_scanner');
  static const _events = EventChannel('flutter_doc_scanner/detections');

  /// Asks for camera permission if needed, then starts the camera.
  /// Throws [PlatformException] with code `PERMISSION_DENIED` if refused.
  static Future<ScannerPreview> start(ScanMode mode) async {
    final r = (await _channel.invokeMapMethod<String, Object?>('start', {'mode': mode.name}))!;
    return ScannerPreview(
      r['textureId']! as int,
      Size((r['width']! as int).toDouble(), (r['height']! as int).toDouble()),
      r['quarterTurns']! as int,
    );
  }

  static Future<void> setMode(ScanMode mode) => _channel.invokeMethod('setMode', {'mode': mode.name});

  static Future<void> setTorch(bool on) => _channel.invokeMethod('setTorch', {'on': on});

  static Future<void> stop() => _channel.invokeMethod('stop');

  /// Opens this app's system settings page (e.g. after camera permission was denied).
  static Future<void> openSettings() => _channel.invokeMethod('openSettings');

  static Stream<Detection> get detections => _events.receiveBroadcastStream().map((e) => Detection.fromMap(e as Map));

  static Future<Capture> capture() async {
    final r = (await _channel.invokeMapMethod<String, Object?>('capture'))!;
    return Capture(r['path']! as String, _points(r['corners']));
  }

  /// Runs [mode]'s analyzer on an image file (e.g. from the gallery).
  static Future<Detection> analyzeFile(String path, ScanMode mode) async =>
      Detection.fromMap((await _channel.invokeMethod<Map>('analyze', {'path': path, 'mode': mode.name}))!);

  /// Perspective crop → rotate → filter → brightness / contrast → JPEG at [outPath]. Null [corners] keeps the
  /// whole image. [maxSize] caps the long side, for fast thumbnails. [brightness] and [contrast] run -1..1
  /// (0 = unchanged): `out = (in − 128) · (1 + contrast) + 128 + 100 · brightness`.
  static Future<void> process({
    required String path,
    required String outPath,
    List<Offset>? corners,
    int rotation = 0,
    PageFilter filter = PageFilter.original,
    int? maxSize,
    double brightness = 0,
    double contrast = 0,
  }) => _channel.invokeMethod('process', {
    'path': path,
    'outPath': outPath,
    'corners': corners?.expand((p) => [p.dx, p.dy]).toList(),
    'rotation': rotation,
    'filter': filter.name,
    'maxSize': maxSize,
    'brightness': brightness,
    'contrast': contrast,
  });

  /// Full OCR of an image file (any photo or rendered PDF page): every text block with its lines, boxes normalized
  /// 0..1 in the upright image. [script]: `latin`, `chinese`, `devanagari`, `japanese`, `korean`.
  /// Throws [PlatformException]: `UNSUPPORTED_SCRIPT` (unknown, or not available on this iOS; Vision has no
  /// Devanagari), `MODEL_UNAVAILABLE` (Android is still downloading that script's model; retry shortly), `FAILED`.
  static Future<List<TextBlock>> recognizeText(String path, {String script = 'latin'}) async => [
    for (final b in (await _channel.invokeListMethod<Map>('recognizeText', {'path': path, 'script': script}))!)
      TextBlock.fromMap(b),
  ];

  static List<Offset>? _points(Object? raw) {
    if (raw is! List || raw.length != 8) return null;
    final v = raw.cast<num>();
    return [for (var i = 0; i < 8; i += 2) Offset(v[i].toDouble(), v[i + 1].toDouble())];
  }
}

/// Shows the camera texture upright, sized to [ScannerPreview.size]. Wrap it in a
/// `FittedBox(fit: BoxFit.cover)` to fill the screen.
class ScannerPreviewView extends StatelessWidget {
  const ScannerPreviewView(this.preview, {super.key});
  final ScannerPreview preview;

  @override
  Widget build(BuildContext context) {
    final s = preview.size;
    final odd = preview.quarterTurns.isOdd;
    return SizedBox.fromSize(
      size: s,
      child: RotatedBox(
        quarterTurns: preview.quarterTurns,
        child: SizedBox(
          width: odd ? s.height : s.width,
          height: odd ? s.width : s.height,
          child: Texture(textureId: preview.textureId),
        ),
      ),
    );
  }
}

/// One AR camera frame. Positions are world-space meters; [viewProjection] maps them to clip space of the
/// preview (column-major, OpenGL convention).
class ArFrame {
  const ArFrame({
    required this.tracking,
    this.reason = 'none',
    this.hit,
    this.normal,
    this.hitKind,
    this.points = const [],
    this.viewProjection,
  });

  /// `tracking`, `paused` (still starting / lost) or `stopped`.
  final String tracking;

  /// Why tracking is poor: `none`, `bad_state`, `insufficient_light`, `excessive_motion`,
  /// `insufficient_features`, `camera_unavailable`.
  final String reason;

  /// Where the screen-center reticle meets a surface; null when it isn't on one.
  final Vector3? hit;

  /// Surface normal at [hit] (unit length): exact on a detected plane, estimated from depth otherwise.
  final Vector3? normal;

  /// `plane` (a detected plane) or `depth` (depth / feature point); null without a hit.
  final String? hitKind;

  /// Placed points, in order.
  final List<Vector3> points;
  final Matrix4? viewProjection;

  bool get isTracking => tracking == 'tracking';

  factory ArFrame.fromMap(Map m) {
    final vp = m['vp'] as List?;
    return ArFrame(
      tracking: m['tracking'] as String? ?? 'paused',
      reason: m['reason'] as String? ?? 'none',
      hit: _vectors(m['hit']).firstOrNull,
      normal: _vectors(m['normal']).firstOrNull?.normalized(),
      hitKind: m['kind'] as String?,
      points: _vectors(m['points']),
      viewProjection: vp == null ? null : Matrix4.fromList([for (final v in vp) (v as num).toDouble()]),
    );
  }

  static List<Vector3> _vectors(Object? raw) {
    if (raw is! List) return const [];
    final v = raw.cast<num>();
    return [
      for (var i = 0; i + 2 < v.length; i += 3) Vector3(v[i].toDouble(), v[i + 1].toDouble(), v[i + 2].toDouble()),
    ];
  }
}

/// AR measuring session (Phase 5). Android: ARCore drawn into a texture. iOS: an ARKit view.
abstract final class ArMeasure {
  static const _channel = MethodChannel('flutter_doc_scanner');
  static const _events = EventChannel('flutter_doc_scanner/ar');

  /// Starts AR for a preview of [aspect] (width / height). Stop [DocScanner] first: AR needs the camera.
  /// Returns the texture id (null on iOS, where [ArPreviewView] hosts a native view).
  /// Throws [PlatformException]: `PERMISSION_DENIED`, `AR_UNSUPPORTED`, `AR_INSTALL` (Play Store opened),
  /// `AR_FAILED`.
  static Future<int?> start(double aspect) async =>
      (await _channel.invokeMapMethod<String, Object?>('arStart', {'aspect': aspect}))?['textureId'] as int?;

  static Stream<ArFrame> get frames => _events.receiveBroadcastStream().map((e) => ArFrame.fromMap(e as Map));

  /// Anchors a point at [at] (world meters), or where the reticle hits when null. False if nothing to anchor.
  static Future<bool> add({Vector3? at}) async =>
      await _channel.invokeMethod<bool>('arAdd', {
        'at': at == null ? null : [at.x, at.y, at.z],
      }) ??
      false;

  /// Moves point [index] to [at] (world meters). Completes once the native anchor has moved.
  static Future<void> move(int index, Vector3 at) => _channel.invokeMethod('arMove', {
    'index': index,
    'at': [at.x, at.y, at.z],
  });

  /// JPEG of exactly what the AR view shows (viewport aspect, camera only) and the frame it shows: points and
  /// view-projection matrix of that very frame, so an overlay drawn from them lines up with the photo exactly.
  /// Throws [PlatformException]: `AR_NOT_RUNNING`, `AR_SNAPSHOT` (capture failed), `AR_TIMEOUT` (no frame in 5 s).
  static Future<(String, ArFrame)> snapshot() async {
    final m = await _channel
        .invokeMapMethod<String, Object?>('arSnapshot')
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw PlatformException(code: 'AR_TIMEOUT', message: 'The camera stopped. Try again.'),
        );
    final path = m?['path'] as String?;
    if (path == null) throw PlatformException(code: 'AR_SNAPSHOT', message: 'No snapshot');
    return (path, ArFrame.fromMap({...m!, 'tracking': 'tracking'}));
  }

  static Future<void> undo() => _channel.invokeMethod('arUndo');

  static Future<void> clear() => _channel.invokeMethod('arClear');

  static Future<void> setTorch(bool on) => _channel.invokeMethod('arTorch', {'on': on});

  static Future<void> stop() => _channel.invokeMethod('arStop');
}

/// The AR camera, filling its box exactly (the session renders at the box's aspect).
class ArPreviewView extends StatelessWidget {
  const ArPreviewView(this.textureId, {super.key});
  final int? textureId;

  @override
  Widget build(BuildContext context) => defaultTargetPlatform == TargetPlatform.iOS
      ? const UiKitView(viewType: 'flutter_doc_scanner/ar')
      : textureId == null
      ? const SizedBox()
      : Texture(textureId: textureId!);
}

enum QuadState { searching, detected, steady }

/// Turns noisy per-frame detections into a calm overlay and an auto-capture signal.
///
/// Feed every [Detection] to [add] with a monotonic timestamp. Pure Dart, unit-tested.
class QuadTracker {
  QuadTracker({
    this.smoothing = 0.35,
    this.holdOnLoss = const Duration(milliseconds: 250),
    this.steadyAfter = const Duration(milliseconds: 700),
    this.tolerance = 0.015,
    this.jump = 0.08,
  });

  /// EMA weight of a new frame (higher = snappier, lower = calmer).
  final double smoothing;

  /// A lost page stays on screen this long, so one dropped frame doesn't flicker.
  final Duration holdOnLoss;

  /// How long corners must stay within [tolerance] before the page counts as steady.
  final Duration steadyAfter;

  /// Max corner movement (fraction of frame) that still counts as "holding still".
  final double tolerance;

  /// Movement beyond this is a different page: snap instead of gliding.
  final double jump;

  List<Offset>? corners;
  Duration? _lastSeen;
  Duration? _stableSince;
  Duration _now = Duration.zero;
  bool _armed = true;

  QuadState get state {
    if (corners == null) return QuadState.searching;
    return _armed && steadyProgress >= 1 ? QuadState.steady : QuadState.detected;
  }

  /// 0..1 progress towards [QuadState.steady], for the shutter ring.
  double get steadyProgress {
    final since = _stableSince;
    if (corners == null || since == null || !_armed) return 0;
    return ((_now - since).inMicroseconds / steadyAfter.inMicroseconds).clamp(0.0, 1.0);
  }

  /// False after [captured] until the page leaves or changes, so one page is never shot twice.
  bool get armed => _armed;

  void add(List<Offset>? raw, Duration now) {
    _now = now;
    final current = corners;
    if (raw == null) {
      if (current != null && now - _lastSeen! > holdOnLoss) reset();
      return;
    }
    _lastSeen = now;
    if (current == null) {
      corners = raw;
      _stableSince = now;
      return;
    }
    var moved = 0.0;
    for (var i = 0; i < 4; i++) {
      moved = math.max(moved, (raw[i] - current[i]).distance);
    }
    if (moved > jump) {
      corners = raw;
      _stableSince = now;
      _armed = true;
      return;
    }
    corners = [for (var i = 0; i < 4; i++) Offset.lerp(current[i], raw[i], smoothing)!];
    if (moved > tolerance) _stableSince = now;
  }

  /// Call after a capture; re-arms when the page is lost or replaced.
  void captured() => _armed = false;

  void reset() {
    corners = null;
    _lastSeen = null;
    _stableSince = null;
    _armed = true;
  }
}
