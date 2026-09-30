import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/count/count_screen.dart';
import 'package:flutter_doc_scanner/src/scanner/session.dart';

import 'counter_test.dart' as scene;

void main() {
  testWidgets('counts, stepper, tap-to-remove and kind switch (Figma 7.5)', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // A synthetic photo: 10 wooden buttons on a brown table.
    final photo = '${Directory.systemTemp.createTempSync().path}/buttons.png';
    await tester.runAsync(() async {
      final buffer = await ui.ImmutableBuffer.fromUint8List(scene.buttons(scene.grid(10)));
      final desc = ui.ImageDescriptor.raw(buffer, width: scene.w, height: scene.h, pixelFormat: ui.PixelFormat.rgba8888);
      final image = (await (await desc.instantiateCodec()).getNextFrame()).image;
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(photo).writeAsBytes(png!.buffer.asUint8List());
    });
    // Fake engine: "process" just copies the image (it's already small and upright).
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_doc_scanner'), (call) async {
      if (call.method == 'process') File(call.arguments['path'] as String).copySync(call.arguments['outPath'] as String);
      return null;
    });

    await tester.pumpWidget(MaterialApp(home: CountScreen(photo: photo, session: ScanSession())));
    // Decoding and the counting isolate run on real time; their continuations need frames to run.
    Future<void> settle() async {
      for (var i = 0; i < 10; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
        await tester.pump();
      }
    }

    await settle();
    expect(find.text('10'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
    expect(find.text('9'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.text('11'), findsOneWidget);

    await tester.ensureVisible(find.text('Custom'));
    await tester.tap(find.text('Custom'));
    await tester.pump();
    expect(find.text('Tap one object to count ones like it'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.ensureVisible(find.text('Round objects'));
    await tester.tap(find.text('Round objects'));
    await settle();
    expect(find.text('10'), findsOneWidget);
  });
}
