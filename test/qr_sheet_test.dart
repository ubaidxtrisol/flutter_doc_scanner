import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/scanner/qr_payload.dart';
import 'package:flutter_doc_scanner/src/scanner/result_sheets.dart';
import 'package:flutter_doc_scanner/src/scanner/session.dart';

// The QR result sheet (Figma 7.3): parsed fields, the re-generated code, password privacy, Save to Documents.
void main() {
  late Directory tmp;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('qr_sheet');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => tmp.path,
    );
  });
  tearDown(() => tmp.deleteSync(recursive: true));

  Future<void> open(WidgetTester tester, String raw, {SaveResult? onSave}) async {
    tester.view.physicalSize = const Size(1179, 2556); // 393×852 pt
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              context = c;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    showQrSheet(context, QrPayload.parse(raw), onSave: onSave);
    await tester.pumpAndSettle();
  }

  /// Taps Save and lets the offscreen card render (real async: image encode + file write).
  Future<void> save(WidgetTester tester) async {
    await tester.tap(find.text('Save to Documents'));
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
  }

  testWidgets('Wi-Fi: fields, generated code, password hidden until toggled, Save renders a card page', (tester) async {
    final saved = <(ScanPage, String)>[];
    await open(
      tester,
      r'WIFI:T:WPA;S:Home\;Net;P:s3cret!;H:true;;',
      onSave: (page, title) async => saved.add((page, title)),
    );
    expect(find.text('Wi-Fi'), findsOneWidget);
    expect(find.text('Home;Net'), findsWidgets);
    expect(find.text('WPA/WPA2'), findsOneWidget);
    expect(find.text('Hidden'), findsOneWidget);
    expect(find.byType(QrCodeView), findsOneWidget);
    expect(find.text('Copy Password'), findsOneWidget);

    expect(find.text('s3cret!'), findsNothing);
    await tester.ensureVisible(find.bySemanticsLabel('Show password'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Show password'));
    await tester.pump();
    expect(find.text('s3cret!'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Hide password'));
    await tester.pump();
    expect(find.text('s3cret!'), findsNothing);

    await save(tester);
    expect(saved, hasLength(1));
    final (page, title) = saved.single;
    expect(title, 'QR · Home;Net');
    expect(title, isNot(contains('s3cret')));
    expect(page.label, title);
    final png = File(page.original);
    expect(png.existsSync(), isTrue);
    expect(png.readAsBytesSync().take(4), [0x89, 0x50, 0x4E, 0x47]); // PNG
  });

  testWidgets('contact and email show every parsed field', (tester) async {
    await open(tester, 'BEGIN:VCARD\nFN:Ada Lovelace\nORG:Engines\nTEL:+1555\nTEL:+1666\nEMAIL:ada@x.org\nEND:VCARD');
    for (final t in ['Contact', 'Organization', 'Engines', '+1555', '+1666', 'ada@x.org']) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.text('Share'), findsOneWidget); // no link to open: Share is the main action

    await open(tester, 'mailto:a@b.co?subject=Hi&body=See%20you');
    for (final t in ['To', 'Subject', 'Hi', 'Message', 'See you', 'Send Email']) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
  });

  testWidgets('long text: full, scrollable, no overflow; too long to encode → text-only card', (tester) async {
    final saved = <ScanPage>[];
    final long = List.generate(400, (i) => 'line $i of a long note').join('\n'); // ~9 kB: beyond any QR version
    expect(encodeQr(long), isNull);
    await open(tester, long, onSave: (page, _) async => saved.add(page));
    expect(find.byType(QrCodeView), findsNothing);
    expect(find.text('Too long to show as a QR code. The full content is below.'), findsOneWidget);
    expect(find.text(long), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.getBottomLeft(find.text('Save to Documents')).dy, lessThan(852)); // actions stay on screen
    await save(tester);
    expect(saved, hasLength(1));
    expect(File(saved.single.original).existsSync(), isTrue);
  });

  testWidgets('empty and unreadable codes show a friendly message', (tester) async {
    await open(tester, '   ');
    expect(find.text('This code is empty'), findsOneWidget);
    expect(find.text('Save to Documents'), findsNothing);
    await tester.tap(find.text('Scan Again'));
    await tester.pumpAndSettle();
    expect(find.text('This code is empty'), findsNothing);

    await open(tester, '\u0001�');
    expect(find.text("Couldn't read this code"), findsOneWidget);
  });

  testWidgets('a failed save shows an error in the sheet, not a crash', (tester) async {
    await open(tester, 'https://docscan.app', onSave: (_, _) async => throw const FileSystemException('disk full'));
    await save(tester);
    expect(find.text("Couldn't save the QR code. Try again."), findsOneWidget);
    expect(find.text('Save to Documents'), findsOneWidget); // ready to retry
  });

  test('encodeQr picks the smallest version at error correction M', () {
    final small = encodeQr('https://docscan.app')!;
    expect((small.moduleCount, small.errorCorrectLevel), (25, 0)); // version 2, M
    expect(encodeQr(''), isNull);
    expect(encodeQr('x' * 2500)!.errorCorrectLevel, 1); // too long for M → L
  });
}
