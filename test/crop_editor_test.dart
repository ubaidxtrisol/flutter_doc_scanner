import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/scanner/crop_editor.dart';

void main() {
  test('accepts convex quads, rejects twisted or collapsed ones', () {
    expect(isConvexQuad(fullPage), isTrue);
    expect(isConvexQuad(const [Offset(.1, .2), Offset(.9, .1), Offset(.8, .9), Offset(.2, .8)]), isTrue);
    // TR dragged past TL: edges cross.
    expect(isConvexQuad(const [Offset(.5, 0), Offset(.2, 0), Offset(1, 1), Offset(0, 1)]), isFalse);
    // BR pulled inside: concave.
    expect(isConvexQuad(const [Offset(0, 0), Offset(1, 0), Offset(.3, .3), Offset(0, 1)]), isFalse);
    // TR on top of TL: collapsed.
    expect(isConvexQuad(const [Offset(0, 0), Offset(0, 0), Offset(1, 1), Offset(0, 1)]), isFalse);
  });
}
