# flutter_doc_scanner (in-house fork)

Camera + on-device detection engine behind the scanner app. Forked from
[shirsh94/flutter_doc_scanner](https://github.com/shirsh94/flutter_doc_scanner) and rewritten:
the system scanner UIs are gone, all UI lives in the app.

- **Android:** CameraX + OpenCV (`DocVision.kt`)
- **iOS 15+:** AVFoundation + Vision + Core Image (`DocVision.swift`)
- **Dart:** `DocScanner` (channel API), `ScannerPreviewView`, `QuadTracker`

API contract, design decisions and roadmap: [`docs/SCANNER_PHASES.md`](../docs/SCANNER_PHASES.md).

```sh
flutter test                                   # QuadTracker unit tests (this package)
flutter test integration_test -d <phone>       # native detector/renderer, from the app root
```
