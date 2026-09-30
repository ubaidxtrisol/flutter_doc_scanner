import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/measure/geometry.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  test('area of a 2×3 m rectangle on a tilted, shifted plane', () {
    final pose = Matrix4.compose(
      Vector3(1.2, -0.8, -2.5),
      Quaternion.axisAngle(Vector3(1, 1, 0.3)..normalize(), 0.9),
      Vector3.all(1),
    );
    final pts = [Vector3(0, 0, 0), Vector3(2, 0, 0), Vector3(2, 0, 3), Vector3(0, 0, 3)].map(pose.transform3).toList();
    expect(polygonArea(pts), closeTo(6, 1e-9));
  });

  test('area of a concave L-shaped floor, either winding', () {
    final l = [
      Vector3(0, 0, 0), Vector3(4, 0, 0), Vector3(4, 0, 2), //
      Vector3(1, 0, 2), Vector3(1, 0, 5), Vector3(0, 0, 5),
    ];
    expect(polygonArea(l), closeTo(4 * 2 + 1 * 3, 1e-9));
    expect(polygonArea(l.reversed.toList()), closeTo(11, 1e-9));
  });

  test('out-of-plane jitter barely changes the area', () {
    final r = math.Random(1);
    double j() => (r.nextDouble() - .5) * .02; // ±1 cm
    final pts = [Vector3(0, j(), 0), Vector3(2, j(), 0), Vector3(2, j(), 3), Vector3(0, j(), 3)];
    expect(polygonArea(pts), closeTo(6, 6 * .005));
  });

  test('projection: center, edges, behind the camera', () {
    final proj = makePerspectiveMatrix(math.pi / 2, 1, .05, 100);
    final view = makeViewMatrix(Vector3.zero(), Vector3(0, 0, -1), Vector3(0, 1, 0));
    final vp = proj * view;
    expect(project(vp, Vector3(0, 0, -2)), const Offset(.5, .5));
    final right = project(vp, Vector3(2, 0, -2))!; // 45° off-axis at a 90° FOV = right edge
    expect(right.dx, closeTo(1, 1e-9));
    final up = project(vp, Vector3(0, 1, -2))!; // up in the world = smaller y on screen
    expect(up.dy, lessThan(.5));
    expect(project(vp, Vector3(0, 0, 2)), isNull);
  });

  test('formatting', () {
    expect(formatLength(3.14, MeasureUnit.m), '3.1 m');
    expect(formatLength(.456, MeasureUnit.m), '46 cm');
    expect(formatLength(2.3, MeasureUnit.ft), '7.5 ft');
    expect(formatLength(.2, MeasureUnit.ft), '8 in');
    expect(formatArea(6.84, MeasureUnit.m), '6.84 m²');
    expect(formatArea(6.84, MeasureUnit.ft), '73.6 ft²');
  });

  group('aimOnPlane', () {
    final proj = makePerspectiveMatrix(math.pi / 2, .75, .05, 100);
    Matrix4 looking(Vector3 dir) => proj * makeViewMatrix(Vector3.zero(), dir, Vector3(0, 1, 0));

    test('straight at a wall 2 m ahead', () {
      final p = aimOnPlane(looking(Vector3(0, 0, -1)), Vector3(0.7, 1.1, -2), Vector3(0, 0, 1))!;
      expect(p.distanceTo(Vector3(0, 0, -2)), lessThan(1e-9));
    });

    test('at 45° onto a side wall', () {
      final p = aimOnPlane(looking(Vector3(1, 0, -1)), Vector3(3, 5, 9), Vector3(-1, 0, 0))!;
      expect(p.distanceTo(Vector3(3, 0, -3)), lessThan(1e-9));
    });

    test('off-center screen point lands where it projects back to', () {
      final vp = looking(Vector3(0, 0, -1));
      final p = aimOnPlane(vp, Vector3(0, 0, -2), Vector3(0, 0, 1), at: const Offset(.2, .7))!;
      expect(p.z, closeTo(-2, 1e-9));
      final back = project(vp, p)!;
      expect((back - const Offset(.2, .7)).distance, lessThan(1e-9));
    });

    test('fitPlane: centroid + normal of a tilted square; null when collinear', () {
      final (c, n) = fitPlane([Vector3(0, 0, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 0, 1)])!;
      expect(c.distanceTo(Vector3(.5, .5, .5)), lessThan(1e-9));
      expect(n.dot(Vector3(1, -1, 0).normalized()).abs(), closeTo(1, 1e-9));
      expect(fitPlane([Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(2, 0, 0)]), isNull);
    });

    test('edge-on and behind give nothing', () {
      expect(aimOnPlane(looking(Vector3(0, 0, -1)), Vector3(0, -1.5, 0), Vector3(0, 1, 0)), isNull);
      expect(aimOnPlane(looking(Vector3(0, 0, -1)), Vector3(0, 0, 2), Vector3(0, 0, 1)), isNull);
    });
  });
}
