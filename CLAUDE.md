# flutter_doc_scanner: agent guide

This package is the app's whole **scanner module**: a native camera + detection engine (Android and iOS) and the complete Flutter UI for eight modes. It covers Document, ID Card, Passport, Book, QR, Math, Count and Measure. Host apps call `Scanner.open(context)` and get pages back. Goals, in order: **accurate, fast, easy to use**.

## Start here
- **`docs/SCANNER_PHASES.md` is the source of truth.** It holds the status of every phase, the channel contract, the design decisions and why, test evidence, and acceptance lists. Work phase by phase and only on the 🟡 current phase or the one the user asks for. When work lands, update the status markers and checkboxes and record *measured* numbers (timings, accuracy). Don't write guesses there.
- Designs: `docs/figma/*.png`, named after the Figma frames (3.1, 3.2, 7.1–7.6).
- Public API: `lib/flutter_doc_scanner.dart`. Export only what a host needs; everything else stays in `lib/src/`.

## Layout
| Path | What |
|---|---|
| `lib/src/engine.dart` | Dart side of the native channels: `DocScanner` (camera, detections, capture, analyze, process, recognizeText), `ArMeasure`, `QuadTracker`, preview widgets |
| `lib/src/scanner/` | Camera screen (`scanner_screen.dart`, all tabs), overlays, review (`pages_screen.dart`), crop + enhance (`editor_screen.dart`, `crop_editor.dart`), book / ID / passport result screens (`result_screens.dart`), QR / math sheets, session model, MRZ / QR / book logic, `ui.dart` design tokens + shared widgets |
| `lib/src/count/` | Object counter: pure-Dart `counter.dart` (runs in an isolate) + `count_screen.dart` |
| `lib/src/math/` | `cloud.dart` (every problem goes to the host's `Scanner.onlineMath` AI hook) + `solver.dart` (result types, OCR line picking; its exact solver is no longer called) |
| `lib/src/measure/` | AR measure: `geometry.dart` (projection, area, plane fit, ray-plane) + `measure.dart` (controller, painter, controls) |
| `lib/src/export/` | PDF export (`pdf` package, JPEG embedded as-is) |
| `lib/src/scanner.dart` | `Scanner.open` facade |
| `android/src/main/kotlin/.../` | `FlutterDocScannerPlugin.kt` (CameraX + channels), `DocVision.kt` (OpenCV page detection + filters), `Readers.kt` (ML Kit), `ArMeasure.kt` (ARCore → texture) |
| `ios/flutter_doc_scanner/Sources/flutter_doc_scanner/` | Swift parity: `SwiftFlutterDocScannerPlugin.swift` (AVFoundation + channels), `DocVision.swift` (Vision / CoreImage), `ArMeasureView.swift` (ARKit) |
| `test/` | Unit + widget tests (no device) |
| `example/` | Minimal host app + `integration_test/` (on-device) |

## Architecture rules
- **UI is 100% Flutter, and native does camera + vision only.** Only small results cross the channel (corners, strings, AR points plus one matrix per frame). Frames never reach Dart.
- **A channel change touches four places:** Kotlin, Swift, `engine.dart`, and the contract table in `docs/SCANNER_PHASES.md`.
- **Logic that can be pure Dart is pure Dart and unit-tested:** tracker smoothing, MRZ, QR payloads, counter, book split, AR geometry. That gives one implementation for both platforms.
- **Pages are non-destructive.** `ScanPage.original` is never modified. Crop, rotation and filter are data, and `DocScanner.process` re-renders.
- **One camera session serves every scanner tab** (mode switch = analyzer swap). Measure is the exception: it swaps CameraX for AR and back (`_restart` in `scanner_screen.dart`).
- **AR:**
  - Native streams world points, the center hit (+ normal and kind) and the view-projection matrix; Dart projects and draws.
  - The first point locks the surface; later points and drags are ray ∩ plane.
  - Android anchors attach to the locked plane or the hit trackable.
- Styling comes from `lib/src/scanner/ui.dart`: exact Figma tokens (`Tone` for the camera, `Palette` light/dark from the ambient theme brightness), Figma text styles (no font family: Inter comes from the host), Iconsax icons, 60% squircles, and the shared widgets (`LightScreen`, `ScanButton`, …). Never hard-code colours in screens. Figma file `pSGWv3vGBBC3nkIcu0rknu`; node ids per screen are in the phases doc (Phase 6b).

## Commands
```sh
flutter analyze                  # package; must be clean
flutter test                     # unit + widget tests (fast, no device)
cd example && flutter test integration_test -d <android-device-id>   # on-device: detector, filters, QR, MRZ, book, math, count, AR
cd example && flutter build apk --debug
```
Format with **`dart format -l 120`**. The code is 120 columns and uses one-line `if`s. The default 80 columns reflows whole files and trips `curly_braces_in_flow_control_structures`.

## Testing patterns (learned the hard way)
- Widget tests mock `MethodChannel('flutter_doc_scanner')` and the event channels `flutter_doc_scanner/detections` and `flutter_doc_scanner/ar`. See `test/scanner_screen_test.dart` and `test/measure_screen_test.dart`.
- `MockStreamHandler.inline(onListen: (_, sink) { emit = sink.success; })` needs a **block body**. An arrow returns the closure and the codec throws.
- Fake platform events and awaited channel calls (camera stop, stream cancel) complete on real async time. Use `tester.runAsync(() => Future.delayed(20ms))` and then `pump()`. Loop it for multi-step flows.
- Canvas-drawn values (AR lengths and area) are exposed as a semantics summary. Find them with `find.bySemanticsLabel(RegExp('^…$', multiLine: true))`, because sibling labels get merged after a newline.
- Tabs can be off-screen: `ensureVisible` before tapping, and let the scroll animation settle before `tap`.
- `Isolate.run` closures must not capture a `State` (the error is "object is unsendable"). Use top-level functions (see `countInBackground`).
- In the integration harness, a `Texture` only repaints while the test pumps frames. A single long `runAsync` shows a black preview.
- `AnimatedDefaultTextStyle` replaces the inherited style and drops the host font; use `AnimatedStyle` from `ui.dart`.
- Visual checks without a device: render a screen in a widget test at 393×852 (dpr 2, padding top 54 / bottom 34), load Inter from the host's `assets/fonts` and the Iconsax fonts as `packages/iconsax_plus/IconsaxPlusLinear|Bold` with `FontLoader`, then `RepaintBoundary.toImage` inside `runAsync`. Mock `process` to copy the input so previews exist.

## Device work: privacy rules (non-negotiable)
- The user's phone holds **real ID card and passport photos**, both in the photo library and in captures in the app cache.
  - Never screenshot or view the live camera when it might show a document. Check pixel statistics numerically instead, then delete the file.
  - Only pull files the user explicitly allows. Delete copies afterwards and never commit user photos.
- Drive the phone by **accessibility labels** (uiautomator `content-desc`), never fixed coordinates. The same screen spot is "Undo" on Measure and "Import from gallery" on other tabs; a coordinate tap once opened the photo picker. Verify which tab is active before tapping.
- The module never holds an AI key. Online math goes through the host's `Scanner.onlineMath` hook.
- ML Kit sends anonymous Firebase telemetry (noted in the phases doc).

## Platform notes
- **Android:**
  - minSdk 24.
  - CameraX 1.6, OpenCV 4.14 (Maven), ML Kit bundled models, ARCore 1.56 (optional; `AR_UNSUPPORTED` / `AR_INSTALL` errors are handled in the UI).
  - The host needs a `FlutterActivity` (a `LifecycleOwner`).
  - The scanner stops CameraX before starting ARCore. ARCore's `resume()` retries while the camera closes.
- **iOS 15+:** the code is written for every phase but **never built or run**. iOS verification is deliberately deferred to Phase 7. Write iOS parity code with each change, but don't spend time on iOS testing unless the user says so.

## Known limits and open decisions
Kept current in `docs/SCANNER_PHASES.md`. At the time of writing:
- Math AI path: measured on rendered photos only; real textbook and handwritten samples are pending.
- Neutral white-on-white pages: a neural segmenter is a candidate.
- AR overlay can trail fast camera motion by one frame.
- Counter: struggles with patterned backgrounds.
