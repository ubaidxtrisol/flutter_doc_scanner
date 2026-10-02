# flutter_doc_scanner: scanner module (in-house fork)

The app's complete scanner as one plugin: a native camera + detection engine and the full Flutter UI.

| Tab | What it does |
|---|---|
| Document | Live edge detection, auto-capture, crop, filters, multi-page, PDF |
| ID Card | Front + back, exported on one A4 sheet at real size |
| Passport | Reads and validates the MRZ (ICAO 9303 check digits) |
| Book | Splits an open spread into two pages at the fold |
| QR | QR codes and barcodes, with actions for URL / Wi-Fi / contact / … |
| Math | Photograph a problem (printed or handwritten); the host's AI solves it step by step in LaTeX |
| Count | Counts objects in a photo; tap to fix; save as a page |
| Measure | AR area and lengths on floors, walls and hanging objects, with draggable corners |

Forked from [shirsh94/flutter_doc_scanner](https://github.com/shirsh94/flutter_doc_scanner) (MIT) and rewritten.
- **Android:** CameraX, OpenCV, ML Kit and ARCore.
- **iOS 15+:** AVFoundation, Vision, Core Image and ARKit. The iOS code is not yet verified (see Phase 7 in the docs).

## Use it in an app

```yaml
# pubspec.yaml
dependencies:
  flutter_doc_scanner:
    path: flutter_doc_scanner            # or: git: {url: git@github.com:ubaidxtrisol/flutter_doc_scanner.git, ref: <tag>}
```

```dart
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';

final result = await Scanner.open(context);                        // or tab: ScannerTab.qr, .measure, …
if (result != null) {
  result.title;                // document name, in the scanner's language (display only)
  result.kind;                 // ResultKind when every page is a math / QR / area / count card, else null
  result.pages;                // ScanPage: original photo, crop, filter, label, `preview` render
  result.pdf;                  // set if the user exported a PDF and didn't edit afterwards
  final pdf = await result.toPdf('Invoice');                       // full-quality PDF
}
```

`Scanner.open` returns `null` when the user closes the scanner. Page files live in the app cache (`<cache>/scans`), so copy anything you want to keep.

### Host app setup
- **Portrait:** lock the app to portrait, because the camera UI is portrait-only.
  `SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])`.
- **Android:**
  - `minSdk 24`.
  - The activity must be a `FlutterActivity` (the default).
  - The camera permission and the optional-ARCore manifest entries merge in automatically.
- **iOS:**
  - Deployment target 15.0.
  - Add to `Info.plist`:
    ```xml
    <key>NSCameraUsageDescription</key>
    <string>The camera scans documents, ID cards, QR codes and measures areas.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Import photos of documents to scan.</string>
    ```
- **Languages:** add `ScannerLocalizations.delegate` to your app's `localizationsDelegates` (with
  `GlobalMaterialLocalizations.delegate` etc., which also load the date formats for saved cards). Without it, or for
  a language the scanner has no strings for yet, the scanner shows English. `ScanResult.title` and page labels are
  display text in that language: use `ScanResult.kind` (`ResultKind.math / qr / area / count`, null for photos or
  mixed pages) and `ScanResult.severalResults` for logic.
- **Math solver (required for Math):** set `Scanner.onlineMath` before opening the scanner. It gets an empty text and a JPEG of the photo (≤ 1280 px)
  (the module runs no OCR for math; read the problem from the photo), and returns a `MathSolution` (steps with LaTeX in
  `MathStep.tex`). Throw an exception whose `toString()` is user-facing. The module holds no keys; the host calls its
  own AI or server. Without the hook, the Math tab says solving isn't set up.

The lower-level engine (`DocScanner`, `ArMeasure`, `ScannerPreviewView`, `QuadTracker`) is exported too, for building custom screens.

## Develop

```sh
flutter test                                              # unit + widget tests
cd example && flutter run                                 # minimal host app
cd example && flutter test integration_test -d <device>   # on-device tests
```

- Roadmap, channel contract, decisions and test evidence: [`docs/SCANNER_PHASES.md`](docs/SCANNER_PHASES.md).
- Guide for coding agents (and humans): [`CLAUDE.md`](CLAUDE.md).
