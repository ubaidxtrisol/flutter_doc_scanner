# Scanner Phases

Tracker for the scanner module (this package): the camera + detection engine and the Figma scanner screens in
`docs/figma/`. Paths below are relative to the package root. Update the status markers and checkboxes as work lands.

**Status legend:** ✅ Complete · 🟡 Current · ⬜ Todo

| Phase | Scope | Figma | Status |
|---|---|---|---|
| 0 | Planning & decisions | — | ✅ Complete |
| 1 | Camera engine + Document scanner (edge detect, auto-capture, crop, multi-page, PDF) | 3.1, 3.2 | 🟡 Current: built, acceptance pending |
| 2 | QR, ID Card, Passport (MRZ), Book | 7.1, 7.2, 7.3 | 🟡 Current: built, acceptance pending |
| 3 | Math scanner (AI only) | 7.4 | 🟡 Current: AI (host hook → OpenAI gpt-5-mini) built; real-sample acceptance pending |
| 4 | Object counter | 7.5 | 🟡 Current: built, real-object acceptance pending |
| 5 | AR area measurement | 7.6 | 🟡 Current: Android built, real-floor acceptance pending |
| 6 | Scanner as a self-contained module (plugin) | — | ✅ Complete |
| 6b | Figma UI match (3.1–3.5, 7.1, 9.1–9.4) + `recognizeText` OCR channel | 3.x, 7.1, 9.x | 🟡 Current: built, device check pending |
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
| Math (Ph 3) | **AI only** (2026-10-01, user decision; was hybrid): every problem goes to an AI model through the host's `Scanner.onlineMath` hook (the module holds no keys) | One consistent answer style (LaTeX steps) for every problem, handwriting included. Costs a network call per problem; the local solver it replaced was instant and offline. |
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
| `process` | `{path, outPath, corners?, rotation, filter, maxSize?, brightness?, contrast?}` | `{path, width, height}`: one pass of perspective crop → rotate (0/90/180/270) → filter → brightness/contrast → JPEG. `maxSize` caps the long side (fast decode path for thumbnails and previews). `filter`: `original, magic, bw, gray, noShadow, color`. `brightness`/`contrast` are -1..1 (0 = unchanged): `out = (in − 128)·(1 + contrast) + 128 + 100·brightness` |
| `recognizeText` | `{path, script}` | `[{text, box:[l,t,r,b], lines:[{text, box}]}]`: full OCR of any image file, boxes normalized 0..1 in the upright image, run off the main thread. `script`: `latin` (default), `chinese`, `devanagari`, `japanese`, `korean`. Errors: `UNSUPPORTED_SCRIPT` (unknown script; iOS: Devanagari, or Japanese/Korean before iOS 16), `MODEL_UNAVAILABLE` (Android: that script's model is still downloading from Play Services; retry), `FAILED` |
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
Tokens in `lib/src/scanner/ui.dart` are the exact Figma variables (see Phase 6b): `Tone` for the camera, `Palette` (light + dark) for the other screens.
- [x] **Camera** (`scanner_screen.dart`, Figma 3.1/3.2): top bar (close, torch, grid, AUTO, settings no-op) · cover-fit preview · dashed guide / blue quad with handles · status pills · swipeable combined tabs (swipe the preview too) · gallery / shutter with steady-progress ring / page stack with badge · white flash + haptic on capture · permission-denied screen with Open Settings · confirm before discarding pages.
- [x] **Auto-capture** via `QuadTracker` (steady ~0.7 s, armed flag). The live quad is the fallback when photo re-detection fails.
- [x] **Pages** (`pages_screen.dart`, restyled to Figma 3.5 in Phase 6b): grid · long-press drag reorder · rotate / delete per page · Select mode · Add page (Camera or Photos) · Save as PDF.
- [x] **Editor** (`editor_screen.dart`, `crop_editor.dart`, restyled to Figma 3.3 / 3.4 in Phase 6b): Crop (corner + edge handles, convexity guard, **loupe** opposite the finger, Auto / Full page / Perspective preview, Rotate, Retake) → Enhance (swipe pages, pinch zoom, rotate, filters with live thumbnails, brightness / contrast, Apply to all).
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
- [x] Detailed fields per kind (`QrPayload.fields`, 9 tests in `test/qr_payload_test.dart`): URL full link · Wi-Fi network,
  security (WPA/WPA2, WPA3/SAE, WEP, open), hidden flag, EAP method/identity · vCard 2.1–4.0 (folded lines, escapes,
  `item1.` groups, `N` fallback) and MECARD (repeated keys, `Last,First`) → name, organization, job title, phones,
  emails, websites, addresses, note · mailto (subject/body) / MATMSG / bare address · `SMSTO:`/`MMSTO:`/`sms:?body=` ·
  `geo:` (coordinates, altitude, `q=` place; `0,0?q=` = address search; out-of-range → text) · tel. Malformed `%`
  escapes never throw. Save title `QR · <display>` ≤ 40 characters (never the password, never cuts an emoji).
- [x] Sheet (`result_sheets.dart`, `test/qr_sheet_test.dart`): header, the code **re-generated** from the raw value
  (`qr` package, byte mode UTF-8, ECC M, or L when too long for M; modules snapped to device pixels), a label/value
  table (selectable), full selectable text for Text codes. Content scrolls inside 60% of the screen; actions stay
  pinned: Copy · Share (text + the code as a PNG) · kind action · **Save to Documents**.
- [x] Wi-Fi password hidden (dots) until the eye is tapped; never in the title or header.
- [x] Save to Documents renders an A4 card (`QrCard` via `renderCard`): "QR Code · <kind>", the code (200 pt), up to 8
  field rows (the password included: the user chose to save), the raw content clipped with "…" to the space left,
  and the date + "Scanned with DocScan". It joins the scan as a page (see "Result cards join the scan" below).
- [x] Errors: empty / binary-only payload → "This code is empty" / "Couldn't read this code" + Scan Again; too long to
  re-encode → info banner and a text-only card; a failed save, share or launch shows a message in the sheet (a snack
  bar would sit behind it); geo: falls back to a Google Maps web link when no app takes `geo:` (iOS).
- [x] Gallery: decode a code from a photo; it opens the same sheet with the same Save.

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
- Unit: `test/mrz_test.dart`, `test/qr_payload_test.dart`, `test/qr_sheet_test.dart` (fields, generated code, password toggle, Save → PNG page, text-only card, unreadable code, failed save), `test/book_test.dart`, plus `test/scanner_screen_test.dart` (fake native engine: every mode's chrome and hint, QR sheet, passport 2-read → capture → verified sheet). This test caught and fixed two overflows (pills and the Front/Back switch at large text) and a scan-line ticker that burned frames in every mode.
- On device (`example/integration_test/scanner_vision_test.dart`, Pixel 6): card found / A4 rejected in ID mode ✓ · QR decoded in 127 ms ✓ · rendered MRZ OCR'd + verified in 253 ms ✓ · book fold within 2% ✓.

### Acceptance
- [ ] QR / ID / Passport each pass on 10 real samples. Passport: 0 wrong fields (check digits guarantee this) and ≥ 90% read within 2 s.
- [ ] Switching between any two modes < 100 ms (no camera restart by design; measure it).
- [ ] Book: fold found on 10 real books (thick bindings, thin bindings, no visible shadow → center).

---

## Phase 3: Math scanner (hybrid) 🟡

**Figma:** `docs/figma/7.4 Math Scanner.png`

### Status (2026-10-01)
**AI only** (changed 2026-10-01 at the user's request; the on-device solver is no longer called). Every problem goes
to the **host's AI hook** (`Scanner.onlineMath`). The DocScan app wires it to OpenAI (`lib/features/scan/math_ai.dart` in the host), so the module
holds no keys and no backend is needed. Without the hook, the pill and the sheet say AI solving isn't set up, and
nothing is sent anywhere. iOS parity is written, untested (deferred).

### Flow (as built)
1. **No live detection** (2026-10-01, user request): the camera runs no analyzer in Math (`math` live frames are
   skipped natively on Android and iOS), nothing is highlighted, and the pill reads "Point at a math problem, then
   tap the shutter" ("Solving math needs AI, which isn't set up" without the hook; the shutter then only toasts and
   takes no photo).
2. **Shutter** (or gallery): full-res photo → the sheet opens at once with the loader → photo downscaled to ≤ 1280 px
   (the original is sent if that fails) → AI. No OCR runs and no text is sent; the AI reads the problem from the photo,
   so handwriting works the same as print.
3. Sheet (`math_sheet.dart`, 7.4): type · step count · "Solved with AI" badge · problem · green Answer card · numbered
   steps (title + math). AI answers are LaTeX rendered with `flutter_math_fork` (a step whose LaTeX doesn't parse
   falls back to its plain text; wide math scrolls sideways). A solution without LaTeX shows plain text in the same styles.
   While the AI works: "Solving with AI…" with a pulsing sparkle and shimmer lines. Errors show the message + Retry
   (Retry re-runs the solve; hidden when there's no hook).
4. **Copy** puts the plain-text solution on the clipboard. **Save to Documents** renders A4 cards (`renderCard`):
   "Math solution" header, the photo, problem, answer, every step with LaTeX, footer with the time and page number.
   Steps are split across pages (4 next to the photo, 6 without, then 9 per page; a page that still overflows is
   scaled to fit). All pages go to the scanner's `_savePages` titled "Math · <answer>" (≤ 40 chars) and join the
   scan, so several problems become one PDF (see "Result cards join the scan" below).

### Result cards join the scan (2026-10-01, user request)
Math, QR, Area and Count cards no longer end the scan. `_savePages` (`scanner_screen.dart`) adds the card's pages to
the session (Original filter, `ScanPage.result` = its title), then `showAddedSheet` (`result_sheets.dart`) asks:
**Solve another problem / Scan another code / Measure another area / Count more objects** (default, and what
dismissing means: stay on the camera), **Review** (the pages screen), or **Save PDF** (finish). "Scan another code"
doesn't reopen the code just saved while it's in view; "Measure another area" clears the AR shape. No QR / MRZ sheet
opens over the prompt. The document title comes from `scanTitle`: one card keeps its own title ("Math · x = 5"),
several of one kind get "Math solutions" / "QR codes" / "Area measurements" / "Count results", anything else (photos
or mixed kinds) gets the dated default. The host's Scan Complete screen words these as "Math solutions saved!" etc.
Tests: `test/scanner_screen_test.dart` (two QR cards → "Scan another code", same code not reopened, "2 pages so far",
Save PDF → 2 pages titled "QR codes"), `test/measure_screen_test.dart` (prompt, then Save PDF → "Area · 1.00 m²").

### On-device solver (`lib/src/math/solver.dart`, pure Dart): **retired 2026-10-01**, code kept but not called
- [x] Tokenizer + recursive-descent parser: numbers, decimals, one variable, `+ − × ÷ ^`, parentheses, implicit multiplication (`2x`, `2(x+1)`, `(x+1)(x−1)`).
- [x] OCR normalization: unicode operators, `²` `³`, `×` read for the variable x ("2× + 5"), `O`/`l` glued to digits.
- [x] Exact rational arithmetic (`BigInt`): `0.1 + 0.2 = 3/10`, `x = 3/5 ≈ 0.6`.
- [x] Arithmetic with one step per operation in order of operations; linear equations (Figma wording: "Subtract 5 from both sides → 2x = 15 − 5 → Simplify → Divide both sides by 2"), no-solution / every-x cases; quadratics (discriminant, rational / irrational / complex / repeated roots); expression simplification.
- [ ] 2×2 linear systems: **not built**. They go to the AI. Add locally if usage shows it matters.
- Unit tests: `test/math_solver_test.dart` (Figma example in exactly 3 steps, linear, quadratic, arithmetic, OCR look-alikes, cloud-routing cases, line picking).

### AI path (`lib/src/math/cloud.dart` → host hook)
- [x] Module: `solveInCloud` downsizes the photo to ≤ 1280 px (JPEG), calls `Scanner.onlineMath('', image)` (no OCR text, no
  cache: every photo is its own problem), and turns any failure into a `CloudMathException` with the host's
  user-facing message. `MathStep.tex` / `MathSolution.answerTex` / `problemTex` carry LaTeX.
- [x] Host (`lib/features/scan/math_ai.dart`): `OpenAi.json` with strict structured output
  `{solvable, reason, type, problem_latex, problem_text, answer_latex, answer_text, steps: [{title, latex, text}]}`.
  The prompt asks it to trust the photo over garbled OCR, verify the answer before writing it, use 3–10 steps, emit
  KaTeX-compatible LaTeX without `$` delimiters, and answer in the problem's language. `solvable: false` (not math,
  unreadable) shows the model's one-line reason instead of an answer. Stray `$…$` / `\[…\]` delimiters are stripped,
  empty steps dropped, and a reply without an answer or steps is an error. Model: `--dart-define=OPENAI_MATH_MODEL`,
  default `gpt-5-mini` (reasoning `low`, 12k token cap, 60 s timeout). Registered in the host's `main.dart` when
  `OPEN_AI_KEY` is set.
- Model choice, **measured 2026-10-01** (Mac → OpenAI over Wi-Fi, not on the phone): 6 problems rendered as ruled-paper
  photos (1280 × 560 JPEG) + deliberately garbled OCR text (exponents flattened, "J" for ∫), 2 runs each. The problems
  were a quadratic `2x² + 3x − 2 = 0`, a 2×2 system, `∫₀² (3x² + 2x) dx`, `d/dx (x² · sin x)`, `(x² − 9)/(x² + 5x + 6)`
  and a ticket word problem.

  | Model | Correct | Median | p90 | Max | LaTeX that failed to parse |
  |---|---|---|---|---|---|
  | `gpt-4.1-mini` (temperature 0) | **8 / 12** | 4.6 s | 6.6 s | 9.0 s | 0 |
  | `gpt-5-mini` (reasoning `low`) | **12 / 12** | 5.3 s | 5.9 s | 6.1 s | 1 (a `$` inside `\text{}`; fell back to plain text, prompt now asks for `\$`) |

  gpt-4.1-mini's misses repeated in both runs. On the quadratic it left an unfinished formula as the "answer". On the
  integral it trusted the OCR `3x2` over the photo and answered 20/3. Accuracy wins, so the default is gpt-5-mini
  (~0.7 s slower at the median).
- Live smoke (host `solveMathWithAi`, gpt-5-mini, system photo + OCR text): `x = 3, y = 2`, 5 steps, 6.6 s.
- Photo only, no OCR text (2026-10-01, gpt-5-mini, Mac → OpenAI): quadratic `x = 1/2, x = −2` 6.7 s, integral `12`
  5.4 s, system `x = 3, y = 2` 4.2 s, word problem `a = 20` 4.9 s: 4 / 4 correct.

### Tests
- Widget (`test/scanner_screen_test.dart`): live text events are ignored (nothing found, AI not called); the shutter
  sends just the photo to the hook (no `analyze` call) and the sheet shows its answer with the AI badge; without the
  hook the pill says AI isn't set up and the shutter takes no photo.
- Bug fixed on the way (seen in the Pixel's log): `pickMathLine` called the old parser, which threw
  `FormatException: Could not parse BigInt` on some OCR text, so the shutter silently did nothing. Math no longer
  calls it.
- Widget (`test/math_sheet_test.dart`): on-device answer as plain text + Copy; AI answer with LaTeX (5 `Math` widgets),
  bad LaTeX → its text, a 22-term line doesn't overflow; loading → error → Retry → answer; no Retry without the hook;
  Save renders 2 A4 pages (1488 × 2105 px) for 12 steps + photo, named "Math · x = 1/2, x = −2"; page split and title
  rules.
- Host (`test/math_ai_test.dart`): JSON → `MathSolution` mapping, delimiter stripping, `solvable: false` reason,
  empty answer / steps rejected.
- On device (Pixel 6): a printed `2x + 5 = 15` on ruled paper → ML Kit read it exactly → `x = 5`, **175 ms** OCR + solve.
  The AI path has not been run on the phone yet.

### Acceptance
- [x] Local: 100% of the unit-test problem set; answer shown < 300 ms after the problem is read.
- [ ] Real samples: 20 printed textbook problems + 10 handwritten (ML Kit Latin OCR is weak on handwriting, fractions and exponents; those should fall through to the AI).
- [ ] AI: correct on a 30-problem mixed set; p90 latency < 6 s. So far: 12 / 12 on the 6-problem rendered set, p90 5.9 s from a Mac; needs the full set on the phone.
- [x] The router never sends a problem the local solver can handle to the AI (by construction: the AI is only called when `solveLocally` returns null).

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
- [x] Save Result renders an **A4 card** (`renderCard` + `PhotoCard`, `lib/src/scanner/card_render.dart`): "Object count", the photo (upright, ≤ 1600 px) with the numbered markers burned in, then "23 objects", the kind (Round objects / Boxes / Custom, "matched to a tapped sample"), the automatic count, what was changed by hand ("2 added · 1 removed": markers vs the automatic set, plus stepper adds), and a footer with the date + "Counted with DocScan". It pops a page labelled "Count: N" (Original filter); the scanner adds it to the scan and asks to count more or save (see "Result cards join the scan").
- [x] Save errors: busy spinner on the button (double taps ignored); a failed render shows "Couldn't save the result. Try again." and leaves the screen as it was; closing the screen mid-render doesn't pop the scanner underneath.
- [ ] Save to the phone's photo gallery. Not built (it needs a new plugin); the card goes to Documents and can be shared from there.

### Tests
- Unit (`test/counter_test.dart`): 23 Figma-style buttons with highlights · touching objects split · markers on the objects in reading order · boxes vs sticks · Custom colour match · faint objects on white · empty table = 0 · speed.
- Widget (`test/count_screen_test.dart`): real decode + isolate + UI, stepper, Custom prompt, kind switch; Save Result → one marker removed → pops a "Count: 9" page whose card PNG exists, and the temp copy is deleted. It caught a real crash: the isolate closure captured the widget State (fixed with a top-level `countInBackground`).
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
| `arSnapshot` | – | `{path, points, vp}`: JPEG (q 90, cache `scans/`) of exactly what the AR view shows (camera only, viewport aspect) plus the points and view-projection matrix **of that same frame**, so Dart's overlay matches the photo exactly (the event stream can be a frame off). Android: `glReadPixels` of the next drawn frame before swap, flipped + encoded off the GL thread. iOS: `ARSCNView.snapshot()` + `currentFrame`. Errors: `AR_NOT_RUNNING`, `AR_SNAPSHOT`; Dart adds `AR_TIMEOUT` (no frame in 5 s) |

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
- **Save measurement** (not in Figma; styled like the area card): a white pill that pops in above the bottom bar once a closed shape has an area (hidden while dragging a corner). It shows "Saving…" with a spinner while exporting and ignores more taps. `MeasureController.exportCard` takes `arSnapshot`, paints the shape on it with `MeasurePainter` in still mode (same dashed edges, points, length pills and area card, plus point names A, B, C…; no reticle or tape) at the live overlay's scale, crops to a square-ish band around the shape, and renders an A4 card: "Area measurement", the photo, the area in the current unit with the other unit small, perimeter, every side ("A–B 3.1 m · B–C 2.4 m …"), the point count, and a footer with the date + "Measured with DocScan AR · approx. ±5%". Title `Area · 6.84 m²`, page label "Area". A failed snapshot shows its message as a toast.
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
  - save: no Save before the shape closes; close → "Save measurement" appears; tap → busy, a second tap doesn't snapshot again; the scanner returns one page (label "Area", Original filter) whose 1488 × 2105 card PNG exists, title "Area · 1.00 m²", and the snapshot JPEG is deleted
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
- [x] Save a measurement to Documents as a card page (built and widget-tested; the `arSnapshot` GL readback is not verified on a device yet).

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
  Phase 6b: Done became **Save as PDF** (Figma 3.5), and Save Book (9.2) / Save PDF (9.3, 9.4) return the same way. The review no longer exports or shares itself, so `ScanResult.pdf` is null from the review; the host builds the PDF with `toPdf` and shows its own "Scan saved!" (3.6).
- **The host app keeps only** a dependency on this package, a portrait lock, permission strings and a call to `Scanner.open`. Transitive plugins (image_picker, share_plus, url_launcher, path_provider) register automatically.
- **Tests.**
  - 53 unit and widget tests in `test/`, including `scanner_api_test.dart` for the host contract (Done returns pages, Close returns null, `tab` picks the mode). (62 after Phase 6b.)
  - 12 on-device tests in `example/integration_test/`, all passing on the Pixel 6.
  - The host app and the example both build.

---

## Phase 6b: Figma UI match + OCR channel 🟡

**Figma** (file `pSGWv3vGBBC3nkIcu0rknu`): 3.1 `22:1177` / `94:6306`, 3.2 `22:1237`, 3.3 `94:5726`, 3.4 `94:5794`, 3.5 `94:5943`,
7.1 `22:3195`, 9.1 `22:4114`, 9.2 `22:4204`, 9.3 `22:4281`, 9.4 `22:4371`.

### Status (2026-09-30)
Built and covered by widget tests; every screen was rendered at 393×852 with Inter + Iconsax and compared with the Figma
frames. Android debug APK builds. iOS Swift type-checks against the iOS 15 SDK (Catalyst, with Flutter stubs; ARKit file
excluded). **Not yet run on a device.**

### Design system
- [x] `ui.dart`: exact tokens copied from the host (`Tone` camera colours, `Palette` light + dark picked from the ambient
  `Theme` brightness, Figma text styles without a font family so Inter comes from the host, `Shadows`, squircles at 60%
  smoothing via `figma_squircle`). Icons are Iconsax (`iconsax_plus`); Figma "rotate-left/right" = `rotate_left_1` /
  `rotate_right_1`, "close" = `add` turned 45°.
- [x] Shared pieces: `LightScreen` (52 pt nav bar + bottom actions as the bottom bar, so toasts float above buttons),
  `ScanButton` (54 pt, r16; primary / secondary / tonal / danger), `SquareButton`, `NavCircle`, `NavText`, `InfoBanner`,
  `Segmented` (sliding), `ScanToggle`, `ImageChip`, `Appear` (staggered fade + rise), `Pressable` (0.97 press scale).
- Pitfall found by the renders: `AnimatedDefaultTextStyle` *replaces* the inherited style, dropping Inter. Use
  `AnimatedStyle` (merges).

### Screens
- [x] **3.1 / 3.2 camera**: Iconsax top bar (52 pt), AUTO pill, vignette, dashed guide 262×340, detected quad (brand 18% fill,
  corner dots r6 + 4 pt ring), Footnote pills, 13 pt mode tabs with 5 pt dot, 78 pt shutter (colour animates), 48 pt gallery
  and page stack (tilted second page + badge). Book uses the titled bar (9.1).
- [x] **7.1 ID camera**: sides switch, 4 pt / 26 pt brackets on the Figma 322×214 frame, info pill.
- [x] **9.1 Book camera**: solid spread guide with dashed fold line (follows the detected spread), "Left · n / Right · n+1"
  chips with the page numbers this spread will get. The pill says "Pages split automatically" (see not built).
- [x] **3.3 Adjust Crop** (`CropScreen`): photo at 353 pt wide, r24, light veil, round corner handles + pill edge handles,
  96 pt loupe with crosshair; Rotate · Auto · Perspective (renders the straightened crop) · Full page; Reset; Retake; Next →
  Enhance. Nothing is saved before Next.
- [x] **3.4 Enhance** (`EnhanceScreen`): 400 pt preview with "Page i of n", filter tiles (Original, Magic, B & W, Gray,
  No Shadow, Color) with live thumbnails, brightness / contrast sliders (the change shows instantly via a colour matrix that
  matches the native curve, then the native render replaces it), Apply to all (filter + sliders, not the crop), rotate.
- [x] **3.5 Review**: "N Pages", Select (multi-select → rotate / delete N with Undo), reorder hint, page cards with rotate /
  delete, dashed Add page card (Camera or Photos), edit (→ Enhance), Save as PDF → `ScanResult`.
- [x] **9.2 Book Result** (after every spread): "Pages a–b", page pair, **Split into two pages** toggle (off = one `Spread`
  page), "N spreads scanned · 2N pages", Back / Next Spread → camera, Done → review, Save Book → `ScanResult`.
- [x] **9.3 ID Card Result** (after the back side): sheet preview, Stacked / Side by side / Separate (drives the PDF: A4
  stacked, A4 landscape side by side, or one page per side), Extracted details from the card's TD1 MRZ when it has one
  (otherwise it says there's nothing verified to extract), copy per field / Copy all, share, Retake / Save PDF.
- [x] **9.4 Passport Result** (replaces the MRZ sheet): data-page thumbnail, surname / given names, MRZ verified, detail
  tiles, validity banner (orange; red once expired), Copy All, share, Save PDF.

### Not built (the engine can't do it honestly yet)
- 9.1 / 9.2 "Curves flattened", "Flatten page curves", "Remove fingers & edges": no dewarp or inpainting in the engine
  (backlog). The toggles are left out and the pill doesn't claim flattening.
- 9.4 "Issued": the MRZ has no issue date, so that tile shows the issuing country. Nationality shows the ICAO code
  (e.g. `PAK`), not the country name.
- 9.4 portrait: shows the scanned data page (left-aligned, where ICAO puts the photo), not a face crop.
- 7.1 right-hand "card" button: purpose unclear in the design; the page stack shows there once pages exist.

### New engine parts (channel change: Kotlin, Swift, `engine.dart`, contract table above)
- [x] `process` gains `brightness` / `contrast` (Android `convertTo`, iOS `CIColorMatrix`, same curve) and two filters:
  `noShadow` (paper-divide without ink deepening) and `color` (saturation ×1.4, contrast ×1.15).
- [x] `recognizeText(path, script)` → `List<TextBlock>` (`TextBlock {text, box, lines}`, exported). Android: ML Kit;
  Latin bundled, Chinese / Devanagari / Japanese / Korean via the unbundled Play Services artifacts
  (`play-services-mlkit-text-recognition-*:16.0.1`, models download on first use → `MODEL_UNAVAILABLE` until then).
  iOS: `VNRecognizeTextRequest` `.accurate` + language correction, languages mapped per script; Vision reports lines, so
  each iOS block is one line.
- [ ] Measure on a device: filter / slider render times, `recognizeText` accuracy and speed per script, APK size delta.

### Tests
- `test/engine_test.dart`: `Detection` / `TextBlock` parsing, `recognizeText` arguments + errors, `process` arguments.
- `test/review_flow_test.dart`: review select / delete / undo / rotate / Save as PDF; crop → enhance (Full page + Rotate
  saved only on Next, filter, slider → `brightness`, Apply to all); book split toggle; ID layouts ↔ export grouping, MRZ
  details and the no-MRZ message.
- Updated: `scanner_screen_test.dart` (passport → 9.4 screen, camera released meanwhile), `scanner_api_test.dart`
  (Save as PDF returns the pages). 62 tests pass.

### Acceptance
- [ ] Walk every screen above on the Pixel 6 in light and dark mode against the Figma frames (no ID/passport photos on screen
  capture, per the privacy rules).
- [ ] `recognizeText` on real printed pages in each script.

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
