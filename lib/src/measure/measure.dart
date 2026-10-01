import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../engine.dart';
import '../scanner/card_render.dart';
import '../scanner/session.dart';
import '../scanner/ui.dart';
import 'geometry.dart';

/// State of the Measure tab (Figma 7.6): the AR session, placed points, closed flag and unit.
class MeasureController extends ChangeNotifier {
  /// A closed shape with an area: Save is offered.
  bool get canExport => running && closed && !dragging && polygonArea(points) >= _minArea;
  static const _minArea = 1e-4; // m² (1 cm²): three nearly collinear points aren't a shape

  /// [exportCard] is running.
  bool exporting = false;
  bool _disposed = false;

  /// The AR view as it is now, with the shape drawn on it exactly like the live overlay, on an A4 card with the
  /// area (both unit systems), perimeter and every side: the page and its title ("Area · 6.84 m²").
  ///
  /// Null when there's no closed shape or a save is already running. Throws [PlatformException] when the
  /// snapshot fails (the caller shows its message).
  Future<(ScanPage, String)?> exportCard(BuildContext context) async {
    if (!canExport || exporting) return null;
    final viewWidth = MediaQuery.sizeOf(context).width, u = unit, now = DateTime.now();
    _setExporting(true);
    String? shot;
    try {
      final (path, still) = await ArMeasure.snapshot();
      shot = path;
      final pts = still.points, area = polygonArea(pts);
      if (pts.length < 3 || area < _minArea) {
        throw PlatformException(code: 'AR_SHAPE', message: 'The shape changed. Close it again, then save.');
      }
      final photo = await _annotate(path, still, viewWidth, u);
      try {
        if (!context.mounted) return null;
        final png = await renderCard(
          context,
          PhotoCard(
            title: 'Area measurement',
            photo: photo,
            details: _AreaDetails(pts, u),
            note: 'Measured with DocScan AR · approx. ±5%',
            time: now,
          ),
        );
        return (ScanPage(png, null, label: 'Area'), 'Area · ${formatArea(area, u)}');
      } finally {
        photo.dispose();
      }
    } finally {
      if (shot != null) File(shot).delete().ignore();
      _setExporting(false);
    }
  }

  void _setExporting(bool on) {
    exporting = on;
    if (!_disposed) notifyListeners();
  }

