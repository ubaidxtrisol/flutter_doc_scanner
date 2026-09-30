/// On-device math solver: arithmetic, linear and quadratic equations in one variable, with
/// human-style steps (Figma 7.4). Exact rational arithmetic throughout. Anything else returns
/// null from [solveLocally], and the caller routes it to the cloud solver.
library;

import 'dart:math' as math;

class MathStep {
  const MathStep(this.title, this.expr);
  final String title;
  final String expr;
}

class MathSolution {
  const MathSolution({
    required this.problem,
    required this.type,
    required this.answer,
    required this.steps,
    this.online = false,
  });
  final String problem;
  final String type; // "Linear equation", …
  final String answer; // "x = 5"
  final List<MathStep> steps;

  /// Solved by the cloud solver rather than on device.
  final bool online;
}

/// Solves [text] (raw OCR output is fine) on device, or returns null if it's outside what we handle.
MathSolution? solveLocally(String text) {
  try {
    final eq = _Parser(_tokens(normalizeMath(text))).equation();
    return eq.$2 == null ? _expression(eq.$1) : _equation(eq.$1, eq.$2!);
  } on _Unsupported {
    return null;
  }
}

/// Picks the most math-looking OCR line, preferring lines the local solver understands, then '=',
/// then closeness to the frame center. [lines] are (text, center-y 0..1) pairs.
String? pickMathLine(List<(String, double)> lines) {
  (String, double)? best;
  var bestScore = -1.0;
  for (final l in lines) {
    final t = normalizeMath(l.$1);
    final mathy = RegExp(r'[0-9]').hasMatch(t) && RegExp(r'[-+*/=^()]').hasMatch(t);
    if (!mathy) continue;
    final score = (solveLocally(t) != null ? 4 : 0) + (t.contains('=') ? 2 : 0) + (1 - (l.$2 - .5).abs());
    if (score > bestScore) (best, bestScore) = (l, score);
  }
  return best?.$1;
}

// ─── Normalizing OCR text ─────────────────────────────────────────────────────────────────────

/// Maps OCR's unicode and look-alikes onto the parser's ASCII grammar.
String normalizeMath(String s) {
  var t = s
      .replaceAll(RegExp('[−–—‐]'), '-')
      .replaceAll(RegExp('[÷:]'), '/')
      .replaceAll(RegExp('[·∙•]'), '*')
      .replaceAll('＝', '=')
      .replaceAll('²', '^2')
      .replaceAll('³', '^3')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim()
      .toLowerCase();
  // '×' is multiplication only when an operand follows; "2× + 5" is OCR reading the variable x as ×.
  t = t.replaceAllMapped(RegExp(r'×(?=\s*[0-9a-z(])'), (_) => '*').replaceAll('×', 'x');
  // o / l / i glued to digits are zeros and ones.
  t = t.replaceAllMapped(RegExp(r'(?<=[0-9])[o]|[o](?=[0-9])'), (_) => '0');
  t = t.replaceAllMapped(RegExp(r'(?<=[0-9])[li]|[li](?=[0-9])'), (_) => '1');
  return t;
}

// ─── Exact rationals ──────────────────────────────────────────────────────────────────────────

class Q {
  factory Q(BigInt n, [BigInt? d]) {
    d ??= BigInt.one;
    if (d == BigInt.zero) throw const _Unsupported('division by zero');
    if (d.isNegative) (n, d) = (-n, -d);
    final g = n.gcd(d);
    return Q._(n ~/ (g == BigInt.zero ? BigInt.one : g), d ~/ (g == BigInt.zero ? BigInt.one : g));
  }
  const Q._(this.n, this.d);
  Q.i(int v) : this._(BigInt.from(v), BigInt.one);

  final BigInt n, d;
  static final zero = Q.i(0), one = Q.i(1);

  bool get isZero => n == BigInt.zero;
  bool get isInt => d == BigInt.one;
  bool get isNegative => n.isNegative;
  Q operator +(Q o) => Q(n * o.d + o.n * d, d * o.d);
  Q operator -(Q o) => Q(n * o.d - o.n * d, d * o.d);
  Q operator *(Q o) => Q(n * o.n, d * o.d);
  Q operator /(Q o) => Q(n * o.d, d * o.n);
  Q operator -() => Q._(-n, d);
  Q abs() => isNegative ? -this : this;
  Q pow(int e) => Q(n.pow(e), d.pow(e));
  double toDouble() => n / d;
  @override
  bool operator ==(Object other) => other is Q && other.n == n && other.d == d;
  @override
  int get hashCode => Object.hash(n, d);

