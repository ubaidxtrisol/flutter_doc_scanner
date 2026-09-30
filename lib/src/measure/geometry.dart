import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

enum MeasureUnit { m, ft }

const _feetPerMeter = 3.28084;

/// World point → normalized 0..1 preview position (y down). Null when it is behind the camera.
Offset? project(Matrix4 viewProjection, Vector3 p) {
  final c = viewProjection.transform(Vector4(p.x, p.y, p.z, 1));
  if (c.w <= 1e-6) return null;
  return Offset((c.x / c.w + 1) / 2, (1 - c.y / c.w) / 2);
}

/// Best-fit plane of 3+ points: (centroid, unit normal), or null when they are collinear.
(Vector3, Vector3)? fitPlane(List<Vector3> points) {
  if (points.length < 3) return null;
  final n = Vector3.zero();
  for (var i = 0; i < points.length; i++) {
    n.add(points[i].cross(points[(i + 1) % points.length]));
  }
  if (n.length < 1e-9) return null;
  final centroid = points.fold(Vector3.zero(), (a, p) => a + p) / points.length.toDouble();
  return (centroid, n.normalized());
}

/// Area of a closed, roughly planar polygon in m². Newell's vector area: the shoelace formula on the best-fit
/// plane, so small out-of-plane jitter in the AR points doesn't inflate it.
double polygonArea(List<Vector3> points) {
  final n = Vector3.zero();
  for (var i = 0; i < points.length; i++) {
    n.add(points[i].cross(points[(i + 1) % points.length]));
  }
  return n.length / 2;
}

/// "3.1 m", "45 cm" / "7.5 ft", "8 in".
String formatLength(double meters, MeasureUnit unit) {
  if (unit == MeasureUnit.m) {
    return meters < 1 ? '${(meters * 100).round()} cm' : '${meters.toStringAsFixed(1)} m';
  }
  final feet = meters * _feetPerMeter;
  return feet < 1 ? '${(feet * 12).round()} in' : '${feet.toStringAsFixed(1)} ft';
}

/// "6.84 m²" / "73.6 ft²".
String formatArea(double squareMeters, MeasureUnit unit) => unit == MeasureUnit.m
    ? '${squareMeters.toStringAsFixed(2)} m²'
    : '${(squareMeters * _feetPerMeter * _feetPerMeter).toStringAsFixed(1)} ft²';

/// Where the ray through preview point [at] (normalized, default the center) meets the plane through [origin]
/// with unit [normal]. Null when the plane is behind the camera, too far, or seen so edge-on (< ~8° grazing) that
/// a small hand shake would throw the point meters away.
Vector3? aimOnPlane(Matrix4 viewProjection, Vector3 origin, Vector3 normal, {Offset at = const Offset(.5, .5)}) {
  final inverse = Matrix4.tryInvert(viewProjection);
  if (inverse == null) return null;
  Vector3 unproject(double z) {
    final v = inverse.transform(Vector4(at.dx * 2 - 1, 1 - at.dy * 2, z, 1));
    return Vector3(v.x, v.y, v.z) / v.w;
  }

  final near = unproject(-1);
  final dir = (unproject(1) - near)..normalize();
  final facing = dir.dot(normal);
  if (facing.abs() < .14) return null;
  final t = (origin - near).dot(normal) / facing;
  if (t <= 0 || t > 15) return null;
  return near + dir * t;
}
