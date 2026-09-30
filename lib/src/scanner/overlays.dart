import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'ui.dart';

/// Maps normalized preview points into a box showing the preview with BoxFit.cover.
Offset Function(Offset) coverMapper(Size box, Size preview) {
  final s = math.max(box.width / preview.width, box.height / preview.height);
  final w = preview.width * s, h = preview.height * s;
  final ox = (box.width - w) / 2, oy = (box.height - h) / 2;
  return (n) => Offset(ox + n.dx * w, oy + n.dy * h);
}

/// Target frame for card / passport / QR modes: centered, [aspect] = width / height.
Rect frameRect(Size size, double aspect, {double widthFactor = .84}) {
  final w = math.min(size.width * widthFactor, size.height * .7 * aspect);
  return Rect.fromCenter(center: Offset(size.width / 2, size.height * .45), width: w, height: w / aspect);
}

/// Detected page quad (Figma 3.2), or the dashed guide (3.1) while searching.
/// [guideAspect] shapes the guide (portrait page 0.79, open book 1.4). [handles] = false draws outline only.
class QuadPainter extends CustomPainter {
  QuadPainter(this.quad, this.preview, {this.guideAspect, this.handles = true}) : super(repaint: quad);
  final ValueNotifier<List<Offset>?> quad;
  final Size preview;
  final double? guideAspect;
  final bool handles;

  @override
  void paint(Canvas canvas, Size size) {
    final q = quad.value;
    if (q == null) {
      if (guideAspect != null) _guide(canvas, size, guideAspect!);
      return;
    }
    final pts = q.map(coverMapper(size, preview)).toList();
    final path = Path()..addPolygon(pts, true);
    if (handles) canvas.drawPath(path, Paint()..color = Tone.accent.withValues(alpha: .22));
    canvas.drawPath(
      path,
      Paint()
        ..color = Tone.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );
    if (!handles) return;
    for (final p in pts) {
      canvas.drawCircle(p, 7, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        7,
        Paint()
          ..color = Tone.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  void _guide(Canvas canvas, Size size, double aspect) {
    final w = math.min(size.width * (aspect < 1 ? .66 : .9), size.height * .7 * aspect);
    final rect = Rect.fromCenter(center: Offset(size.width / 2, size.height * .47), width: w, height: w / aspect);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final metric in (Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)))).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 14) {
        canvas.drawPath(metric.extractPath(d, d + 8), paint);
      }
    }
  }

  @override
  bool shouldRepaint(QuadPainter old) => old.preview != preview || old.quad != quad || old.guideAspect != guideAspect;
}

/// Corner brackets around the target frame (Figma 7.1–7.3).
class BracketsPainter extends CustomPainter {
  BracketsPainter({required this.aspect, required this.color});
  final double aspect;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = frameRect(size, aspect, widthFactor: aspect == 1 ? .6 : .84);
    final len = math.min(28.0, r.shortestSide / 4);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (final (corner, dx, dy) in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomRight, -1.0, -1.0),
      (r.bottomLeft, 1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(corner.dx + dx * len, corner.dy)
          ..lineTo(corner.dx, corner.dy)
          ..lineTo(corner.dx, corner.dy + dy * len),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(BracketsPainter old) => old.color != color || old.aspect != aspect;
}

/// Rounded box around a detected region in normalized preview coordinates: the MRZ zone (7.2) or the
/// math problem (7.4).
class HighlightPainter extends CustomPainter {
  HighlightPainter(this.box, this.preview, {required this.color, this.fill}) : super(repaint: box);
  final ValueNotifier<Rect?> box;
  final Size preview;
  final Color color;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final b = box.value;
    if (b == null) return;
    final map = coverMapper(size, preview);
    final rrect = RRect.fromRectAndRadius(
      Rect.fromPoints(map(b.topLeft), map(b.bottomRight)).inflate(8),
      const Radius.circular(10),
    );
    canvas.drawRRect(rrect, Paint()..color = fill ?? color.withValues(alpha: .15));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(HighlightPainter old) => old.color != color || old.preview != preview || old.box != box;
}

/// Sweeping scan line with a glow trail, inside the square QR frame (Figma 7.3).
class ScanLinePainter extends CustomPainter {
  ScanLinePainter(this.t) : super(repaint: t);
  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final r = frameRect(size, 1, widthFactor: .6).deflate(12);
    final y = r.top + r.height * Curves.easeInOut.transform(t.value);
    final forward = t.status != AnimationStatus.reverse;
    final glow = Rect.fromLTRB(r.left, forward ? y - 40 : y, r.right, forward ? y : y + 40);
    canvas.drawRect(
      glow,
      Paint()
        ..shader = LinearGradient(
          begin: forward ? Alignment.topCenter : Alignment.bottomCenter,
          end: forward ? Alignment.bottomCenter : Alignment.topCenter,
          colors: [Tone.accent.withValues(alpha: 0), Tone.accent.withValues(alpha: .35)],
        ).createShader(glow),
    );
    canvas.drawLine(
      Offset(r.left, y),
      Offset(r.right, y),
      Paint()
        ..color = Tone.accent
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(ScanLinePainter old) => false;
}

class GridPainter extends CustomPainter {
  const GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      canvas.drawLine(Offset(size.width * i / 3, 0), Offset(size.width * i / 3, size.height), p);
      canvas.drawLine(Offset(0, size.height * i / 3), Offset(size.width, size.height * i / 3), p);
    }
  }

  @override
  bool shouldRepaint(GridPainter old) => false;
}

/// Shutter with a steady-progress ring (auto-capture countdown).
class ShutterPainter extends CustomPainter {
  ShutterPainter(this.progress, {required this.fill}) : super(repaint: progress);
  final ValueNotifier<double> progress;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(c, r, ring..color = Colors.white);
    if (progress.value > 0) {
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * progress.value, false,
          ring..color = Tone.success);
    }
    canvas.drawCircle(c, r - 7, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(ShutterPainter old) => old.fill != fill;
}
