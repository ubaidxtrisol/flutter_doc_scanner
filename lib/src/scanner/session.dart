import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../engine.dart';
import '../export/pdf_export.dart';
import '../scanner.dart';

/// Long side of on-screen page renders. Exports render at full quality separately.
const previewSize = 1600;

/// One scanned page. Non-destructive: [original] is never modified; [preview] is
/// re-rendered from `{corners, rotation, filter}` whenever they change.
class ScanPage {
  ScanPage(this.original, this.detected, {this.label, this.group}) : corners = detected;

  static var _ids = 0;
  final _id = ++_ids;

  final String original;

  /// Shown under the thumbnail ("ID front", "Left", …).
  String? label;

  /// Pages sharing a group are laid out together on export (ID card front + back on one sheet).
  String? group;

  /// For result cards (math, QR, area, count): the card's document title ("Math · x = 5"), see [scanTitle].
  String? result;

  /// The auto-detected page quad (null if detection failed).
  final List<Offset>? detected;

  /// Crop quad TL, TR, BR, BL, normalized. Null = whole image.
  List<Offset>? corners;
  int rotation = 0;
  PageFilter filter = Scanner.defaultFilter;

  /// -1..1, 0 = unchanged (see [DocScanner.process]).
  double brightness = 0, contrast = 0;

  /// Grouped ID pages: front and back side by side on a landscape sheet instead of stacked.
  bool sideBySide = false;

  /// Latest screen-size render; null until the first render finishes.
  String? preview;
  int _version = 0;

  Future<void> render() async {
    final version = ++_version;
    final out = '${original}_${_id}_$version.jpg'; // new name per render, so Image caches never go stale
    await DocScanner.process(
      path: original,
      outPath: out,
      corners: corners,
      rotation: rotation,
      filter: filter,
      maxSize: previewSize,
      brightness: brightness,
      contrast: contrast,
    );
    if (version != _version) return File(out).delete().ignore(); // a newer edit won
    final old = preview;
    preview = out;
    if (old != null) File(old).delete().ignore();
  }
}

/// Default document name: "Scan 2026-09-30 14.05".
String defaultTitle([DateTime? at]) {
  final d = at ?? DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return 'Scan ${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}.${two(d.minute)}';
}

/// Document name for [pages]: one result card keeps its own title ("Math · x = 5"), several of one kind get a plural
/// ("Math solutions"), anything else (photos, mixed kinds) gets [defaultTitle].
String scanTitle(List<ScanPage> pages) {
  final titles = {for (final p in pages) p.result};
  if (titles.isEmpty || titles.contains(null)) return defaultTitle();
  if (titles.length == 1) return titles.single!;
  final kinds = {for (final t in titles) t!.split(RegExp('[ :]')).first};
  return switch (kinds.length == 1 ? kinds.single : null) {
    'Math' => 'Math solutions',
    'QR' => 'QR codes',
    'Area' => 'Area measurements',
    'Count' => 'Count results',
    _ => defaultTitle(),
  };
}

/// What [Scanner.open] returns when the user taps Done: the pages they kept, in order.
///
/// Page files live in the app's cache (`<cache>/scans`). Copy [ScanPage.preview] / [ScanPage.original], or call
/// [toPdf], before the OS clears the cache if you want to keep them.
class ScanResult {
  const ScanResult(this.pages, {this.title = 'Scan', this.pdf});
  final List<ScanPage> pages;

  /// Document name the user typed on the review screen.
  final String title;

  /// The PDF, if the user exported one and didn't edit the pages afterwards.
  final File? pdf;

  /// Full-quality PDF of [pages] (ID card front + back share one A4 sheet), written to the cache.
  Future<File> toPdf(String name) => exportPdf(pages, name);
}

/// Pages captured in one scanning session, shared by the camera, review and editor screens.
class ScanSession extends ChangeNotifier {
  final pages = <ScanPage>[];

  /// When set, the next capture replaces this page instead of appending.
  int? retakeIndex;

  Future<void> add(ScanPage page) async {
    final i = retakeIndex;
    retakeIndex = null;
    if (i != null && i < pages.length) {
      page
        ..label = pages[i].label
        ..group = pages[i].group;
      pages[i] = page;
    } else {
      pages.add(page);
    }
    notifyListeners();
    await update(page);
  }

  /// Re-renders [page] after an edit and refreshes listeners.
  Future<void> update(ScanPage page) async {
    try {
      await page.render();
    } catch (e) {
      debugPrint('render failed: $e');
      page.preview ??= page.original; // show the raw photo rather than a spinner forever
    }
    notifyListeners();
  }

  void remove(ScanPage page) {
    pages.remove(page);
    notifyListeners();
  }

  void insert(int index, ScanPage page) {
    pages.insert(index.clamp(0, pages.length), page);
    notifyListeners();
  }

  void move(int from, int to) {
    pages.insert(to, pages.removeAt(from));
    notifyListeners();
  }
}
