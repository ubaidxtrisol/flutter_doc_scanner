// On-device AR smoke test (needs ARCore). Run on a phone:
//   flutter test integration_test/ar_measure_test.dart -d <device>
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AR streams frames, then hands the camera back to the scanner', (tester) async {
    final frames = <ArFrame>[];
    final sub = ArMeasure.frames.listen(frames.add);
    final sw = Stopwatch()..start();
    final id = await ArMeasure.start(9 / 16);
    await tester.pumpWidget(Center(child: SizedBox(width: 360, height: 640, child: ArPreviewView(id))));
    for (var i = 0; i < 60; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
    }
    // Anchor + move (corner drag) round trip, when the phone can see enough to track.
    final tracked = frames.lastWhere((f) => f.isTracking && f.hit != null, orElse: () => frames.last);
    if (tracked.isTracking && tracked.hit != null) {
      final at = tracked.hit!;
      expect(await ArMeasure.add(at: at), isTrue);
      final moved = at + Vector3(.1, 0, 0);
      await ArMeasure.move(0, moved);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      final p = frames.last.points.single;
      debugPrint('ar move: requested ${moved.distanceTo(at)} m, anchor now ${p.distanceTo(moved)} m from target');
      expect(p.distanceTo(moved), lessThan(.02));
    } else {
      debugPrint('ar move: skipped (not tracking, point the phone at a lit surface)');
    }
    await ArMeasure.stop();
    await sub.cancel();

    final withMatrix = frames.where((f) => f.viewProjection != null).length;
    debugPrint('ar: ${frames.length} frames in ${sw.elapsedMilliseconds} ms, $withMatrix with matrix, '
        'states ${frames.map((f) => '${f.tracking}/${f.reason}').toSet()}, '
        'hits ${frames.where((f) => f.hit != null).length}');
    expect(withMatrix, greaterThan(60)); // ~30 fps for 6 s, allowing for camera start-up

    // Camera must be free again for the document scanner.
    final preview = await DocScanner.start(ScanMode.document);
    expect(preview.size.isEmpty, isFalse);
    await DocScanner.stop();
  });
}
