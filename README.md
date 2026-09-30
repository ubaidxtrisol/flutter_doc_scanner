# flutter_doc_scanner: scanner module (in-house fork)

The app's complete scanner as one plugin: a native camera + detection engine and the full Flutter UI.

| Tab | What it does |
|---|---|
| Document | Live edge detection, auto-capture, crop, filters, multi-page, PDF |
| ID Card | Front + back, exported on one A4 sheet at real size |
| Passport | Reads and validates the MRZ (ICAO 9303 check digits) |
| Book | Splits an open spread into two pages at the fold |
| QR | QR codes and barcodes, with actions for URL / Wi-Fi / contact / … |
| Math | Reads a printed problem and solves it step by step (on device, optional cloud) |
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
  result.title;                // name typed on the review screen
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
- **Math cloud solver (optional):** build with `--dart-define=MATH_API_URL=https://…`. The contract is in the docs. Without it, math works on device only.

The lower-level engine (`DocScanner`, `ArMeasure`, `ScannerPreviewView`, `QuadTracker`) is exported too, for building custom screens.

## Develop

```sh
flutter test                                              # unit + widget tests
cd example && flutter run                                 # minimal host app
cd example && flutter test integration_test -d <device>   # on-device tests
```

- Roadmap, channel contract, decisions and test evidence: [`docs/SCANNER_PHASES.md`](docs/SCANNER_PHASES.md).
- Guide for coding agents (and humans): [`CLAUDE.md`](CLAUDE.md).
