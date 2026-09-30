// On-device check of the native detector + renderer. Run on a phone:
//   flutter test integration_test/scanner_vision_test.dart -d <device>
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_doc_scanner/src/count/counter.dart';
import 'package:flutter_doc_scanner/src/math/solver.dart';
import 'package:flutter_doc_scanner/src/scanner/book.dart';
import 'package:flutter_doc_scanner/src/scanner/mrz.dart';
import 'package:path_provider/path_provider.dart';

const size = Size(1200, 1600);
const page = [Offset(300, 250), Offset(950, 330), Offset(880, 1350), Offset(220, 1280)];

/// Renders [paint] into a PNG file and returns its path.
Future<String> draw(String name, void Function(Canvas c) paint) async {
  final rec = ui.PictureRecorder();
  paint(Canvas(rec));
  final img = await rec.endRecording().toImage(size.width.toInt(), size.height.toInt());
  final png = await img.toByteData(format: ui.ImageByteFormat.png);
  final file = File('${(await getTemporaryDirectory()).path}/$name.png');
  await file.writeAsBytes(png!.buffer.asUint8List());
  return file.path;
}

Paint fill(int argb) => Paint()..color = Color(argb);

/// Draws a sheet of "paper" with text lines at [page] on [background], optionally with a soft shadow.
Future<String> scene(String name, Color background, {bool paper = true, bool shadow = false}) => draw(name, (c) {
  c.drawRect(Offset.zero & size, Paint()..color = background);
  // Some background texture so "empty" isn't trivially empty.
  final rnd = math.Random(7);
  for (var i = 0; i < 40; i++) {
    c.drawCircle(Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height), 20 + rnd.nextDouble() * 60,
        Paint()..color = background.withValues(alpha: 1).withRed((background.r * 255 * .9).round()));
  }
  if (paper) {
    final quad = Path()..addPolygon(page, true);
    if (shadow) {
      c.drawPath(quad.shift(const Offset(10, 14)),
          Paint()
            ..color = Colors.black26
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    }
    c.drawPath(quad, Paint()..color = const Color(0xFFFDFDFB));
    c.save();
    c.clipPath(quad);
    for (var y = 400.0; y < 1200; y += 45) {
      c.drawRRect(RRect.fromLTRBR(340, y, 800, y + 16, const Radius.circular(8)), Paint()..color = const Color(0xFFB8BECA));
    }
    c.restore();
  }
});

Future<List<Offset>?> corners(String path, [ScanMode mode = ScanMode.document]) async =>
    (await DocScanner.analyzeFile(path, mode)).corners;

