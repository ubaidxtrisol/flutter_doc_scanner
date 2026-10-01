import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart' show MathSolution, MathStep;
import 'package:flutter_doc_scanner/src/scanner.dart';
import 'package:flutter_doc_scanner/src/scanner/scanner_screen.dart';
import 'package:flutter_doc_scanner/src/scanner/session.dart';

// Drives the camera screen through every mode with a fake native engine: catches layout overflows,
// wrong pills and broken result flows without a camera.
void main() {
  late void Function(Map<String, Object?>) emit;
  final calls = <String>[];

  setUp(() {
    calls.clear();
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('flutter_doc_scanner'), (call) async {
      calls.add(call.method);
      return switch (call.method) {
        'start' => {'textureId': 1, 'width': 1080, 'height': 1440, 'quarterTurns': 0},
        'capture' => {'path': '/nonexistent/cap.jpg', 'corners': null},
        _ => null,
      };
    });
    messenger.setMockStreamHandler(
      const EventChannel('flutter_doc_scanner/detections'),
      MockStreamHandler.inline(
        onListen: (_, sink) {
          emit = sink.success;
        },
      ),
    );
  });

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1179, 2556); // iPhone 15-class, 393×852 pt
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ScannerScreen()));
    await tester.pump();
  }

  /// Fake platform events arrive on real async time, so let it pass before pumping frames.
  Future<void> send(WidgetTester tester, Map<String, Object?> event) async {
    emit(event);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // sheet slide-in
  }

  Future<void> tab(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label).last);
    await tester.pump();
    await tester.tap(find.text(label).last);
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('every mode lays out with its own chrome and hint', (tester) async {
    await open(tester);
    expect(find.text('Point at a document'), findsOneWidget);
    expect(find.text('AUTO'), findsOneWidget);

    await tab(tester, 'ID Card');
    expect(find.text('1  Front side'), findsOneWidget);
    expect(find.text('Fit the card inside the frame'), findsOneWidget);
    expect(find.text('AUTO'), findsNothing);
    await tester.tap(find.text('2  Back side'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Now scan the back side'), findsOneWidget);

    await tab(tester, 'Passport');
    expect(find.text('Place the photo page inside the frame'), findsOneWidget);

    await tab(tester, 'Book');
    expect(find.text('Point at an open book'), findsOneWidget);

    await tab(tester, 'QR');
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Point at a QR code or barcode'), findsOneWidget);

    await tab(tester, 'Math');
    expect(find.text("Solving math needs AI, which isn't set up"), findsOneWidget);

    await tab(tester, 'Count');
    expect(find.text('Point at the objects, then tap the shutter'), findsOneWidget);
    expect(calls, contains('setMode'));
  });

  testWidgets('QR code opens the result sheet (Figma 7.3)', (tester) async {
    await open(tester);
    await tab(tester, 'QR');
    await send(tester, {
      'mode': 'qr',
      'codes': [
        {'value': 'https://docscan.app/welcome', 'corners': null},
      ],
    });
    expect(find.text('Website'), findsOneWidget);
    expect(find.text('docscan.app/welcome'), findsOneWidget);
    expect(find.text('Open Link'), findsOneWidget);
  });

  testWidgets('result cards: each one joins the scan, then "add another" or "Save PDF" (several → plural title)', (
    tester,
  ) async {
    final tmp = Directory.systemTemp.createTempSync('cards');
    addTearDown(() => tmp.deleteSync(recursive: true));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => tmp.path,
    );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        null,
      ),
    );
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    ScanResult? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await Scanner.open(context, tab: ScannerTab.qr),
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 300));
    }
    Future<void> settle() async {
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> code(String value) => send(tester, {
      'mode': 'qr',
      'codes': [
        {'value': value, 'corners': null},
      ],
    });

    await code('https://docscan.app/one');
    await tester.tap(find.text('Save to Documents'));
    await settle();
    expect(find.text('Added to your scan'), findsOneWidget);
    expect(find.textContaining('1 page so far'), findsOneWidget);
    expect(result, isNull); // the scanner stays open
    await tester.tap(find.text('Scan another code'));
    await settle();
    expect(find.text('Added to your scan'), findsNothing);

    await code('https://docscan.app/one'); // still in view: not reopened
    expect(find.text('Save to Documents'), findsNothing);

    await code('https://docscan.app/two');
    await tester.tap(find.text('Save to Documents'));
    await settle();
    expect(find.textContaining('2 pages so far'), findsOneWidget);
    await tester.tap(find.text('Save PDF'));
    await settle();
    expect(result, isNotNull);
    expect(result!.pages, hasLength(2));
    expect(result!.title, 'QR codes');
  });

  testWidgets('passport: two matching MRZ reads → capture → result screen (Figma 9.4)', (tester) async {
    await open(tester);
    await tab(tester, 'Passport');
    final lines = [
      {
        'text': 'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<',
        'box': [.1, .70, .9, .74],
      },
      {
        'text': 'L898902C36UTO7408122F1204159ZE184226B<<<<<10',
        'box': [.1, .75, .9, .79],
      },
    ];
    await send(tester, {'mode': 'passport', 'lines': lines});
    expect(find.text('MRZ detected · Hold steady'), findsOneWidget);
    expect(calls, isNot(contains('capture')));
    await send(tester, {'mode': 'passport', 'lines': lines});
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20))); // capture round-trip
    await tester.pump(const Duration(milliseconds: 400));
    expect(calls, contains('capture'));
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20))); // camera stop, push
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(calls, contains('stop')); // the camera is released while the result screen is up
    expect(find.text('MRZ verified'), findsOneWidget);
    expect(find.text('ERIKSSON'), findsOneWidget);
    expect(find.text('Anna Maria'), findsOneWidget);
    expect(find.text('L898902C3'), findsOneWidget);
    expect(find.text('UTO'), findsNWidgets(2)); // nationality + issuing country, straight from the MRZ
    expect(find.text('Expired on 15 Apr 2012'), findsOneWidget); // the specimen expired in 2012
  });

  testWidgets('math: without AI the pill says so', (tester) async {
    await open(tester);
    await tab(tester, 'Math');
    expect(find.text("Solving math needs AI, which isn't set up"), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Capture'));
    await tester.pump();
    expect(calls, isNot(contains('capture'))); // never takes a photo it can't solve
  });

  testWidgets('math: no live detection; the shutter sends the photo straight to the AI', (tester) async {
    final asked = <String>[];
    Scanner.onlineMath = (text, image) async {
      asked.add('$text|$image');
      return const MathSolution(
        problem: '2x + 5 = 15',
        type: 'Linear equation',
        answer: 'x = 5',
        steps: [MathStep('Subtract 5 from both sides', '2x = 10')],
        online: true,
      );
    };
    addTearDown(() => Scanner.onlineMath = null);
    await open(tester);
    await tab(tester, 'Math');
    expect(find.text('Point at a math problem, then tap the shutter'), findsOneWidget);
    // Live text events (an older native build) are ignored: nothing is detected or solved before the shutter.
    await send(tester, {
      'mode': 'math',
      'lines': [
        {
          'text': '2x + 5 = 15',
          'box': [.2, .45, .8, .52],
        },
      ],
    });
    expect(find.text('Point at a math problem, then tap the shutter'), findsOneWidget);
    expect(find.text('Answer'), findsNothing);
    expect(asked, isEmpty);

    await tester.tap(find.bySemanticsLabel('Capture'));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(calls, isNot(contains('analyze'))); // no OCR step before the AI
    expect(asked, ['|/nonexistent/cap.jpg']); // just the photo (downscale failed here, so the original)
    expect(find.text('x = 5'), findsWidgets);
    expect(find.text('Solved with AI'), findsOneWidget);
  });
}
