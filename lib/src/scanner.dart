import 'package:flutter/material.dart';

import 'engine.dart';
import 'math/solver.dart';
import 'scanner/scanner_screen.dart';
import 'scanner/session.dart';

/// Entry point for host apps: the whole scanner (document, ID card, passport, book, QR, math, count, measure) as
/// one full-screen flow.
abstract final class Scanner {
  /// Host defaults (e.g. from its settings screen), read when the scanner opens or a page is added.
  static bool autoCapture = true;
  static PageFilter defaultFilter = PageFilter.magic;

  /// Long side, in px, of each page image in exported PDFs (3508 = A4 at 300 dpi).
  static int exportSize = 3508;

  /// Solves math the on-device solver can't (e.g. with an AI model the host calls). Gets the OCR text and a JPEG
  /// of the photo (long side ≤ 1280 px) or null, and returns steps with LaTeX in [MathStep.tex] /
  /// [MathSolution.answerTex]. Throw an exception whose `toString()` is user-facing. Null = online solving off.
  static Future<MathSolution> Function(String text, String? image)? onlineMath;

  /// Pushes the scanner and completes with the kept pages when the user saves (review "Save as PDF", "Save Book",
  /// ID / passport "Save PDF"), or null if they close it. The PDF itself is the host's job ([ScanResult.toPdf]).
  /// QR, math, count and measure results are shown inside the scanner; count results the user saves become
  /// pages too.
  ///
  /// Lock the host app to portrait (the camera UI is portrait-only).
  static Future<ScanResult?> open(BuildContext context, {ScannerTab tab = ScannerTab.document}) =>
      Navigator.of(context).push<ScanResult>(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'scanner'),
          builder: (_) => ScannerScreen(initialTab: tab),
        ),
      );
}
