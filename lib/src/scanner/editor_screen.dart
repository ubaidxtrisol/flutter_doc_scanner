import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../engine.dart';
import '../strings.dart';
import 'crop_editor.dart';
import 'session.dart';
import 'ui.dart';

/// English filter names. Show [filterName] in UI instead (it follows the app's language).
const filterNames = {
  PageFilter.original: 'Original',
  PageFilter.magic: 'Magic',
  PageFilter.bw: 'B & W',
  PageFilter.gray: 'Gray',
  PageFilter.noShadow: 'No Shadow',
  PageFilter.color: 'Color',
};

/// [f]'s name in the app's language, e.g. "Magic".
String filterName(BuildContext context, PageFilter f) {
  final l = context.l10n;
  return switch (f) {
    PageFilter.original => l.filterOriginal,
    PageFilter.magic => l.filterMagic,
    PageFilter.bw => l.filterBw,
    PageFilter.gray => l.filterGray,
    PageFilter.noShadow => l.filterNoShadow,
    PageFilter.color => l.filterColor,
  };
}

/// Figma 3.3 Adjust Crop: drag corners / edges (loupe), rotate, Auto / Perspective preview / Full page, Retake.
/// Next saves the crop and continues to [EnhanceScreen] for the same page.
class CropScreen extends StatefulWidget {
  const CropScreen({super.key, required this.session, required this.index});
  final ScanSession session;
  final int index;

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  late final page = widget.session.pages[widget.index];
  late List<Offset> draft = page.corners ?? fullPage;
  late int rotation = page.rotation;
  final area = GlobalKey();
  Offset? loupe;

  /// Straightened render of [draft] while "Perspective" is on.
  String? straight;
  bool straightening = false;

  bool _same(List<Offset>? a, List<Offset> b) =>
      a != null && [for (var i = 0; i < 4; i++) (a[i] - b[i]).distance < 1e-3].every((x) => x);

  void _set(List<Offset> corners) => setState(() {
    draft = corners;
    straight = null;
  });

  Future<void> _perspective() async {
    if (straight != null) return setState(() => straight = null);
    setState(() => straightening = true);
    final out = '${(await getTemporaryDirectory()).path}/straight_${DateTime.now().microsecondsSinceEpoch}.jpg';
    try {
      await DocScanner.process(path: page.original, outPath: out, corners: draft, rotation: rotation, maxSize: 1200);
      if (mounted) setState(() => straight = out);
    } on PlatformException {
      // Preview only; the crop itself is unaffected.
    } finally {
      if (mounted) setState(() => straightening = false);
    }
  }

