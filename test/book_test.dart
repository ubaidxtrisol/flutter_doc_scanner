import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/scanner/book.dart';

const square = [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(0, 1)];
const tilted = [Offset(.1, .2), Offset(.9, .1), Offset(.95, .9), Offset(.05, .8)];

double cross(Offset a, Offset b, Offset p) => (b - a).dx * (p - a).dy - (b - a).dy * (p - a).dx;

void main() {
  test('projective map hits the corners and stays on the edges', () {
    for (final (u, v, i) in [(0.0, 0.0, 0), (1.0, 0.0, 1), (1.0, 1.0, 2), (0.0, 1.0, 3)]) {
      expect((quadPoint(tilted, u, v) - tilted[i]).distance, lessThan(1e-9));
    }
    expect(cross(tilted[0], tilted[1], quadPoint(tilted, .37, 0)).abs(), lessThan(1e-9)); // on top edge
    expect(cross(tilted[3], tilted[2], quadPoint(tilted, .37, 1)).abs(), lessThan(1e-9)); // on bottom edge
    expect((quadPoint(square, .3, .6) - const Offset(.3, .6)).distance, lessThan(1e-9));
  });

  test('split shares the fold edge', () {
    final (left, right) = splitQuad(tilted, .5);
    expect(left[1], right[0]);
    expect(left[2], right[3]);
    expect((left[0], left[3], right[1], right[2]), (tilted[0], tilted[3], tilted[1], tilted[2]));
  });

  test('gutter: darkest column near the middle, else center', () {
    final bright = List<double>.filled(100, 230);
    expect(findGutter(bright), .5);
    final fold = [...bright]..setRange(54, 57, [120, 90, 120]);
    expect(findGutter(fold), closeTo(.555, .01));
    final edgeShadow = [...bright]..setRange(0, 10, List.filled(10, 40)); // dark desk edge, outside the middle band
    expect(findGutter(edgeShadow), .5);
  });
}
