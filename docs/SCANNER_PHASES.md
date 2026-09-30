# Scanner Phases

Tracker for the scanner module (this package): the camera + detection engine and the Figma scanner screens in
`docs/figma/`. Paths below are relative to the package root. Update the status markers and checkboxes as work lands.

**Status legend:** ✅ Complete · 🟡 Current · ⬜ Todo

| Phase | Scope | Figma | Status |
|---|---|---|---|
| 0 | Planning & decisions | — | ✅ Complete |
| 1 | Camera engine + Document scanner (edge detect, auto-capture, crop, multi-page, PDF) | 3.1, 3.2 | 🟡 Current: built, acceptance pending |
| 2 | QR, ID Card, Passport (MRZ), Book | 7.1, 7.2, 7.3 | 🟡 Current: built, acceptance pending |
| 3 | Math scanner (hybrid on-device + cloud LLM) | 7.4 | 🟡 Current: on-device built; cloud backend not decided |
| 4 | Object counter | 7.5 | 🟡 Current: built, real-object acceptance pending |
| 5 | AR area measurement | 7.6 | 🟡 Current: Android built, real-floor acceptance pending |
| 6 | Scanner as a self-contained module (plugin) | — | ✅ Complete |
| 7 | iOS pass (build, run, fix, accept every phase on iPhone) | all | ⬜ Todo: deferred to the end by decision |

Goals, in order: **accurate**, **fast**, **easy to use**. Each phase has acceptance criteria that
check all three. A phase is not ✅ until those pass on a real iPhone and a real mid-range Android
phone. Simulators don't count because they have no camera.

---

## Phase 0: Planning ✅

### Why the plugin must change
The upstream plugin only launches sealed system UIs: ML Kit `GmsDocumentScanner` on Android and
`VNDocumentCameraViewController` on iOS. They cannot be restyled, so none of the Figma screens can
be built on top of them. The plugin becomes a **native camera + detection engine**, and **all UI
is drawn in Flutter**.

### Decisions
| Topic | Decision | Why |
|---|---|---|
| UI | 100% Flutter | One UI codebase that matches Figma exactly on both platforms. |
| Preview | Native camera → Flutter `Texture` | Zero-copy. Frames never cross into Dart. |
| Detection | Native, per-mode analyzers on one camera session | Only small results (corners, strings) cross the channel. Mode switch = analyzer swap, no camera restart. |
| iOS doc edges | Vision `VNDetectDocumentSegmentationRequest` (iOS 15+), fallback `VNDetectRectanglesRequest` | Apple's neural doc detector. App already targets iOS 15.0. |
| Android doc edges | **OpenCV** (`org.opencv:opencv` from Maven Central) | Proven contour pipeline. Chosen over a hand-rolled detector for accuracy. **Measured:** arm64 release APK is 45 MB, and the full prebuilt OpenCV is roughly 35 MB of that. ponytail: fix = a custom OpenCV build with only `core` + `imgproc` + `imgcodecs` (a few MB) when app size matters. |
| Android camera | CameraX (Preview + ImageAnalysis + ImageCapture) | Handles device quirks. |
| Text / barcode (Ph 2+) | iOS Vision; Android ML Kit (bundled models) | On-device, fast, offline. |
| Math (Ph 3) | **Hybrid**: simple → on-device Dart solver; complex → cloud LLM through our backend | Instant + offline for common cases, and full coverage for the rest. |
| Smoothing / stability | In **Dart** (shared) | One implementation, unit-testable, cheap (8 numbers per frame). |
| PDF export | Dart `pdf` package, embedding JPEG bytes as-is (no re-encode) | One implementation, fast. |
| Gallery import | `image_picker` → native `detect(path)` for corners | Don't rebuild a picker. |
| Platforms | iOS + Android only | Remove the linux/macos/windows/web stubs. |

---

## Phase 1: Camera engine + Document scanner 🟡

**Figma:** `docs/figma/3.1 Camera Scanner.png` (searching), `docs/figma/3.2 Auto Detection.png` (detected, hold still).

### Status (2026-09-29)
All Phase 1 code is written. **Android** is built and running on a Pixel 6; the on-device detector/renderer tests pass.
**iOS** type-checks against the iOS APIs (via the Mac Catalyst SDK) but has **not been built or run**,
because Xcode isn't installed on the dev machine. Remaining work is the real-world acceptance pass in 1.7.