  /// [path] with the shape of [still] painted on by [MeasurePainter] at the live overlay's scale ([viewWidth]
  /// logical px across), cropped vertically to a roughly square band around the shape so it fills the card.
  Future<ui.Image> _annotate(String path, ArFrame still, double viewWidth, MeasureUnit u) async {
    final photo = await decodeForCard(path);
    try {
      final s = photo.width / viewWidth;
      final size = Size(viewWidth, photo.height / s); // logical, like the live overlay
      final vp = still.viewProjection!;
      final ys = [for (final p in still.points) ?project(vp, p)?.dy].map((y) => y * size.height);
      var top = 0.0, height = size.height;
      if (ys.isNotEmpty) {
        const pad = 72.0; // room for the length pills and point names
        final lo = ys.reduce(math.min) - pad, hi = ys.reduce(math.max) + pad;
        height = math.min(size.height, math.max(hi - lo, size.width));
        top = ((lo + hi - height) / 2).clamp(0, size.height - height);
      }
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)
        ..translate(0, -top * s)
        ..drawImage(photo, Offset.zero, Paint())
        ..scale(s);
      MeasurePainter(this, still: still, unit: u).paint(canvas, size);
      final picture = recorder.endRecording();
      try {
        return await picture.toImage(photo.width, (height * s).round());
      } finally {
        picture.dispose();
      }
    } finally {
      photo.dispose();
    }
  }

  ArFrame? frame;
  int? textureId;
  bool running = false, closed = false;
  MeasureUnit unit = MeasureUnit.m;
  StreamSubscription<ArFrame>? _frames;

  // Surface lock: the first point fixes the plane (floor, wall, table…) and every later point is where the aim ray
  // meets it. Keeps a shape's corners coplanar, and works on blank walls where ARCore finds no hits at all.
  // The plane passes through the first point's *live* anchor, so it follows ARCore's map corrections instead of
  // staying where the wall was before the map moved.
  Vector3? _planeNormal;
  bool _planeExact = false; // normal came from a detected plane, not a depth estimate
  Vector3? get _planeOrigin => _planeNormal == null ? null : frame?.points.firstOrNull;

  // Raw depth hits jitter 1–2 cm frame to frame; while the aim holds still, average the last few.
  final _recentHits = <Vector3>[];
  static const _steadyFrames = 6, _steadyRadius = .03; // m

  // Corner drag: the dragged point follows the finger along the surface until the native anchor has moved.
  int? _dragIndex;
  Offset? _dragAt; // normalized preview position of the dragged point
  Offset _grab = Offset.zero; // finger → point, so the point doesn't jump under the finger
  bool _settle = false; // released; waiting for the native move
  bool _moved = false; // native move done; the next frame carries the new pose

  List<Offset?> get _screen {
    final f = frame, vp = f?.viewProjection;
    if (f == null || vp == null) return const [];
    return [for (final p in f.points) project(vp, p)];
  }

  int get pointCount => frame?.points.length ?? 0;

  /// Placed points, with the corner being dragged at its live position.
  List<Vector3> get points {
    final pts = frame?.points ?? const <Vector3>[];
    final i = _dragIndex, p = _dragPoint;
    if (i == null || p == null || i >= pts.length) return pts;
    return [...pts]..[i] = p;
  }

  bool get dragging => _dragIndex != null && !_settle;

  int? get draggedIndex => dragging ? _dragIndex : null;

  /// Normalized preview position of the dragged corner, for the loupe.
  Offset? get dragAt => dragging ? _dragAt : null;

  /// The surface a dragged corner slides on: the lock, else the plane of the shape itself.
  (Vector3, Vector3)? get _surface {
    final origin = _planeOrigin, normal = _planeNormal;
    return origin != null && normal != null ? (origin, normal) : fitPlane(frame?.points ?? const []);
  }

  Vector3? get _dragPoint {
    final at = _dragAt, vp = frame?.viewProjection, s = _surface;
    if (at == null || vp == null || s == null) return null;
    return aimOnPlane(vp, s.$1, s.$2, at: at);
  }

  /// Picks up the corner under [position] (view pixels). False when there's none within reach.
  bool dragStart(Offset position, Size view) {
    final vp = frame?.viewProjection;
    if (vp == null || _surface == null || view.isEmpty) return false;
    final finger = Offset(position.dx / view.width, position.dy / view.height);
    int? best;
    var bestDistance = 36.0; // px
    final pts = frame!.points;
    for (var i = 0; i < pts.length; i++) {
      final p = project(vp, pts[i]);
      if (p == null) continue;
      final d = Offset((p.dx - finger.dx) * view.width, (p.dy - finger.dy) * view.height).distance;
      if (d < bestDistance) (best, bestDistance) = (i, d);
    }
    if (best == null) return false;
    final p = project(vp, pts[best])!;
    _dragIndex = best;
    _grab = p - finger;
    _dragAt = p;
    _settle = false;
    HapticFeedback.selectionClick();
    notifyListeners();
    return true;
  }

  void dragUpdate(Offset position, Size view) {
    if (!dragging || view.isEmpty) return;
    _dragAt = Offset(position.dx / view.width, position.dy / view.height) + _grab;
    notifyListeners();
  }

  /// Drops the corner. The live position stays on screen until the anchor's new pose comes back in a frame.
  Future<void> dragEnd() async {
    final i = _dragIndex, p = _dragPoint;
    if (i == null) return;
    if (p == null) return dragCancel();
    _settle = true;
    notifyListeners();
    await ArMeasure.move(i, p);
    _moved = true;
  }

  void dragCancel() {
    _dragIndex = _dragAt = null;
    _settle = _moved = false;
    notifyListeners();
  }

  bool get onSurface => target != null;

  /// Where "+" would drop the next point: on the locked surface once there is one, else the raw hit.
  Vector3? get target {
    final f = frame, vp = f?.viewProjection;
    if (f == null || !f.isTracking || closed) return f?.hit;
    final origin = _planeOrigin, normal = _planeNormal;
    if (origin == null || normal == null || vp == null) return _steadyHit;
    return aimOnPlane(vp, origin, normal);
  }

  /// Mean of the recent hits while they stay within [_steadyRadius] of each other.
  Vector3? get _steadyHit {
    if (_recentHits.isEmpty) return null;
    return _recentHits.fold(Vector3.zero(), (a, p) => a + p) / _recentHits.length.toDouble();
  }

  void _onFrame(ArFrame f) {
    frame = f;
    final hit = f.hit;
    if (hit == null || (_steadyHit?.distanceTo(hit) ?? 0) > _steadyRadius) _recentHits.clear();
    if (hit != null) {
      _recentHits.add(hit);
      if (_recentHits.length > _steadyFrames) _recentHits.removeAt(0);
    }
    if (_moved) {
      _dragIndex = _dragAt = null;
      _settle = _moved = false;
    }
    // A depth-estimated lock upgrades to a detected plane that it matches (same side, < 20°, within 5 cm).
    final origin = _planeOrigin, normal = _planeNormal, n = f.normal;
    if (origin != null && normal != null && !_planeExact && f.hitKind == 'plane' && hit != null && n != null) {
      if (n.dot(normal) > .94 && (hit - origin).dot(n).abs() < .05) {
        _planeNormal = n;
        _planeExact = true;
      }
    }
    notifyListeners();
  }

  void _unlock() {
    _planeNormal = null;
    _planeExact = false;
  }

  /// Throws [PlatformException] from [ArMeasure.start].
  Future<void> start(double aspect) async {
    _frames ??= ArMeasure.frames.listen(_onFrame);
    textureId = await ArMeasure.start(aspect);
    running = true;
    notifyListeners();
  }

  Future<void> stop() async {
    final frames = _frames;
    _frames = null;
    running = false;
    frame = null;
    textureId = null;
    closed = false; // anchors die with the session
    _unlock();
    notifyListeners();
    await ArMeasure.stop(); // frees the camera first; the scanner may be waiting for it
    await frames?.cancel();
  }

  /// "+": drops a point at the reticle, closes the shape when the reticle is on the first point, or starts a
  /// new shape after a closed one.
  Future<bool> add(Size view) async {
    if (closed) {
      await clear();
    } else if (pointCount >= 3 && _nearFirst(view.center(Offset.zero), view)) {
      _close();
      return true;
    }
    final at = target;
    if (at == null) return false;
    final first = _planeNormal == null;
    final ok = await ArMeasure.add(at: at);
    if (ok) {
      HapticFeedback.lightImpact();
      final n = frame?.normal;
      if (first && n != null) {
        _planeNormal = n;
        _planeExact = frame?.hitKind == 'plane';
      }
    }
    notifyListeners();
    return ok;
  }

  /// Removes every point (a new shape starts with the next "+").
  Future<void> clear() async {
    await ArMeasure.clear();
    closed = false;
    _unlock();
    notifyListeners();
  }

  void undo() {
    if (closed) {
      closed = false;
      notifyListeners();
    } else if (pointCount > 0) {
      if (pointCount == 1) _unlock();
      ArMeasure.undo();
    }
  }

  /// Tapping the first point closes the shape.
  void tap(Offset position, Size view) {
    if (!closed && pointCount >= 3 && _nearFirst(position, view)) _close();
  }

  void setUnit(MeasureUnit u) {
    unit = u;
    notifyListeners();
  }

  void _close() {
    HapticFeedback.mediumImpact();
    closed = true;
    notifyListeners();
  }

  bool _nearFirst(Offset position, Size view) {
    final first = _screen.firstOrNull;
    return first != null && (Offset(first.dx * view.width, first.dy * view.height) - position).distance < 32;
  }

  /// What the overlay shows, for screen readers: "Area 6.84 m². Sides 3.1 m, 2.4 m, …".
  String? get summary {
    final pts = points;
    if (pts.isEmpty) return null;
    final n = pts.length;
    final sides = [
      for (var i = 0; i < (closed ? n : n - 1); i++) formatLength(pts[i].distanceTo(pts[(i + 1) % n]), unit),
    ];
    final head = closed ? 'Area ${formatArea(polygonArea(pts), unit)}' : '$n point${n == 1 ? '' : 's'}';
    return sides.isEmpty ? head : '$head. Sides ${sides.join(', ')}';
  }

  /// Guidance for the status pill; null hides it.
  (IconData, String)? get hint {
    final f = frame;
    if (f == null) return (Icons.view_in_ar_rounded, 'Starting AR…');
    if (!f.isTracking) {
      return switch (f.reason) {
        'insufficient_light' => (Icons.flashlight_on_rounded, 'Too dark · Turn on the flash'),
        'excessive_motion' => (Icons.pan_tool_alt_outlined, 'Move your phone more slowly'),
        'insufficient_features' => (Icons.texture_rounded, 'Point at a surface with more detail'),
        _ => (Icons.screen_rotation_alt_rounded, 'Move your phone slowly to find a surface'),
      };
    }
    if (dragging) return null;
    if (closed) return (Icons.open_with_rounded, 'Drag a corner to adjust');
    if (target == null) {
      return f.points.isEmpty
          ? (Icons.center_focus_weak_rounded, 'Point the circle at a surface')
          : (Icons.center_focus_weak_rounded, 'Aim back at the same surface');
    }
    if (f.points.isEmpty) return (Icons.control_camera_rounded, 'Tap + to drop points');
    if (f.points.length < 3) return (Icons.add_rounded, 'Tap + to add the next corner');
    return (Icons.change_history_rounded, 'Tap the first point to close the shape');
  }

  @override
  void dispose() {
    _disposed = true;
    _frames?.cancel();
    super.dispose();
  }
}

