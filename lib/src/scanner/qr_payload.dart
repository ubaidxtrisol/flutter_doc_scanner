/// What a scanned code contains, parsed from its raw text (same on both platforms).
enum QrKind { url, wifi, email, phone, sms, contact, geo, text }

class QrPayload {
  const QrPayload(this.kind, this.raw, {required this.title, required this.display, this.link, this.secret});

  final QrKind kind;
  final String raw;

  /// Label for the sheet ("Website", "Wi-Fi", …).
  final String title;

  /// Main line shown to the user.
  final String display;

  /// URI to open for the primary action (null if there is none).
  final Uri? link;

  /// Wi-Fi password, copied instead of the raw payload.
  final String? secret;

  static QrPayload parse(String raw) {
    final s = raw.trim();
    final lower = s.toLowerCase();

    if (RegExp(r'^https?://', caseSensitive: false).hasMatch(s) || RegExp(r'^www\.\S+\.\S+$', caseSensitive: false).hasMatch(s)) {
      final uri = Uri.tryParse(lower.startsWith('www.') ? 'https://$s' : s);
      if (uri != null && uri.host.isNotEmpty) {
        final shown = '${uri.host.replaceFirst(RegExp('^www\\.'), '')}${uri.path == '/' ? '' : uri.path}';
        return QrPayload(QrKind.url, raw, title: 'Website', display: shown, link: uri);
      }
    }
    if (lower.startsWith('wifi:')) {
      final f = _fields(s.substring(5));
      final ssid = f['S'] ?? '';
      return QrPayload(QrKind.wifi, raw,
          title: 'Wi-Fi', display: ssid.isEmpty ? 'Hidden network' : ssid, secret: f['P']);
    }
    if (lower.startsWith('mailto:')) {
      final uri = Uri.tryParse(s);
      return QrPayload(QrKind.email, raw, title: 'Email', display: uri?.path ?? s.substring(7), link: uri);
    }
    if (lower.startsWith('matmsg:')) {
      final to = _fields(s.substring(7))['TO'] ?? '';
      return QrPayload(QrKind.email, raw, title: 'Email', display: to, link: Uri(scheme: 'mailto', path: to));
    }
    if (lower.startsWith('tel:')) {
      final number = s.substring(4);
      return QrPayload(QrKind.phone, raw, title: 'Phone', display: number, link: Uri(scheme: 'tel', path: number));
    }
    if (lower.startsWith('smsto:') || lower.startsWith('sms:')) {
      final number = s.substring(s.indexOf(':') + 1).split(':').first;
      return QrPayload(QrKind.sms, raw, title: 'SMS', display: number, link: Uri(scheme: 'sms', path: number));
    }
    if (lower.startsWith('geo:')) {
      return QrPayload(QrKind.geo, raw, title: 'Location', display: s.substring(4).split('?').first, link: Uri.tryParse(s));
    }
    if (lower.startsWith('begin:vcard')) {
      final name = RegExp(r'^FN[^:]*:(.+)$', multiLine: true).firstMatch(s)?.group(1)?.trim();
      return QrPayload(QrKind.contact, raw, title: 'Contact', display: name ?? 'Contact card');
    }
    if (lower.startsWith('mecard:')) {
      final name = _fields(s.substring(7))['N']?.replaceAll(',', ' ').trim();
      return QrPayload(QrKind.contact, raw, title: 'Contact', display: name ?? 'Contact card');
    }
    return QrPayload(QrKind.text, raw, title: 'Text', display: s);
  }

  /// `KEY:value;KEY:value;;` with `\` escapes, as used by WIFI:, MATMSG: and MECARD:.
  static Map<String, String> _fields(String body) {
    final out = <String, String>{};
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
        if (key != null) out[key] = buf.toString();
        key = null;
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    if (key != null) out[key] = buf.toString();
    return out;
  }
}