  static Q parse(String s) {
    final parts = s.split('.');
    if (parts.length == 1) return Q(BigInt.parse(s));
    final scale = BigInt.from(10).pow(parts[1].length);
    return Q(BigInt.parse(parts[0].isEmpty ? '0' : parts[0]) * scale + BigInt.parse(parts[1]), scale);
  }

  /// "5", "−3", "3/4"; plus " ≈ 0.667" style decimals when [approx] and not an integer.
  String show({bool approx = false}) {
    final base = isInt ? '$n' : '$n/$d';
    final s = base.replaceFirst('-', '−');
    if (!approx || isInt) return s;
    return '$s ≈ ${_decimal(toDouble())}';
  }
}

String _decimal(double v) {
  final s = v.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return s.replaceFirst('-', '−');
}

class _Unsupported implements Exception {
  const _Unsupported(this.why);
  final String why;
}

// ─── Tokens and parser ────────────────────────────────────────────────────────────────────────

enum _T { num, name, op, lp, rp, eq }

List<(_T, String)> _tokens(String s) {
  final out = <(_T, String)>[];
  for (final m in RegExp(r'\d+(?:\.\d+)?|\.\d+|[a-z]+|[-+*/^()=]|\S').allMatches(s)) {
    final t = m[0]!;
    out.add(switch (t) {
      '(' => (_T.lp, t),
      ')' => (_T.rp, t),
      '=' => (_T.eq, t),
      _ when RegExp(r'^[\d.]').hasMatch(t) => (_T.num, t),
      _ when RegExp(r'^[a-z]+$').hasMatch(t) => (_T.name, t),
      _ when '+-*/^'.contains(t) => (_T.op, t),
      _ => throw _Unsupported('symbol $t'),
    });
  }
  return out;
}

sealed class _N {}

class _Num extends _N {
  _Num(this.v);
  final Q v;
}

class _Var extends _N {
  _Var(this.name);
  final String name;
}

class _Neg extends _N {
  _Neg(this.x);
  final _N x;
}

class _Bin extends _N {
  _Bin(this.op, this.l, this.r);
  final String op;
  final _N l, r;
}

class _Parser {
  _Parser(this.t);
  final List<(_T, String)> t;
  var i = 0;

  (_T, String)? get peek => i < t.length ? t[i] : null;

  (_N, _N?) equation() {
    if (t.isEmpty) throw const _Unsupported('empty');
    final l = expr();
    _N? r;
    if (peek?.$1 == _T.eq) {
      i++;
      r = expr();
    }
    if (i != t.length) throw const _Unsupported('trailing input');
    return (l, r);
  }

  _N expr() {
    var n = term();
    while (true) {
      final p = peek;
      if (p == null || p.$1 != _T.op || (p.$2 != '+' && p.$2 != '-')) return n;
      i++;
      n = _Bin(p.$2, n, term());
    }
  }

  _N term() {
    var n = unary();
    while (true) {
      final p = peek;
      if (p case (_T.op, final op) when op == '*' || op == '/') {
        i++;
        n = _Bin(op, n, unary());
      } else if (p != null && (p.$1 == _T.num || p.$1 == _T.name || p.$1 == _T.lp)) {
        n = _Bin('*', n, power()); // implicit: 2x, 2(x+1), (x+1)(x-1)
      } else {
        return n;
      }
    }
  }

  _N unary() {
    if (peek case (_T.op, final op) when op == '-' || op == '+') {
      i++;
      final x = unary();
      return op == '-' ? _Neg(x) : x;
    }
    return power();
  }

  _N power() {
    final base = atom();
    if (peek case (_T.op, '^')) {
      i++;
      return _Bin('^', base, unary());
    }
    return base;
  }

