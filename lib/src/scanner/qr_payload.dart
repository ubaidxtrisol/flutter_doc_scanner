import '../strings.dart';

/// What a scanned code contains, parsed from its raw text (same on both platforms).
enum QrKind { url, wifi, email, phone, sms, contact, geo, text }

class QrPayload {
  const QrPayload(
    this.kind,
    this.raw, {
    required this.title,
    required this.display,
    this.link,
    this.secret,
    this.fields = const [],
    this.strings,
  });

  final QrKind kind;
  final String raw;

  /// Label for the sheet ("Website", "Wi-Fi", …).
  final String title;

  /// Main line shown to the user. Never holds the Wi-Fi password.
  final String display;

  /// URI to open for the primary action (null if there is none).
  final Uri? link;

  /// Wi-Fi password, copied instead of the raw payload.
  final String? secret;

  /// Parsed details as (label, value) rows in display order. Never holds the Wi-Fi password (see [secret]).
  final List<(String, String)> fields;

  /// Language of [title], [display] and [fields]; English when null.
  final ScannerLocalizations? strings;

  /// False when the code holds nothing printable (empty, or binary data the reader couldn't turn into text).
  bool get readable => raw.replaceAll(RegExp(r'[\x00-\x1F\x7F�]'), '').trim().isNotEmpty;

  /// What Copy puts on the clipboard: the link, the main field (network name, number, address…) or the raw text.
  String get copyText => switch (kind) {
    QrKind.url => link.toString(),
    QrKind.text || QrKind.contact => raw,
    _ => fields.isEmpty ? raw : fields.first.$2,
  };

  /// Document title for a saved card, at most 40 characters: "QR · docscan.app/welcome". Built from [display],
  /// so it never holds a password.
  String get saveTitle {
    final short = display.replaceAll(RegExp(r'\s+'), ' ').trim();
    final t = (strings ?? scannerEnglish).qrSaveTitle(short.isEmpty ? title : short);
    return t.runes.length <= 40 ? t : '${String.fromCharCodes(t.runes.take(39)).trimRight()}…';
  }

  /// [l] labels the fields (English when null).
  static QrPayload parse(String raw, [ScannerLocalizations? l]) {
    l ??= scannerEnglish;
    final s = raw.trim();
    final lower = s.toLowerCase();

    if (RegExp(r'^https?://', caseSensitive: false).hasMatch(s) ||
        RegExp(r'^www\.\S+\.\S+$', caseSensitive: false).hasMatch(s)) {
      final uri = Uri.tryParse(lower.startsWith('www.') ? 'https://$s' : s);
      if (uri != null && uri.host.isNotEmpty) {
        final shown = '${uri.host.replaceFirst(RegExp('^www\\.'), '')}${uri.path == '/' ? '' : uri.path}';
        return QrPayload(
          QrKind.url,
          raw,
          title: l.qrWebsite,
          display: shown,
          link: uri,
          fields: [(l.qrLink, uri.toString())],
          strings: l,
        );
      }
    }
    if (lower.startsWith('wifi:')) return _wifi(l, raw, s.substring(5));
    if (lower.startsWith('mailto:')) {
      final q = s.indexOf('?');
      final to = _decode(s.substring(7, q < 0 ? s.length : q));
      final params = q < 0 ? const <String, String>{} : _query(s.substring(q + 1));
      return _email(l, raw, to, params['subject'] ?? '', params['body'] ?? '');
    }
    if (lower.startsWith('matmsg:')) {
      final f = _fields(s.substring(7));
      return _email(l, raw, f['TO'] ?? '', f['SUB'] ?? '', f['BODY'] ?? '');
    }
    if (RegExp(r'^[^\s@:/]+@[^\s@:/]+\.[^\s@:/]+$').hasMatch(s)) return _email(l, raw, s, '', '');
    if (lower.startsWith('tel:')) {
      final number = _decode(s.substring(4)).trim();
      return QrPayload(
        QrKind.phone,
        raw,
        title: l.qrPhone,
        display: number,
        link: Uri(scheme: 'tel', path: number),
        fields: [(l.qrNumber, number)],
        strings: l,
      );
    }
    if (lower.startsWith('smsto:') || lower.startsWith('mmsto:')) {
      final rest = s.substring(6);
      final i = rest.indexOf(':');
      return _sms(l, raw, i < 0 ? rest : rest.substring(0, i), i < 0 ? '' : rest.substring(i + 1));
    }
    if (lower.startsWith('sms:')) {
      final q = s.indexOf('?');
      final number = _decode(s.substring(4, q < 0 ? s.length : q));
      return _sms(l, raw, number, q < 0 ? '' : _query(s.substring(q + 1), plus: true)['body'] ?? '');
    }
    if (lower.startsWith('geo:')) {
      final geo = _geo(l, raw, s);
      if (geo != null) return geo;
    }
    if (lower.startsWith('begin:vcard')) return _vcard(l, raw, s);
    if (lower.startsWith('mecard:')) return _mecard(l, raw, s.substring(7));
    return QrPayload(QrKind.text, raw, title: l.qrText, display: s, strings: l);
  }

