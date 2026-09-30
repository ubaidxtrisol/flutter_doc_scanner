/// ICAO 9303 machine-readable zone parser (TD1 ID cards, TD2, TD3 passports).
///
/// Every result has passed all check digits, so a returned [Mrz] is never a misread.
class Mrz {
  const Mrz({
    required this.format,
    required this.documentType,
    required this.issuingCountry,
    required this.surname,
    required this.givenNames,
    required this.documentNumber,
    required this.nationality,
    required this.birthDate,
    required this.sex,
    required this.expiryDate,
  });

  final String format; // TD1 | TD2 | TD3
  final String documentType;
  final String issuingCountry;
  final String surname;
  final String givenNames;
  final String documentNumber;
  final String nationality;
  final DateTime birthDate;
  final String sex; // M | F | X
  final DateTime expiryDate;

  /// Identity of the read, used to require the same MRZ in consecutive frames.
  String get key => '$documentNumber|${birthDate.toIso8601String()}|${expiryDate.toIso8601String()}';

  /// Finds and validates an MRZ among OCR'd text lines (top-to-bottom order).
  static Mrz? find(List<String> lines, {DateTime? now}) {
    final clean = [for (final l in lines) _clean(l)].where((l) => l.length >= 28).toList();
    for (var i = 0; i < clean.length; i++) {
      final rest = clean.sublist(i);
      final r = (rest.length >= 3 ? _td1(rest[0], rest[1], rest[2], now) : null) ??
          (rest.length >= 2 ? _td3(rest[0], rest[1], now) ?? _td2(rest[0], rest[1], now) : null);
      if (r != null) return r;
    }
    return null;
  }

  static String _clean(String s) =>
      s.toUpperCase().replaceAll(RegExp(r'\s'), '').replaceAll('«', '<<').replaceAll(RegExp(r'[^A-Z0-9<]'), '<');

  /// Fits a filler-terminated line to [n] chars: OCR often drops or adds trailing '<' (ML Kit can drop a
  /// dozen). Safe because every field we report is covered by a check digit or sits on a line that is.
  static String? _fit(String s, int n) {
    if (s.length == n) return s;
    if (s.length < n && s.length >= n ~/ 2) return s.padRight(n, '<');
    if (s.length > n && s.substring(n).replaceAll('<', '').isEmpty) return s.substring(0, n);
    return null;
  }

  static Mrz? _td3(String a, String b, DateTime? now) {
    final l1 = _fit(a, 44), l2 = b.length == 44 ? b : null;
    if (l1 == null || l2 == null || !l1.startsWith('P')) return null;
    final doc = l2.substring(0, 9), birth = _digits(l2.substring(13, 19)), expiry = _digits(l2.substring(21, 27));
    final checks = _digits('${l2[9]}${l2[19]}${l2[27]}${l2[42]}${l2[43]}');
    if (!_ok(doc, checks[0]) || !_ok(birth, checks[1]) || !_ok(expiry, checks[2])) return null;
    if (!_ok(l2.substring(28, 42), checks[3], allowEmpty: true)) return null;
    final composite = '$doc${checks[0]}$birth${checks[1]}$expiry${checks[2]}${l2.substring(28, 42)}${checks[3]}';
    if (!_ok(composite, checks[4])) return null;
    return _build('TD3', l1.substring(0, 2), l1.substring(2, 5), l1.substring(5), doc, l2.substring(10, 13), birth,
        l2[20], expiry, now);
  }

  static Mrz? _td2(String a, String b, DateTime? now) {
    final l1 = _fit(a, 36), l2 = b.length == 36 ? b : null;
    if (l1 == null || l2 == null) return null;
    final doc = l2.substring(0, 9), birth = _digits(l2.substring(13, 19)), expiry = _digits(l2.substring(21, 27));
    final checks = _digits('${l2[9]}${l2[19]}${l2[27]}${l2[35]}');
    if (!_ok(doc, checks[0]) || !_ok(birth, checks[1]) || !_ok(expiry, checks[2])) return null;
    final composite = '$doc${checks[0]}$birth${checks[1]}$expiry${checks[2]}${l2.substring(28, 35)}';
    if (!_ok(composite, checks[3])) return null;
    return _build('TD2', l1.substring(0, 2), l1.substring(2, 5), l1.substring(5), doc, l2.substring(10, 13), birth,
        l2[20], expiry, now);
  }