void expectCorners(List<Offset>? found) {
  expect(found, isNotNull, reason: 'page not detected');
  for (var i = 0; i < 4; i++) {
    final truth = Offset(page[i].dx / size.width, page[i].dy / size.height);
    expect((found![i] - truth).distance, lessThan(.02), reason: 'corner $i: ${found[i]} vs $truth');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('finds white paper on a dark desk', (_) async {
    expectCorners(await corners(await scene('dark', const Color(0xFF6B4E35))));
  });

  testWidgets('finds white paper on a white desk', (_) async {
    expectCorners(await corners(await scene('light', const Color(0xFFE4E4E2), shadow: true)));
  });

  testWidgets('finds neutral white paper on a warm white desk (no shadow)', (_) async {
    // Reproduces a real Pixel 6 miss: brightness is nearly equal, only the tint differs
    // (desk ≈ RGB 247,243,231 vs paper ≈ 238,238,236, measured from the user's photo).
    final path = await draw('warm_desk', (c) {
      c.drawRect(Offset.zero & size, fill(0xFFF7F3E7));
      c.drawPath(Path()..addPolygon(page, true), fill(0xFFEEEEEC));
      for (var y = 420.0; y < 1200; y += 40) {
        c.drawLine(Offset(320, y), Offset(840, y + 50), Paint()..color = const Color(0xFFD6D8DE)..strokeWidth = 2);
      }
    });
    expectCorners(await corners(path));
  });

  testWidgets('finds nothing on an empty desk', (_) async {
    expect(await corners(await scene('empty', const Color(0xFF6B4E35), paper: false)), isNull);
  });

  testWidgets('renders every filter with the page aspect, fast', (_) async {
    final src = await scene('render', const Color(0xFF6B4E35));
    final corners = [for (final p in page) Offset(p.dx / size.width, p.dy / size.height)];
    final w = math.max((page[1] - page[0]).distance, (page[2] - page[3]).distance);
    final h = math.max((page[3] - page[0]).distance, (page[2] - page[1]).distance);
    for (final f in PageFilter.values) {
      final out = '$src.${f.name}.jpg';
      final sw = Stopwatch()..start();
      await DocScanner.process(path: src, outPath: out, corners: corners, filter: f);
      debugPrint('process ${f.name}: ${sw.elapsedMilliseconds} ms');
      final img = (await (await ui.instantiateImageCodec(await File(out).readAsBytes())).getNextFrame()).image;
      expect(img.width / img.height, closeTo(w / h, .03), reason: f.name);
    }
    final sw = Stopwatch()..start();
    await DocScanner.process(path: src, outPath: '$src.rot.jpg', corners: corners, rotation: 90);
    final rot = (await (await ui.instantiateImageCodec(await File('$src.rot.jpg').readAsBytes())).getNextFrame()).image;
    expect(rot.width / rot.height, closeTo(h / w, .03));
    debugPrint('process rotate: ${sw.elapsedMilliseconds} ms');
  });

  testWidgets('ID mode finds a card and ignores a sheet of paper', (_) async {
    final card = await draw('card', (c) {
      c.drawRect(Offset.zero & size, fill(0xFF3A3F4A));
      final r = Rect.fromCenter(center: const Offset(600, 800), width: 900, height: 900 / 1.586);
      c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(36)), fill(0xFFD8EEEA));
      c.drawRect(Rect.fromLTWH(r.left + 40, r.top + 150, 220, 260), fill(0xFF9CC6BE)); // photo
    });
    expect(await corners(card, ScanMode.idCard), isNotNull, reason: 'card not found');
    final a4 = await draw('a4', (c) {
      c.drawRect(Offset.zero & size, fill(0xFF6B4E35));
      c.translate(600, 800);
      c.rotate(.08);
      c.drawRect(Rect.fromCenter(center: Offset.zero, width: 800, height: 800 * 1.414), fill(0xFFFDFDFB));
    });
    expect(await corners(a4, ScanMode.document), isNotNull, reason: 'control: the page itself is detectable');
    expect(await corners(a4, ScanMode.idCard), isNull, reason: 'an A4 sheet must not pass as an ID card');
  });

  testWidgets('QR decodes', (_) async {
    const url = 'https://docscan.app/welcome';
    final qr = await draw('qr', (c) {
      c.drawRect(Offset.zero & size, fill(0xFFFFFFFF));
      for (final e in Barcode.qrCode().make(url, width: 700, height: 700)) {
        if (e is BarcodeBar && e.black) c.drawRect(Rect.fromLTWH(250 + e.left, 450 + e.top, e.width, e.height), fill(0xFF000000));
      }
    });
    final sw = Stopwatch()..start();
    final d = await DocScanner.analyzeFile(qr, ScanMode.qr);
    debugPrint('qr decode: ${sw.elapsedMilliseconds} ms');
    expect(d.codes.map((c) => c.value), contains(url));
  });

  testWidgets('passport MRZ is read and passes every check digit', (_) async {
    const td3 = ['P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<', 'L898902C36UTO7408122F1204159ZE184226B<<<<<10'];
    final path = await draw('mrz', (c) {
      c.drawRect(Offset.zero & size, fill(0xFFF3EFE6));
      for (final (i, line) in td3.indexed) {
        (TextPainter(
          text: TextSpan(text: line, style: const TextStyle(fontFamily: 'monospace', fontSize: 44, color: Colors.black)),
          textDirection: TextDirection.ltr,
        )..layout())
            .paint(c, Offset(30, 1100 + i * 72.0));
      }
    });
    final sw = Stopwatch()..start();
    final d = await DocScanner.analyzeFile(path, ScanMode.passport);
    debugPrint('mrz ocr: ${sw.elapsedMilliseconds} ms');
    final lines = [...d.lines]..sort((a, b) => a.box.top.compareTo(b.box.top));
    final mrz = Mrz.find([for (final l in lines) l.text]);
    expect(mrz?.documentNumber, 'L898902C3', reason: 'OCR lines: ${lines.map((l) => l.text).toList()}');
  });

  testWidgets('book spread splits at the fold', (_) async {
    final path = await draw('book', (c) {
      c.drawRect(Offset.zero & size, fill(0xFF5A4330));
      c.drawRect(const Rect.fromLTWH(100, 500, 1000, 700), fill(0xFFF7F5EF));
      c.drawRect(const Rect.fromLTWH(615, 500, 50, 700), fill(0xFFCFCBC2)); // soft fold shadow
      c.drawRect(const Rect.fromLTWH(632, 500, 16, 700), fill(0xFF9C978C));
      for (var y = 580.0; y < 1150; y += 40) {
        c.drawRect(Rect.fromLTWH(160, y, 400, 12), fill(0xFFB5B5B5));
        c.drawRect(Rect.fromLTWH(700, y, 360, 12), fill(0xFFB5B5B5));
      }
    });
    final spread = await corners(path, ScanMode.book);
    expect(spread, isNotNull, reason: 'spread not found');
    final (left, right) = await splitSpread(path, spread);
    expect(left[1].dx, closeTo(640 / 1200, .02), reason: 'fold at $left');
    expect(right[0], left[1]);
  });

  testWidgets('math: printed equation is read and solved on device', (_) async {
    final path = await draw('math', (c) {
      c.drawRect(Offset.zero & size, fill(0xFFF4F1E8));
      for (var y = 200.0; y < 1600; y += 70) {
        c.drawLine(Offset(0, y), Offset(1200, y), Paint()..color = const Color(0xFFB9C7E8)..strokeWidth = 2); // ruled paper
      }
      (TextPainter(
        text: const TextSpan(text: '2x + 5 = 15', style: TextStyle(fontSize: 110, color: Color(0xFF1F2A44))),
        textDirection: TextDirection.ltr,
      )..layout())
          .paint(c, const Offset(250, 700));
    });
    final sw = Stopwatch()..start();
    final lines = (await DocScanner.analyzeFile(path, ScanMode.math)).lines;
    final picked = pickMathLine([for (final l in lines) (l.text, l.box.center.dy)]);
    final solution = picked == null ? null : solveLocally(picked);
    debugPrint('math ocr+solve: ${sw.elapsedMilliseconds} ms, read "$picked"');
    expect(solution?.answer, 'x = 5', reason: 'OCR lines: ${lines.map((l) => l.text).toList()}');
  });

  testWidgets('count: 23 buttons on a table, full on-device pipeline', (_) async {
    final path = await draw('buttons', (c) {
      c.drawRect(Offset.zero & size, fill(0xFF6E5439));
      for (var i = 0; i < 23; i++) {
        final center = Offset(150.0 + (i % 5) * 225, 180.0 + (i ~/ 5) * 290);
        c.drawCircle(center + const Offset(6, 8), 62, fill(0x55000000)); // soft shadow
        c.drawCircle(center, 60, fill(0xFFD6B276));
        c.drawCircle(center - const Offset(18, 18), 14, fill(0xFFF7EEDC)); // highlight
      }
    });
    final sw = Stopwatch()..start();
    final small = '$path.small.jpg';
    await DocScanner.process(path: path, outPath: small, maxSize: 640);
    final image = (await (await ui.instantiateImageCodec(await File(small).readAsBytes())).getNextFrame()).image;
    final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
    final found = await countInBackground(rgba, image.width, image.height, CountKind.round);
    debugPrint('count: ${found.length} in ${sw.elapsedMilliseconds} ms');
    expect(found.length, 23);
  });
}
