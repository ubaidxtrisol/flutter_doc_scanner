/// Object counting on a still photo (Figma 7.5), pure Dart so it runs identically on both platforms
/// and is unit-testable without a device. Works on a ~640 px RGBA copy of the photo.
///
/// 1. Reference colour: the background (median of the image border), or the colour under a tapped sample.
/// 2. Per-pixel Lab distance from it → Otsu threshold → foreground mask (holes filled, specks removed).
/// 3. Connected blobs. The typical object size is the median blob (or the tapped one); a blob about k times
///    that size is k touching objects, split with k-means so each gets its own marker.
/// 4. Shape filter per kind: round (fills its bounding circle), boxes (fills its bounding box).
library;

import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

enum CountKind { round, boxes, custom }

/// One counted object: center in 0..1 image coordinates, radius as a fraction of image width.
class Counted {
  const Counted(this.x, this.y, this.r);
  final double x, y, r;
}

/// [countObjects] on a background isolate. Top-level on purpose: a closure created inside a widget
/// method shares that method's capture context and would try to send the whole State to the isolate.
Future<List<Counted>> countInBackground(Uint8List rgba, int w, int h, CountKind kind, {(double, double)? sample}) =>
    Isolate.run(() => countObjects(rgba, w, h, kind, sample: sample));

/// [rgba] is [w]×[h] RGBA. [sample] (0..1) picks the object colour for [CountKind.custom].
List<Counted> countObjects(Uint8List rgba, int w, int h, CountKind kind, {(double, double)? sample}) {
  final n = w * h;
  final lab = Float32List(n * 3);
  for (var i = 0; i < n; i++) {
    _lab(rgba[i * 4], rgba[i * 4 + 1], rgba[i * 4 + 2], lab, i * 3);
  }

  // 1. Reference colour.
  final custom = kind == CountKind.custom && sample != null;
  final ref = custom
      ? _meanAround(lab, w, h, (sample.$1 * w).round(), (sample.$2 * h).round())
      : _borderMedian(lab, w, h);

  // 2. Distance map → Otsu → mask. Lightness counts a bit less than colour, so soft shadows don't
  //    become objects.
  final dist = Uint8List(n);
  for (var i = 0; i < n; i++) {
    final dl = .6 * (lab[i * 3] - ref[0]), da = lab[i * 3 + 1] - ref[1], db = lab[i * 3 + 2] - ref[2];
    dist[i] = math.min(255, 2 * math.sqrt(dl * dl + da * da + db * db)).round();
  }
  final (t, separation) = _otsu(dist);
  // Otsu always splits something; if the two sides barely differ, it's just background noise.
  // Measured: an empty noisy table separates by ~1.7, faint grey-on-white objects by ~8.6, typical scenes 50+.
  if (!custom && separation < 5) return const [];
  var mask = Uint8List(n);
  for (var i = 0; i < n; i++) {
    mask[i] = (custom ? dist[i] <= t : dist[i] > t) ? 1 : 0;
  }
  mask = _open(_fillHoles(mask, w, h), w, h);

  // 3. Blobs.
  final blobs = _components(mask, w, h).where((b) => b.area >= math.max(12, n * .0002) && b.area < n * .25).toList();
  if (blobs.isEmpty) return const [];
  double unit;
  if (custom) {
    final sx = (sample.$1 * w).round(), sy = (sample.$2 * h).round();
    final picked = blobs.reduce((a, b) => a.distanceTo(sx, sy) <= b.distanceTo(sx, sy) ? a : b);
    unit = picked.area.toDouble();
  } else {
    final areas = blobs.map((b) => b.area).toList()..sort();
    unit = areas[areas.length ~/ 2].toDouble();
  }
  final r = math.sqrt(unit / math.pi) / w;

  final out = <Counted>[];
  for (final b in blobs) {
    final ratio = b.area / unit;
    if (ratio < .4) continue; // crumbs, reflections, text
    final k = ratio < 1.5 ? 1 : ratio.round();
    if (k == 1 && !_shapeOk(b, kind)) continue;
    for (final (x, y) in k == 1 ? [(b.cx, b.cy)] : _kmeans(b, k)) {
      out.add(Counted(x / w, y / h, r));
    }
  }
  // Reading order: top-to-bottom rows, then left-to-right, so markers number the way people count.
  final rowH = 2 * r * w / h;
  out.sort((a, b) {
    final ra = (a.y / rowH).floor(), rb = (b.y / rowH).floor();
    return ra != rb ? ra - rb : a.x.compareTo(b.x);
  });
  return out;
}