  _N atom() {
    final p = peek;
    if (p == null) throw const _Unsupported('unexpected end');
    i++;
    switch (p.$1) {
      case _T.num:
        return _Num(Q.parse(p.$2));
      case _T.name:
        if (p.$2.length > 1) {
          // "xy" is x·y; words like sin/log/sqrt are beyond the local solver.
          if (RegExp(r'^(sin|cos|tan|log|ln|sqrt|lim|int|sum)').hasMatch(p.$2)) throw _Unsupported(p.$2);
          return p.$2.split('').map<_N>(_Var.new).reduce((a, b) => _Bin('*', a, b));
        }
        return _Var(p.$2);
      case _T.lp:
        final e = expr();
        if (peek?.$1 != _T.rp) throw const _Unsupported('missing )');
        i++;
        return e;
      default:
        throw _Unsupported('unexpected ${p.$2}');
    }
  }
}

// ─── Polynomials in one variable ──────────────────────────────────────────────────────────────

/// Coefficients by degree, for a single variable (tracked in [_Poly.v]).
class _Poly {
  _Poly(this.c, [this.v]);
  final Map<int, Q> c;
  String? v;

  int get degree => c.entries.where((e) => !e.value.isZero).map((e) => e.key).fold(0, math.max);
  Q at(int k) => c[k] ?? Q.zero;
  bool get isConstant => degree == 0;

  static String? _join(String? a, String? b) {
    if (a != null && b != null && a != b) throw const _Unsupported('more than one variable');
    return a ?? b;
  }

  _Poly operator +(_Poly o) => _Poly({for (final k in {...c.keys, ...o.c.keys}) k: at(k) + o.at(k)}, _join(v, o.v));
  _Poly operator -(_Poly o) => this + o.scale(-Q.one);
  _Poly scale(Q s) => _Poly({for (final e in c.entries) e.key: e.value * s}, v);
  _Poly operator *(_Poly o) {
    final out = <int, Q>{};
    for (final a in c.entries) {
      for (final b in o.c.entries) {
        out[a.key + b.key] = (out[a.key + b.key] ?? Q.zero) + a.value * b.value;
      }
    }
    if (out.keys.fold(0, math.max) > 4) throw const _Unsupported('degree too high');
    return _Poly(out, _join(v, o.v));
  }

  static _Poly of(_N n) => switch (n) {
        _Num(:final v) => _Poly({0: v}),
        _Var(:final name) => _Poly({1: Q.one}, name),
        _Neg(:final x) => of(x).scale(-Q.one),
        _Bin(op: '+', :final l, :final r) => of(l) + of(r),
        _Bin(op: '-', :final l, :final r) => of(l) - of(r),
        _Bin(op: '*', :final l, :final r) => of(l) * of(r),
        _Bin(op: '/', :final l, :final r) => _divide(of(l), of(r)),
        _Bin(op: '^', :final l, :final r) => _power(of(l), of(r)),
        _ => throw const _Unsupported('operator'),
      };

  static _Poly _divide(_Poly a, _Poly b) {
    if (!b.isConstant) throw const _Unsupported('variable in a denominator');
    if (b.at(0).isZero) throw const _Unsupported('division by zero');
    return a.scale(Q.one / b.at(0));
  }

  static _Poly _power(_Poly base, _Poly e) {
    final k = e.at(0);
    if (!e.isConstant || !k.isInt || k.isNegative || k.n > BigInt.from(4)) throw const _Unsupported('exponent');
    var out = _Poly({0: Q.one}, base.v);
    for (var j = 0; j < k.n.toInt(); j++) {
      out = out * base;
    }
    return out;
  }

  /// "2x² − 5x + 3", "−x", "0".
  String show() {
    final v = this.v ?? 'x';
    final parts = <String>[];
    for (var k = degree; k >= 0; k--) {
      final q = at(k);
      if (q.isZero) continue;
      final a = q.abs();
      final coef = k > 0 && a == Q.one ? '' : (a.isInt || k == 0 ? a.show() : '(${a.show()})');
      final term = '$coef${k == 0 ? '' : k == 1 ? v : '$v${k == 2 ? '²' : k == 3 ? '³' : '⁴'}'}';
      parts.add(parts.isEmpty ? (q.isNegative ? '−$term' : term) : '${q.isNegative ? '−' : '+'} $term');
    }
    return parts.isEmpty ? '0' : parts.join(' ');
  }
}

// ─── Solving ──────────────────────────────────────────────────────────────────────────────────

MathSolution _expression(_N e) {
  final p = _Poly.of(e);
  final problem = _show(e);
  if (p.v == null) return _arithmetic(e, problem);
  final simplified = p.show();
  return MathSolution(
    problem: problem,
    type: 'Expression',
    answer: simplified,
    steps: [if (simplified != problem) MathStep('Expand and combine like terms', simplified)],
  );
}

