import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Live camera modes the native engine understands.
/// `count` has no live analyzer (it counts a still photo in Dart); the camera just keeps running.
enum ScanMode { document, idCard, passport, book, qr, math, count }

/// Page filters applied by [DocScanner.process].
enum PageFilter { original, magic, gray, bw }

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
        lines: [
          for (final l in (m['lines'] as List?) ?? const [])
            TextLine((l as Map)['text'] as String, _rect(l['box'] as List)),
        ],
      );

  static Rect _rect(List b) => Rect.fromLTRB(
      (b[0] as num).toDouble(), (b[1] as num).toDouble(), (b[2] as num).toDouble(), (b[3] as num).toDouble());
}

class ScannedCode {
  const ScannedCode(this.value, this.corners);
  final String value;
  final List<Offset>? corners;
}

class TextLine {
  const TextLine(this.text, this.box);
  final String text;
  final Rect box;
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

  /// Perspective crop → rotate → filter → JPEG at [outPath]. Null [corners] keeps the whole image.
  /// [maxSize] caps the long side, for fast thumbnails.
  static Future<void> process({
    required String path,
    required String outPath,
    List<Offset>? corners,
    int rotation = 0,
    PageFilter filter = PageFilter.original,
    int? maxSize,
  }) =>
      _channel.invokeMethod('process', {
        'path': path,
        'outPath': outPath,
        'corners': corners?.expand((p) => [p.dx, p.dy]).toList(),
        'rotation': rotation,
        'filter': filter.name,
        'maxSize': maxSize,
      });

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
