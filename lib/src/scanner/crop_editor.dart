import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Full-image corners, TL, TR, BR, BL.
const fullPage = [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(0, 1)];

/// True if [q] (TL, TR, BR, BL) is a proper convex quad, which keeps the perspective crop well-defined.
bool isConvexQuad(List<Offset> q) {
  var sign = 0.0;
  for (var i = 0; i < 4; i++) {
    final a = q[i], b = q[(i + 1) % 4], c = q[(i + 2) % 4];
    final cross = (b - a).dx * (c - b).dy - (b - a).dy * (c - b).dx;
    if (cross.abs() < 1e-4) return false;
    if (sign == 0) {
      sign = cross.sign;
    } else if (cross.sign != sign) {
      return false;
    }
  }
  return true;
}

/// Drag corners, or edge midpoints to move a whole side. [corners] is controlled by the parent.
/// [onDrag] reports the global position of the handle being dragged (null on release), for a loupe.
class CropEditor extends StatefulWidget {
  const CropEditor({
    super.key,
    required this.image,
    required this.corners,
    required this.onChanged,
    this.onDrag,
    this.padding = 24,
    this.radius = 0,
    this.shrinkWrap = false,
  });

  /// Size to the fitted photo (+ [padding]) instead of filling the space, so controls can sit right under it.
  final bool shrinkWrap;

  /// Space around the image, so handles on its edges stay inside this widget (and hittable).
  final double padding;

  /// Corner radius of the photo (Figma 3.3: 24).
  final double radius;
  final ImageProvider image;
  final List<Offset> corners;
  final ValueChanged<List<Offset>> onChanged;
  final ValueChanged<Offset?>? onDrag;

  @override
  State<CropEditor> createState() => _CropEditorState();
}

class _CropEditorState extends State<CropEditor> {
  ImageStream? _stream;
  late final _listener = ImageStreamListener((info, _) {
    if (mounted) setState(() => aspect = info.image.width / info.image.height);
  });
  double? aspect;
  int? active; // 0-3 corner, 4-7 edge starting at that corner
  Offset? last;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stream?.removeListener(_listener);
    _stream = widget.image.resolve(createLocalImageConfiguration(context))..addListener(_listener);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener);
    super.dispose();
  }

  Rect _imageRect(Size box) {
    final a = aspect!;
    final w = box.width - 2 * widget.padding, h = box.height - 2 * widget.padding;
    final fit = w / h > a ? Size(h * a, h) : Size(w, w / a);
    return Rect.fromCenter(center: box.center(Offset.zero), width: fit.width, height: fit.height);
  }

  List<Offset> _handles(Rect r) {
    final c = [for (final p in widget.corners) Offset(r.left + p.dx * r.width, r.top + p.dy * r.height)];
    return [...c, for (var i = 0; i < 4; i++) (c[i] + c[(i + 1) % 4]) / 2];
  }

  @override
  Widget build(BuildContext context) {
    if (aspect == null) return const Center(child: CircularProgressIndicator());
    return LayoutBuilder(
      builder: (context, box) {
        var rect = _imageRect(box.biggest);
        if (widget.shrinkWrap) rect = Offset(widget.padding, widget.padding) & rect.size;
        final editor = GestureDetector(
          onPanStart: (d) {
            final handles = _handles(rect);
            var best = double.infinity;
            int? pick;
            for (var i = 0; i < handles.length; i++) {
              // Corners win ties: they matter more than edges.
              final dist = (handles[i] - d.localPosition).distance - (i < 4 ? 8 : 0);
              if (dist < best && dist < 44) (best, pick) = (dist, i);
            }
            setState(() {
              active = pick;
              last = d.localPosition;
            });
            if (pick != null) _report(handles[pick]);
          },
          onPanUpdate: (d) {
            final a = active;
            if (a == null) return;
            final delta = d.localPosition - last!;
            last = d.localPosition;
            final n = Offset(delta.dx / rect.width, delta.dy / rect.height);
            final moved = [...widget.corners];
            for (final i in a < 4 ? [a] : [a - 4, (a - 3) % 4]) {
              moved[i] = Offset((moved[i].dx + n.dx).clamp(0, 1), (moved[i].dy + n.dy).clamp(0, 1));
            }
            if (!isConvexQuad(moved)) return;
            widget.onChanged(moved);
            final c = [for (final p in moved) Offset(rect.left + p.dx * rect.width, rect.top + p.dy * rect.height)];
            _report(a < 4 ? c[a] : (c[a - 4] + c[(a - 3) % 4]) / 2);
          },
          onPanEnd: (_) => _release(),
          onPanCancel: _release,
          child: Stack(
            children: [
              Positioned.fromRect(
                rect: rect,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.radius),
                  child: Image(image: widget.image, fit: BoxFit.fill, gaplessPlayback: true),
                ),
              ),
              Positioned.fill(child: CustomPaint(painter: _CropPainter(rect, _handles(rect), active, widget.radius))),
            ],
          ),
        );
        return widget.shrinkWrap ? SizedBox.fromSize(size: rect.inflate(widget.padding).size, child: editor) : editor;
      },
    );
  }

  void _report(Offset local) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null) widget.onDrag?.call(box.localToGlobal(local));
  }

  void _release() {
    setState(() => active = null);
    widget.onDrag?.call(null);
  }
}

/// Figma 3.3: light veil outside the crop, 2 pt accent frame, round corner handles, pill edge handles.
class _CropPainter extends CustomPainter {
  _CropPainter(this.image, this.handles, this.active, this.radius);
  final Rect image;
  final List<Offset> handles;
  final int? active;
  final double radius;

  static const _frame = Color(0xFF4F83FF), _brand = Color(0xFF2F6BFF), _veil = Color(0x73D9D9D9);

  @override
  void paint(Canvas canvas, Size size) {
    final quad = Path()..addPolygon(handles.sublist(0, 4), true);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRRect(RRect.fromRectAndRadius(image, Radius.circular(radius))),
        quad,
      ),
      Paint()..color = _veil,
    );
    canvas.drawPath(
      quad,
      Paint()
        ..color = _frame
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final ring = Paint()..color = _brand;
    final fill = Paint()..color = Colors.white;
    for (var i = 0; i < 4; i++) {
      final s = i == active ? 1.3 : 1.0;
      canvas.drawCircle(handles[i], 11 * s, ring);
      canvas.drawCircle(handles[i], 6 * s, fill);
    }
    for (var i = 4; i < 8; i++) {
      final a = handles[i - 4], b = handles[(i - 3) % 4];
      final s = i == active ? 1.3 : 1.0;
      canvas
        ..save()
        ..translate(handles[i].dx, handles[i].dy)
        ..rotate(math.atan2(b.dy - a.dy, b.dx - a.dx));
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 28 * s, height: 8 * s),
        const Radius.circular(4),
      );
      canvas
        ..drawRRect(r, ring)
        ..drawRRect(r.deflate(2), fill)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_CropPainter old) => true;
}