  static QrPayload _wifi(ScannerLocalizations l, String raw, String body) {
    final f = _fields(body);
    final ssid = f['S'] ?? '';
    final pass = f['P'] ?? '';
    final type = (f['T'] ?? '').toUpperCase();
    final security = switch (type) {
      '' => pass.isEmpty ? l.qrSecurityOpen : l.qrSecurityUnspecified,
      'NOPASS' => l.qrSecurityOpen,
      'WPA' || 'WPA2' => 'WPA/WPA2',
      'SAE' || 'WPA3' => 'WPA3',
      _ => type,
    };
    return QrPayload(
      QrKind.wifi,
      raw,
      title: l.qrWifi,
      display: ssid.isEmpty ? l.qrHiddenNetwork : ssid,
      secret: pass.isEmpty ? null : pass,
      fields: [
        (l.qrNetwork, ssid.isEmpty ? l.qrNoName : ssid),
        (l.qrSecurity, security),
        if ((f['H'] ?? '').toLowerCase() == 'true') (l.qrHidden, l.qrYes),
        if ((f['E'] ?? '').isNotEmpty) (l.qrEapMethod, f['E']!),
        if ((f['I'] ?? '').isNotEmpty) (l.qrIdentity, f['I']!),
      ],
      strings: l,
    );
  }

  static QrPayload _email(ScannerLocalizations l, String raw, String to, String subject, String body) => QrPayload(
    QrKind.email,
    raw,
    title: l.qrEmail,
    display: to.isEmpty ? subject : to,
    link: Uri(scheme: 'mailto', path: to, query: _encodeQuery({'subject': subject, 'body': body})),
    fields: [
      if (to.isNotEmpty) (l.qrTo, to),
      if (subject.isNotEmpty) (l.qrSubject, subject),
      if (body.isNotEmpty) (l.qrMessage, body),
    ],
    strings: l,
  );

  static QrPayload _sms(ScannerLocalizations l, String raw, String number, String message) {
    final n = number.trim();
    return QrPayload(
      QrKind.sms,
      raw,
      title: l.qrSms,
      display: n.isEmpty ? message : n,
      link: Uri(scheme: 'sms', path: n, query: _encodeQuery({'body': message})),
      fields: [if (n.isNotEmpty) (l.qrNumber, n), if (message.isNotEmpty) (l.qrMessage, message)],
      strings: l,
    );
  }

  /// `geo:lat,lng[,alt][;params][?q=place]`. Null (→ plain text) when the coordinates aren't valid.
  static QrPayload? _geo(ScannerLocalizations l, String raw, String s) {
    final q = s.indexOf('?');
    final coords = s.substring(4, q < 0 ? s.length : q).split(';').first.split(',').map((e) => e.trim()).toList();
    final lat = double.tryParse(coords.first), lng = coords.length > 1 ? double.tryParse(coords[1]) : null;
    if (lat == null || lng == null || lat.abs() > 90 || lng.abs() > 180) return null;
    final place = q < 0 ? '' : (_query(s.substring(q + 1), plus: true)['q'] ?? '').trim();
    final at = '${coords[0]}, ${coords[1]}';
    final alt = coords.length > 2 ? double.tryParse(coords[2]) : null;
    final nowhere = lat == 0 && lng == 0; // "geo:0,0?q=address" means: search for the address
    return QrPayload(
      QrKind.geo,
      raw,
      title: l.qrLocation,
      display: nowhere && place.isNotEmpty ? place : at,
      link: Uri.tryParse(s),
      fields: [
        if (!nowhere) (l.qrCoordinates, at),
        if (place.isNotEmpty) (l.qrPlace, place),
        if (alt != null) (l.qrAltitude, '${coords[2]} m'),
      ],
      strings: l,
    );
  }

  /// vCard 2.1–4.0: unfolds continuation lines, reads `NAME;PARAMS:value`, drops group prefixes (`item1.TEL`).
  static QrPayload _vcard(ScannerLocalizations l, String raw, String s) {
    final lines = s.replaceAll(RegExp(r'\r?\n[ \t]'), '').split(RegExp(r'\r?\n'));
    String? fn, n, org, job, note;
    final phones = <String>[], emails = <String>[], urls = <String>[], addresses = <String>[];
    for (final line in lines) {
      final colon = line.indexOf(':');
      if (colon < 0) continue;
      final name = line.substring(0, colon).split(';').first.split('.').last.toUpperCase();
      final value = line.substring(colon + 1).trim();
      if (value.isEmpty) continue;
      String parts(String sep) => _vParts(value).where((e) => e.isNotEmpty).join(sep);
      switch (name) {
        case 'FN':
          fn = parts(' ');
        case 'N':
          final p = [..._vParts(value), '', '', '', '']; // family; given; additional; prefix; suffix
          n = [p[3], p[1], p[2], p[0], p[4]].where((e) => e.isNotEmpty).join(' ');
        case 'ORG':
          org = parts(', ');
        case 'TITLE':
          job = parts(' ');
        case 'TEL':
          phones.add(parts(' ').replaceFirst(RegExp('^tel:', caseSensitive: false), ''));
        case 'EMAIL':
          emails.add(parts(' '));
        case 'URL':
          urls.add(_vParts(value).join(';'));
        case 'ADR':
          addresses.add(parts(', ').replaceAll('\n', ', '));
        case 'NOTE':
          note = parts('; ');
      }
    }
    return _contact(l, raw, fn?.isNotEmpty == true ? fn : n, org, job, phones, emails, urls, addresses, note);
  }

