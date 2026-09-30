import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine.dart';
import '../scanner/session.dart';
import '../scanner/ui.dart';
import 'counter.dart';

const _ink = Color(0xFF111318);
const _sub = Color(0xFF6B7280);

/// Figma 7.5: the photo with numbered markers, and a sheet with the count, −/+ stepper, kind chips,
/// Retake and Save Result. Tap a marker to remove it, tap empty space to add one.
/// Pops `true` after saving the result as a page into [session].
class CountScreen extends StatefulWidget {
  const CountScreen({super.key, required this.photo, required this.session});
  final String photo;
  final ScanSession session;

  @override
  State<CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  CountKind kind = CountKind.round;
  List<Offset> marks = [];
  int extra = 0; // stepper adjustments without a placed marker
  double radius = .03; // marker radius, fraction of image width
  (double, double)? sample;
  bool counting = true, saving = false;

  Uint8List? rgba;
  int w = 0, h = 0;

  int get total => marks.length + extra;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Decodes a ~640 px upright copy once; every recount reuses it.
  Future<void> _load() async {
    final small = '${widget.photo}.count.jpg';
    await DocScanner.process(path: widget.photo, outPath: small, maxSize: 640);
    final image = (await (await ui.instantiateImageCodec(await File(small).readAsBytes())).getNextFrame()).image;
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    File(small).delete().ignore();
    w = image.width;
    h = image.height;
    rgba = data!.buffer.asUint8List();
    image.dispose();
    await _count();
  }

