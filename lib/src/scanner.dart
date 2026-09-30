import 'package:flutter/material.dart';

import 'scanner/scanner_screen.dart';
import 'scanner/session.dart';

/// Entry point for host apps: the whole scanner (document, ID card, passport, book, QR, math, count, measure) as
/// one full-screen flow.
abstract final class Scanner {
  /// Pushes the scanner and completes with the kept pages when the user taps Done, or null if they close it.
  /// QR, math, count and measure results are shown inside the scanner; count results the user saves become
  /// pages too.
  ///
  /// Lock the host app to portrait (the camera UI is portrait-only).
  static Future<ScanResult?> open(BuildContext context, {ScannerTab tab = ScannerTab.document}) =>
      Navigator.of(context).push<ScanResult>(
        MaterialPageRoute(settings: const RouteSettings(name: 'scanner'), builder: (_) => ScannerScreen(initialTab: tab)),
      );
}
