import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import '../engine.dart';
import 'crop_editor.dart' show fullPage;

/// Splits a photographed two-page spread into left and right page quads (normalized, TL, TR, BR, BL).
/// Null [spread] means the whole photo is the spread.
Future<(List<Offset>, List<Offset>)> splitSpread(String photo, List<Offset>? spread) async {
  final quad = spread ?? fullPage;
  final small = '$photo.gutter.jpg';
  await DocScanner.process(path: photo, outPath: small, corners: quad, filter: PageFilter.gray, maxSize: 480);
  final bytes = await File(small).readAsBytes();
  File(small).delete().ignore();
  final image = (await (await instantiateImageCodec(bytes)).getNextFrame()).image;
  final rgba = (await image.toByteData(format: ImageByteFormat.rawRgba))!;
  final w = image.width, h = image.height;
  final columns = List<double>.filled(w, 0);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      columns[x] += rgba.getUint8((y * w + x) * 4);
    }
  }
  image.dispose();
  return splitQuad(quad, findGutter([for (final c in columns) c / h]));
}

/// Fold position (0..1) from per-column mean brightness (0..255) across the rectified spread:
/// the darkest smoothed column in the middle 30%, or the center if there is no clear fold shadow.
double findGutter(List<double> columns) {
  final n = columns.length;
  double smooth(int i) {
    var s = 0.0, k = 0;
    for (var j = math.max(0, i - 3); j <= math.min(n - 1, i + 3); j++, k++) {
      s += columns[j];
    }
    return s / k;
  }

  var best = -1;
  var bestValue = double.infinity;
  for (var i = (n * .35).floor(); i < (n * .65).ceil(); i++) {
    final v = smooth(i);
    if (v < bestValue) (best, bestValue) = (i, v);
  }
  // Smoothing flattens the dip; refine to the darkest raw column inside it.
  for (var j = math.max(0, best - 3); j <= math.min(n - 1, best + 3); j++) {
    if (columns[j] < columns[best]) best = j;
  }
  final sorted = [...columns]..sort();
  final median = sorted[n ~/ 2];
  return median - bestValue < 6 ? .5 : (best + .5) / n;
}

/// Maps (u, v) of the unit square onto quad [q] (TL, TR, BR, BL) with a projective map (Heckbert),
/// so straight lines on the flattened page stay on the right line in the photo.
Offset quadPoint(List<Offset> q, double u, double v) {
  final (x0, y0, x1, y1) = (q[0].dx, q[0].dy, q[1].dx, q[1].dy);
  final (x2, y2, x3, y3) = (q[2].dx, q[2].dy, q[3].dx, q[3].dy);
  final sx = x0 - x1 + x2 - x3, sy = y0 - y1 + y2 - y3;
  double a, b, c = x0, d, e, f = y0, g = 0, h = 0;
  if (sx.abs() < 1e-12 && sy.abs() < 1e-12) {
    (a, b, d, e) = (x1 - x0, x3 - x0, y1 - y0, y3 - y0);
  } else {
    final dx1 = x1 - x2, dx2 = x3 - x2, dy1 = y1 - y2, dy2 = y3 - y2;
    final det = dx1 * dy2 - dx2 * dy1;
    g = (sx * dy2 - dx2 * sy) / det;
    h = (dx1 * sy - sx * dy1) / det;
    (a, b, d, e) = (x1 - x0 + g * x1, x3 - x0 + h * x3, y1 - y0 + g * y1, y3 - y0 + h * y3);
  }
  final w = g * u + h * v + 1;
  return Offset((a * u + b * v + c) / w, (d * u + e * v + f) / w);
}

/// Left and right page quads for a fold at [t] across the spread.
(List<Offset>, List<Offset>) splitQuad(List<Offset> q, double t) {
  final top = quadPoint(q, t, 0), bottom = quadPoint(q, t, 1);
  return ([q[0], top, bottom, q[3]], [top, q[1], q[2], bottom]);
}
