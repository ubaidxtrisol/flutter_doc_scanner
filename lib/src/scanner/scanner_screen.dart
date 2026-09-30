import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../engine.dart';
import '../count/count_screen.dart';
import '../math/cloud.dart';
import '../math/solver.dart';
import '../measure/measure.dart';
import 'book.dart';
import 'mrz.dart';
import 'overlays.dart';
import 'pages_screen.dart';
import 'qr_payload.dart';
import 'result_sheets.dart';
import 'session.dart';
import 'ui.dart';

/// The scanner's modes, in tab-bar order. Pass one to [Scanner.open] to start there.
enum ScannerTab {
  document('Document', 'Document', ScanMode.document),
  idCard('ID Card', 'ID Card', ScanMode.idCard),
  passport('Passport', 'Passport', ScanMode.passport),
  book('Book', 'Book', ScanMode.book),
  qr('QR', 'Scan QR', ScanMode.qr),
  math('Math', 'Math', ScanMode.math),
  count('Count', 'Count Objects', ScanMode.count),
  measure('Measure', 'Measure', null);

  const ScannerTab(this.label, this.title, this.mode);
  final String label;
  final String title;
  final ScanMode? mode;

  /// Tabs that track a page / card / spread quad.
  bool get quad => this == document || this == book || this == idCard;
}

const _cardAspect = 85.6 / 54; // ISO/IEC 7810 ID-1
const _passportAspect = 125 / 88; // ID-3 data page

