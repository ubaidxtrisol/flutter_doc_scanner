import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/count/counter.dart';

const w = 480, h = 640;

/// A noisy flat background, like a photographed table.
Uint8List table((int, int, int) c, {int seed = 1}) {
  final rnd = math.Random(seed), px = Uint8List(w * h * 4);
  for (var i = 0; i < w * h; i++) {
    final n = rnd.nextInt(13) - 6;
    px
      ..[i * 4] = (c.$1 + n).clamp(0, 255)
      ..[i * 4 + 1] = (c.$2 + n).clamp(0, 255)
      ..[i * 4 + 2] = (c.$3 + n).clamp(0, 255)
      ..[i * 4 + 3] = 255;
  }
  return px;
}

void paint(Uint8List px, bool Function(int x, int y) inside, (int, int, int) c) {
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (!inside(x, y)) continue;
      final i = (y * w + x) * 4;
      px
        ..[i] = c.$1
        ..[i + 1] = c.$2
        ..[i + 2] = c.$3;
    }
  }
}

void disc(Uint8List px, double cx, double cy, double r, (int, int, int) c) =>
    paint(px, (x, y) => (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r, c);

const brown = (110, 84, 58), wood = (214, 178, 118), shine = (250, 244, 228);

/// Figma 7.5-like: wooden buttons with a shiny highlight (must not become a hole or a second object).
Uint8List buttons(List<(double, double)> centers, {double r = 22}) {
  final px = table(brown);
  for (final (x, y) in centers) {
    disc(px, x, y, r, wood);
    disc(px, x - r / 3, y - r / 3, r / 4, shine);
  }
  return px;
}

List<(double, double)> grid(int n) => [for (var i = 0; i < n; i++) (60.0 + (i % 5) * 85, 70.0 + (i ~/ 5) * 100)];

void main() {
  test('counts the Figma scene: 23 round buttons with highlights', () {
    expect(countObjects(buttons(grid(23)), w, h, CountKind.round).length, 23);
  });

  test('touching objects are counted separately', () {
    final centers = [...grid(7), (120.0, 560.0), (160.0, 560.0), (300.0, 560.0), (340.0, 560.0), (320.0, 596.0)];
    final found = countObjects(buttons(centers), w, h, CountKind.round);
    expect(found.length, 12);
  });

  test('markers land on the objects and read in rows', () {
    final found = countObjects(buttons(grid(10)), w, h, CountKind.round);
    for (final (i, c) in found.indexed) {
      final (x, y) = grid(10)[i];
      expect((c.x * w - x).abs() < 4 && (c.y * h - y).abs() < 4, isTrue, reason: 'marker $i at ${c.x * w},${c.y * h}');
    }
  });

  test('boxes mode counts boxes; round mode rejects long sticks', () {
    final px = table(brown);
    for (var i = 0; i < 12; i++) {
      final x = 50 + (i % 4) * 110, y = 60 + (i ~/ 4) * 150;
      paint(px, (a, b) => a >= x && a < x + 70 && b >= y && b < y + 50, (200, 200, 205));
    }
    paint(px, (a, b) => a >= 40 && a < 440 && b >= 540 && b < 552, (200, 200, 205)); // a stick
    expect(countObjects(px, w, h, CountKind.boxes).length, 13);
    expect(countObjects(px, w, h, CountKind.round).length, 12);
  });

  test('custom: tap one object, count only its kind', () {
    final px = table(brown);
    final blue = <(double, double)>[];
    for (final (i, (x, y)) in grid(20).indexed) {
      disc(px, x, y, 20, i.isEven ? (40, 90, 200) : (200, 50, 50));
      if (i.isEven) blue.add((x, y));
    }
    final found = countObjects(px, w, h, CountKind.custom, sample: (blue.first.$1 / w, blue.first.$2 / h));
    expect(found.length, 10);
  });

  test('subtle objects on white still count; an empty table counts zero', () {
    final px = table((236, 235, 230));
    for (final (x, y) in grid(9)) {
      disc(px, x, y, 22, (212, 211, 206));
    }
    expect(countObjects(px, w, h, CountKind.round).length, 9);
    expect(countObjects(table(brown), w, h, CountKind.round), isEmpty);
  });

  test('fast enough to feel instant', () {
    final px = buttons(grid(23));
    final sw = Stopwatch()..start();
    countObjects(px, w, h, CountKind.round);
    expect(sw.elapsedMilliseconds, lessThan(400), reason: '${sw.elapsedMilliseconds} ms in the test VM');
  });
}