  void _next() {
    HapticFeedback.lightImpact();
    page
      ..corners = draft
      ..rotation = rotation;
    widget.session.update(page);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EnhanceScreen(session: widget.session, initialIndex: widget.index),
      ),
    );
  }

  void _retake() {
    widget.session.retakeIndex = widget.index;
    Navigator.of(context).popUntil(ModalRoute.withName('scanner'));
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final auto = page.detected != null && _same(page.detected, draft);
    final full = _same(fullPage, draft);
    final l = context.l10n;
    Widget tool(IconData icon, String label, VoidCallback? onTap, {bool on = false}) => SizedBox(
      width: 72,
      child: Column(
        children: [
          SquareButton(icon: icon, label: label, size: 48, selected: on, onTap: onTap),
          const SizedBox(height: 6),
          // The label is part of the target too.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: ExcludeSemantics(
              child: AnimatedStyle(
                style: on
                    ? TextStyles.caption1Medium.copyWith(color: c.brand)
                    : TextStyles.caption1.copyWith(color: c.textSecondary),
                child: Text(label, maxLines: 1, overflow: TextOverflow.visible, softWrap: false),
              ),
            ),
          ),
        ],
      ),
    );
    return LightScreen(
      title: l.adjustCrop,
      right: NavText(
        l.reset,
        onTap: () {
          setState(() => rotation = 0);
          _set(page.detected ?? fullPage);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          children: [
            Flexible(
              child: Padding(
                // The editor pads the photo by 11 so edge handles stay hittable; the photo itself sits 20 from the edge.
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: Stack(
                  key: area,
                  children: [
                    RotatedBox(
                      quarterTurns: rotation ~/ 90,
                      child: CropEditor(
                        image: ResizeImage(
                          FileImage(File(page.original)),
                          width: 1600,
                          height: 1600,
                          policy: ResizeImagePolicy.fit,
                        ),
                        corners: draft,
                        padding: 11,
                        radius: 24,
                        shrinkWrap: true,
                        onChanged: _set,
                        onDrag: (g) => setState(() => loupe = g),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: straight == null
                              ? const SizedBox()
                              : Container(
                                  key: ValueKey(straight),
                                  margin: const EdgeInsets.all(11),
                                  decoration: squircleBox(24, color: c.bgFill),
                                  padding: const EdgeInsets.all(16),
                                  child: Image.file(File(straight!), fit: BoxFit.contain),
                                ),
                        ),
                      ),
                    ),
                    if (loupe != null) _loupe(loupe!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  tool(IconsaxPlusLinear.rotate_left_1, l.rotate, () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      rotation = (rotation + 270) % 360;
                      straight = null;
                    });
                  }),
                  tool(
                    IconsaxPlusLinear.magicpen,
                    l.cropAuto,
                    page.detected == null ? null : () => _set(page.detected!),
                    on: auto,
                  ),
                  tool(
                    IconsaxPlusLinear.maximize_4,
                    l.cropPerspective,
                    straightening ? null : _perspective,
                    on: straight != null,
                  ),
                  tool(IconsaxPlusLinear.crop, l.cropFullPage, () => _set(fullPage), on: full),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: Row(
        children: [
          Expanded(
            child: ScanButton(l.retake, icon: IconsaxPlusLinear.camera, kind: ButtonKind.secondary, onPressed: _retake),
          ),
          const SizedBox(width: 12),
          Expanded(child: ScanButton(l.next, onPressed: _next)),
        ],
      ),
    );
  }

  /// Figma loupe: 96 pt, 3 pt white ring, accent crosshair, pinned to the top corner away from the finger.
  Widget _loupe(Offset global) {
    final box = area.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox();
    const size = 96.0;
    final p = box.globalToLocal(global);
    final left = p.dx < box.size.width / 2 ? box.size.width - size - 16 : 16.0;
    final center = Offset(left + size / 2, 12 + size / 2);
    return Positioned(
      left: left,
      top: 12,
      child: IgnorePointer(
        child: RawMagnifier(
          size: const Size.square(size),
          magnificationScale: 2.2,
          focalPointOffset: p - center,
          decoration: const MagnifierDecoration(
            shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
            shadows: [BoxShadow(color: Color(0x59000000), offset: Offset(0, 8), blurRadius: 20)],
          ),
          child: const Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 1.5, height: 20, child: ColoredBox(color: Tone.accent)),
              SizedBox(width: 20, height: 1.5, child: ColoredBox(color: Tone.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Figma 3.4 Enhance: swipe pages, rotate, filters with live thumbnails, brightness / contrast, Apply to all.
class EnhanceScreen extends StatefulWidget {
  const EnhanceScreen({super.key, required this.session, required this.initialIndex});
  final ScanSession session;
  final int initialIndex;

  @override
  State<EnhanceScreen> createState() => _EnhanceScreenState();
}

class _EnhanceScreenState extends State<EnhanceScreen> {
  late final pager = PageController(initialPage: widget.initialIndex);
  late int index = widget.initialIndex;
  final thumbs = <PageFilter, String>{};

  /// Slider values while dragging, and the values the current preview was rendered with. The difference is shown
  /// instantly with a colour matrix until the native render catches up.
  late double brightness = page.brightness, contrast = page.contrast;
  late double shownBrightness = page.brightness, shownContrast = page.contrast;

  ScanSession get session => widget.session;
  ScanPage get page => session.pages[index];

  @override
  void initState() {
    super.initState();
    _loadThumbs();
  }

  @override
  void dispose() {
    pager.dispose();
    super.dispose();
  }

  Future<void> _render() async {
    final p = page;
    await session.update(p);
    if (mounted && p == page) {
      setState(() {
        shownBrightness = p.brightness;
        shownContrast = p.contrast;
      });
    }
  }

  Future<void> _loadThumbs() async {
    final p = page;
    final key = Object.hash(p.original, p.rotation, Object.hashAll(p.corners ?? const []));
    final tmp = (await getTemporaryDirectory()).path;
    await Future.wait([
      for (final f in PageFilter.values)
        () async {
          final out = '$tmp/thumb_${key}_${f.name}.jpg';
          try {
            if (!File(out).existsSync()) {
              await DocScanner.process(
                path: p.original,
                outPath: out,
                corners: p.corners,
                rotation: p.rotation,
                filter: f,
                maxSize: 300,
              );
            }
            if (mounted && p == page) setState(() => thumbs[f] = out);
          } on PlatformException {
            // Leave the tile blank; the filter itself still works.
          }
        }(),
    ]);
  }

  void _select(int i) {
    setState(() {
      index = i;
      thumbs.clear();
      brightness = shownBrightness = page.brightness;
      contrast = shownContrast = page.contrast;
    });
    _loadThumbs();
  }

  void _applyToAll() {
    HapticFeedback.lightImpact();
    for (final p in session.pages) {
      if (p == page) continue;
      p
        ..filter = page.filter
        ..brightness = page.brightness
        ..contrast = page.contrast;
      session.update(p);
    }
    showToast(context, context.l10n.filterAppliedToAll(filterName(context, page.filter), session.pages.length));
  }

  /// Maps the rendered preview (b0, c0) to the live slider values (b1, c1), same curve as the native filter.
  ColorFilter _live() {
    final k = (1 + contrast) / (1 + shownContrast).clamp(.05, 2);
    final t = 128 + 100 * brightness - (128 + 100 * shownBrightness) * k;
    return ColorFilter.matrix([k, 0, 0, 0, t, 0, k, 0, 0, t, 0, 0, k, 0, t, 0, 0, 0, 1, 0]);
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final l = context.l10n;
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        if (session.pages.isEmpty) return Scaffold(backgroundColor: c.bgBase);
        index = index.clamp(0, session.pages.length - 1);
        return LightScreen(
          title: l.enhance,
          right: NavCircle(
            icon: IconsaxPlusLinear.rotate_right_1,
            label: l.rotate,
            onTap: () {
              HapticFeedback.selectionClick();
              page.rotation = (page.rotation + 90) % 360;
              thumbs.clear();
              _render();
              _loadThumbs();
            },
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              children: [
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: squircleBox(24, color: c.bgFill),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: pager,
                              itemCount: session.pages.length,
                              onPageChanged: _select,
                              itemBuilder: (_, i) => _preview(session.pages[i], live: i == index),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 10,
                              child: Center(child: ImageChip(l.pageOf(index + 1, session.pages.length))),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _filters(c),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _slider(c, IconsaxPlusLinear.sun_1, l.brightness, brightness, (v) => brightness = v, (v) {
                        page.brightness = v;
                        _render();
                      }),
                      const SizedBox(height: 14),
                      _slider(c, IconsaxPlusLinear.colorfilter, l.contrast, contrast, (v) => contrast = v, (v) {
                        page.contrast = v;
                        _render();
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: Row(
            children: [
              Expanded(
                child: ScanButton(
                  l.applyToAll,
                  kind: ButtonKind.tonal,
                  onPressed: session.pages.length > 1 ? _applyToAll : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: ScanButton(l.next, onPressed: () => Navigator.of(context).pop())),
            ],
          ),
        );
      },
    );
  }

  Widget _preview(ScanPage p, {required bool live}) {
    final path = p.preview;
    Widget image = path == null
        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
        : Image.file(File(path), fit: BoxFit.contain, gaplessPlayback: true);
    if (live && path != null && (brightness != shownBrightness || contrast != shownContrast)) {
      image = ColorFiltered(colorFilter: _live(), child: image);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
      child: InteractiveViewer(
        maxScale: 5,
        child: Center(
          child: path == null
              ? image
              : DecoratedBox(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), boxShadow: Shadows.raised),
                  child: ClipRRect(borderRadius: BorderRadius.circular(4), child: image),
                ),
        ),
      ),
    );
  }

  Widget _filters(Palette c) => SizedBox(
    height: 104,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: PageFilter.values.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (_, i) {
        final f = PageFilter.values[i];
        final on = page.filter == f;
        return Semantics(
          button: true,
          selected: on,
          label: filterName(context, f),
          child: GestureDetector(
            onTap: () {
              if (on) return;
              HapticFeedback.selectionClick();
              setState(() => page.filter = f);
              _render();
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: fast,
                  width: 66,
                  height: 82,
                  decoration: squircleBox(
                    14,
                    color: c.bgCard,
                    side: on ? BorderSide(color: c.brand, width: 2.5) : BorderSide(color: c.borderSubtle),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: SizedBox(
                          width: 48,
                          height: 64,
                          child: AnimatedSwitcher(
                            duration: fast,
                            child: thumbs[f] == null
                                ? ColoredBox(key: const ValueKey(0), color: c.bgFill)
                                : Image.file(File(thumbs[f]!), key: ValueKey(thumbs[f]), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      if (f == PageFilter.magic)
                        Positioned(
                          left: 43.5 - (on ? 2.5 : 1),
                          top: 3.5 - (on ? 2.5 : 1),
                          child: Icon(IconsaxPlusBold.magic_star, size: 14, color: c.brand),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedStyle(
                  style: on
                      ? TextStyles.caption1Medium.copyWith(color: c.brand)
                      : TextStyles.caption1.copyWith(color: c.textSecondary),
                  child: Text(filterName(context, f)),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _slider(
    Palette c,
    IconData icon,
    String label,
    double value,
    ValueChanged<double> changed,
    ValueChanged<double> done,
  ) => Row(
    children: [
      Icon(icon, size: 20, color: c.textSecondary),
      const SizedBox(width: 12),
      Expanded(
        child: SizedBox(
          height: 24,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: c.brand,
              inactiveTrackColor: c.bgFillStrong,
              thumbColor: Colors.white,
              overlayShape: SliderComponentShape.noOverlay,
              thumbShape: const _Thumb(),
              trackShape: const RoundedRectSliderTrackShape(),
              padding: EdgeInsets.zero,
            ),
            child: Slider(
              value: value,
              min: -1,
              max: 1,
              semanticFormatterCallback: (v) => context.l10n.sliderValue(label, ((v + 1) * 50).round()),
              onChanged: (v) => setState(() => changed(v)),
              onChangeEnd: done,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      SizedBox(
        width: 28,
        child: Text(
          '${((value + 1) * 50).round()}',
          textAlign: TextAlign.right,
          style: TextStyles.footnoteSemibold.copyWith(color: c.textPrimary),
        ),
      ),
    ],
  );
}

/// Figma slider knob: 24 pt white circle with Shadow/Raised.
class _Thumb extends SliderComponentShape {
  const _Thumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size.square(24);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final r = 12 * (1 + .1 * activationAnimation.value);
    for (final s in Shadows.raised) {
      canvas.drawCircle(
        center + s.offset,
        r + s.spreadRadius,
        Paint()
          ..color = s.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma),
      );
    }
    canvas.drawCircle(center, r, Paint()..color = Colors.white);
  }
}
