import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/math/solver.dart';

List<(String, String)> steps(MathSolution s) => [for (final t in s.steps) (t.title, t.expr)];

void main() {
  test('Figma 7.4: 2x + 5 = 15 in exactly three steps', () {
    final s = solveLocally('2x + 5 = 15')!;
    expect(s.type, 'Linear equation');
    expect(s.answer, 'x = 5');
    expect(steps(s), [
      ('Subtract 5 from both sides', '2x = 15 − 5'),
      ('Simplify', '2x = 10'),
      ('Divide both sides by 2', 'x = 5'),
    ]);
  });

  test('linear equations', () {
    final both = solveLocally('3x - 7 = 2x + 4')!;
    expect(both.answer, 'x = 11');
    expect(steps(both), [
      ('Subtract 2x from both sides', 'x − 7 = 4'),
      ('Add 7 to both sides', 'x = 4 + 7'),
      ('Simplify', 'x = 11'),
    ]);
    final expand = solveLocally('2(x + 3) = 10')!;
    expect((expand.steps.first.title, expand.steps.first.expr), ('Expand and simplify', '2x + 6 = 10'));
    expect(expand.answer, 'x = 2');
    expect(solveLocally('x/3 = 4')!.answer, 'x = 12');
    expect(solveLocally('5x = 3')!.answer, 'x = 3/5 ≈ 0.6');
    expect(solveLocally('4 - x = 1')!.answer, 'x = 3');
    expect(solveLocally('x + 1 = x + 1')!.answer, 'Every x is a solution');
    expect(solveLocally('x + 1 = x')!.answer, 'No solution');
  });

  test('quadratics: rational, irrational, complex, repeated', () {
    final q = solveLocally('x^2 - 5x + 6 = 0')!;
    expect(q.type, 'Quadratic equation');
    expect(q.answer, 'x = 3, x = 2');
    expect(q.steps.map((s) => s.title), contains('Apply the quadratic formula'));
    expect(solveLocally('x² = 2')!.answer, 'x ≈ 1.4142, x ≈ −1.4142');
    expect(solveLocally('x^2 + 1 = 0')!.answer, 'x = 0 ± 1i');
    expect(solveLocally('x^2 - 6x + 9 = 0')!.answer, 'x = 3');
  });

  test('arithmetic follows order of operations, exactly', () {
    final s = solveLocally('12 + 3 × 4')!;
    expect(s.type, 'Arithmetic');
    expect(s.answer, '24');
    expect(steps(s), [('Multiply', '12 + 12'), ('Add', '24')]);
    expect(solveLocally('(2+3)^2')!.answer, '25');
    expect(solveLocally('7 ÷ 2')!.answer, '7/2 ≈ 3.5');
    expect(solveLocally('0.1 + 0.2')!.answer, '3/10 ≈ 0.3'); // no floating-point 0.30000000000000004
  });

  test('OCR look-alikes', () {
    expect(solveLocally('2× + 5 = 15')!.answer, 'x = 5'); // variable x read as ×
    expect(solveLocally('2X+5=15')!.answer, 'x = 5');
    expect(solveLocally('2x + 5 = 1O')!.answer, 'x = 5/2 ≈ 2.5'); // O read for 0
    expect(solveLocally('2x − 5 = 15')!.answer, 'x = 10'); // unicode minus
  });

  test('anything outside the local solver returns null (goes to the cloud)', () {
    for (final t in ['sin(x) = 1', 'x^3 = 8', 'x + y = 3', '1/x = 2', 'hello world', '5/0', '∫ x dx']) {
      expect(solveLocally(t), isNull, reason: t);
    }
  });

  test('picks the math line out of a page of OCR text', () {
    expect(pickMathLine([('Chapter 3 Exercises', .2), ('2x + 5 = 15', .5), ('Page 12', .9)]), '2x + 5 = 15');
    expect(pickMathLine([('Find x', .4), ('Name: ____', .1)]), isNull);
  });
}