bool _shapeOk(_Blob b, CountKind kind) {
  final bw = b.maxX - b.minX + 1, bh = b.maxY - b.minY + 1;
  final aspect = math.max(bw, bh) / math.min(bw, bh);
  return switch (kind) {
    // Fills most of its bounding circle and isn't a stick.
    CountKind.round => aspect <= 1.8 && b.area / (math.pi * math.pow(math.max(bw, bh) / 2, 2)) > .5,
    // Fills its bounding box (a 45°-rotated square still fills half of it).
    CountKind.boxes => b.area / (bw * bh) > .45,
    CountKind.custom => true,
  };
}

// ─── Colour ───────────────────────────────────────────────────────────────────────────────────

void _lab(int r8, int g8, int b8, Float32List out, int o) {
  double lin(int c) {
    final v = c / 255;
    return v <= .04045 ? v / 12.92 : math.pow((v + .055) / 1.055, 2.4).toDouble();
  }

  final r = lin(r8), g = lin(g8), b = lin(b8);
  final x = (r * .4124 + g * .3576 + b * .1805) / .95047;
  final y = r * .2126 + g * .7152 + b * .0722;
  final z = (r * .0193 + g * .1192 + b * .9505) / 1.08883;
  double f(double v) => v > .008856 ? math.pow(v, 1 / 3).toDouble() : 7.787 * v + 16 / 116;
  final fx = f(x), fy = f(y), fz = f(z);
  out[o] = 116 * fy - 16;
  out[o + 1] = 500 * (fx - fy);
  out[o + 2] = 200 * (fy - fz);
}

List<double> _borderMedian(Float32List lab, int w, int h) {
  final band = math.max(2, (math.min(w, h) * .04).round());
  final chans = [<double>[], <double>[], <double>[]];
  for (var y = 0; y < h; y += 2) {
    for (var x = 0; x < w; x += 2) {
      if (x >= band && x < w - band && y >= band && y < h - band) continue;
      for (var c = 0; c < 3; c++) {
        chans[c].add(lab[(y * w + x) * 3 + c]);
      }
    }
  }
  return [for (final c in chans) (c..sort())[c.length ~/ 2]];
}

List<double> _meanAround(Float32List lab, int w, int h, int cx, int cy) {
  final s = [0.0, 0.0, 0.0];
  var k = 0;
  for (var y = math.max(0, cy - 2); y <= math.min(h - 1, cy + 2); y++) {
    for (var x = math.max(0, cx - 2); x <= math.min(w - 1, cx + 2); x++) {
      for (var c = 0; c < 3; c++) {
        s[c] += lab[(y * w + x) * 3 + c];
      }
      k++;
    }
  }
  return [for (final v in s) v / k];
}

/// Otsu threshold and the gap between the two class means (how real the split is).
(int, double) _otsu(Uint8List v) {
  final hist = List<int>.filled(256, 0);
  for (final x in v) {
    hist[x]++;
  }
  final total = v.length;
  var sum = 0.0;
  for (var i = 0; i < 256; i++) {
    sum += i * hist[i];
  }
  var sumB = 0.0, wB = 0, best = 0.0, t = 0, gap = 0.0;
  for (var i = 0; i < 256; i++) {
    wB += hist[i];
    if (wB == 0) continue;
    final wF = total - wB;
    if (wF == 0) break;
    sumB += i * hist[i];
    final mB = sumB / wB, mF = (sum - sumB) / wF;
    final between = wB * wF * (mB - mF) * (mB - mF);
    if (between > best) (best, t, gap) = (between, i, mF - mB);
  }
  return (t, gap);
}

// ─── Morphology and blobs ─────────────────────────────────────────────────────────────────────