  static Mrz? _td1(String a, String b, String c, DateTime? now) {
    final l1 = _fit(a, 30), l2 = _fit(b, 30), l3 = _fit(c, 30);
    if (l1 == null || l2 == null || l3 == null) return null;
    final doc = l1.substring(5, 14), birth = _digits(l2.substring(0, 6)), expiry = _digits(l2.substring(8, 14));
    final checks = _digits('${l1[14]}${l2[6]}${l2[14]}${l2[29]}');
    if (!_ok(doc, checks[0]) || !_ok(birth, checks[1]) || !_ok(expiry, checks[2])) return null;
    final composite = '${l1.substring(5, 30)}$birth${checks[1]}$expiry${checks[2]}${l2.substring(18, 29)}';
    if (!_ok(composite, checks[3])) return null;
    return _build('TD1', l1.substring(0, 2), l1.substring(2, 5), l3, doc, l2.substring(15, 18), birth, l2[7],
        expiry, now);
  }

  static Mrz? _build(String format, String type, String issuer, String names, String doc, String nationality,
      String birth, String sex, String expiry, DateTime? now) {
    final parts = names.split('<<');
    final today = now ?? DateTime.now();
    final b = _date(birth, today, past: true), e = _date(expiry, today, past: false);
    if (b == null || e == null) return null;
    String words(String s) => s.replaceAll('<', ' ').trim().replaceAll(RegExp(' +'), ' ');
    return Mrz(
      format: format,
      documentType: _letters(type).replaceAll('<', ''),
      issuingCountry: _letters(issuer).replaceAll('<', ''),
      surname: words(_letters(parts.first)),
      givenNames: words(_letters(parts.skip(1).join(' '))),
      documentNumber: doc.replaceAll('<', ''),
      nationality: _letters(nationality).replaceAll('<', ''),
      birthDate: b,
      sex: sex == '<' ? 'X' : sex,
      expiryDate: e,
    );
  }

  static DateTime? _date(String yymmdd, DateTime today, {required bool past}) {
    final yy = int.tryParse(yymmdd.substring(0, 2)), mm = int.tryParse(yymmdd.substring(2, 4));
    final dd = int.tryParse(yymmdd.substring(4));
    if (yy == null || mm == null || dd == null || mm < 1 || mm > 12 || dd < 1 || dd > 31) return null;
    // Birth dates are in the past; expiry dates are within a few decades either way.
    var year = 2000 + yy;
    if (past ? year > today.year : year > today.year + 50) year -= 100;
    return DateTime(year, mm, dd);
  }

  /// ICAO check digit: weights 7-3-1; digits count as themselves, A-Z as 10-35, '<' as 0.
  static int checkDigit(String s) {
    const w = [7, 3, 1];
    var sum = 0;
    for (var i = 0; i < s.length; i++) {
      final c = s.codeUnitAt(i);
      final v = c >= 48 && c <= 57 ? c - 48 : (c >= 65 && c <= 90 ? c - 55 : 0);
      sum += v * w[i % 3];
    }
    return sum % 10;
  }

  static bool _ok(String field, String check, {bool allowEmpty = false}) {
    if (allowEmpty && check == '<' && field.replaceAll('<', '').isEmpty) return true;
    return check == '${checkDigit(field)}';
  }

  // OCR fix-ups by field type.
  static const _toDigit = {'O': '0', 'Q': '0', 'D': '0', 'I': '1', 'L': '1', 'Z': '2', 'S': '5', 'G': '6', 'B': '8'};
  static const _toLetter = {'0': 'O', '1': 'I', '2': 'Z', '5': 'S', '6': 'G', '8': 'B'};
  static String _digits(String s) => s.split('').map((c) => _toDigit[c] ?? c).join();
  static String _letters(String s) => s.split('').map((c) => _toLetter[c] ?? c).join();
}
