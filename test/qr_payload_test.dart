import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/scanner/qr_payload.dart';

void main() {
  test('websites', () {
    final p = QrPayload.parse('https://www.docscan.app/welcome');
    expect((p.kind, p.title, p.display), (QrKind.url, 'Website', 'docscan.app/welcome'));
    expect(p.link.toString(), 'https://www.docscan.app/welcome');
    expect(p.fields, [('Link', 'https://www.docscan.app/welcome')]);
    expect(p.copyText, 'https://www.docscan.app/welcome');
    expect(QrPayload.parse('www.example.com').link.toString(), 'https://www.example.com');
  });

  test('wifi: escapes, security, hidden flag, password kept out of display and fields', () {
    final p = QrPayload.parse(r'WIFI:T:WPA;S:Home\;Net;P:pa\:ss;H:true;;');
    expect((p.kind, p.display, p.secret), (QrKind.wifi, 'Home;Net', 'pa:ss'));
    expect(p.fields, [('Network', 'Home;Net'), ('Security', 'WPA/WPA2'), ('Hidden', 'Yes')]);
    expect(p.copyText, 'Home;Net');
    expect(p.saveTitle, 'QR · Home;Net');
    for (final (_, v) in p.fields) {
      expect(v, isNot(contains('pa:ss')));
    }

    final open = QrPayload.parse('WIFI:S:Cafe;T:nopass;;');
    expect((open.secret, open.fields[1]), (null, ('Security', 'None (open)')));
    expect(QrPayload.parse('WIFI:T:SAE;S:x;P:y;;').fields[1], ('Security', 'WPA3'));
    expect(QrPayload.parse('WIFI:T:WPA2-EAP;S:Corp;E:PEAP;I:ada;P:z;;').fields, [
      ('Network', 'Corp'),
      ('Security', 'WPA2-EAP'),
      ('EAP method', 'PEAP'),
      ('Identity', 'ada'),
    ]);
  });

  test('email: mailto with subject and body, MATMSG, bare address', () {
    final m = QrPayload.parse('mailto:a@b.co?subject=Hi%20there&body=See%20you');
    expect((m.kind, m.display), (QrKind.email, 'a@b.co'));
    expect(m.fields, [('To', 'a@b.co'), ('Subject', 'Hi there'), ('Message', 'See you')]);
    expect(m.link.toString(), 'mailto:a@b.co?subject=Hi%20there&body=See%20you');

    final mat = QrPayload.parse('MATMSG:TO:a@b.co;SUB:Hi;BODY:Line\\;two;;');
    expect(mat.fields, [('To', 'a@b.co'), ('Subject', 'Hi'), ('Message', 'Line;two')]);
    expect(mat.link.toString(), 'mailto:a@b.co?subject=Hi&body=Line%3Btwo');
    expect(QrPayload.parse('MATMSG:TO:a@b.co;;').link.toString(), 'mailto:a@b.co');

    expect(QrPayload.parse('ada@example.org').kind, QrKind.email);
    expect(QrPayload.parse('mailto:a@b.co?subject=100%').fields[1], ('Subject', '100%')); // bad escape kept
  });

  test('phone and SMS', () {
    final t = QrPayload.parse('tel:+923001234567');
    expect(t.link.toString(), 'tel:+923001234567');
    expect(t.fields, [('Number', '+923001234567')]);

    final s = QrPayload.parse('SMSTO:+1555:hello: world');
    expect(s.display, '+1555');
    expect(s.fields, [('Number', '+1555'), ('Message', 'hello: world')]);
    expect(s.link.toString(), 'sms:+1555?body=hello%3A%20world');
    expect(QrPayload.parse('sms:+1555?body=hi+there').fields, [('Number', '+1555'), ('Message', 'hi there')]);
    expect(QrPayload.parse('SMSTO:+1555').link.toString(), 'sms:+1555');
  });

  test('geo: coordinates, place, altitude; invalid coordinates stay text', () {
    final g = QrPayload.parse('geo:33.6,73.0?q=x');
    expect((g.kind, g.display), (QrKind.geo, '33.6, 73.0'));
    expect(g.fields, [('Coordinates', '33.6, 73.0'), ('Place', 'x')]);
    expect(QrPayload.parse('geo:48.2,16.37,180').fields, [('Coordinates', '48.2, 16.37'), ('Altitude', '180 m')]);
    final search = QrPayload.parse('geo:0,0?q=1600+Amphitheatre%20Pkwy');
    expect(search.display, '1600 Amphitheatre Pkwy');
    expect(search.fields, [('Place', '1600 Amphitheatre Pkwy')]);
    expect(QrPayload.parse('geo:abc').kind, QrKind.text);
    expect(QrPayload.parse('geo:95,10').kind, QrKind.text);
  });

  test('vCard: name, phones, emails, organization, folded lines, escapes', () {
    const card =
        'BEGIN:VCARD\r\nVERSION:3.0\r\nN:Lovelace;Ada;;Countess;\r\nFN:Ada Lovelace\r\nORG:Analytical\\, Ltd;R&D\r\n'
        'TITLE:Mathematician\r\nTEL;TYPE=CELL:+44 20 1234\r\nitem1.TEL:+44 20 5678\r\nEMAIL;TYPE=INTERNET:ada@\r\n'
        ' example.org\r\nADR;TYPE=WORK:;;12 St James\\nSquare;London;;SW1;UK\r\nURL:https://ada.dev\r\nEND:VCARD';
    final p = QrPayload.parse(card);
    expect((p.kind, p.display), (QrKind.contact, 'Ada Lovelace'));
    expect(p.fields, [
      ('Name', 'Ada Lovelace'),
      ('Organization', 'Analytical, Ltd, R&D'),
      ('Job title', 'Mathematician'),
      ('Phone', '+44 20 1234'),
      ('Phone', '+44 20 5678'),
      ('Email', 'ada@example.org'),
      ('Website', 'https://ada.dev'),
      ('Address', '12 St James, Square, London, SW1, UK'),
    ]);
    expect(p.copyText, card);
    expect(QrPayload.parse('BEGIN:VCARD\nN:Lovelace;Ada;;Dr.;\nEND:VCARD').display, 'Dr. Ada Lovelace');
    expect(QrPayload.parse('BEGIN:VCARD\nTEL;VALUE=uri:tel:+1555\nEND:VCARD').fields, [('Phone', '+1555')]);
  });

  test('MECARD: repeated keys, Last,First order', () {
    final p = QrPayload.parse(r'MECARD:N:Lovelace,Ada;TEL:1;TEL:2;EMAIL:a@b.co;ORG:Engines\;Co;;');
    expect(p.display, 'Ada Lovelace');
    expect(p.fields, [
      ('Name', 'Ada Lovelace'),
      ('Organization', 'Engines;Co'),
      ('Phone', '1'),
      ('Phone', '2'),
      ('Email', 'a@b.co'),
    ]);
  });

  test('text, empty and unreadable payloads', () {
    final t = QrPayload.parse('just some words');
    expect((t.kind, t.link, t.readable), (QrKind.text, null, true));
    expect(t.fields, isEmpty);
    expect(QrPayload.parse('').readable, false);
    expect(QrPayload.parse('  \n ').readable, false);
    expect(QrPayload.parse('\u0000\u0001�').readable, false);
  });

  test('save titles stay short and never empty', () {
    expect(QrPayload.parse('https://docscan.app/welcome').saveTitle, 'QR · docscan.app/welcome');
    final long = QrPayload.parse('word ' * 40).saveTitle;
    expect(long.length, 40);
    expect(long, startsWith('QR · word word'));
    expect(long, endsWith('…'));
    expect(QrPayload.parse('line one\n\nline two').saveTitle, 'QR · line one line two');
    expect(QrPayload.parse('MATMSG:;;').saveTitle, 'QR · Email');
    expect(QrPayload.parse('🙂' * 50).saveTitle.runes.length, 40); // never cuts an emoji in half
  });
}