  Future<void> _count() async {
    if (kind == CountKind.custom && sample == null) {
      setState(() {
        marks = [];
        extra = 0;
        counting = false;
      });
      return;
    }
    setState(() => counting = true);
    final found = await countInBackground(rgba!, w, h, kind, sample: sample);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      marks = [for (final c in found) Offset(c.x, c.y)];
      if (found.isNotEmpty) radius = found.first.r;
      extra = 0;
      counting = false;
    });
  }

  void _setKind(CountKind k) {
    if (k == kind) return;
    setState(() {
      kind = k;
      sample = null;
    });
    _count();
  }

  void _tap(Offset n) {
    if (counting) return;
    if (kind == CountKind.custom && sample == null) {
      sample = (n.dx, n.dy);
      _count();
      return;
    }
    HapticFeedback.selectionClick();
    final hit = marks.indexWhere((m) => (m - n).distance < radius * 1.2);
    setState(() => hit >= 0 ? marks.removeAt(hit) : marks.add(n));
  }

  /// Burns markers + count into a ~2000 px copy and adds it to the scan as a page.
  Future<void> _save() async {
    setState(() => saving = true);
    final dir = File(widget.photo).parent.path;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final base = '$dir/count_${stamp}_base.jpg', png = '$dir/count_$stamp.png', out = '$dir/count_$stamp.jpg';
    await DocScanner.process(path: widget.photo, outPath: base, maxSize: 2000);
    final image = (await (await ui.instantiateImageCodec(await File(base).readAsBytes())).getNextFrame()).image;
    final size = Size(image.width.toDouble(), image.height.toDouble());
    final rec = ui.PictureRecorder();
    final canvas = Canvas(rec)..drawImage(image, Offset.zero, Paint());
    _MarksPainter(marks, radius, Offset.zero & size, scale: size.width / 390).paint(canvas, size);
    _badge(canvas, '$total object${total == 1 ? '' : 's'}', size.width / 390);
    final rendered = await rec.endRecording().toImage(image.width, image.height);
    final bytes = await rendered.toByteData(format: ui.ImageByteFormat.png);
    await File(png).writeAsBytes(bytes!.buffer.asUint8List());
    await DocScanner.process(path: png, outPath: out); // PNG → JPEG
    File(base).delete().ignore();
    File(png).delete().ignore();
    widget.session.add(ScanPage(out, null, label: 'Count: $total')..filter = PageFilter.original);
    if (mounted) Navigator.of(context).pop(true);
  }

  void _badge(Canvas canvas, String text, double s) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.white, fontSize: 16 * s, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(12 * s, 12 * s, tp.width + 24 * s, tp.height + 12 * s), Radius.circular(10 * s));
    canvas.drawRRect(r, Paint()..color = Tone.success);
    tp.paint(canvas, Offset(24 * s, 18 * s));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Tone.chrome,
        body: Column(children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  ChipButton(icon: Icons.close_rounded, label: 'Close', onTap: () => Navigator.of(context).pop()),
                  const Expanded(
                    child: Text('Count Objects',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 40),
                ]),
              ),
            ),
          ),
          Expanded(child: _photo()),
          _sheet(),
        ]),
      ),
    );
  }

  Widget _photo() {
    if (rgba == null) return const Center(child: CircularProgressIndicator());
    return LayoutBuilder(builder: (context, box) {
      final aspect = w / h;
      final fit = box.maxWidth / box.maxHeight > aspect
          ? Size(box.maxHeight * aspect, box.maxHeight)
          : Size(box.maxWidth, box.maxWidth / aspect);
      final rect = Rect.fromCenter(center: box.biggest.center(Offset.zero), width: fit.width, height: fit.height);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) {
          if (rect.contains(d.localPosition)) {
            _tap(Offset((d.localPosition.dx - rect.left) / rect.width, (d.localPosition.dy - rect.top) / rect.height));
          }
        },
        child: Stack(children: [
          Positioned.fromRect(
            rect: rect,
            child: Image(
              image: ResizeImage(FileImage(File(widget.photo)), width: 1600, height: 1600, policy: ResizeImagePolicy.fit),
              fit: BoxFit.fill,
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _MarksPainter(marks, radius, rect))),
          if (counting) const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (kind == CountKind.custom && sample == null)
            const Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Center(child: StatusPill(icon: Icons.touch_app_outlined, text: 'Tap one object to count ones like it')),
            ),
        ]),
      );
    });
  }

  Widget _sheet() => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Objects detected', style: TextStyle(color: _sub, fontSize: 14)),
                    Text('$total',
                        style: const TextStyle(color: _ink, fontSize: 44, fontWeight: FontWeight.w800, height: 1.1)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFFF1F2F4), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    _step(Icons.remove_rounded, 'Remove one', total == 0 ? null : () {
                      setState(() => extra > 0 ? extra-- : marks.removeLast());
                    }),
                    const SizedBox(width: 6),
                    _step(Icons.add_rounded, 'Add one', () => setState(() => extra++)),
                  ]),
                ),
              ]),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _chip(CountKind.round, Icons.radio_button_checked_rounded, 'Round objects'),
                  const SizedBox(width: 8),
                  _chip(CountKind.boxes, Icons.view_in_ar_outlined, 'Boxes'),
                  const SizedBox(width: 8),
                  _chip(CountKind.custom, Icons.auto_awesome_outlined, 'Custom'),
                ]),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Retake'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Tone.accent,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    onPressed: counting || saving || rgba == null ? null : _save,
                    icon: saving
                        ? const SizedBox.square(
                            dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Save Result'),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      );

  Widget _step(IconData icon, String label, VoidCallback? onTap) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox.square(dimension: 44, child: Icon(icon, color: onTap == null ? Colors.black26 : _ink)),
          ),
        ),
      );

  Widget _chip(CountKind k, IconData icon, String label) {
    final on = kind == k;
    return GestureDetector(
      onTap: () => _setKind(k),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: on ? Tone.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: on ? Tone.accent : const Color(0xFFD1D5DB)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: on ? Colors.white : _ink),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: on ? Colors.white : _ink, fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

/// Numbered green markers (Figma 7.5). [scale] enlarges them when burning into a full-size image.
class _MarksPainter extends CustomPainter {
  _MarksPainter(this.marks, this.radius, this.image, {this.scale = 1});
  final List<Offset> marks;
  final double radius;
  final Rect image;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final r = 11.0 * scale;
    for (final (i, m) in marks.indexed) {
      final c = Offset(image.left + m.dx * image.width, image.top + m.dy * image.height);
      canvas.drawCircle(c, r + 2 * scale, Paint()..color = Colors.white);
      canvas.drawCircle(c, r, Paint()..color = Tone.success);
      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(color: Colors.white, fontSize: (i >= 99 ? 8 : 10) * scale, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, c - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_MarksPainter old) => true;
}
