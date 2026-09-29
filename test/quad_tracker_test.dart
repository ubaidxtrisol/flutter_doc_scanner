import 'dart:math';

import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

const page = [Offset(.2, .2), Offset(.8, .2), Offset(.8, .8), Offset(.2, .8)];
Duration ms(int v) => Duration(milliseconds: v);
List<Offset> shift(List<Offset> q, double d) => [for (final p in q) p + Offset(d, d)];

void main() {
  test('smooths jitter', () {
    final t = QuadTracker(), rnd = Random(1);
    var maxErr = 0.0;
    for (var i = 0; i < 60; i++) {
      t.add(shift(page, (rnd.nextDouble() - .5) * .01), ms(i * 33));
      if (i > 10) maxErr = max(maxErr, (t.corners![0] - page[0]).distance);
    }
    expect(maxErr, lessThan(.005 * sqrt2)); // raw jitter reaches .005*sqrt2
  });

  test('brief dropout keeps the quad, long one clears it', () {
    final t = QuadTracker()..add(page, ms(0));
    t.add(null, ms(200));
    expect(t.state, isNot(QuadState.searching));
    t.add(null, ms(300));
    expect(t.state, QuadState.searching);
  });

  test('steady only after holding still', () {
    final t = QuadTracker();
    for (var i = 0; i <= 20; i++) {
      t.add(page, ms(i * 33)); // 660ms
    }
    expect(t.state, QuadState.detected);
    t.add(page, ms(720));
    expect(t.state, QuadState.steady);
  });

  test('movement restarts the steady timer', () {
    final t = QuadTracker()..add(page, ms(0));
    t.add(shift(page, .03), ms(600));
    t.add(shift(page, .03), ms(800));
    expect(t.state, QuadState.detected);
  });

  test('does not re-shoot the same page until it leaves or changes', () {
    final t = QuadTracker()..add(page, ms(0));
    t.add(page, ms(800));
    expect(t.state, QuadState.steady);
    t.captured();
    t.add(page, ms(3000));
    expect(t.state, QuadState.detected);
    t.add(shift(page, .1), ms(3033)); // new page placed
    t.add(shift(page, .1), ms(3800));
    expect(t.state, QuadState.steady);
    t.captured();
    t.add(null, ms(4200)); // page removed
    t.add(page, ms(4300));
    t.add(page, ms(5100));
    expect(t.state, QuadState.steady);
  });
}