  /// `MECARD:N:Last,First;TEL:…;EMAIL:…;;` (keys may repeat).
  static QrPayload _mecard(ScannerLocalizations l, String raw, String body) {
    final e = _entries(body);
    List<String> all(String key) => [
      for (final (k, v) in e)
        if (k == key && v.trim().isNotEmpty) v.trim(),
    ];
    final n = all('N').firstOrNull?.split(',');
    final name = n == null ? null : [...n.skip(1), n.first].map((x) => x.trim()).where((x) => x.isNotEmpty).join(' ');
    return _contact(
      l,
      raw,
      name,
      all('ORG').firstOrNull,
      all('TITLE').firstOrNull,
      all('TEL'),
      all('EMAIL'),
      all('URL'),
      all('ADR'),
      all('NOTE').firstOrNull,
    );
  }

  static QrPayload _contact(
    ScannerLocalizations l,
    String raw,
    String? name,
    String? org,
    String? job,
    List<String> phones,
    List<String> emails,
    List<String> urls,
    List<String> addresses,
    String? note,
  ) {
    bool has(String? v) => v != null && v.trim().isNotEmpty;
    return QrPayload(
      QrKind.contact,
      raw,
      title: l.qrContact,
      display: has(name) ? name! : (has(org) ? org! : l.qrContactCard),
      fields: [
        if (has(name)) (l.qrName, name!),
        if (has(org)) (l.qrOrganization, org!),
        if (has(job)) (l.qrJobTitle, job!),
        for (final p in phones) (l.qrPhone, p),
        for (final e in emails) (l.qrEmail, e),
        for (final u in urls) (l.qrWebsite, u),
        for (final a in addresses) (l.qrAddress, a),
        if (has(note)) (l.qrNote, note!),
      ],
      strings: l,
    );
  }

  /// Splits a vCard value on unescaped `;` and unescapes `\n \, \; \\`.
  static List<String> _vParts(String value) {
    final out = <String>[];
    final buf = StringBuffer();
    for (var i = 0; i < value.length; i++) {
      final c = value[i];
      if (c == r'\' && i + 1 < value.length) {
        final next = value[++i];
        buf.write(next == 'n' || next == 'N' ? '\n' : next);
      } else if (c == ';') {
        out.add(buf.toString().trim());
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    return out..add(buf.toString().trim());
  }

  static Map<String, String> _fields(String body) => {for (final (k, v) in _entries(body)) k: v};

  /// `KEY:value;KEY:value;;` with `\` escapes, as used by WIFI:, MATMSG: and MECARD:. Keys are upper-cased.
  static List<(String, String)> _entries(String body) {
    final out = <(String, String)>[];
    final buf = StringBuffer();
    String? key;
    for (var i = 0; i < body.length; i++) {
      final c = body[i];
      if (c == r'\' && i + 1 < body.length) {
        buf.write(body[++i]);
      } else if (c == ':' && key == null) {
        key = buf.toString().toUpperCase();
        buf.clear();
      } else if (c == ';') {
        if (key != null) out.add((key, buf.toString()));
        key = null;
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    if (key != null) out.add((key, buf.toString()));
    return out;
  }

  /// Query parameters with lower-cased keys. [plus]: `+` means a space (form encoding, used by geo: and sms:
  /// generators; RFC 6068 mailto: keeps it literal). Malformed `%` escapes are kept as typed instead of throwing.
  static Map<String, String> _query(String q, {bool plus = false}) {
    final out = <String, String>{};
    for (final part in (plus ? q.replaceAll('+', ' ') : q).split('&')) {
      if (part.isEmpty) continue;
      final i = part.indexOf('=');
      out[_decode(i < 0 ? part : part.substring(0, i)).toLowerCase()] = i < 0 ? '' : _decode(part.substring(i + 1));
    }
    return out;
  }

  static String _decode(String s) {
    try {
      return Uri.decodeComponent(s);
    } on ArgumentError {
      return s;
    }
  }

  /// `subject=Hi%20there&body=…` (spaces as %20, not `+`, which mail and SMS apps show literally). Empty values
  /// are skipped; null when nothing is left.
  static String? _encodeQuery(Map<String, String> params) {
    final q = [
      for (final MapEntry(:key, :value) in params.entries)
        if (value.isNotEmpty) '$key=${Uri.encodeComponent(value)}',
    ].join('&');
    return q.isEmpty ? null : q;
  }
}
