import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine.dart';
import '../scanner/card_render.dart';
import '../strings.dart';
import '../scanner/session.dart';
import '../scanner/ui.dart';
import 'counter.dart';

const _ink = Color(0xFF111318);
const _sub = Color(0xFF6B7280);

/// Figma 7.5: the photo with numbered markers, and a sheet with the count, −/+ stepper, kind chips,
/// Retake and Save Result. Tap a marker to remove it, tap empty space to add one.
/// Pops the result as a [ScanPage] ("Count: N") on Save Result, or null on close.
class CountScreen extends StatefulWidget {
  const CountScreen({super.key, required this.photo});
  final String photo;

  @override
  State<CountScreen> createState() => _CountScreenState();
}

class _CountScreenState extends State<CountScreen> {
  CountKind kind = CountKind.round;
  List<Offset> marks = [];
  List<Offset> found = []; // the automatic count's markers, to tell hand edits apart on the saved card
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
        found = [];
        extra = 0;
        counting = false;
      });
      return;
    }
    setState(() => counting = true);
    final counted = await countInBackground(rgba!, w, h, kind, sample: sample);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() {
      found = [for (final c in counted) Offset(c.x, c.y)];
      marks = List.of(found);
      if (counted.isNotEmpty) radius = counted.first.r;
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

  /// The photo with its markers burned in, on an A4 card with the count, kind and hand edits underneath.
  /// Pops it as a page ("Count: N"); a failure leaves the screen as it was, with a message.
  Future<void> _save() async {
    if (saving) return;
    setState(() => saving = true);
    final l = context.l10n;
    final base = '${widget.photo}.card.jpg';
    try {
      await DocScanner.process(path: widget.photo, outPath: base, maxSize: 1600); // upright, card-sized
      final photo = await decodeForCard(base);
      ui.Image? marked;
      try {
        final size = Size(photo.width.toDouble(), photo.height.toDouble());
        final rec = ui.PictureRecorder();
        final canvas = Canvas(rec)..drawImage(photo, Offset.zero, Paint());
        _MarksPainter(marks, radius, Offset.zero & size, scale: size.width / 390).paint(canvas, size);
        final picture = rec.endRecording();
        marked = await picture.toImage(photo.width, photo.height);
        picture.dispose();
        if (!mounted) return;
        final png = await renderCard(
          context,
          PhotoCard(
            title: l.objectCount,
            photo: marked,
            details: _details(l),
            note: l.countedWithDocScan,
            time: DateTime.now(),
          ),
        );
        // Closed (back gesture, Close) while rendering: don't pop the scanner underneath.
        if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) return File(png).delete().ignore();
        Navigator.of(context).pop(
          ScanPage(png, null, label: l.countPageLabel(total))
            ..filter = PageFilter.original
            ..kind = ResultKind.count,
        );
      } finally {
        photo.dispose();
        marked?.dispose();
      }
    } catch (_) {
      if (mounted) showToast(context, l.countSaveFailed);
    } finally {
      File(base).delete().ignore();
      if (mounted) setState(() => saving = false);
    }
  }

  /// "23 objects", kind, and what was changed by hand vs the automatic count.
  Widget _details(ScannerLocalizations l) {
    const p = Palette.light;
    final added = marks.where((m) => !found.contains(m)).length + extra;
    final removed = found.where((m) => !marks.contains(m)).length;
    final edits = [if (added > 0) l.countAdded(added), if (removed > 0) l.countRemoved(removed)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: '$total',
            style: TextStyles.title3.copyWith(
              fontSize: 30,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: p.textPrimary,
            ),
            children: [
              TextSpan(
                text: '  ${l.objectsUnit(total)}',
                style: TextStyles.headline.copyWith(color: p.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        CardFact(l.countKind, switch (kind) {
          CountKind.round => l.roundObjects,
          CountKind.boxes => l.boxes,
          CountKind.custom => l.custom,
        }, note: kind == CountKind.custom ? l.matchedToSample : null),
        CardFact(l.countAutomatic, '${found.length}'),
        CardFact(l.countByHand, edits.isEmpty ? l.noChanges : edits.join(' · ')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Tone.chrome,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      ChipButton(
                        icon: Icons.close_rounded,
                        label: context.l10n.close,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          context.l10n.titleCountObjects,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(child: _photo()),
            _sheet(),
          ],
        ),
      ),
    );
  }

  Widget _photo() {
    if (rgba == null) return const Center(child: CircularProgressIndicator());
    return LayoutBuilder(
      builder: (context, box) {
        final aspect = w / h;
        final fit = box.maxWidth / box.maxHeight > aspect
            ? Size(box.maxHeight * aspect, box.maxHeight)
            : Size(box.maxWidth, box.maxWidth / aspect);
        final rect = Rect.fromCenter(center: box.biggest.center(Offset.zero), width: fit.width, height: fit.height);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            if (rect.contains(d.localPosition)) {
              _tap(
                Offset((d.localPosition.dx - rect.left) / rect.width, (d.localPosition.dy - rect.top) / rect.height),
              );
            }
          },
          child: Stack(
            children: [
              Positioned.fromRect(
                rect: rect,
                child: Image(
                  image: ResizeImage(
                    FileImage(File(widget.photo)),
                    width: 1600,
                    height: 1600,
                    policy: ResizeImagePolicy.fit,
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              Positioned.fill(child: CustomPaint(painter: _MarksPainter(marks, radius, rect))),
              if (counting) const Center(child: CircularProgressIndicator(color: Colors.white)),
              if (kind == CountKind.custom && sample == null)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Center(
                    child: StatusPill(icon: Icons.touch_app_outlined, text: context.l10n.tapOneObject),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.objectsDetected, style: const TextStyle(color: _sub, fontSize: 14)),
                      Text(
                        '$total',
                        style: const TextStyle(color: _ink, fontSize: 44, fontWeight: FontWeight.w800, height: 1.1),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: const Color(0xFFF1F2F4), borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      _step(
                        Icons.remove_rounded,
                        context.l10n.removeOne,
                        total == 0
                            ? null
                            : () {
                                setState(() => extra > 0 ? extra-- : marks.removeLast());
                              },
                      ),
                      const SizedBox(width: 6),
                      _step(Icons.add_rounded, context.l10n.addOne, () => setState(() => extra++)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip(CountKind.round, Icons.radio_button_checked_rounded, context.l10n.roundObjects),
                  const SizedBox(width: 8),
                  _chip(CountKind.boxes, Icons.view_in_ar_outlined, context.l10n.boxes),
                  const SizedBox(width: 8),
                  _chip(CountKind.custom, Icons.auto_awesome_outlined, context.l10n.custom),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
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
                    label: Text(context.l10n.retake),
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
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: Text(context.l10n.saveResult),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: on ? Colors.white : _ink),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: on ? Colors.white : _ink, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
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
