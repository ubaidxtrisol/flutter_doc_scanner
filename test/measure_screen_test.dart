import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/measure/geometry.dart';
import 'package:flutter_doc_scanner/src/measure/measure.dart';
import 'package:flutter_doc_scanner/src/engine.dart' show PageFilter;
import 'package:flutter_doc_scanner/src/scanner.dart';
import 'package:flutter_doc_scanner/src/scanner/session.dart';
import 'package:flutter_doc_scanner/src/scanner/scanner_screen.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

// Measure tab (Figma 7.6) against a fake AR engine: engine swap, guidance, add / close / undo, units.
void main() {
  late void Function(Map<String, Object?>) emit;
  final calls = <String>[];
  final adds = <List<double>?>[];
  final moves = <Map>[];
  var aspect = .75;
  final tmp = Directory.systemTemp.createTempSync('measure_test');
  // What the fake AR view "shows": a 60 × 80 JPEG (the viewport's 3:4 aspect).
  final shot = base64Decode(
    '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAA0JCgsKCA0LCgsODg0PEyAVExISEyccHhcgLikxMC4pLSwzOko+MzZGNywtQFdBRkxOUlNSMj5aYVpQYEpRUk//2wBDAQ4ODhMREyYVFSZPNS01T09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0//wAARCABQADwDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwCmBSgU4ClArC5umIBSgUoFOApXNExAKUClApwFTc1TGgU7FKBTsUrmiZXApwFKBTgKdzzkxoFOApQKcBU3NExoFOApQKcBSuapjQKXFOApcVNzRMgApwFKBTgKq55yY0CnAUoFOAqbmiY0CnAUoFKBSuapiAUuKcBS4qbmiZABSgU4ClAqrnnJiAUoFOApQKm5qmIBSgU4ClApXNExAKXFOApcVNzVMgApQKcBSgVVzzUxAKUCnAUoFTc1TEApQKcBSgUrmiYgFLinAUuKm5qmf//Z',
  );

  // Camera at the origin looking down -z; a 1 × 1 m square 2 m away.
  Matrix4 vp() => makePerspectiveMatrix(math.pi / 2, aspect, .05, 100);
  final square = [Vector3(-.5, .5, -2), Vector3(.5, .5, -2), Vector3(.5, -.5, -2), Vector3(-.5, -.5, -2)];

  setUp(() {
    calls.clear();
    adds.clear();
    moves.clear();
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('flutter_doc_scanner'), (call) async {
      calls.add(call.method);
      return switch (call.method) {
        'start' => {'textureId': 1, 'width': 1080, 'height': 1440, 'quarterTurns': 0},
        'arStart' => {'textureId': 2, 'aspect': aspect = (call.arguments as Map)['aspect'] as double},
        'arMove' => moves.add(call.arguments as Map),
        'arAdd' => (adds..add(((call.arguments as Map)['at'] as List?)?.cast<double>())).isNotEmpty,
        'arSnapshot' => {
          'path': (File('${tmp.path}/ar_${calls.length}.jpg')..writeAsBytesSync(shot)).path,
          'points': [
            for (final p in square) ...[p.x, p.y, p.z],
          ],
          'vp': vp().storage.toList(),
        },
        _ => null,
      };
    });
    messenger.setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => tmp.path);
    messenger.setMockStreamHandler(
      const EventChannel('flutter_doc_scanner/detections'),
      MockStreamHandler.inline(onListen: (_, _) {}),
    );
    messenger.setMockStreamHandler(
      const EventChannel('flutter_doc_scanner/ar'),
      MockStreamHandler.inline(
        onListen: (_, sink) {
          emit = sink.success;
        },
      ),
    );
  });

  Future<void> frame(
    WidgetTester tester, {
    String tracking = 'tracking',
    String reason = 'none',
    bool hit = true,
    int points = 0,
  }) async {
    emit({
      'tracking': tracking,
      'reason': reason,
      'hit': hit ? [0.0, 0.0, -2.0] : null,
      'points': [
        for (final p in square.take(points)) ...[p.x, p.y, p.z],
      ],
      'vp': vp().storage.toList(),
    });
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }

  testWidgets('measure flow: swap engines, guide, add, close, units, undo, leave', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: ScannerScreen()));
    await tester.pump();

    await tester.ensureVisible(find.text('Measure').last);
    await tester.pump();
    await tester.tap(find.text('Measure').last);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(calls, containsAllInOrder(['stop', 'arStart']));
    expect(find.text('Starting AR…'), findsOneWidget);
    expect(find.text('Import from gallery'), findsNothing);

    await frame(tester, tracking: 'paused', reason: 'excessive_motion', hit: false);
    expect(find.text('Move your phone more slowly'), findsOneWidget);

    await frame(tester, hit: false);
    expect(find.text('Point the circle at a surface'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Add point'));
    await tester.pump();
    expect(calls, isNot(contains('arAdd')), reason: '+ is disabled off-surface');

    await frame(tester);
    expect(find.text('Tap + to drop points'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Add point'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    expect(calls, contains('arAdd'));

    await frame(tester, points: 4);
    expect(find.text('Tap the first point to close the shape'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^4 points\. Sides 1\.0 m, 1\.0 m, 1\.0 m$', multiLine: true)),
      findsOneWidget,
    );

    // Tap the first point to close.
    final view = tester.getRect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MeasurePainter));
    final first = project(vp(), square.first)!;
    await tester.tapAt(view.topLeft + Offset(first.dx * view.width, first.dy * view.height));
    await tester.pump();
    expect(
      find.bySemanticsLabel(RegExp(r'^Area 1\.00 m²\. Sides 1\.0 m, 1\.0 m, 1\.0 m, 1\.0 m$', multiLine: true)),
      findsOneWidget,
    );
    expect(find.text('Tap the first point to close the shape'), findsNothing);

    await tester.tap(find.bySemanticsLabel(RegExp('^Feet')));
    await tester.pump();
    expect(find.bySemanticsLabel(RegExp(r'^Area 10\.8 ft²\. Sides 3\.3 ft')), findsOneWidget);

    // Undo on a closed shape reopens it without removing a point.
    await tester.tap(find.bySemanticsLabel('Undo'));
    await tester.pump();
    expect(find.text('Tap the first point to close the shape'), findsOneWidget);
    expect(calls, isNot(contains('arUndo')));

    calls.clear();
    await tester.pump(const Duration(seconds: 1));
    await tester.ensureVisible(find.text('Count').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Count').last);
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(calls, containsAllInOrder(['arStop', 'start']));
    expect(find.text('Point at the objects, then tap the shutter'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('AR unsupported shows a friendly message', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_doc_scanner'),
      (call) async {
        if (call.method == 'arStart') throw PlatformException(code: 'AR_UNSUPPORTED');
        return call.method == 'start' ? {'textureId': 1, 'width': 1080, 'height': 1440, 'quarterTurns': 0} : null;
      },
    );
    await tester.pumpWidget(const MaterialApp(home: ScannerScreen()));
    await tester.pump();
    await tester.ensureVisible(find.text('Measure').last);
    await tester.tap(find.text('Measure').last);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("AR isn't available on this phone"), findsOneWidget);
  });

  testWidgets('walls: the first point locks the surface, later points land on it even with no hits', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ScannerScreen()));
    await tester.pump();
    await tester.ensureVisible(find.text('Measure').last);
    await tester.pump();
    await tester.tap(find.text('Measure').last);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 300));

    // Fake engine: anchors sit where they were added, optionally moved by an ARCore map correction [shiftZ].
    Future<void> aim(Vector3 dir, {List<double>? hit, double shiftZ = 0}) async {
      final vp =
          makePerspectiveMatrix(math.pi / 2, aspect, .05, 100) * makeViewMatrix(Vector3.zero(), dir, Vector3(0, 1, 0));
      emit({
        'tracking': 'tracking',
        'hit': hit,
        'normal': hit == null ? null : [0.0, 0.0, 1.0], // wall facing the camera, estimated from depth
        'kind': hit == null ? null : 'depth',
        'points': [
          for (final a in adds) ...[a![0], a[1], a[2] + shiftZ],
        ],
        'vp': vp.storage.toList(),
      });
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }

    Future<void> plus() async {
      await tester.tap(find.bySemanticsLabel('Add point'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }

    // A noisy depth hit 2 cm in front of the wall starts the shape.
    await aim(Vector3(0, 0, -1), hit: [0.0, 0.0, -1.98]);
    await plus();
    expect(adds.single, [0.0, 0.0, -1.98]);

    // Blank wall: no hit at all, yet "+" works and the point lands on the locked plane z = -1.98.
    await aim(Vector3(1, 0, -2));
    expect(find.text('Tap + to add the next corner'), findsOneWidget);
    await plus();
    expect(adds.last![0], closeTo(.99, 1e-6));
    expect(adds.last![2], closeTo(-1.98, 1e-6));

    // Turning away from the wall (edge-on) asks to aim back instead of dropping a point somewhere wrong.
    await aim(Vector3(1, 0, 0));
    expect(find.text('Aim back at the same surface'), findsOneWidget);
    await plus();
    expect(adds, hasLength(2));

    // ARCore corrects its map: the anchors (and the real wall) are now 4 cm further. The next point follows the
    // live first anchor instead of the stale wall position.
    await aim(Vector3(0, 1, -2), shiftZ: -.04);
    await plus();
    expect(adds.last![2], closeTo(-2.02, 1e-6));
  });

  testWidgets('first point: jittery depth hits are averaged while the aim holds still', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: ScannerScreen()));
    await tester.pump();
    await tester.ensureVisible(find.text('Measure').last);
    await tester.pump();
    await tester.tap(find.text('Measure').last);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 300));

    for (final z in [-2.012, -1.991, -2.009, -1.988, -2.006, -1.994]) {
      emit({
        'tracking': 'tracking',
        'hit': [0.0, 0.0, z],
        'points': <double>[],
        'vp': vp().storage.toList(),
      });
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 5)));
    }
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Add point'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    expect(adds.single![2], closeTo(-2, 1e-9)); // the last raw hit alone was 6 mm off
  });

  testWidgets('drag a corner: slides on the surface, area updates live, anchor moves on release', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const MaterialApp(home: ScannerScreen()));
    await tester.pump();
    await tester.ensureVisible(find.text('Measure').last);
    await tester.pump();
    await tester.tap(find.text('Measure').last);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump(const Duration(milliseconds: 300));

    await frame(tester, points: 4);
    final view = tester.getRect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MeasurePainter));
    Offset px(Vector3 p) {
      final n = project(vp(), p)!;
      return view.topLeft + Offset(n.dx * view.width, n.dy * view.height);
    }

    await tester.tapAt(px(square.first));
    await tester.pump();
    expect(find.text('Drag a corner to adjust'), findsOneWidget);

    // Grab 10 px off the corner (no jump), drag it half a meter left along the wall.
    final start = px(square.first) + const Offset(10, 0);
    final gesture = await tester.startGesture(start);
    await tester.pump();
    final delta = px(Vector3(-1, .5, -2)) - px(square.first);
    for (var i = 1; i <= 4; i++) {
      await gesture.moveTo(start + delta * (i / 4));
      await tester.pump();
    }
    expect(
      find.bySemanticsLabel(RegExp(r'^Area 1\.25 m²\. Sides 1\.5 m, 1\.0 m, 1\.0 m, 1\.1 m$', multiLine: true)),
      findsOneWidget,
    );
    expect(find.byType(RawMagnifier), findsOneWidget);

    await gesture.up();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    expect(moves, hasLength(1));
    expect(moves.single['index'], 0);
    final at = (moves.single['at'] as List).cast<double>();
    expect(Vector3(at[0], at[1], at[2]).distanceTo(Vector3(-1, .5, -2)), lessThan(1e-6));
    expect(find.byType(RawMagnifier), findsNothing);
    semantics.dispose();
  });

  testWidgets('save: a closed shape exports the AR snapshot with the shape and details as a card page', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final semantics = tester.ensureSemantics();
    ScanResult? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await Scanner.open(context, tab: ScannerTab.measure),
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
    expect(calls, contains('arStart'));

    await frame(tester, points: 4);
    expect(find.bySemanticsLabel(RegExp('^Save measurement')), findsNothing, reason: 'no area yet');
    final view = tester.getRect(find.byWidgetPredicate((w) => w is CustomPaint && w.painter is MeasurePainter));
    final first = project(vp(), square.first)!;
    await tester.tapAt(view.topLeft + Offset(first.dx * view.width, first.dy * view.height));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300)); // the pill pops in
    expect(find.bySemanticsLabel(RegExp('^Save measurement')), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('^Save measurement')));
    await tester.pump();
    expect(find.bySemanticsLabel(RegExp('^Saving measurement')), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(RegExp('^Saving measurement'))); // busy: a second tap does nothing
    for (var i = 0; i < 20 && find.text('Added to your scan').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(calls.where((c) => c == 'arSnapshot'), hasLength(1));
    // The card joins the scan and the user is asked what's next; the scanner stays open.
    await tester.pump(const Duration(milliseconds: 400)); // sheet slide-in
    expect(result, isNull);
    expect(find.text('Area · 1.00 m² · 1 page so far'), findsOneWidget);
    expect(find.text('Measure another area'), findsOneWidget);
    await tester.tap(find.text('Save PDF'));
    for (var i = 0; i < 10 && result == null; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(result, isNotNull);
    expect(result!.title, 'Area · 1.00 m²');
    final page = result!.pages.single;
    expect(page.label, 'Area');
    expect(page.filter, PageFilter.original);
    expect(File(page.original).existsSync(), isTrue);
    // A4 card at 2.5×, and the snapshot itself was cleaned up.
    final size = await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(File(page.original).readAsBytesSync());
      final image = (await codec.getNextFrame()).image;
      return Size(image.width.toDouble(), image.height.toDouble());
    });
    expect(size, const Size(1488, 2105));
    expect(tmp.listSync().whereType<File>().where((f) => f.path.endsWith('.jpg')), isEmpty);
    semantics.dispose();
  });
}
