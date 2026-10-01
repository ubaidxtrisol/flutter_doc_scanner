import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/src/math/cloud.dart';
import 'package:flutter_doc_scanner/src/math/solver.dart';
import 'package:flutter_doc_scanner/src/scanner.dart';
import 'package:flutter_doc_scanner/src/scanner/math_sheet.dart';
import 'package:flutter_doc_scanner/src/scanner/session.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';

// Figma 7.4 answer sheet: local and AI answers, LaTeX with fallback, loading, error + Retry, Copy, and Save as
// A4 card pages.
void main() {
  late Directory tmp;
  String? clipboard;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('math_sheet');
    clipboard = null;
    final m = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    m.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => tmp.path);
    m.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') clipboard = (call.arguments as Map)['text'] as String;
      return null;
    });
  });
  tearDown(() {
    Scanner.onlineMath = null;
    tmp.deleteSync(recursive: true);
  });

  Future<void> open(
    WidgetTester tester,
    FutureOr<MathSolution> Function() solve, {
    String? photo,
    SavePages? onSave,
  }) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showMathSheet(context, solve, photo: photo, onSave: onSave),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // sheet slide-in
  }

  MathSolution online({List<MathStep>? steps}) => MathSolution(
    problem: '2x² + 3x − 2 = 0',
    problemTex: r'2x^2 + 3x - 2 = 0',
    type: 'Quadratic equation',
    answer: 'x = 1/2, x = −2',
    answerTex: r'x = \frac{1}{2},\; x = -2',
    online: true,
    steps:
        steps ??
        const [
          MathStep('Factor the left side', '(2x − 1)(x + 2) = 0', tex: r'(2x - 1)(x + 2) = 0'),
          MathStep('Set each factor to zero', 'broken step', tex: r'\frac{1}{'), // invalid LaTeX
          MathStep(
            'Write a very long line',
            'long',
            tex:
                r'x = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15 + 16 + 17 + 18 + 19 + 20 + 21 + 22',
          ),
        ],
  );

  testWidgets('on-device solution: plain styled text, no AI badge', (tester) async {
    await open(tester, () => solveLocally('2x + 5 = 15')!);
    expect(find.text('Linear equation'), findsOneWidget);
    expect(find.text('3 steps'), findsOneWidget);
    expect(find.text('x = 5'), findsWidgets);
    expect(find.text('Subtract 5 from both sides'), findsOneWidget);
    expect(find.text('Solved with AI'), findsNothing);
    expect(find.byType(Math), findsNothing);
    expect(find.text('Save to Documents'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Copy'));
    await tester.pump();
    expect(clipboard, startsWith('Problem: 2x + 5 = 15\nAnswer: x = 5\n'));
    expect(clipboard, contains('1. Subtract 5 from both sides\n   2x = 15 − 5'));
    expect(find.bySemanticsLabel('Copied'), findsOneWidget);
  });

  testWidgets('AI solution: LaTeX rendered, bad LaTeX falls back to text, long math never overflows', (tester) async {
    await open(tester, () => online());
    expect(tester.takeException(), isNull);
    expect(find.text('Solved with AI'), findsOneWidget);
    expect(find.text('Quadratic equation'), findsOneWidget);
    expect(find.byType(Math), findsNWidgets(5)); // problem, answer, 3 steps
    expect(find.text('(2x − 1)(x + 2) = 0'), findsNothing); // shown as math, not text
    expect(find.text('broken step'), findsOneWidget); // the fallback
    expect(find.text('Factor the left side'), findsOneWidget);
  });

  testWidgets('AI loading, error with Retry, then the answer', (tester) async {
    Scanner.onlineMath = (_, _) async => online();
    var calls = 0;
    late Completer<MathSolution> pending;
    await open(tester, () {
      calls++;
      return (pending = Completer<MathSolution>()).future;
    });
    expect(find.text('Solving with AI…'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700)); // animating, no layout errors
    expect(tester.takeException(), isNull);

    pending.completeError(const CloudMathException('Needs an internet connection.'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("Couldn't solve this"), findsOneWidget);
    expect(find.text('Needs an internet connection.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(calls, 2);
    expect(find.text('Solving with AI…'), findsOneWidget);
    pending.complete(online());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Solved with AI'), findsOneWidget);
  });

  testWidgets('no online solver: the error has no Retry', (tester) async {
    await open(
      tester,
      () => throw const CloudMathException("This problem needs the online solver, which isn't set up."),
    );
    expect(find.text("This problem needs the online solver, which isn't set up."), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
  });

  testWidgets('Save renders A4 card pages (photo on page 1, steps split) and hands them over', (tester) async {
    final photo = '${tmp.path}/photo.png';
    await tester.runAsync(() async {
      final r = ui.PictureRecorder();
      Canvas(r).drawRect(const Rect.fromLTWH(0, 0, 400, 300), Paint()..color = const Color(0xFF808080));
      final img = await r.endRecording().toImage(400, 300);
      File(photo).writeAsBytesSync((await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List());
    });
    final steps = [for (var i = 1; i <= 12; i++) MathStep('Step $i', 'x = $i', tex: 'x = $i')];
    List<ScanPage>? saved;
    String? title;
    await open(
      tester,
      () => online(steps: steps),
      photo: photo,
      onSave: (pages, t) async {
        saved = pages;
        title = t;
      },
    );
    await tester.tap(find.text('Save to Documents'));
    for (var i = 0; i < 50 && saved == null; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
    expect(saved, isNotNull);
    expect(saved!.length, 2); // 4 steps next to the photo, then 8
    expect(title, 'Math · x = 1/2, x = −2');
    for (final page in saved!) {
      expect(page.label, 'Math');
      final size = await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(File(page.original).readAsBytesSync());
        final img = (await codec.getNextFrame()).image;
        return Size(img.width.toDouble(), img.height.toDouble());
      });
      expect(size, const Size(1488, 2105)); // A4 (595 × 842 pt) at ×2.5, rounded
    }
    expect(find.text('Save to Documents'), findsOneWidget); // back from "Saving…"
  });

  test('card pages, title and plain text', () {
    expect(mathCardChunks(0, photo: false), [(0, 0)]);
    expect(mathCardChunks(4, photo: true), [(0, 4)]);
    expect(mathCardChunks(5, photo: true), [(0, 4), (4, 1)]);
    expect(mathCardChunks(16, photo: false), [(0, 6), (6, 9), (15, 1)]);

    final long = MathSolution(problem: '', type: 'Arithmetic', answer: '123456789 ' * 6, steps: const []);
    expect(mathTitle(long).length, lessThanOrEqualTo(40));
    expect(mathTitle(long), endsWith('…'));
    expect(mathTitle(online()), 'Math · x = 1/2, x = −2');
  });
}