/// Camera screen: Figma 3.1 / 3.2 (document), 7.1 (ID card), 7.2 (passport), 7.3 (QR), 7.4 (math),
/// 7.5 (count), 7.6 (measure, an AR session instead of the scanner camera), plus Book.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, this.initialTab = ScannerTab.document});

  /// Tab the scanner opens on.
  final ScannerTab initialTab;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  final session = ScanSession();
  final tracker = QuadTracker();
  final quad = ValueNotifier<List<Offset>?>(null);
  final progress = ValueNotifier<double>(0);
  final mrzBox = ValueNotifier<Rect?>(null);
  final clock = Stopwatch()..start();
  final tabKeys = {for (final t in ScannerTab.values) t: GlobalKey()};
  final measure = MeasureController();
  Size viewSize = Size.zero;
  late final flash = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  // Runs only while the QR tab is scanning: a ticking controller forces a frame every vsync.
  late final scanLine = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  ScannerPreview? preview;
  String? error;
  StreamSubscription<Detection>? detections;
  QuadState state = QuadState.searching;
  bool armed = true, torch = false, grid = false, auto = true;
  bool starting = false, busy = false, away = false, sheetOpen = false;
  late ScannerTab tab = widget.initialTab;

  // ID card: front then back, both in one group so they export onto one sheet.
  bool idBack = false;
  String idGroup = _newGroup();
  static String _newGroup() => 'id-${DateTime.now().microsecondsSinceEpoch}';

  // Passport: the same valid MRZ must be read twice in a row before we trust it.
  String? mrzKey;
  int mrzHits = 0;

  // Math: the same locally-solvable problem read twice in a row opens the answer by itself.
  final mathBox = ValueNotifier<Rect?>(null);
  String? mathKey;
  int mathHits = 0;
  bool mathLocal = false;

  // QR / math: don't reopen the sheet for what the user just dismissed.
  String? lastMath;
  DateTime lastMathClosed = DateTime(0);

  // QR: don't reopen the sheet for the code the user just dismissed.
  String? lastCode;
  DateTime lastCodeClosed = DateTime(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = tabKeys[tab]!.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, alignment: .5);
      if (tab == ScannerTab.measure) _start(); // AR renders at the viewport's aspect, known after layout
    });
    if (tab != ScannerTab.measure) _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    detections?.cancel();
    DocScanner.stop();
    if (measure.running) ArMeasure.stop();
    measure.dispose();
    flash.dispose();
    scanLine.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (away) return;
    if (s == AppLifecycleState.resumed && preview == null && !measure.running) _start();
    if (s == AppLifecycleState.paused) _stop();
  }

  Future<void> _start() async {
    if (starting) return;
    starting = true;
    final ar = tab == ScannerTab.measure;
    try {
      if (ar) {
        await measure.start(viewSize.isEmpty ? .75 : viewSize.aspectRatio);
        if (mounted) setState(() => error = null);
        return;
      }
      final p = await DocScanner.start(tab.mode ?? ScanMode.document);
      detections ??= DocScanner.detections.listen(_onDetection);
      if (!mounted) return;
      setState(() {
        preview = p;
        error = null;
      });
    } on PlatformException catch (e) {
      if (mounted) setState(() => error = e.code);
    } finally {
      starting = false;
      // The user switched between Measure and a scanner tab while we were starting: swap engines.
      if (mounted && !away && ar != (tab == ScannerTab.measure)) unawaited(_restart());
    }
  }

  Future<void> _restart() async {
    await _stop();
    await _start();
  }

  Future<void> _stop() async {
    if (measure.running) await measure.stop();
    await detections?.cancel();
    detections = null;
    _resetDetection();
    if (mounted) {
      setState(() {
        preview = null;
        torch = false;
      });
    }
    await DocScanner.stop();
  }

  void _resetDetection() {
    tracker.reset();
    quad.value = null;
    progress.value = 0;
    mrzBox.value = null;
    mrzKey = null;
    mrzHits = 0;
    mathBox.value = null;
    mathKey = null;
    mathHits = 0;
    mathLocal = false;
    state = QuadState.searching;
    armed = true;
  }

  void _onDetection(Detection d) {
    if (sheetOpen || busy || d.mode != tab.mode?.name) return;
    if (tab.quad) {
      _onQuad(d.corners);
    } else if (tab == ScannerTab.qr && d.codes.isNotEmpty) {
      _showQr(d.codes.first.value);
    } else if (tab == ScannerTab.passport) {
      _onMrzLines(d.lines);
    } else if (tab == ScannerTab.math) {
      _onMathLines(d.lines);
    }
  }

  void _onMathLines(List<TextLine> lines) {
    final picked = pickMathLine([for (final l in lines) (l.text, l.box.center.dy)]);
    if (picked == null) {
      if (mathBox.value != null) setState(_resetDetection);
      return;
    }
    mathBox.value = lines.firstWhere((l) => l.text == picked).box;
    final key = normalizeMath(picked);
    final local = solveLocally(picked);
    setState(() {
      mathHits = key == mathKey ? mathHits + 1 : 1;
      mathLocal = local != null;
    });
    mathKey = key;
    final recentlyClosed = key == lastMath && DateTime.now().difference(lastMathClosed) < const Duration(seconds: 3);
    if (local != null && mathHits >= 2 && !recentlyClosed) _showMath(Future.value(local), key);
  }

  Future<void> _showMath(Future<MathSolution> solving, String key) async {
    setState(() => sheetOpen = true);
    HapticFeedback.mediumImpact();
    await showMathSheet(context, solving);
    lastMath = key;
    lastMathClosed = DateTime.now();
    if (mounted) setState(() => sheetOpen = false);
  }

  /// OCR a photo (sharper than live frames), then solve on device, else in the cloud.
  Future<void> _solvePhoto(String photo) async {
    final lines = (await DocScanner.analyzeFile(photo, ScanMode.math)).lines;
    final picked = pickMathLine([for (final l in lines) (l.text, l.box.center.dy)]);
    // Word problems have no single "math line": send all the text to the cloud.
    final text = picked ?? lines.map((l) => l.text).join('\n');
    if (text.trim().isEmpty) return _toast("Couldn't find a math problem. Try getting closer.");
    final local = solveLocally(text);
    await _showMath(local != null ? Future.value(local) : solveInCloud(text, photo: photo), normalizeMath(text));
  }

  void _onQuad(List<Offset>? corners) {
    final autoCapture = auto || tab == ScannerTab.idCard;
    tracker.add(corners, clock.elapsed);
    quad.value = tracker.corners;
    progress.value = autoCapture ? tracker.steadyProgress : 0;
    if (tracker.state != state || tracker.armed != armed) {
      setState(() {
        state = tracker.state;
        armed = tracker.armed;
      });
    }
    if (autoCapture && tracker.state == QuadState.steady) _shoot();
  }

  void _onMrzLines(List<TextLine> lines) {
    final sorted = [...lines]..sort((a, b) => a.box.top.compareTo(b.box.top));
    final mrz = Mrz.find([for (final l in sorted) l.text]);
    if (mrz == null) {
      if (mrzHits > 0) setState(() => mrzHits = 0);
      mrzKey = null;
      mrzBox.value = null;
      return;
    }
    mrzBox.value = sorted.map((l) => l.box).reduce((a, b) => a.expandToInclude(b));
    setState(() => mrzHits = mrz.key == mrzKey ? mrzHits + 1 : 1);
    mrzKey = mrz.key;
    if (mrzHits >= 2) _capturePassport(mrz);
  }

  Future<void> _capturePassport(Mrz mrz) async {
    busy = true;
    HapticFeedback.mediumImpact();
    flash.forward(from: 0);
    Capture? shot;
    try {
      shot = await DocScanner.capture();
    } on PlatformException {
      // The MRZ read is still valid; only the page photo is missing.
    }
    await _presentMrz(mrz, shot?.path, shot?.corners);
    busy = false;
  }

  Future<void> _presentMrz(Mrz mrz, String? photo, List<Offset>? corners) async {
    sheetOpen = true;
    final save = await showMrzSheet(context, mrz);
    sheetOpen = false;
    if (!mounted) return;
    setState(_resetDetection);
    if (save && photo != null) {
      unawaited(session.add(ScanPage(photo, corners, label: mrz.format == 'TD3' ? 'Passport' : 'ID document')));
      _toast('Page saved');
    }
  }

  Future<void> _showQr(String value) async {
    if (value == lastCode && DateTime.now().difference(lastCodeClosed) < const Duration(seconds: 3)) return;
    setState(() => sheetOpen = true);
    HapticFeedback.mediumImpact();
    scanLine.stop();
    await showQrSheet(context, QrPayload.parse(value));
    lastCode = value;
    lastCodeClosed = DateTime.now();
    if (!mounted) return;
    setState(() => sheetOpen = false);
    if (tab == ScannerTab.qr) scanLine.repeat(reverse: true);
  }

  Future<void> _shoot() async {
    if (busy || preview == null || tab.mode == null || tab == ScannerTab.qr) return;
    busy = true;
    if (tab == ScannerTab.math || tab == ScannerTab.count) {
      final kind = tab;
      HapticFeedback.mediumImpact();
      flash.forward(from: 0);
      try {
        final photo = (await DocScanner.capture()).path;
        kind == ScannerTab.math ? await _solvePhoto(photo) : await _openCount(photo);
      } on PlatformException catch (e) {
        _toast('Capture failed: ${e.message}');
      } finally {
        busy = false;
      }
      return;
    }
    final kind = tab;
    final live = tracker.corners;
    final retake = session.retakeIndex != null;
    tracker.captured();
    setState(() => armed = false);
    HapticFeedback.mediumImpact();
    flash.forward(from: 0);
    try {
      final shot = await DocScanner.capture();
      final corners = shot.corners ?? live;
      if (retake) {
        unawaited(session.add(ScanPage(shot.path, corners)));
        await _openPages();
      } else if (kind == ScannerTab.book) {
        final (left, right) = await splitSpread(shot.path, corners);
        unawaited(session.add(ScanPage(shot.path, left, label: 'Left')));
        unawaited(session.add(ScanPage(shot.path, right, label: 'Right')));
      } else if (kind == ScannerTab.idCard) {
        unawaited(session.add(ScanPage(shot.path, corners, label: idBack ? 'ID back' : 'ID front', group: idGroup)));
        if (!idBack) {
          setState(() => idBack = true);
        } else {
          setState(() => idBack = false);
          idGroup = _newGroup();
          await _openPages();
        }
      } else {
        unawaited(session.add(ScanPage(shot.path, corners, label: kind == ScannerTab.passport ? 'Passport' : null)));
      }
    } on PlatformException catch (e) {
      _toast('Capture failed: ${e.message}');
    } finally {
      busy = false;
    }
  }

  Future<void> _importFromGallery() async {
    final picker = ImagePicker();
    final mode = tab.mode ?? ScanMode.document;
    if (tab == ScannerTab.qr || tab == ScannerTab.passport || tab == ScannerTab.math || tab == ScannerTab.count) {
      final file = await picker.pickImage(source: ImageSource.gallery, requestFullMetadata: false);
      if (file == null) return;
      if (tab == ScannerTab.math) return _solvePhoto(file.path);
      if (tab == ScannerTab.count) return _openCount(file.path);
      final d = await DocScanner.analyzeFile(file.path, mode);
      if (tab == ScannerTab.qr) {
        if (d.codes.isEmpty) return _toast('No code found in that image');
        lastCode = null;
        return _showQr(d.codes.first.value);
      }
      final sorted = [...d.lines]..sort((a, b) => a.box.top.compareTo(b.box.top));
      final mrz = Mrz.find([for (final l in sorted) l.text]);
      if (mrz == null) return _toast('No readable MRZ in that image. Try a sharper photo.');
      final page = await DocScanner.analyzeFile(file.path, ScanMode.document);
      return _presentMrz(mrz, file.path, page.corners);
    }

    final files = await picker.pickMultiImage(requestFullMetadata: false);
    if (files.isEmpty) return;
    for (final (i, f) in files.indexed) {
      final corners = (await DocScanner.analyzeFile(f.path, mode)).corners;
      if (tab == ScannerTab.book) {
        final (left, right) = await splitSpread(f.path, corners);
        unawaited(session.add(ScanPage(f.path, left, label: 'Left')));
        unawaited(session.add(ScanPage(f.path, right, label: 'Right')));
      } else if (tab == ScannerTab.idCard) {
        unawaited(session.add(ScanPage(f.path, corners, label: i.isEven ? 'ID front' : 'ID back', group: idGroup)));
      } else {
        unawaited(session.add(ScanPage(f.path, corners)));
      }
    }
    if (tab == ScannerTab.idCard) idGroup = _newGroup();
    await _openPages();
  }

  Future<void> _openCount(String photo) async {
    away = true;
    await _stop();
    if (!mounted) return;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CountScreen(photo: photo, session: session),
      ),
    );
    away = false;
    if (!mounted) return;
    if (saved == true) _toast('Count saved to your pages');
    _start();
  }

  Future<void> _openPages() async {
    if (session.pages.isEmpty || !mounted) return;
    away = true;
    await _stop();
    if (!mounted) return;
    final done = await Navigator.of(context)
        .push<ScanResult>(MaterialPageRoute(builder: (_) => PagesScreen(session: session)));
    away = false;
    if (!mounted) return;
    if (done != null) return Navigator.of(context).pop(done);
    _start();
  }

  Future<void> _close() async {
    final n = session.pages.length;
    if (n > 0) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('Discard $n scanned page${n == 1 ? '' : 's'}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep scanning')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Discard')),
          ],
        ),
      );
      if (discard != true) return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _selectTab(ScannerTab t) {
    if (t == tab) return;
    HapticFeedback.selectionClick();
    final swap = (t == ScannerTab.measure) != (tab == ScannerTab.measure);
    setState(() {
      tab = t;
      _resetDetection();
      if (swap) error = null;
    });
    if (swap) {
      if (!starting) _restart();
    } else if (t.mode != null && preview != null) {
      DocScanner.setMode(t.mode!);
    }
    t == ScannerTab.qr ? scanLine.repeat(reverse: true) : scanLine.stop();
    final ctx = tabKeys[t]!.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, alignment: .5, duration: const Duration(milliseconds: 250));
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) => didPop ? null : _close(),
        child: Scaffold(
          backgroundColor: Tone.chrome,
          body: Column(
            children: [
              SafeArea(bottom: false, child: _topBar()),
              Expanded(child: _viewport()),
              _bottom(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    final close = ChipButton(icon: Icons.close_rounded, label: 'Close', onTap: _close);
    final torchButton = ChipButton(
      icon: torch ? Icons.flash_on_rounded : Icons.flash_off_rounded,
      label: torch ? 'Flash on' : 'Flash off',
      color: torch ? Tone.auto : null,
      onTap: () {
        setState(() => torch = !torch);
        tab == ScannerTab.measure ? ArMeasure.setTorch(torch) : DocScanner.setTorch(torch);
      },
    );
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: tab == ScannerTab.document || tab == ScannerTab.book
            ? Row(
                children: [
                  close,
                  const Spacer(),
                  torchButton,
                  const SizedBox(width: 12),
                  ChipButton(
                    icon: Icons.grid_on_rounded,
                    label: grid ? 'Hide grid' : 'Show grid',
                    color: grid ? Tone.auto : null,
                    onTap: () => setState(() => grid = !grid),
                  ),
                  const SizedBox(width: 12),
                  _autoButton(),
                  const Spacer(),
                  ChipButton(icon: Icons.settings_outlined, label: 'Settings', onTap: () {}),
                ],
              )
            : Row(
                children: [
                  close,
                  Expanded(
                    child: Text(
                      tab.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ),
                  torchButton,
                ],
              ),
      ),
    );
  }

  Widget _autoButton() => Semantics(
    button: true,
    label: auto ? 'Auto capture on' : 'Auto capture off',
    child: Material(
      color: Tone.chip,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => auto = !auto);
        },
        child: SizedBox(
          height: 40,
          width: 64,
          child: Center(
            child: Text(
              'AUTO',
              style: TextStyle(
                color: auto ? Tone.auto : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: .6,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _viewport() {
    final p = preview;
    final ar = tab == ScannerTab.measure;
    return GestureDetector(
      // Measure: one-finger drags move corners, so swiping between tabs is off there (the tab bar still works).
      onPanDown: ar ? (d) => measure.dragStart(d.localPosition, viewSize) : null,
      onPanUpdate: ar ? (d) => measure.dragUpdate(d.localPosition, viewSize) : null,
      onPanEnd: ar ? (_) => measure.dragEnd() : null,
      onPanCancel: ar ? measure.dragCancel : null,
      onHorizontalDragEnd: ar
          ? null
          : (d) {
              final v = d.primaryVelocity ?? 0;
              final i =
                  tab.index +
                  (v < -300
                      ? 1
                      : v > 300
                      ? -1
                      : 0);
              if (i >= 0 && i < ScannerTab.values.length) _selectTab(ScannerTab.values[i]);
            },
      onTapUp: ar ? (d) => measure.tap(d.localPosition, viewSize) : null,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Colors.black),
            LayoutBuilder(
              builder: (_, box) {
                viewSize = box.biggest;
                return const SizedBox();
              },
            ),
            if (ar) ..._measureLayers(),
            if (p != null && !ar) FittedBox(fit: BoxFit.cover, child: ScannerPreviewView(p)),
            if (grid && (tab == ScannerTab.document || tab == ScannerTab.book)) const CustomPaint(painter: GridPainter()),
            if (p != null && error == null && !ar) ..._overlays(p),
            if (error != null) _errorView(error!),
            if (error == null && !ar) Positioned(left: 16, right: 16, bottom: 40, child: Center(child: _pill())),
            IgnorePointer(
              child: AnimatedBuilder(
                animation: flash,
                builder: (_, _) =>
                    ColoredBox(color: Colors.white.withValues(alpha: flash.isAnimating ? (1 - flash.value) * .6 : 0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _overlays(ScannerPreview p) => switch (tab) {
    ScannerTab.document => [CustomPaint(painter: QuadPainter(quad, p.size, guideAspect: .79))],
    ScannerTab.book => [CustomPaint(painter: QuadPainter(quad, p.size, guideAspect: 1.4))],
    ScannerTab.idCard => [
      CustomPaint(
        painter: BracketsPainter(
          aspect: _cardAspect,
          color: state != QuadState.searching && armed ? Tone.success : Tone.accent,
        ),
      ),
      CustomPaint(painter: QuadPainter(quad, p.size, handles: false)),
      Positioned(
        top: 16,
        left: 16,
        right: 16,
        child: FittedBox(fit: BoxFit.scaleDown, child: _sides()),
      ),
    ],
    ScannerTab.passport => [
      CustomPaint(
        painter: BracketsPainter(aspect: _passportAspect, color: Colors.white),
      ),
      CustomPaint(painter: HighlightPainter(mrzBox, p.size, color: Tone.success)),
    ],
    ScannerTab.math => [
      CustomPaint(
        painter: HighlightPainter(mathBox, p.size, color: Tone.accent, fill: Colors.white.withValues(alpha: .35)),
      ),
    ],
    ScannerTab.qr => [
      CustomPaint(painter: BracketsPainter(aspect: 1, color: Tone.accent)),
      if (!sheetOpen) CustomPaint(painter: ScanLinePainter(scanLine)),
    ],
    _ => const [],
  };

  List<Widget> _measureLayers() => [
    ListenableBuilder(
      listenable: measure,
      builder: (_, _) => measure.running ? ArPreviewView(measure.textureId) : const SizedBox(),
    ),
    if (error == null) ...[
      CustomPaint(
        painter: MeasurePainter(measure),
        child: ListenableBuilder(
          listenable: measure,
          builder: (_, _) => Semantics(liveRegion: true, label: measure.summary, child: const SizedBox.expand()),
        ),
      ),
      // Pill sits just above the reticle, as in Figma 7.6.
      Align(
        alignment: Alignment.center,
        child: Transform.translate(
          offset: const Offset(0, -64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListenableBuilder(
              listenable: measure,
              builder: (_, _) {
                final h = measure.hint;
                return h == null ? const SizedBox() : StatusPill(icon: h.$1, text: h.$2);
              },
            ),
          ),
        ),
      ),
      _measureLoupe(),
    ],
  ];

  /// Magnifier over the dragged corner, pinned to the top corner away from the finger.
  Widget _measureLoupe() => ListenableBuilder(
    listenable: measure,
    builder: (_, _) {
      final at = measure.dragAt;
      if (at == null || viewSize.isEmpty) return const SizedBox();
      const size = 120.0;
      final p = Offset(at.dx * viewSize.width, at.dy * viewSize.height);
      final left = p.dx < viewSize.width / 2 ? viewSize.width - size - 16 : 16.0;
      final center = Offset(left + size / 2, 16 + size / 2);
      return Stack(
        children: [
          Positioned(
            left: left,
            top: 16,
            child: IgnorePointer(
              child: RawMagnifier(
                size: const Size.square(size),
                magnificationScale: 2.2,
                focalPointOffset: p - center,
                decoration: const MagnifierDecoration(
                  shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
                  shadows: [BoxShadow(color: Colors.black54, blurRadius: 12)],
                ),
                child: const Center(child: Icon(Icons.add, color: Tone.accent, size: 20)),
              ),
            ),
          ),
        ],
      );
    },
  );

  Future<void> _addPoint() async {
    if (!await measure.add(viewSize)) _toast('Point the circle at a surface first');
  }

  /// "1 Front side | 2 Back side" switch (Figma 7.1).
  Widget _sides() {
    Widget side(int n, String label, bool back) {
      final on = idBack == back;
      return GestureDetector(
        onTap: () => setState(() {
          idBack = back;
          _resetDetection();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$n   $label',
            style: TextStyle(color: on ? Tone.chrome : Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Tone.pill, borderRadius: BorderRadius.circular(24)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [side(1, 'Front side', false), side(2, 'Back side', true)]),
    );
  }

  Widget _pill() {
    const info = Icons.info_outline_rounded;
    const ok = Icons.check_circle_rounded;
    switch (tab) {
      case ScannerTab.qr:
        return const StatusPill(icon: Icons.qr_code_scanner_rounded, text: 'Point at a QR code or barcode');
      case ScannerTab.count:
        return const StatusPill(icon: Icons.grid_view_rounded, text: 'Point at the objects, then tap the shutter');
      case ScannerTab.math:
        if (mathKey == null) return const StatusPill(icon: Icons.calculate_outlined, text: 'Point at a math problem');
        return mathLocal
            ? const StatusPill(icon: ok, text: 'Problem found · Hold steady', color: Tone.success)
            : const StatusPill(icon: info, text: 'Tap the shutter to solve');
      case ScannerTab.passport:
        return mrzHits > 0
            ? const StatusPill(icon: ok, text: 'MRZ detected · Hold steady', color: Tone.success)
            : const StatusPill(icon: info, text: 'Place the photo page inside the frame');
      case ScannerTab.idCard:
        if (!armed && state != QuadState.searching) {
          return StatusPill(icon: Icons.check_rounded, text: idBack ? 'Front saved · Flip the card' : 'Saved');
        }
        if (state == QuadState.searching) {
          return StatusPill(icon: info, text: idBack ? 'Now scan the back side' : 'Fit the card inside the frame');
        }
        return const StatusPill(icon: ok, text: 'Card detected · Hold still', color: Tone.success);
      default:
        final book = tab == ScannerTab.book;
        if (!armed && state != QuadState.searching) {
          return StatusPill(
            icon: Icons.check_rounded,
            text: book ? 'Captured · Turn the page' : 'Captured · Place the next page',
          );
        }
        if (state == QuadState.searching) {
          return StatusPill(
            icon: Icons.document_scanner_outlined,
            text: book ? 'Point at an open book' : 'Point at a document',
          );
        }
        final what = book ? 'Book' : 'Document';
        return StatusPill(
          icon: ok,
          text: auto ? '$what detected · Hold still' : '$what detected · Tap to capture',
          color: Tone.success,
        );
    }
  }

  Widget _errorView(String code) {
    final denied = code == 'PERMISSION_DENIED';
    final (title, body) = switch (code) {
      'PERMISSION_DENIED' => ('Camera access is off', 'Allow camera access to scan documents.'),
      'AR_UNSUPPORTED' => ("AR isn't available on this phone", 'Measuring needs Google Play Services for AR.'),
      'AR_INSTALL' => ('Install AR support', 'Finish installing Google Play Services for AR, then try again.'),
      _ when tab == ScannerTab.measure => ("AR couldn't start", 'Something went wrong starting the AR camera.'),
      _ => ('Camera unavailable', 'Something went wrong starting the camera.'),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Tone.muted),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Tone.accent),
              onPressed: denied ? DocScanner.openSettings : _start,
              child: Text(denied ? 'Open Settings' : 'Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottom() => ColoredBox(
    color: Tone.chrome,
    child: SafeArea(
      top: false,
      child: Column(
        children: [
          const SizedBox(height: 14),
          _tabs(),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: tab == ScannerTab.measure
                ? SizedBox(
                    height: 80,
                    child: MeasureControls(c: measure, onAdd: _addPoint),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _squareButton(Icons.image_outlined, 'Import from gallery', _importFromGallery),
                      if (tab == ScannerTab.qr) const SizedBox.square(dimension: 80) else _shutter(),
                      SizedBox.square(dimension: 56, child: _stack()),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );

  Widget _tabs() {
    final half = MediaQuery.sizeOf(context).width / 2;
    return SizedBox(
      height: 34,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: half - 40),
        child: Row(
          children: [
            for (final t in ScannerTab.values)
              GestureDetector(
                key: tabKeys[t],
                behavior: HitTestBehavior.opaque,
                onTap: () => _selectTab(t),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  child: Column(
                    children: [
                      Text(
                        t.label,
                        style: TextStyle(
                          color: t == tab ? Colors.white : Tone.muted,
                          fontSize: 15,
                          fontWeight: t == tab ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedOpacity(
                        opacity: t == tab ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const CircleAvatar(radius: 2.5, backgroundColor: Tone.accent),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _squareButton(IconData icon, String label, VoidCallback onTap) => Semantics(
    button: true,
    label: label,
    child: Material(
      color: Tone.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox.square(dimension: 48, child: Icon(icon, color: Colors.white)),
      ),
    ),
  );

  Widget _shutter() {
    final enabled = tab.mode != null && preview != null;
    final found =
        (tab.quad && state != QuadState.searching && armed) ||
        (tab == ScannerTab.passport && mrzHits > 0) ||
        (tab == ScannerTab.math && mathKey != null);
    return Semantics(
      button: true,
      label: 'Capture',
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? _shoot : null,
        child: SizedBox.square(
          dimension: 80,
          child: CustomPaint(
            painter: ShutterPainter(progress, fill: !enabled ? Colors.white24 : (found ? Tone.accent : Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _stack() => ListenableBuilder(
    listenable: session,
    builder: (context, _) {
      if (session.pages.isEmpty) return const SizedBox();
      final last = session.pages.last;
      final image = last.preview ?? last.original;
      return Semantics(
        button: true,
        label: 'Review ${session.pages.length} pages',
        child: GestureDetector(
          onTap: _openPages,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Transform.rotate(angle: .12, child: _thumbCard(null)),
              _thumbCard(image),
              Positioned(
                top: -4,
                right: -2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Tone.accent,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Tone.chrome, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${session.pages.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _thumbCard(String? path) => Container(
    width: 38,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
    ),
    child: path == null
        ? null
        : ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image(
              image: ResizeImage(FileImage(File(path)), width: 120, height: 160, policy: ResizeImagePolicy.fit),
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
          ),
  );
}