MathSolution _arithmetic(_N e, String problem) {
  final steps = <MathStep>[];
  var cur = e;
  while (cur is! _Num) {
    final (next, title) = _reduceOnce(cur);
    cur = next;
    steps.add(MathStep(title, _show(cur)));
  }
  final v = cur.v;
  if (steps.length > 8) steps.replaceRange(0, steps.length - 1, [const MathStep('Evaluate', '…')]);
  return MathSolution(problem: problem, type: 'Arithmetic', answer: v.show(approx: true), steps: steps);
}

/// Evaluates the first operation whose operands are both numbers (order of operations is in the tree).
(_N, String) _reduceOnce(_N n) {
  switch (n) {
    case _Neg(x: _Num(:final v)):
      return (_Num(-v), 'Apply the sign');
    case _Neg(:final x):
      final (r, t) = _reduceOnce(x);
      return (_Neg(r), t);
    case _Bin(:final op, l: _Num(v: final a), r: _Num(v: final b)):
      final (v, title) = switch (op) {
        '+' => (a + b, 'Add'),
        '-' => (a - b, 'Subtract'),
        '*' => (a * b, 'Multiply'),
        '/' => (a / b, 'Divide'),
        _ => (_Poly._power(_Poly({0: a}), _Poly({0: b})).at(0), 'Evaluate the power'),
      };
      return (_Num(v), title);
    case _Bin(:final op, :final l, :final r):
      if (l is! _Num) {
        final (x, t) = _reduceOnce(l);
        return (_Bin(op, x, r), t);
      }
      final (x, t) = _reduceOnce(r);
      return (_Bin(op, l, x), t);
    default:
      throw const _Unsupported('not arithmetic');
  }
}

MathSolution _equation(_N lhs, _N rhs) {
  final problem = '${_show(lhs)} = ${_show(rhs)}';
  var l = _Poly.of(lhs), r = _Poly.of(rhs);
  final v = _Poly._join(l.v, r.v);
  if (v == null) throw const _Unsupported('no variable');
  l.v = v;
  r.v = v;
  final steps = <MathStep>[];
  String eq(_Poly a, _Poly b) => '${a.show()} = ${b.show()}';
  if (eq(l, r) != problem) steps.add(MathStep('Expand and simplify', eq(l, r)));

  final diff = l - r;
  if (diff.degree >= 2) return _quadratic(problem, l, r, steps);

  // Linear: variable terms left, constants right.
  final rVar = r - _Poly({0: r.at(0)}, v);
  if (rVar.c.values.any((q) => !q.isZero)) {
    final what = rVar.show();
    l = l - rVar;
    r = r - rVar;
    steps.add(MathStep(rVar.at(rVar.degree).isNegative ? 'Add ${rVar.scale(-Q.one).show()} to both sides' : 'Subtract $what from both sides',
        eq(l, r)));
  }
  final a = l.at(1), b = l.at(0), c = r.at(0);
  if (a.isZero) {
    final always = b == c;
    return MathSolution(
      problem: problem,
      type: 'Linear equation',
      answer: always ? 'Every $v is a solution' : 'No solution',
      steps: [...steps, MathStep(always ? 'Both sides are always equal' : 'The sides can never be equal', '${b.show()} = ${c.show()}')],
    );
  }
  final ax = _Poly({1: a}, v).show();
  if (!b.isZero) {
    steps.add(MathStep(b.isNegative ? 'Add ${b.abs().show()} to both sides' : 'Subtract ${b.show()} from both sides',
        '$ax = ${c.show()} ${b.isNegative ? '+' : '−'} ${b.abs().show()}'));
    steps.add(MathStep('Simplify', '$ax = ${(c - b).show()}'));
  }
  final x = (c - b) / a;
  if (a != Q.one) {
    steps.add(MathStep(a == -Q.one ? 'Multiply both sides by −1' : 'Divide both sides by ${a.show()}', '$v = ${x.show()}'));
  }
  return MathSolution(problem: problem, type: 'Linear equation', answer: '$v = ${x.show(approx: true)}', steps: steps);
}

