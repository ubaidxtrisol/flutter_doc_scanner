import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/scanner/qr_payload.dart';

void main() {
  test('websites', () {
    final p = QrPayload.parse('https://www.docscan.app/welcome');
    expect((p.kind, p.title, p.display), (QrKind.url, 'Website', 'docscan.app/welcome'));
    expect(p.link.toString(), 'https://www.docscan.app/welcome');
    expect(QrPayload.parse('www.example.com').link.toString(), 'https://www.example.com');
  });

  test('wifi with escapes', () {
    final p = QrPayload.parse(r'WIFI:T:WPA;S:Home\;Net;P:pa\:ss;;');
    expect((p.kind, p.display, p.secret), (QrKind.wifi, 'Home;Net', 'pa:ss'));
  });

  test('email, phone, sms, geo, contacts, text', () {
    expect(QrPayload.parse('mailto:a@b.co').display, 'a@b.co');
    expect(QrPayload.parse('MATMSG:TO:a@b.co;SUB:Hi;;').link.toString(), 'mailto:a@b.co');
    expect(QrPayload.parse('tel:+923001234567').link.toString(), 'tel:+923001234567');
    expect(QrPayload.parse('SMSTO:+1555:hello').display, '+1555');
    expect(QrPayload.parse('geo:33.6,73.0?q=x').display, '33.6,73.0');
    expect(QrPayload.parse('BEGIN:VCARD\nVERSION:3.0\nFN:Ada Lovelace\nEND:VCARD').display, 'Ada Lovelace');
    expect(QrPayload.parse('MECARD:N:Lovelace,Ada;TEL:1;;').display, 'Lovelace Ada');
    final t = QrPayload.parse('just some words');
    expect((t.kind, t.link), (QrKind.text, null));
  });
}