/// Background pixels not reachable from the border are holes (e.g. a shiny highlight on a coin).
Uint8List _fillHoles(Uint8List m, int w, int h) {
  final outside = Uint8List(w * h);
  final stack = <int>[];
  void seed(int i) {
    if (m[i] == 0 && outside[i] == 0) {
      outside[i] = 1;
      stack.add(i);
    }
  }

  for (var x = 0; x < w; x++) {
    seed(x);
    seed((h - 1) * w + x);
  }
  for (var y = 0; y < h; y++) {
    seed(y * w);
    seed(y * w + w - 1);
  }
  while (stack.isNotEmpty) {
    final i = stack.removeLast(), x = i % w, y = i ~/ w;
    if (x > 0) seed(i - 1);
    if (x < w - 1) seed(i + 1);
    if (y > 0) seed(i - w);
    if (y < h - 1) seed(i + w);
  }
  return Uint8List.fromList([for (var i = 0; i < w * h; i++) outside[i] == 1 ? 0 : 1]);
}

/// 3×3 erode then dilate: removes specks and thin bridges between touching objects.
Uint8List _open(Uint8List m, int w, int h) {
  Uint8List pass(Uint8List src, bool erode) {
    final out = Uint8List(w * h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        var v = erode ? 1 : 0;
        for (var dy = -1; dy <= 1 && v == (erode ? 1 : 0); dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            final xx = x + dx, yy = y + dy;
            final s = xx < 0 || yy < 0 || xx >= w || yy >= h ? 0 : src[yy * w + xx];
            if (erode ? s == 0 : s == 1) {
              v = erode ? 0 : 1;
              break;
            }
          }
        }
        out[y * w + x] = v;
      }
    }
    return out;
  }

  return pass(pass(m, true), false);
}

class _Blob {
  final pixels = <int>[];
  int area = 0, minX = 1 << 30, minY = 1 << 30, maxX = 0, maxY = 0;
  double sx = 0, sy = 0;
  late int w;
  double get cx => sx / area;
  double get cy => sy / area;
  double distanceTo(int x, int y) => (cx - x) * (cx - x) + (cy - y) * (cy - y);
}

List<_Blob> _components(Uint8List m, int w, int h) {
  final seen = Uint8List(w * h);
  final blobs = <_Blob>[];
  final stack = <int>[];
  for (var start = 0; start < w * h; start++) {
    if (m[start] == 0 || seen[start] == 1) continue;
    final b = _Blob()..w = w;
    seen[start] = 1;
    stack.add(start);
    while (stack.isNotEmpty) {
      final i = stack.removeLast(), x = i % w, y = i ~/ w;
      b
        ..pixels.add(i)
        ..area += 1
        ..sx += x
        ..sy += y;
      if (x < b.minX) b.minX = x;
      if (x > b.maxX) b.maxX = x;
      if (y < b.minY) b.minY = y;
      if (y > b.maxY) b.maxY = y;
      for (final j in [if (x > 0) i - 1, if (x < w - 1) i + 1, if (y > 0) i - w, if (y < h - 1) i + w]) {
        if (m[j] == 1 && seen[j] == 0) {
          seen[j] = 1;
          stack.add(j);
        }
      }
    }
    blobs.add(b);
  }
  return blobs;
}

/// Splits a blob of k touching objects into k centers (farthest-point seeding + Lloyd iterations).
List<(double, double)> _kmeans(_Blob b, int k) {
  final w = b.w;
  final px = [for (final i in b.pixels) ((i % w).toDouble(), (i ~/ w).toDouble())];
  final centers = [px.first];
  while (centers.length < k) {
    var far = px.first;
    var farD = -1.0;
    for (final p in px) {
      final d = centers.map((c) => (c.$1 - p.$1) * (c.$1 - p.$1) + (c.$2 - p.$2) * (c.$2 - p.$2)).reduce(math.min);
      if (d > farD) (far, farD) = (p, d);
    }
    centers.add(far);
  }
  for (var iter = 0; iter < 10; iter++) {
    final sx = List.filled(k, 0.0), sy = List.filled(k, 0.0), cnt = List.filled(k, 0);
    for (final p in px) {
      var best = 0;
      var bestD = double.infinity;
      for (var c = 0; c < k; c++) {
        final d = (centers[c].$1 - p.$1) * (centers[c].$1 - p.$1) + (centers[c].$2 - p.$2) * (centers[c].$2 - p.$2);
        if (d < bestD) (best, bestD) = (c, d);
      }
      sx[best] += p.$1;
      sy[best] += p.$2;
      cnt[best]++;
    }
    for (var c = 0; c < k; c++) {
      if (cnt[c] > 0) centers[c] = (sx[c] / cnt[c], sy[c] / cnt[c]);
    }
  }
  return centers;
}