MathSolution _quadratic(String problem, _Poly l, _Poly r, List<MathStep> steps) {
  var p = l - r;
  if (p.degree > 2) throw const _Unsupported('cubic or higher');
  final v = p.v!;
  if (p.at(2).isNegative) p = p.scale(-Q.one); // a > 0 reads nicer
  if (!r.isConstant || !r.at(0).isZero || l.at(2) != p.at(2)) {
    steps.add(MathStep('Move all terms to one side', '${p.show()} = 0'));
  }
  final a = p.at(2), b = p.at(1), c = p.at(0);
  final disc = b * b - Q.i(4) * a * c;
  String paren(Q q) => q.isNegative ? '(${q.show()})' : q.show();
  steps.add(MathStep('Find the discriminant',
      'Δ = ${paren(b)}² − 4·${paren(a)}·${paren(c)} = ${disc.show()}'));

  final twoA = Q.i(2) * a;
  final root = _sqrt(disc.abs());
  String answer;
  if (disc.isZero) {
    final x = -b / twoA;
    steps.add(MathStep('Δ = 0, so there is one repeated root', '$v = ${(-b).show()} / ${twoA.show()}'));
    answer = '$v = ${x.show(approx: true)}';
  } else if (root != null && !disc.isNegative) {
    final x1 = (-b + root) / twoA, x2 = (-b - root) / twoA;
    steps.add(MathStep('Apply the quadratic formula', '$v = (${(-b).show()} ± ${root.show()}) / ${twoA.show()}'));
    answer = '$v = ${x1.show()}, $v = ${x2.show()}';
  } else {
    final surd = '√${disc.abs().show()}';
    final i = disc.isNegative ? 'i' : '';
    steps.add(MathStep('Apply the quadratic formula', '$v = (${(-b).show()} ± $surd$i) / ${twoA.show()}'));
    final re = (-b / twoA).toDouble(), im = math.sqrt(disc.abs().toDouble()) / twoA.toDouble().abs();
    answer = disc.isNegative
        ? '$v = ${_decimal(re)} ± ${_decimal(im)}i'
        : '$v ≈ ${_decimal(re + im)}, $v ≈ ${_decimal(re - im)}';
  }
  return MathSolution(problem: problem, type: 'Quadratic equation', answer: answer, steps: steps);
}

/// Exact square root of a non-negative rational, or null if it's irrational.
Q? _sqrt(Q q) {
  BigInt? isqrt(BigInt x) {
    if (x < BigInt.two) return x;
    var r = BigInt.from(math.sqrt(x.toDouble()));
    while (r * r > x) {
      r -= BigInt.one;
    }
    while ((r + BigInt.one) * (r + BigInt.one) <= x) {
      r += BigInt.one;
    }
    return r * r == x ? r : null;
  }

  final n = isqrt(q.n), d = isqrt(q.d);
  return n == null || d == null ? null : Q(n, d);
}

// ─── Printing expression trees ────────────────────────────────────────────────────────────────

int _prec(_N n) => switch (n) {
      _Bin(op: '+' || '-') => 1,
      _Bin(op: '*' || '/') => 2,
      _Neg() => 3,
      _Num(:final v) when v.isNegative => 3,
      _Num(:final v) when !v.isInt => 2,
      _Bin(op: '^') => 4,
      _ => 5,
    };

String _show(_N n) {
  String wrap(_N c, bool need) => need ? '(${_show(c)})' : _show(c);
  switch (n) {
    case _Num(:final v):
      return v.show();
    case _Var(:final name):
      return name;
    case _Neg(:final x):
      return '−${wrap(x, _prec(x) < 3)}';
    case _Bin(op: '^', :final l, :final r):
      final exp = _show(r);
      final sup = const {'2': '²', '3': '³', '4': '⁴'}[exp];
      return '${wrap(l, _prec(l) <= 4)}${sup ?? '^$exp'}';
    case _Bin(:final op, :final l, :final r):
      final p = _prec(n);
      final left = wrap(l, _prec(l) < p);
      final right = wrap(r, _prec(r) < p || (_prec(r) == p && (op == '-' || op == '/')));
      if (op == '*') {
        // 2x, 2(x + 1), x(x − 1) read naturally; number × number needs the sign.
        final implicit = r is! _Num && r is! _Neg && (l is _Num || l is _Var || right.startsWith('('));
        return implicit ? '$left$right' : '$left × $right';
      }
      return '$left ${const {'+': '+', '-': '−', '/': '÷'}[op]} $right';
  }
}
