import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

// The host-app contract: Scanner.open → ScanResult on Done, null on Close, starting on the requested tab.
void main() {
  final calls = <String>[];

  setUp(() {
    calls.clear();
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('flutter_doc_scanner'), (call) async {
      calls.add(call.method);
      return switch (call.method) {
        'start' => {'textureId': 1, 'width': 1080, 'height': 1440, 'quarterTurns': 0},
        'capture' => {'path': '/nonexistent/cap.jpg', 'corners': null},
        'arStart' => {'textureId': 2},
        _ => null,
      };
    });
    for (final name in ['flutter_doc_scanner/detections', 'flutter_doc_scanner/ar']) {
      messenger.setMockStreamHandler(EventChannel(name), MockStreamHandler.inline(onListen: (_, _) {}));
    }
  });

  Future<Future<ScanResult?>> openFromHost(WidgetTester tester, {ScannerTab tab = ScannerTab.document}) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    late Future<ScanResult?> result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(onPressed: () => result = Scanner.open(context, tab: tab), child: const Text('Host')),
      ),
    ));
    await tester.tap(find.text('Host'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    return result;
  }

  testWidgets('Done returns the scanned pages', (tester) async {
    final result = await openFromHost(tester);
    expect(calls, contains('start'));

    await tester.tap(find.bySemanticsLabel('Capture'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    await tester.tap(find.bySemanticsLabel(RegExp('^Review 1 page')));
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text('Done'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final pages = (await result)!.pages;
    expect(pages, hasLength(1));
    expect(pages.single.original, '/nonexistent/cap.jpg');
    expect(find.text('Host'), findsOneWidget);
  });

  testWidgets('Close returns null; tab picks the starting mode', (tester) async {
    final result = await openFromHost(tester, tab: ScannerTab.measure);
    expect(calls, contains('arStart'));
    expect(calls, isNot(contains('start')));

    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(await result, isNull);
  });
}
