import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/src/engine.dart';
import 'package:flutter_doc_scanner/src/scanner/crop_editor.dart';
import 'package:flutter_doc_scanner/src/scanner/editor_screen.dart';
import 'package:flutter_doc_scanner/src/scanner/pages_screen.dart';
import 'package:flutter_doc_scanner/src/scanner/result_screens.dart';
import 'package:flutter_doc_scanner/src/scanner/session.dart';
import 'package:flutter_test/flutter_test.dart';

// Figma 3.3–3.5 and 9.2 / 9.3 against a fake engine: every control does what it says and stays non-destructive.
void main() {
  final calls = <MethodCall>[];
  late String photo; // a real 30×40 image, so the crop editor can decode it

  setUpAll(() async {
    final rec = ui.PictureRecorder();
    Canvas(rec).drawRect(const Rect.fromLTWH(0, 0, 30, 40), Paint()..color = const Color(0xFF9A7658));
    final png = await (await rec.endRecording().toImage(30, 40)).toByteData(format: ui.ImageByteFormat.png);
    photo = '${Directory.systemTemp.createTempSync('review').path}/photo.png';
    File(photo).writeAsBytesSync(png!.buffer.asUint8List());
  });

  setUp(() {
    calls.clear();
    final m = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    m.setMockMethodCallHandler(const MethodChannel('flutter_doc_scanner'), (call) async {
      calls.add(call);
      final a = call.arguments is Map ? call.arguments as Map : const {};
      return switch (call.method) {
        'analyze' when (a['path'] as String).contains('back') => {
          'mode': 'passport',
          'lines': [
            {
              'text': 'I<UTOD231458907<<<<<<<<<<<<<<<',
              'box': [.05, .6, .95, .7],
            },
            {
              'text': '7408122F1204159UTO<<<<<<<<<<<6',
              'box': [.05, .7, .95, .8],
            },
            {
              'text': 'ERIKSSON<<ANNA<MARIA<<<<<<<<<<',
              'box': [.05, .8, .95, .9],
            },
          ],
        },
        'analyze' => {'mode': 'passport', 'lines': []},
        'process' when File(a['path'] as String).existsSync() => () {
          File(a['path'] as String).copySync(a['outPath'] as String);
          return {'path': a['outPath'], 'width': 30, 'height': 40};
        }(),
        _ => null,
      };
    });
    m.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => '/nonexistent');
  });

  List<MethodCall> process() => [
    for (final c in calls)
      if (c.method == 'process') c,
  ];

  Future<void> show(WidgetTester t, Widget w) async {
    t.view.physicalSize = const Size(1179, 2556);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: w));
    await t.pump(const Duration(milliseconds: 500));
  }

  Future<void> settle(WidgetTester t) async {
    for (var i = 0; i < 4; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 10)));
      await t.pump(const Duration(milliseconds: 300));
    }
  }

  ScanSession three({bool real = false}) => ScanSession()
    ..pages.addAll([
      for (final n in ['a', 'b', 'c'])
        ScanPage(real ? photo : '/nonexistent/$n.jpg', const [
          Offset(.1, .1),
          Offset(.9, .1),
          Offset(.9, .9),
          Offset(.1, .9),
        ]),
    ]);

  testWidgets('3.5 review: select + delete with undo, rotate, Save as PDF returns the pages', (t) async {
    final s = three();
    ScanResult? result;
    await show(
      t,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await Navigator.of(
            context,
          ).push<ScanResult>(MaterialPageRoute(builder: (_) => PagesScreen(session: s))),
          child: const Text('open'),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('3 Pages'), findsOneWidget);
    expect(find.text('Long-press and drag to reorder pages'), findsOneWidget);
    expect(find.text('Add page'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Rotate page 2'));
    await t.pump();
    expect(s.pages[1].rotation, 90);
    expect(process().last.arguments['rotation'], 90);

    await t.tap(find.text('Select'));
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.text('1')); // page badge
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('1 Selected'), findsOneWidget);
    await t.tap(find.text('Delete 1'));
    await t.pump(const Duration(milliseconds: 300));
    expect(s.pages.map((p) => p.original), ['/nonexistent/b.jpg', '/nonexistent/c.jpg']);
    expect(find.text('2 Pages'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 700)); // toast slides in
    await t.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await t.pump(const Duration(milliseconds: 300));
    expect(s.pages.first.original, '/nonexistent/a.jpg');

    await t.tap(find.text('Save as PDF'));
    await t.pump(const Duration(milliseconds: 500));
    expect(result!.pages, hasLength(3));
    expect(result!.title, startsWith('Scan '));
  });

  testWidgets('3.3 crop → 3.4 enhance: Auto / Full page, Next saves the crop; filter, sliders, apply to all', (
    t,
  ) async {
    final s = three(real: true);
    await show(t, CropScreen(session: s, index: 0));
    expect(find.text('Adjust Crop'), findsOneWidget);
    for (final label in ['Rotate', 'Auto', 'Perspective', 'Full page', 'Retake', 'Next', 'Reset']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await t.tap(find.text('Full page'));
    await t.pump();
    await t.tap(find.text('Rotate'));
    await t.pump();
    expect(s.pages[0].corners, isNot(fullPage)); // nothing is saved before Next
    await t.tap(find.text('Next'));
    await t.pump(const Duration(milliseconds: 500));
    await settle(t);
    expect(s.pages[0].corners, fullPage);
    expect(s.pages[0].rotation, 270);

    // Enhance for the same page.
    expect(find.text('Enhance'), findsOneWidget);
    expect(find.text('Page 1 of 3'), findsOneWidget);
    for (final f in filterNames.values) {
      expect(find.text(f, skipOffstage: false), findsOneWidget, reason: f);
    }
    await t.tap(find.text('Gray'));
    await t.pump();
    expect(s.pages[0].filter, PageFilter.gray);
    expect(process().last.arguments['filter'], 'gray');

    final slider = find.byType(Slider).first;
    await t.drag(slider, const Offset(60, 0));
    await t.pump();
    expect(s.pages[0].brightness, greaterThan(0));
    expect(process().last.arguments['brightness'], s.pages[0].brightness);

    await t.tap(find.text('Apply to all'));
    await t.pump();
    for (final p in s.pages) {
      expect(p.filter, PageFilter.gray);
      expect(p.brightness, s.pages[0].brightness);
    }
    expect(s.pages[1].corners, isNot(fullPage)); // only the enhancement is shared, not the crop
    await t.pump(const Duration(seconds: 4)); // toast
  });

  testWidgets('9.2 book result: split toggle swaps Left + Right for one Spread page', (t) async {
    final s = ScanSession();
    await show(
      t,
      BookResultScreen(
        session: s,
        photo: '/nonexistent/spread.jpg',
        spread: null,
        left: const [Offset(0, 0), Offset(.5, 0), Offset(.5, 1), Offset(0, 1)],
        right: const [Offset(.5, 0), Offset(1, 0), Offset(1, 1), Offset(.5, 1)],
      ),
    );
    await settle(t);
    expect(find.text('Pages 1–2'), findsOneWidget);
    expect(find.text('Page 1'), findsOneWidget);
    expect(find.text('1 spread scanned · 2 pages'), findsOneWidget);
    expect([for (final p in s.pages) p.label], ['Left', 'Right']);
    expect(find.text('Flatten page curves'), findsNothing); // no dewarp in the engine yet, so no fake toggle

    await t.tap(find.byType(Switch));
    await settle(t);
    expect([for (final p in s.pages) p.label], ['Spread']);
    expect(s.pages.single.corners, isNull);
    expect(find.text('Pages 1–2'), findsNWidgets(2)); // title + chip under the single image
    await t.tap(find.byType(Switch));
    await settle(t);
    expect([for (final p in s.pages) p.label], ['Left', 'Right']);
  });

  testWidgets('9.3 ID result: layouts map to the export grouping; details come from the MRZ', (t) async {
    final s = ScanSession();
    final front = ScanPage('/nonexistent/front.jpg', null, label: 'ID front', group: 'g');
    final back = ScanPage('/nonexistent/back.jpg', null, label: 'ID back', group: 'g');
    s.pages.addAll([front, back]);
    await show(t, IdResultScreen(session: s, front: front, back: back));
    await settle(t);
    expect(find.text('Anna Maria Eriksson'), findsOneWidget);
    expect(find.text('D23145890'), findsOneWidget);
    expect(find.text('12 Aug 1974'), findsOneWidget);

    await t.tap(find.text('Side by side'));
    await t.pump(const Duration(milliseconds: 400));
    expect(front.sideBySide && back.sideBySide, isTrue);
    expect(front.group, 'g');
    await t.tap(find.text('Separate'));
    await t.pump(const Duration(milliseconds: 400));
    expect(front.group, isNull);
    expect(back.group, isNull);
    await t.tap(find.text('Stacked'));
    await t.pump(const Duration(milliseconds: 400));
    expect(front.group, 'g');
    expect(front.sideBySide, isFalse);
  });

  testWidgets('9.3 ID result without an MRZ says so instead of inventing fields', (t) async {
    final s = ScanSession();
    final front = ScanPage('/nonexistent/f.jpg', null, group: 'g');
    final back = ScanPage('/nonexistent/b2.jpg', null, group: 'g');
    await show(t, IdResultScreen(session: s, front: front, back: back));
    await settle(t);
    expect(find.textContaining('no machine-readable zone'), findsOneWidget);
    expect(find.text('Copy all'), findsNothing);
  });
}
