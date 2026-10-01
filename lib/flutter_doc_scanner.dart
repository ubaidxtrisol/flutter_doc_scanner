/// Document scanner module: native camera + detection engine and the complete scanner UI.
///
/// Host apps usually need only [Scanner.open]. See README.md for setup and CLAUDE.md for how the module is built.
library;

export 'src/engine.dart';
export 'src/math/solver.dart' show MathSolution, MathStep;
export 'src/export/pdf_export.dart' show exportPdf;
export 'src/scanner.dart';
export 'src/scanner/editor_screen.dart' show filterNames;
export 'src/scanner/scanner_screen.dart' show ScannerScreen, ScannerTab;
export 'src/scanner/session.dart' show ScanPage, ScanResult;