/// "A", "B", … "Z", "A2", …: point names on a saved measurement, matching its list of sides.
String pointName(int i) => String.fromCharCode(65 + i % 26) + (i >= 26 ? '${i ~/ 26 + 1}' : '');

/// Area (both unit systems), perimeter, sides and point count under a saved measurement's photo.
class _AreaDetails extends StatelessWidget {
  const _AreaDetails(this.points, this.unit);
  final List<Vector3> points;
  final MeasureUnit unit;

  @override
  Widget build(BuildContext context) {
    const p = Palette.light;
    final n = points.length, area = polygonArea(points);
    final other = unit == MeasureUnit.m ? MeasureUnit.ft : MeasureUnit.m;
    final sides = [for (var i = 0; i < n; i++) points[i].distanceTo(points[(i + 1) % n])];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Area', style: TextStyles.footnoteMedium.copyWith(color: p.textSecondary)),
        Text.rich(
          TextSpan(
            text: formatArea(area, unit),
            style: TextStyles.title3.copyWith(
              fontSize: 30,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
            children: [
              TextSpan(
                text: '   ${formatArea(area, other)}',
                style: TextStyles.subhead.copyWith(color: p.textTertiary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        CardFact(
          'Perimeter',
          formatLength(sides.fold(0.0, (a, b) => a + b), unit),
          note: formatLength(sides.fold(0.0, (a, b) => a + b), other),
        ),
        CardFact(
          'Sides',
          [
            for (var i = 0; i < n; i++) '${pointName(i)}–${pointName((i + 1) % n)} ${formatLength(sides[i], unit)}',
          ].join(' · '),
        ),
        CardFact('Points', '$n'),
      ],
    );
  }
}

/// Reticle, polygon, dashed edges, length pills and the area card, drawn over the AR camera.
class MeasurePainter extends CustomPainter {
  MeasurePainter(this.c, {this.still, this.unit}) : super(repaint: c);
  final MeasureController c;

  /// A saved frame ([ArMeasure.snapshot]): draws its closed shape with named points, no reticle or tape.
  final ArFrame? still;

  /// Overrides [MeasureController.unit] (a saved measurement keeps the unit it was saved in).
  final MeasureUnit? unit;

  static const _fill = Color(0x664D6FC4);
  static const _pillColor = Color(0xE61C1F26);

  @override
  void paint(Canvas canvas, Size size) {
    final f = still ?? c.frame;
    final vp = f?.viewProjection;
    final center = size.center(Offset.zero);
    final target = still == null ? c.target : null;
    final closed = still != null || c.closed, unit = this.unit ?? c.unit;
    if (still == null) _reticle(canvas, center, target != null);
    final pts3 = still?.points ?? c.points;
    if (f == null || vp == null || pts3.isEmpty) return;

    Offset? px(Offset? n) => n == null ? null : Offset(n.dx * size.width, n.dy * size.height);
    final pts = [for (final p in pts3) px(project(vp, p))];
    final visible = pts.whereType<Offset>().toList();
    final mid = visible.isEmpty ? center : visible.reduce((a, b) => a + b) / visible.length.toDouble();

    if (closed && visible.length == pts.length) {
      canvas.drawPath(Path()..addPolygon(visible, true), Paint()..color = _fill);
    }
    final n = pts3.length;
    final edges = closed ? n : n - 1;
    for (var i = 0; i < edges; i++) {
      final a = pts[i], b = pts[(i + 1) % n];
      if (a == null || b == null) continue;
      _dashed(canvas, a, b);
      _pill(canvas, _outward(a, b, mid), formatLength(pts3[i].distanceTo(pts3[(i + 1) % n]), unit));
    }
    // Live edge from the last point to the reticle, like a tape being pulled out.
    final last = pts.last;
    if (!closed && target != null && last != null) {
      _dashed(canvas, last, center, alpha: .7);
      if ((center - last).distance > 60) {
        _pill(
          canvas,
          Offset.lerp(last, center, .5)! + const Offset(0, -22),
          formatLength(pts3.last.distanceTo(target), unit),
        );
      }
    }
    for (var i = 0; i < pts.length; i++) {
      final p = pts[i];
      if (p == null) continue;
      final r = still == null && i == c.draggedIndex ? 12.0 : 8.0;
      canvas.drawCircle(p, r, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = Tone.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
    }
    if (still != null) {
      for (var i = 0; i < pts.length; i++) {
        final p = pts[i];
        if (p != null) _name(canvas, p, mid, pointName(i));
      }
    }
    if (closed && visible.length == pts.length) {
      _areaCard(canvas, mid, formatArea(polygonArea(pts3), unit));
    }
  }

  void _reticle(Canvas canvas, Offset c, bool onSurface) {
    final color = Colors.white.withValues(alpha: onSurface ? 1 : .45);
    canvas.drawCircle(
      c,
      22,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(c, onSurface ? 4 : 3, Paint()..color = color);
  }

  void _dashed(Canvas canvas, Offset a, Offset b, {double alpha = 1}) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final length = (b - a).distance;
    if (length < 1) return;
    final dir = (b - a) / length;
    for (var d = 0.0; d < length; d += 14) {
      canvas.drawLine(a + dir * d, a + dir * math.min(d + 8, length), paint);
    }
  }

  /// Edge midpoint pushed away from the shape, so pills sit outside the polygon like Figma.
  Offset _outward(Offset a, Offset b, Offset mid) {
    final m = Offset.lerp(a, b, .5)!;
    final d = b - a;
    if (d.distance < 1) return m;
    var normal = Offset(-d.dy, d.dx) / d.distance;
    if ((m + normal - mid).distance < (m - mid).distance) normal = -normal;
    return m + normal * 20;
  }

  void _pill(Canvas canvas, Offset at, String text) {
    final tp = _text(text, const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600));
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: at, width: tp.width + 20, height: tp.height + 10),
      const Radius.circular(14),
    );
    canvas.drawRRect(r, Paint()..color = _pillColor);
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  /// A point's name in a small dark dot just outside the shape.
  void _name(Canvas canvas, Offset p, Offset mid, String name) {
    final away = p - mid;
    final at = p + (away.distance < 1 ? const Offset(0, -1) : away / away.distance) * 22;
    final tp = _text(name, const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700));
    canvas.drawCircle(at, math.max(tp.width, tp.height) / 2 + 5, Paint()..color = _pillColor);
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  void _areaCard(Canvas canvas, Offset at, String value) {
    final label = _text('Area', const TextStyle(color: Tone.muted, fontSize: 12, fontWeight: FontWeight.w500));
    final big = _text(value, const TextStyle(color: Tone.chrome, fontSize: 20, fontWeight: FontWeight.w700));
    final w = math.max(label.width, big.width) + 32, h = label.height + big.height + 20;
    final r = RRect.fromRectAndRadius(Rect.fromCenter(center: at, width: w, height: h), const Radius.circular(14));
    canvas.drawRRect(r.shift(const Offset(0, 2)), Paint()..color = Colors.black26);
    canvas.drawRRect(r, Paint()..color = Colors.white);
    label.paint(canvas, Offset(at.dx - label.width / 2, r.top + 10));
    big.paint(canvas, Offset(at.dx - big.width / 2, r.top + 10 + label.height));
  }

  TextPainter _text(String s, TextStyle style) => TextPainter(
    text: TextSpan(text: s, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  @override
  bool shouldRepaint(MeasurePainter old) => old.c != c || old.still != still || old.unit != unit;
}

/// Undo · + · m/ft row that replaces the gallery / shutter / pages row on the Measure tab.
class MeasureControls extends StatefulWidget {
  const MeasureControls({super.key, required this.c, required this.onAdd, this.onSave});
  final MeasureController c;
  final VoidCallback onAdd;

  /// Saves a closed shape as a card. Its button floats above the bottom bar once there's an area.
  final VoidCallback? onSave;

  @override
  State<MeasureControls> createState() => _MeasureControlsState();
}

class _MeasureControlsState extends State<MeasureControls> {
  final _link = LayerLink();
  final _portal = OverlayPortalController()..show(); // the button lives in the overlay: the bar has no room

  // ponytail: tied to the bottom bar in scanner_screen (18 gap + 27 tabs + 20 gap above this row) + 12 pt air.
  static const _lift = 77.0;

  MeasureController get c => widget.c;

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _portal,
    overlayChildBuilder: (_) => Align(
      alignment: Alignment.topLeft,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: Alignment.topCenter,
        followerAnchor: Alignment.bottomCenter,
        offset: const Offset(0, -_lift),
        child: ListenableBuilder(listenable: c, builder: (_, _) => _save()),
      ),
    ),
    child: CompositedTransformTarget(link: _link, child: _row()),
  );

  /// "Save measurement" pill (white, like the area card): pops in once a closed shape has an area.
  Widget _save() {
    final shown = widget.onSave != null && (c.canExport || c.exporting);
    final busy = c.exporting;
    return IgnorePointer(
      ignoring: !shown,
      child: ExcludeSemantics(
        excluding: !shown,
        child: AnimatedOpacity(
          opacity: shown ? 1 : 0,
          duration: fast,
          child: AnimatedScale(
            scale: shown ? 1 : .8,
            duration: fast,
            curve: Curves.easeOutBack,
            child: Pressable(
              label: busy ? 'Saving measurement' : 'Save measurement',
              onTap: busy ? null : widget.onSave,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: Shadows.raised,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 18,
                      child: busy
                          ? const CircularProgressIndicator(strokeWidth: 2, color: Tone.accent)
                          : const Icon(IconsaxPlusLinear.document_download, size: 18, color: Tone.accent),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      busy ? 'Saving…' : 'Save measurement',
                      style: TextStyles.subheadSemibold.copyWith(color: Tone.chrome),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row() => ListenableBuilder(
    listenable: c,
    builder: (context, _) {
      final canAdd = c.running && (c.closed || c.onSurface);
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            button: true,
            label: 'Undo',
            enabled: c.pointCount > 0,
            child: Material(
              color: Tone.surface,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: c.pointCount > 0 ? c.undo : null,
                child: SizedBox.square(
                  dimension: 48,
                  child: Icon(Icons.undo_rounded, color: c.pointCount > 0 ? Colors.white : Colors.white30),
                ),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: c.closed ? 'New measurement' : 'Add point',
            enabled: canAdd,
            child: GestureDetector(
              onTap: canAdd ? widget.onAdd : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: canAdd ? Colors.white : Colors.white30, shape: BoxShape.circle),
                child: const Icon(Icons.add_rounded, size: 36, color: Tone.chrome),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: Tone.surface, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final u in MeasureUnit.values)
                  Semantics(
                    button: true,
                    selected: c.unit == u,
                    label: u == MeasureUnit.m ? 'Meters' : 'Feet',
                    child: GestureDetector(
                      onTap: () => c.setUnit(u),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 38,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c.unit == u ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Text(
                          u.name,
                          style: TextStyle(
                            color: c.unit == u ? Tone.chrome : Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