### 1.1 Cleanup
- [x] Deleted plugin `linux/`, `macos/`, `windows/`, web, `example/`, `demo/`, old tests, platform interface, exception class.
- [x] Deleted the system-scanner paths (ML Kit document scanner, VNDocumentCamera, `AutoScanViewController.swift`; its perspective crop is ported to `DocVision.swift`).
- [x] Plugin Android: Kotlin-DSL Gradle mirroring `camera_android_camerax`, `minSdk 24`, CameraX 1.6.1, `org.opencv:opencv:4.14.0`.
- [x] Plugin iOS minimum raised to 15.0 (podspec + Package.swift).
- [x] App deps: `flutter_doc_scanner` (path), `pdf`, `image_picker`, `path_provider`, `share_plus`.
  The app's **Dart package name** was renamed `pdf` → `pdf_scanner` (it clashed with the `pdf` package; bundle IDs unchanged).
- [x] Permissions: Android `CAMERA` (plugin manifest); iOS `NSCameraUsageDescription` + `NSPhotoLibraryUsageDescription`.

### 1.2 Channel contract (the engine API)
MethodChannel `flutter_doc_scanner`:

| Method | Args | Returns |
|---|---|---|
| `start` | `{mode}` | `{textureId, width, height, quarterTurns}`: portrait preview size; `quarterTurns` = rotation Dart applies to the raw texture (Android ImageReader backend needs it; iOS and SurfaceTexture return 0). Asks for camera permission first; `PERMISSION_DENIED` error if refused |
| `setMode` | `{mode}` | – (swaps the analyzer; camera keeps running) |
| `setTorch` | `{on}` | – |
| `capture` | – | `{path, corners?}`: full-res JPEG (EXIF orientation). `corners` come from re-running detection on the photo |
| `analyze` | `{path, mode}` | same shape as a detection event, for gallery imports (Phase 2 replaced `detect`) |
| `process` | `{path, outPath, corners?, rotation, filter, maxSize?}` | `{path, width, height}`: one pass of perspective crop → rotate (0/90/180/270) → filter → JPEG. `maxSize` caps the long side (fast decode path for thumbnails and previews) |
| `stop` | – | – (release camera + texture) |
| `openSettings` | – | – (app's system settings page) |

EventChannel `flutter_doc_scanner/detections`: `{mode, corners: [x0,y0 … x3,y3] | null}` per analyzed frame.
- Corners are **normalized 0..1 in portrait preview space**, ordered TL, TR, BR, BL (same ordering rule on both platforms).
- Backpressure: Android `STRATEGY_KEEP_ONLY_LATEST`; iOS drops frames while one analysis is in flight.

Modes enum: `document, idCard, passport, book, qr, math`. Count / Measure are UI tabs with their own screens later.

### 1.3 iOS engine (`ios/flutter_doc_scanner/Sources/flutter_doc_scanner/`), ⚠️ unverified on device
- [x] `SwiftFlutterDocScannerPlugin.swift`: channels, permission, and `CameraEngine` (`.photo` preset, BGRA video output with portrait connection, `FlutterTexture`, photo capture to `tmp/scans/`, torch).
- [x] `DocVision.swift`: `VNDetectDocumentSegmentationRequest` (confidence ≥ 0.6) → fallback `VNDetectRectanglesRequest`, area 10–98%. Analysis runs on its own queue so the preview never stalls.
- [x] `process`: `CGImageSource` thumbnail decode when `maxSize` is set → `CIPerspectiveCorrection` → Lanczos scale → `oriented()` → filter → JPEG q 0.9.
- [ ] **Verify on an iPhone:** preview orientation, `oriented(.right)` = 90° clockwise, and the `CIDivideBlendMode` operand order in the Magic filter (should be page ÷ paper estimate).

### 1.4 Android engine (`android/src/main/kotlin/com/shirsh/flutter_doc_scanner/`)
- [x] `FlutterDocScannerPlugin.kt`: CameraX bound to the activity lifecycle. Preview → `SurfaceProducer` (with surface-cleanup invalidation), 4:3 for preview / analysis (640×480) / capture, so all three share one field of view.
- [x] `DocVision.kt` (OpenCV) on the zero-copy **Y plane**: resize to 480 → blur → auto-Canny (median-based) → dilate → `RETR_LIST` contours → top 6 by area → **convex hull** (fingers or glare don't break it) → solidity ≥ 0.8 → `approxPolyDP` with widening epsilon → convex 4-gon, 15–98% of frame. A second low-threshold Canny pass handles white-on-white.
- [x] `process`: `imread` with reduced decode (1/2, 1/4, 1/8) when `maxSize` allows → `warpPerspective` (cubic) → rotate → filter → JPEG q 90. EXIF orientation is applied by `imread`.
- [x] Filters: **Magic** = divide by the dilated + median-blurred paper estimate (computed at 512 px), then deepen ink; **Gray**; **B&W** = Magic on gray + adaptive threshold.

### 1.5 Dart plugin API (`lib/src/engine.dart`)
- [x] `DocScanner` static API, `ScannerPreview`, `Detection`, `Capture`, `ScanMode`, `PageFilter`.
- [x] `ScannerPreviewView`: handles `quarterTurns`; wrap it in `FittedBox(cover)`.
- [x] `QuadTracker`: EMA smoothing, 250 ms hold on loss, 700 ms steady window, jump detection, and an **armed** flag (no re-shoot until the page leaves or changes). 5 unit tests in `test/quad_tracker_test.dart`.

### 1.6 App UI (`lib/src/scanner/`, `lib/src/export/`)
Tokens in `lib/src/scanner/ui.dart` (`Tone`) are eyeballed from the PNGs; swap in exact Figma variables when available.
- [x] **Camera** (`scanner_screen.dart`, Figma 3.1/3.2): top bar (close, torch, grid, AUTO, settings no-op) · cover-fit preview · dashed guide / blue quad with handles · status pills · swipeable combined tabs (swipe the preview too) · gallery / shutter with steady-progress ring / page stack with badge · white flash + haptic on capture · permission-denied screen with Open Settings · confirm before discarding pages.
- [x] **Auto-capture** via `QuadTracker` (steady ~0.7 s, armed flag). The live quad is the fallback when photo re-detection fails.
- [x] **Pages** (`pages_screen.dart`): grid · long-press drag reorder · rename · Add page · Export PDF → share sheet · Done.
- [x] **Editor** (`editor_screen.dart`, `crop_editor.dart`): swipe pages · pinch zoom · Crop (corner + edge handles, convexity guard, **loupe** opposite the finger, Auto / Full) · Rotate · Filters with live thumbnails + Apply to all · Retake (replaces the page in place) · Delete with Undo.
- [x] Non-destructive pages (`session.dart`): the original photo is kept; the preview is re-rendered at 1600 px on each edit; stale renders are dropped.
- [x] **PDF** (`lib/src/export/pdf_export.dart`): each page rendered at 3508 px (A4 @ 300 dpi) in parallel, JPEG embedded as-is, page size = scan aspect at A4 width, saved to app documents.
- [x] Semantics labels on icon buttons.

### 1.7 Acceptance: Phase 1 is ✅ when
**Accurate**
- [ ] Correct corners (visually within about 2% of the true edges) on: white paper on dark desk, **white paper on white desk**, 45° angled shot, low light, glare, receipt (long narrow), paper held in hand. Record results in this doc.
- [ ] No false detection on an empty desk or wall within 10 s of pointing at it.

**Fast** (release build, mid-range Android + iPhone 12-class)
- [ ] Camera first frame < 500 ms after screen push.
- [ ] Analyzer < 40 ms per frame, and the overlay updates ≥ 20 per second.
- [ ] Shutter → thumbnail in stack < 300 ms. Crop done < 1 s.
- [ ] Mode tab switch < 100 ms (no camera restart).
- [ ] 20-page PDF export < 3 s.

**Easy to use**
- [ ] A first-time user scans a 3-page document to PDF without instructions.
- [ ] Auto-capture never double-shoots the same page.
- [ ] The overlay never flickers during normal hand shake.

**Evidence so far** (Pixel 6, debug build, `example/integration_test/scanner_vision_test.dart`):
- Synthetic scenes: paper on a dark desk ✓ and white-on-white with shadow ✓ (all corners within 2%); empty textured desk → no detection ✓.
- `process` on 1.9 MP: original 76 ms · magic 99 ms · gray 71 ms · B&W 80 ms · rotate 88 ms.
- Live camera → texture → analyzer runs; a card cut off by the frame edge was correctly *not* detected.
- Still to do by hand: every real-world case in "Accurate" above, the timing items in release mode, and the 3-page first-time-user run.
- ❌ **Real-world failure (2026-09-29, user test, Pixel 6):** a white notebook on a white surface, with no corners detected.
  Classic edge detection (OpenCV on luminance) has almost no signal when white is on white; iOS avoids this with Vision's neural segmentation.
  **Fixed (classical tuning, as chosen):** the notebook differed from the desk mainly in *tint* (desk Lab b ≈ 134 vs
  paper ≈ 128), not brightness. `DocVision.detect` now runs a third, lazy **chroma pass** (|U−128|+|V−128|,
  stretched ×12 around the scene median → Canny) only when both brightness passes fail. Verified on the real
  photo with the Kotlin code (found in Document and Book mode) and on crops of desk, floor and monitor with no document
  (no false positives). A CLAHE pass was tried and dropped: it never fired.
  New regression test: "neutral white paper on a warm white desk", which fails on the old detector.
  **Known limit:** white paper on a *neutral* white surface with no shadow still has no signal. That's the case for the
  neural segmenter (option a) if it shows up in practice.

### 1.8 Resolved questions (2026-09-29)
- Review / editor: no Figma. Build an advanced editor that goes beyond stock (see 1.6).
- Tabs: combine all modes into one tab bar (see 1.6).
- ⚙ settings: clickable only for now.
- ID card: proper front + back flow (Phase 2).

---

## Phase 2: QR · ID Card · Passport · Book 🟡

**Figma:** `docs/figma/7.1 ID Card Scanner.png`, `docs/figma/7.2 Passport Scanner.png`, `docs/figma/7.3 QR Scanner.png`.
Every mode is a new analyzer + overlay on the Phase 1 engine, and one camera session serves all of them.

### Status (2026-09-29)
All Phase 2 code is written. **Android** is built and on-device tested (8/8 integration checks); live QR and passport
analysis confirmed running on the Pixel 6. **iOS** is written for parity but **not built, type-checked or run**:
iOS testing is deferred to the end by decision. Remaining: the real-sample acceptance pass below.

### Engine changes
- [x] Live analysis frame raised to **1280×960** (MRZ glyphs are too small at 640×480). The page detector still works at 480 px internally.
- [x] Per-mode analyzer, switched by `setMode` with no camera restart: `document`/`book` → page quad · `idCard` → quad restricted to card shape · `qr` → barcodes · `passport` → MRZ-like text lines.
- [x] `analyze {path, mode}` replaces `detect`: the same result shape as a live event, for gallery imports in every mode.
- [x] Event shape: `{mode, corners?, codes?: [{value, corners}], lines?: [{text, box:[l,t,r,b]}]}`.
- [x] Android: ML Kit `barcode-scanning:17.3.0` + `text-recognition:16.0.1` (bundled, offline) in `Readers.kt`. iOS: `VNDetectBarcodesRequest` / `VNRecognizeTextRequest` in `DocVision.swift`.
- ⚠️ **Privacy note:** bundled ML Kit sends anonymous SDK usage telemetry (`FIREBASE_ML_SDK` events in logcat). This is API usage stats, not images or text. Review before release; mention it in the privacy policy.

### QR (7.3)
- [x] Square brackets + sweeping scan line (runs only while the QR tab is scanning, so no idle frame cost).
- [x] First decode → haptic → result sheet (Figma 7.3). The same code isn't re-shown for 3 s after dismissing.
- [x] `qr_payload.dart` (pure Dart, unit-tested): Website / Wi-Fi / Email / Phone / SMS / Location / Contact / Text → icon, label, primary action (`url_launcher`, copy password, or share) + Copy.
- [x] Gallery: decode a code from a photo.

### ID Card (7.1)
- [x] Card-shaped detection: long/short side **1.45–1.85** (ID-1 is 1.586; A4 is 1.414 and is rejected square-on), minimum 6% of the frame.
- [x] Brackets (blue → green when a card is held steady) + subtle detected outline + "1 Front side / 2 Back side" switch.
- [x] Auto-capture is always on. Front → "Front saved · Flip the card" → back → opens review.
- [x] Front + back share a page **group**; PDF export puts them on **one A4 sheet at real card size** (85.6 × 54 mm), front above back.
- [ ] Bonus: TD1 MRZ on the back side. The parser supports TD1, but the ID tab doesn't run OCR yet.

### Passport (7.2)
- [x] `mrz.dart` (pure Dart, unit-tested): TD3 / TD2 / TD1, ICAO 7-3-1 check digits on every field + composite, OCR fix-ups by field type (O→0 in digit fields etc.), `«` → `<<`, and filler padding (ML Kit drops up to a dozen trailing `<`, seen on device).
- [x] Same valid MRZ in **2 consecutive frames** → auto-capture → "Verified" result sheet (name, document no., nationality, sex, DOB, expiry with an Expired flag) → Rescan / Save Page.
- [x] MRZ zone highlighted in green on the overlay.
- [x] Privacy: only MRZ-looking lines (≥25 chars, ≥90% `A-Z0-9<`) leave native code; parsed data is never logged or persisted beyond the saved page image.

### Book
- [x] Spread detected as a page → `book.dart` finds the fold (darkest column band in the middle 30% of a 480 px gray render; center if no clear shadow) → a projective (Heckbert) map puts the fold line back on the photo → two non-destructive pages labelled Left / Right.
- [ ] Page-curl dewarp stays in the **backlog**.

### Tests
- Unit: `test/mrz_test.dart`, `test/qr_payload_test.dart`, `test/book_test.dart`, plus `test/scanner_screen_test.dart` (fake native engine: every mode's chrome and hint, QR sheet, passport 2-read → capture → verified sheet). This test caught and fixed two overflows (pills and the Front/Back switch at large text) and a scan-line ticker that burned frames in every mode.
- On device (`example/integration_test/scanner_vision_test.dart`, Pixel 6): card found / A4 rejected in ID mode ✓ · QR decoded in 127 ms ✓ · rendered MRZ OCR'd + verified in 253 ms ✓ · book fold within 2% ✓.

### Acceptance
- [ ] QR / ID / Passport each pass on 10 real samples. Passport: 0 wrong fields (check digits guarantee this) and ≥ 90% read within 2 s.
- [ ] Switching between any two modes < 100 ms (no camera restart by design; measure it).
- [ ] Book: fold found on 10 real books (thick bindings, thin bindings, no visible shadow → center).

---

## Phase 3: Math scanner (hybrid) 🟡

**Figma:** `docs/figma/7.4 Math Scanner.png`

### Status (2026-09-29)
The on-device path is built and tested on Android. The cloud path's **app client** is built against the contract below,
but **no backend exists yet** (decision: "decide later"). Until `MATH_API_URL` is set, anything the local solver can't
handle shows "This problem needs the online solver, which isn't set up yet." Nothing is ever sent anywhere.
iOS parity is written, untested (deferred).

### Flow (as built)
1. **Live:** the `math` analyzer returns all text lines + boxes. `pickMathLine` picks the most math-looking one (locally
   solvable > has `=` > closest to center), and a blue box highlights it (7.4).
2. If the local solver handles it and the **same problem is read in 2 consecutive frames**, the answer sheet opens by
   itself with no photo taken. Dismissing it doesn't reopen the same problem for 3 s.
3. **Shutter** (or gallery): full-res photo → OCR → local solver; if unsupported → cloud with the OCR text + photo
   (word problems with no single math line send all the text).
4. Sheet (7.4): type · step count · problem as read · green Answer card · numbered steps. Spinner while the cloud works;
   a friendly error when offline, timed out or not configured. A cloud badge marks online answers.

### On-device solver (`lib/src/math/solver.dart`, pure Dart)
- [x] Tokenizer + recursive-descent parser: numbers, decimals, one variable, `+ − × ÷ ^`, parentheses, implicit multiplication (`2x`, `2(x+1)`, `(x+1)(x−1)`).
- [x] OCR normalization: unicode operators, `²` `³`, `×` read for the variable x ("2× + 5"), `O`/`l` glued to digits.
- [x] Exact rational arithmetic (`BigInt`): `0.1 + 0.2 = 3/10`, `x = 3/5 ≈ 0.6`.
- [x] Arithmetic with one step per operation in order of operations; linear equations (Figma wording: "Subtract 5 from both sides → 2x = 15 − 5 → Simplify → Divide both sides by 2"), no-solution / every-x cases; quadratics (discriminant, rational / irrational / complex / repeated roots); expression simplification.
- [ ] 2×2 linear systems: **not built**. They go to the cloud. Add locally if usage shows it matters.
- Unit tests: `test/math_solver_test.dart` (Figma example in exactly 3 steps, linear, quadratic, arithmetic, OCR look-alikes, cloud-routing cases, line picking).

### Cloud path (`lib/src/math/cloud.dart`)
- [x] Client: enabled by `--dart-define=MATH_API_URL=https://…`, 10 s connect / 15 s response timeout, in-memory cache by normalized text, response validated before use.
- [ ] **Backend** (open: Cloudflare Worker / Firebase / your own). It holds the Claude API key and must implement:

```
POST {MATH_API_URL}/solve
Content-Type: application/json
{ "text": "<OCR text>", "image": "<base64 JPEG, long side ≤ 1280, optional>" }

200 → { "type": "Linear equation",
        "answer": "x = 5",
        "steps": [ { "title": "Subtract 5 from both sides", "expr": "2x = 15 − 5" }, … ] }
non-200 → the app shows "The online solver had a problem (code)".
```
  The backend should call Claude (current Sonnet model) with the image + text, force this JSON shape (tool use /
  structured output), validate it, and apply auth + rate limits + a cost cap.

### Tests
- Widget (`test/scanner_screen_test.dart`): a problem seen twice → sheet with "Linear equation · 3 steps · x = 5" and no photo taken; an unsupported problem waits for the shutter.
- On device (Pixel 6): a printed `2x + 5 = 15` on ruled paper → ML Kit read it exactly → `x = 5`, **175 ms** OCR + solve.

### Acceptance
- [x] Local: 100% of the unit-test problem set; answer shown < 300 ms after the problem is read.
- [ ] Real samples: 20 printed textbook problems + 10 handwritten (ML Kit Latin OCR is weak on handwriting, fractions and exponents; those should fall through to the cloud).
- [ ] Cloud: correct on a 30-problem mixed set; p90 latency < 6 s (needs the backend).
- [x] The router never sends a problem the local solver can handle to the cloud (by construction: cloud is only called when `solveLocally` returns null).

---

## Phase 4: Object counter 🟡

**Figma:** `docs/figma/7.5 Object Counter.png`. This is the least off-the-shelf feature, so the goal is
**auto-count + easy manual correction**.

### Status (2026-09-29)
Built and tested (unit, widget, on-device Pixel 6). Real-object acceptance pending.

### Design change from the plan
The plan had separate native counters (OpenCV on Android, Vision contours on iOS). Built instead as **one pure-Dart
algorithm** (`lib/src/count/counter.dart`) on a 640 px copy of the photo in a background isolate. That means identical results on
both platforms, no iOS work, and plain unit tests with synthetic scenes. The camera tab just captures; `count` is a
no-op mode natively.

### Algorithm
1. Reference colour: median Lab of the image border (the background), or the colour under a tapped sample (Custom).
2. Lab distance (lightness weighted 0.6 so soft shadows stay background) → Otsu → mask. Holes are filled (shiny
   highlights) and a 3×3 open removes specks. If the two Otsu classes barely separate (< 5), there is nothing to count:
   an empty table measures ~1.7, faint grey-on-white objects ~8.6, typical scenes 50+.
3. Blobs: the typical object area is the median blob (or the tapped one). < 0.4× is dropped; ~k× is k touching objects,
   split by k-means so each gets a marker. Blobs over 25% of the frame are dropped (background).
4. Shape per kind: **Round** fills > 50% of its bounding circle with aspect ≤ 1.8; **Boxes** fills > 45% of its bounding box;
   **Custom** has no shape filter (colour decides).
5. Markers are numbered in reading order (rows, then left to right).

### UI (`lib/src/count/count_screen.dart`)
- [x] Count tab → shutter or gallery → result screen: photo with numbered green markers · "Objects detected" + big count · −/+ stepper · Round / Boxes / Custom chips · Retake · Save Result.
- [x] Tap a marker to remove it; tap empty space to add one. −/+ adjust the count without a marker (− removes the last marker once those are used up).
- [x] Custom: "Tap one object to count ones like it" → recount by that colour and size.
- [x] Save Result burns the markers + an "N objects" badge into a ~2000 px image → added to the scan as a page labelled "Count: N" (Original filter) → exportable as PDF.
- [ ] Save to the phone's photo gallery. Not built (it needs a new plugin); share via PDF export for now.

### Tests
- Unit (`test/counter_test.dart`): 23 Figma-style buttons with highlights · touching objects split · markers on the objects in reading order · boxes vs sticks · Custom colour match · faint objects on white · empty table = 0 · speed.
- Widget (`test/count_screen_test.dart`): real decode + isolate + UI, stepper, Custom prompt, kind switch. It caught a real crash: the isolate closure captured the widget State (fixed with a top-level `countInBackground`).
- On device (Pixel 6): 23 buttons with shadows + highlights → **23**, 558 ms for the full pipeline in a *debug* build.

### Acceptance
- [ ] ≥ 95% count accuracy on real separated objects (coins, pills, bolts, 5–100 items); report measured accuracy here.
- [ ] Known limits to check: objects touching the frame edge (they skew the background estimate), busy or patterned backgrounds (use Custom), heavy overlap.
- Backlog: a class-agnostic counting ML model if the heuristics fall short on real samples.

---

## Phase 5: AR area measurement 🟡

**Figma:** `docs/figma/7.6 Area Measurement.png`. This is a separate AR session and does not use the camera engine. The Measure tab swaps engines: it stops CameraX, then starts AR. Leaving the tab stops AR (which frees the camera synchronously), then restarts CameraX. A swap that happens during a start is caught up when the start finishes.

### Design changes from the plan
- **Android renders ARCore itself, not SceneView.** `ArMeasure.kt` draws the camera into a Flutter `SurfaceProducer` texture with its own EGL context and a 20-line OES shader. This is the same texture path as the scanner, with no Filament/SceneView dependency and no `AndroidView` (SurfaceView-in-platform-view) quirks. The texture is rendered at the viewport's aspect (1080 px wide), so Dart shows it 1:1 with no cover math.
- **Native streams world points plus the view-projection matrix, not screen positions.** Dart does the projection (`lib/src/measure/geometry.dart`), so projection, lengths and area are in one tested place for both platforms.
- **iOS uses an `ARSCNView` `UiKitView`**, with `ARCoachingOverlayView`, mesh reconstruction on LiDAR devices, and raycasts against existing plane geometry, then estimated planes. Written, not built (iOS testing is deferred).

### Channel contract (additions)
| Method | Args | Returns |
|---|---|---|
| `arStart` | `{aspect}` | `{textureId}` (null on iOS). Errors: `PERMISSION_DENIED`, `AR_UNSUPPORTED`, `AR_INSTALL` (Play Store opened for Google Play Services for AR), `AR_FAILED` |
| `arAdd` | – | `bool`: anchors a point at the current center hit (false = reticle not on a surface) |
| `arMove` | `{index, at}` | – once the anchor at `index` is replaced by one at `at` (corner drag) |
| `arUndo` / `arClear` | – | – (detach last / all anchors) |
| `arTorch` | `{on}` | – (ARCore `Config.FlashMode.TORCH`; iOS torch on the AR camera) |
| `arStop` | – | – (pause + close session, release texture) |

Event channel `flutter_doc_scanner/ar`, one event per camera frame (30 fps): `{tracking, reason, hit?: [x,y,z], points: [x,y,z,…], vp: [16, column-major]}`. Anchors are re-read each frame, so points follow ARCore/ARKit's map refinements.

### Hit test (Android)
`frame.hitTest(center)` takes the first hit that is on a tracked plane inside its polygon, a depth point, or a feature point with an estimated surface normal. Depth mode `AUTOMATIC` is enabled when supported (Pixel 6: yes), so the reticle lands on plain floors before a plane is found.

### Surface lock (walls and hanging objects)
User report: floors worked, walls and hanging objects didn't. Cause: painted walls have little texture, so ARCore rarely detects a wall plane and depth hits are sparse and noisy. The reticle dropped out, and corners landed centimetres in front of or behind the wall.

Fix (the approach Apple / Google Measure use), in `MeasureController`:
- The first point locks the plane: the hit position plus the hit's surface normal, sent natively as `normal` (+Y of the hit pose) and `kind` (`plane` = exact, `depth` = estimated).
- Every later point, and the live tape, is **where the center ray meets that plane** (`aimOnPlane`). Corners stay coplanar, and blank wall areas with no hits still work.
- A depth-estimated lock upgrades to a detected plane when one matches it (< 20° apart, within 5 cm).
- The lock is refused edge-on (< ~8° grazing), behind the camera, or beyond 15 m. The hint then says "Aim back at the same surface".
- The lock resets on a new shape, when the last point is undone, or when the session stops.
- `arAdd {at}` anchors exactly the point Dart shows, so what you see is what you get.

Limit: an object hanging in free air (no wall or detected plane behind it) starts from a depth-estimated normal. Pick its most frontal, textured corner first.

### Point stability (user report: points sometimes sit off the exact spot)
- **Anchors attach to surfaces again (Android).** The surface lock had made every point a free world anchor (`session.createAnchor`), which drifts when ARCore corrects its map. `anchorAt` now attaches to the plane the first point was placed on (following merges via `subsumedBy`), or to the trackable hit within 3 cm. It falls back to a world anchor only when there's no surface. ARKit adjusts its own anchors, so iOS is unchanged.
- **The lock follows the map.** The lock plane passes through the first point's *live* anchor, not a frozen coordinate, so later points still land on the real wall after a map correction.
- **Steady-hit averaging.** While the aim holds still (hits within 3 cm), the unlocked target is the mean of the last 6 hits. This removes most of the 1–2 cm depth jitter on the first point.
- Known and not fixed: during fast phone motion the Flutter overlay can trail the camera image by up to one frame (~16 ms), then settles when the motion stops. The only full fix is drawing points natively in the GL pass. Do that if it's noticeable in practice.

### Corner drag (user request)
- Press a corner (within 36 px) and drag it. It slides along the surface: the lock plane, else the shape's own best-fit plane (`fitPlane`). Its position is where the finger's ray meets that plane (`aimOnPlane(at:)`). The grab offset is kept, so the corner doesn't jump under the finger.
- Sides, area and the screen-reader summary update live. A 2.2× loupe sits in the top corner away from the finger. The dragged corner is drawn larger.
- On release, `arMove {index, at}` replaces that anchor natively. The live position stays on screen until a frame with the new pose arrives, so nothing snaps back.
- Swipe-to-change-tabs is off on Measure only (drags would fight it); tapping a tab still works. The hint on a closed shape reads "Drag a corner to adjust".

### UI (Figma 7.6)
- Reticle at the center, dimmed when off-surface. The guidance pill sits just above it:
  - Starting AR…
  - Move your phone slowly / more slowly
  - Too dark · Turn on the flash
  - Point at a surface with more detail
  - Point the circle at a surface
  - Tap + to drop points
  - Tap + to add the next corner
  - Tap the first point to close the shape
- Dashed white edges, white-and-blue points, dark length pills pushed outside the shape, blue-grey fill, and a white "Area" card at the centroid.
- A live dashed "tape" runs from the last point to the reticle, with its length.
- Controls:
  - **Undo:** reopens a closed shape; otherwise removes the last point.
  - **+:** disabled off-surface. It drops a point, closes the shape when the reticle is on the first point, and starts a new shape after a closed one.
  - **m / ft:** toggles cm·m·m² / in·ft·ft².
  - **Tap the first point:** closes the shape.
- The overlay has a live-region semantics summary ("Area 6.84 m². Sides 3.1 m, …") for screen readers, which the tests also use.

### Geometry (`lib/src/measure/geometry.dart`)
- Edge lengths are 3D distances.
- Area is Newell's vector area (|Σ pᵢ × pᵢ₊₁| / 2): the shoelace formula on the best-fit plane, so out-of-plane jitter doesn't inflate it.
- The projection is clip → NDC → normalized screen, and returns null behind the camera.

### Tests
- Unit (`test/measure_geometry_test.dart`):
  - 2×3 m rectangle on a tilted, shifted plane = 6.000
  - concave L-shape, both windings
  - ±1 cm jitter stays within 0.5%
  - projection center, edge and behind-camera cases
  - formatting
  - `aimOnPlane`: head-on wall, 45° side wall, off-center point projects back exactly, edge-on and behind → null
  - `fitPlane`: tilted square centroid + normal, collinear → null
- Widget (`test/measure_screen_test.dart`), against a fake AR engine:
  - engine swap in both directions
  - every guidance state
  - + disabled off-surface
  - add, then close by tapping the first point → "Area 1.00 m²"
  - ft → "10.8 ft²"
  - undo reopens the shape
  - AR-unsupported message
  - drag a corner: grabbed off-center, dragged 0.5 m → live "Area 1.25 m²", loupe shown, `arMove` at the exact point, loupe gone
  - map correction: anchors shift 4 cm → the next point follows the live first anchor
  - jittery first hit (±12 mm) → placed at the 6-frame mean
  - walls: a noisy depth hit starts the shape; a blank wall (no hits) still takes points on the locked plane; edge-on aim refuses with "Aim back at the same surface"
- On device (Pixel 6, `example/integration_test/ar_measure_test.dart`):
  - frames stream at camera rate (~30 fps, measured with a temporary native fps log in the real app; the test harness itself pumps slower)
  - tracking reached, center hits on real surfaces
  - the scanner camera restarts cleanly after AR
  - the preview renders a real image (checked numerically: center-crop mean 178, stddev 72)
  - native add / undo verified in the real app (anchors 1→2→3→2)

### Acceptance
- [ ] Within ±5% of tape-measured values on a 2×3 m floor area (Android, Pixel 6). Report the numbers here.
- [ ] Wall area and a hanging object (frame / TV) within ±5%, after the surface lock fix.
- [ ] Within ±3% on a LiDAR iPhone (with the iOS pass at the end).
- Not built: saving a measurement to the scan pages (not in Figma; add like Count's Save Result if wanted).

---

## Phase 6: Scanner as a module ✅

The app's scanner grew to eight modes. To keep a big host app clean, the whole feature now lives in this plugin.

- **Layout.**
  - `lib/src/engine.dart`: the channel API.
  - `lib/src/{scanner,count,math,measure,export}/`: the UI and pure-Dart logic.
  - `lib/flutter_doc_scanner.dart`: exports the public surface only.
  - `example/`: a minimal host app plus the on-device integration tests.
  - `docs/`: this file and `docs/figma/`.
  - `CLAUDE.md`: the agent guide.
- **Host contract.** `Scanner.open(context, tab:)` returns `Future<ScanResult?>`:
  - `pages`: `ScanPage` with original, crop, filter, label, group and preview.
  - `title`: the name typed on the review screen.
  - `pdf`: set if the user exported one and didn't edit afterwards.
  - `toPdf(name)`: full-quality export.
  - It returns `null` when the user closes the scanner.
  - `ScannerTab` picks the starting mode. Measure starts after the first layout, because AR needs the viewport aspect.
- **Behaviour change.** Review → **Done** is always available and returns the pages. Previously it only appeared after an export, because the scanner was the whole app.
- **The host app keeps only** a dependency on this package, a portrait lock, permission strings and a call to `Scanner.open`. Transitive plugins (image_picker, share_plus, url_launcher, path_provider) register automatically.
- **Tests.**
  - 53 unit and widget tests in `test/`, including `scanner_api_test.dart` for the host contract (Done returns pages, Close returns null, `tab` picks the mode).
  - 12 on-device tests in `example/integration_test/`, all passing on the Pixel 6.
  - The host app and the example both build.

---

## Phase 7: iOS pass ⬜

Deferred to the end by decision. iOS code exists for every phase but has never been built.
- [ ] `cd example && flutter build ios`: fix compile errors (Swift: `SwiftFlutterDocScannerPlugin.swift`, `DocVision.swift`, `ArMeasureView.swift`).
- [ ] Run `example/integration_test` on an iPhone; add iOS branches where Android-specific numbers differ.
- [ ] Walk every tab on device against `docs/figma/`, and each phase's acceptance list (LiDAR ±3% for Measure).
- [ ] Check the host Info.plist keys (README).

---

## Backlog (not scheduled)
- Cleanup brush (erase stains / fingers) in the editor.
- OCR text layer in exported PDFs (searchable PDFs).
- Book page dewarp.
- Batch mode: continuous auto-capture of many pages without stopping.
