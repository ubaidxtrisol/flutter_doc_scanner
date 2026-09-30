import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
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
import 'result_screens.dart';
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

const _cardAspect = 322 / 214; // Figma 7.1 bracket frame (an ID-1 card, 85.6 × 54 mm, with a margin)
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
  ScanPage? idFront;
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

  /// Figma 9.4. Save adds the data page and finishes the scan; Back returns to the camera.
  Future<void> _presentMrz(Mrz mrz, String? photo, List<Offset>? corners) async {
    final page = photo == null
        ? null
        : ScanPage(photo, corners, label: mrz.format == 'TD3' ? 'Passport' : 'ID document');
    final save = await _away(
      () => Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PassportResultScreen(mrz: mrz, page: page),
        ),
      ),
    );
    if (!mounted) return;
    setState(_resetDetection);
    if (save == true && page != null) {
      unawaited(session.add(page));
      return _finish();
    }
    _resume();
  }

  /// Stops the camera while a full-screen route is up. Callers either finish or [_resume].
  Future<T?> _away<T>(Future<T?> Function() route) async {
    away = true;
    await _stop();
    if (!mounted) return null;
    return route();
  }

  /// Back on the camera after [_away].
  void _resume() {
    away = false;
    if (mounted) _start();
  }

  /// Returns every kept page to the host (review "Save as PDF", "Save Book", "Save PDF").
  void _finish() => Navigator.of(context).pop(ScanResult(List.of(session.pages), title: defaultTitle()));

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
        await _openBook(shot.path, corners, left, right);
      } else if (kind == ScannerTab.idCard) {
        final page = ScanPage(shot.path, corners, label: idBack ? 'ID back' : 'ID front', group: idGroup);
        unawaited(session.add(page));
        if (!idBack || idFront == null) {
          idFront = page;
          setState(() => idBack = true);
        } else {
          final front = idFront!;
          setState(() => idBack = false);
          idFront = null;
          idGroup = _newGroup();
          await _openId(front, page);
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

    if (await _importPages(mode)) await _openPages();
  }

  /// Adds gallery photos as pages (book spreads are split, ID photos pair up front / back). False if none picked.
  Future<bool> _importPages(ScanMode mode) async {
    final files = await ImagePicker().pickMultiImage(requestFullMetadata: false);
    if (files.isEmpty) return false;
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
    return true;
  }

  /// Figma 9.2 after each spread: Next Spread / Back → camera, Done → review, Save Book → finish.
  Future<void> _openBook(String photo, List<Offset>? spread, List<Offset> left, List<Offset> right) async {
    final action = await _away(
      () => Navigator.of(context).push<ResultAction>(
        MaterialPageRoute(
          builder: (_) => BookResultScreen(session: session, photo: photo, spread: spread, left: left, right: right),
        ),
      ),
    );
    if (!mounted) return;
    if (action == ResultAction.save) return _finish();
    action == ResultAction.review ? await _openPages() : _resume();
  }

  /// Figma 9.3 after the back side: Retake drops both sides, Save PDF finishes, Back keeps them.
  Future<void> _openId(ScanPage front, ScanPage back) async {
    final action = await _away(
      () => Navigator.of(context).push<ResultAction>(
        MaterialPageRoute(
          builder: (_) => IdResultScreen(session: session, front: front, back: back),
        ),
      ),
    );
    if (!mounted) return;
    if (action == ResultAction.save) return _finish();
    if (action == ResultAction.retake) {
      session
        ..remove(front)
        ..remove(back);
    }
    _resume();
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
    final done = await _away(
      () => Navigator.of(context).push<ScanResult>(
        MaterialPageRoute(
          builder: (_) => PagesScreen(
            session: session,
            onAddFromPhotos: () => _importPages(tab.quad ? tab.mode! : ScanMode.document),
          ),
        ),
      ),
    );
    if (!mounted) return;
    done == null ? _resume() : Navigator.of(context).pop(done);
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

  /// Figma camera controls: 52 pt, 20 pt sides. Document: close · flash, grid, AUTO · settings. Other modes:
  /// close · title · flash.
  Widget _topBar() {
    final close = ChipButton(icon: IconsaxPlusLinear.add, label: 'Close', onTap: _close, size: 24, angle: math.pi / 4);
    final torchButton = ChipButton(
      icon: torch ? Icons2.flashOn : Icons2.flash,
      label: torch ? 'Flash on' : 'Flash off',
      color: torch ? Tone.auto : null,
      onTap: () {
        setState(() => torch = !torch);
        tab == ScannerTab.measure ? ArMeasure.setTorch(torch) : DocScanner.setTorch(torch);
      },
    );
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: tab == ScannerTab.document
            ? Row(
                children: [
                  close,
                  const Spacer(),
                  torchButton,
                  const SizedBox(width: 10),
                  ChipButton(
                    icon: IconsaxPlusLinear.grid_1,
                    label: grid ? 'Hide grid' : 'Show grid',
                    color: grid ? Tone.auto : null,
                    onTap: () => setState(() => grid = !grid),
                  ),
                  const SizedBox(width: 10),
                  _autoButton(),
                  const Spacer(),
                  ChipButton(icon: IconsaxPlusLinear.setting_2, label: 'Settings', onTap: () {}),
                ],
              )
            : Row(
                children: [
                  close,
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: fast,
                      child: Text(
                        tab.title,
                        key: ValueKey(tab),
                        textAlign: TextAlign.center,
                        style: TextStyles.headline.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  torchButton,
                ],
              ),
      ),
    );
  }

  Widget _autoButton() => Pressable(
    label: auto ? 'Auto capture on' : 'Auto capture off',
    onTap: () {
      HapticFeedback.selectionClick();
      setState(() => auto = !auto);
    },
    child: Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Tone.chip, borderRadius: BorderRadius.circular(20)),
      child: AnimatedStyle(
        style: TextStyles.caption2Semibold.copyWith(
          color: auto ? Tone.auto : Colors.white.withValues(alpha: .7),
          letterSpacing: .6,
        ),
        child: const Text('AUTO'),
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
            // Figma "Vignette": clear to 55%, then down to 40% black, so the pill reads on any scene.
            if (!ar)
              const IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [.55, 1],
                      colors: [Color(0x00000000), Color(0x66000000)],
                    ),
                  ),
                ),
              ),
            if (grid && tab == ScannerTab.document) const CustomPaint(painter: GridPainter()),
            if (p != null && error == null && !ar) ..._overlays(p),
            if (error != null) _errorView(error!),
            if (error == null && !ar)
              Positioned(
                left: 16,
                right: 16,
                bottom: 36,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: fast,
                    child: KeyedSubtree(key: ValueKey(_pillKey), child: _pill()),
                  ),
                ),
              ),
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

  /// Changes whenever the pill's message does, so it cross-fades instead of snapping.
  Object get _pillKey => (tab, state, armed, idBack, mrzHits > 0, mathKey == null, mathLocal, auto);

  List<Widget> _overlays(ScannerPreview p) => switch (tab) {
    ScannerTab.document => [CustomPaint(painter: QuadPainter(quad, p.size, guideAspect: 262 / 340))],
    ScannerTab.book => [
      CustomPaint(painter: QuadPainter(quad, p.size, guideAspect: 346 / 270, book: true)),
      ..._bookChips(),
    ],
    ScannerTab.idCard => [
      CustomPaint(
        painter: BracketsPainter(
          aspect: _cardAspect,
          widthFactor: 322 / 393,
          centerY: 265 / 540,
          color: state != QuadState.searching && armed ? Tone.success : Tone.accent,
        ),
      ),
      CustomPaint(painter: QuadPainter(quad, p.size, handles: false)),
      Positioned(
        top: 24,
        left: 16,
        right: 16,
        child: Center(
          child: FittedBox(fit: BoxFit.scaleDown, child: _sides()),
        ),
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

  /// Figma 9.1: "Left · n" / "Right · n+1" under each half of the spread guide (the page numbers this spread gets).
  List<Widget> _bookChips() {
    final n = spreadCount(session.pages) * 2 + 1;
    return [
      LayoutBuilder(
        builder: (_, box) {
          final r = bookGuide(box.biggest);
          return Stack(
            children: [
              for (final (i, text) in ['Left · $n', 'Right · ${n + 1}'].indexed)
                Positioned(
                  top: r.bottom + 20,
                  left: r.left + r.width * (i == 0 ? 0 : .5),
                  width: r.width / 2,
                  child: Center(child: ImageChip(text)),
                ),
            ],
          );
        },
      ),
    ];
  }

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

  /// "1  Front side | 2  Back side" switch (Figma 7.1).
  Widget _sides() {
    Widget side(int n, String label, bool back) {
      final on = idBack == back;
      return GestureDetector(
        onTap: () => setState(() {
          idBack = back;
          if (!back) idFront = null;
          _resetDetection();
        }),
        child: AnimatedContainer(
          duration: fast,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: on ? Colors.white : Colors.white.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedStyle(
            style: TextStyles.footnoteSemibold.copyWith(
              color: on ? const Color(0xFF0E1116) : Colors.white.withValues(alpha: .7),
            ),
            child: Text('$n  $label'),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Tone.chip, borderRadius: BorderRadius.circular(18)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [side(1, 'Front side', false), const SizedBox(width: 6), side(2, 'Back side', true)],
      ),
    );
  }

  Widget _pill() {
    const info = IconsaxPlusLinear.info_circle;
    const ok = IconsaxPlusLinear.tick_circle;
    switch (tab) {
      case ScannerTab.qr:
        return const StatusPill(icon: IconsaxPlusLinear.scan_barcode, text: 'Point at a QR code or barcode');
      case ScannerTab.count:
        return const StatusPill(icon: IconsaxPlusLinear.shapes, text: 'Point at the objects, then tap the shutter');
      case ScannerTab.math:
        const find = StatusPill(icon: IconsaxPlusLinear.calculator, text: 'Point at a math problem');
        if (mathKey == null) return find;
        return mathLocal
            ? const StatusPill(icon: ok, text: 'Problem found · Hold steady', color: Tone.success)
            : const StatusPill(icon: info, text: 'Tap the shutter to solve');
      case ScannerTab.passport:
        return mrzHits > 0
            ? const StatusPill(icon: ok, text: 'MRZ detected · Hold steady', color: Tone.success)
            : const StatusPill(icon: info, text: 'Place the photo page inside the frame');
      case ScannerTab.idCard:
        if (!armed && state != QuadState.searching) {
          return StatusPill(icon: ok, text: idBack ? 'Front saved · Flip the card' : 'Saved', color: Tone.success);
        }
        if (state == QuadState.searching) {
          return StatusPill(icon: info, text: idBack ? 'Now scan the back side' : 'Fit the card inside the frame');
        }
        return const StatusPill(icon: ok, text: 'Card detected · Hold still', color: Tone.success);
      case ScannerTab.book:
        if (state == QuadState.searching) {
          return const StatusPill(icon: IconsaxPlusLinear.book_1, text: 'Point at an open book');
        }
        // Figma 9.1 says "Curves flattened · pages split automatically"; the engine splits pages but doesn't
        // flatten curls yet, so the pill only claims the split.
        return StatusPill(
          icon: IconsaxPlusLinear.magicpen,
          text: auto ? 'Book detected · Pages split automatically' : 'Book detected · Tap to capture',
          color: armed ? Tone.pill : Tone.success,
        );
      default:
        if (!armed && state != QuadState.searching) {
          return const StatusPill(icon: ok, text: 'Captured · Place the next page', color: Tone.success);
        }
        if (state == QuadState.searching) {
          return const StatusPill(icon: IconsaxPlusLinear.scan, text: 'Point at a document');
        }
        return StatusPill(
          icon: ok,
          text: auto ? 'Document detected · Hold still' : 'Document detected · Tap to capture',
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
            const Icon(IconsaxPlusLinear.camera_slash, color: Colors.white, size: 40),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyles.headline.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyles.subhead.copyWith(color: Tone.muted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ScanButton(
                denied ? 'Open Settings' : 'Try again',
                onPressed: denied ? DocScanner.openSettings : _start,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Figma: modes (pt 18, pb 6), shutter row (pt 14, 32 pt sides), 34 pt above the home indicator.
  Widget _bottom() => ColoredBox(
    color: Tone.chrome,
    child: SafeArea(
      top: false,
      child: Column(
        children: [
          const SizedBox(height: 18),
          _tabs(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: tab == ScannerTab.measure
                ? SizedBox(
                    height: 78,
                    child: MeasureControls(c: measure, onAdd: _addPoint),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _squareButton(IconsaxPlusLinear.gallery, 'Import from gallery', _importFromGallery),
                      if (tab == ScannerTab.qr) const SizedBox.square(dimension: 78) else _shutter(),
                      SizedBox.square(dimension: 48, child: _stack()),
                    ],
                  ),
          ),
          const SizedBox(height: 29),
        ],
      ),
    ),
  );

  Widget _tabs() {
    final half = MediaQuery.sizeOf(context).width / 2;
    return SizedBox(
      height: 27,
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
                      AnimatedStyle(
                        style: t == tab
                            ? TextStyles.footnoteSemibold.copyWith(color: Colors.white)
                            : TextStyles.footnoteMedium.copyWith(color: Tone.muted),
                        child: Text(t.label),
                      ),
                      const SizedBox(height: 4),
                      AnimatedScale(
                        scale: t == tab ? 1 : 0,
                        duration: fast,
                        curve: Curves.easeOutBack,
                        child: const SizedBox.square(
                          dimension: 5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Tone.accent, shape: BoxShape.circle),
                          ),
                        ),
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

  Widget _squareButton(IconData icon, String label, VoidCallback onTap) => Pressable(
    label: label,
    onTap: onTap,
    child: Container(
      width: 48,
      height: 48,
      decoration: squircleBox(14, color: Tone.chip),
      child: Icon(icon, size: 24, color: Colors.white),
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
      child: Pressable(
        onTap: enabled ? _shoot : null,
        scale: .92,
        child: SizedBox.square(
          dimension: 78,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: !enabled ? Colors.white24 : (found ? Tone.accent : Colors.white)),
            duration: fast,
            builder: (_, fill, _) => CustomPaint(painter: ShutterPainter(progress, fill: fill!)),
          ),
        ),
      ),
    );
  }

  /// Figma page stack: the last page, the one before tilted -6° behind it, and a count badge.
  Widget _stack() => ListenableBuilder(
    listenable: session,
    builder: (context, _) {
      final pages = session.pages;
      return AnimatedSwitcher(
        duration: fast,
        transitionBuilder: (child, a) => ScaleTransition(
          scale: a,
          child: FadeTransition(opacity: a, child: child),
        ),
        child: pages.isEmpty
            ? const SizedBox()
            : Semantics(
                button: true,
                label: 'Review ${pages.length} page${pages.length == 1 ? '' : 's'}',
                child: GestureDetector(
                  onTap: _openPages,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (pages.length > 1)
                        Positioned(
                          left: 10,
                          top: 0,
                          child: Transform.rotate(
                            angle: -6 * math.pi / 180,
                            child: _thumbCard(_image(pages[pages.length - 2])),
                          ),
                        ),
                      Positioned(left: 4, top: 2, child: _thumbCard(_image(pages.last), shadow: true)),
                      Positioned(
                        left: 30,
                        top: -6,
                        child: AnimatedSwitcher(
                          duration: fast,
                          transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                          child: Container(
                            key: ValueKey(pages.length),
                            constraints: const BoxConstraints(minWidth: 22),
                            height: 22,
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: Tone.brand,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(color: Tone.chrome, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${pages.length}',
                              style: TextStyles.caption2Semibold.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
    },
  );

  String _image(ScanPage p) => p.preview ?? p.original;

  Widget _thumbCard(String path, {bool shadow = false}) => Container(
    width: 36,
    height: 46,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      boxShadow: shadow ? Shadows.card : null,
    ),
    clipBehavior: Clip.antiAlias,
    child: Image(
      image: ResizeImage(FileImage(File(path)), width: 120, height: 160, policy: ResizeImagePolicy.fit),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const SizedBox(),
    ),
  );
}
