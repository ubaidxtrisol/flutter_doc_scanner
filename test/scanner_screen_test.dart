import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/scanner/scanner_screen.dart';

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
      MockStreamHandler.inline(onListen: (_, sink) {
        emit = sink.success;
      }),
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
    expect(find.text('Point at a math problem'), findsOneWidget);

    await tab(tester, 'Count');
    expect(find.text('Point at the objects, then tap the shutter'), findsOneWidget);
    expect(calls, contains('setMode'));
  });

  testWidgets('QR code opens the result sheet (Figma 7.3)', (tester) async {
    await open(tester);
    await tab(tester, 'QR');
    await send(tester, {'mode': 'qr', 'codes': [{'value': 'https://docscan.app/welcome', 'corners': null}]});
    expect(find.text('Website'), findsOneWidget);
    expect(find.text('docscan.app/welcome'), findsOneWidget);
    expect(find.text('Open Link'), findsOneWidget);
  });

  testWidgets('passport: two matching MRZ reads → capture → result screen (Figma 9.4)', (tester) async {
    await open(tester);
    await tab(tester, 'Passport');
    final lines = [
      {'text': 'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<', 'box': [.1, .70, .9, .74]},
      {'text': 'L898902C36UTO7408122F1204159ZE184226B<<<<<10', 'box': [.1, .75, .9, .79]},
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

  testWidgets('math: a solvable problem seen twice opens the answer (Figma 7.4)', (tester) async {
    await open(tester);
    await tab(tester, 'Math');
    final lines = [
      {'text': 'Exercise 4', 'box': [.1, .2, .4, .24]},
      {'text': '2x + 5 = 15', 'box': [.2, .45, .8, .52]},
    ];
    await send(tester, {'mode': 'math', 'lines': lines});
    expect(find.text('Problem found · Hold steady'), findsOneWidget);
    await send(tester, {'mode': 'math', 'lines': lines});
    expect(find.text('Linear equation'), findsOneWidget);
    expect(find.text('3 steps'), findsOneWidget);
    expect(find.text('x = 5'), findsWidgets);
    expect(find.text('Subtract 5 from both sides'), findsOneWidget);
    expect(calls, isNot(contains('capture'))); // solved from live frames, no photo needed
  });

  testWidgets('math: unsupported problem waits for the shutter', (tester) async {
    await open(tester);
    await tab(tester, 'Math');
    final lines = [{'text': 'sin(x) + 2 = 3', 'box': [.2, .45, .8, .52]}];
    await send(tester, {'mode': 'math', 'lines': lines});
    await send(tester, {'mode': 'math', 'lines': lines});
    expect(find.text('Tap the shutter to solve'), findsOneWidget);
    expect(find.text('Answer'), findsNothing);
  });
}
