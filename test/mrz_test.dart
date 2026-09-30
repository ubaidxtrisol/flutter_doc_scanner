import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_doc_scanner/src/scanner/mrz.dart';

// ICAO 9303 specimen MRZs.
const td3 = ['P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<<<<<<<', 'L898902C36UTO7408122F1204159ZE184226B<<<<<10'];
const td2 = ['I<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<', 'D231458907UTO7408122F1204159<<<<<<<6'];
const td1 = ['I<UTOD231458907<<<<<<<<<<<<<<<', '7408122F1204159UTO<<<<<<<<<<<6', 'ERIKSSON<<ANNA<MARIA<<<<<<<<<<'];
final now = DateTime(2026, 9, 29);

void expectAnna(Mrz? m, String format, String doc) {
  expect(m, isNotNull);
  expect(m!.format, format);
  expect(m.surname, 'ERIKSSON');
  expect(m.givenNames, 'ANNA MARIA');
  expect(m.documentNumber, doc);
  expect(m.issuingCountry, 'UTO');
  expect(m.nationality, 'UTO');
  expect(m.birthDate, DateTime(1974, 8, 12));
  expect(m.expiryDate, DateTime(2012, 4, 15));
  expect(m.sex, 'F');
}

void main() {
  test('check digit', () {
    expect(Mrz.checkDigit('L898902C3'), 6);
    expect(Mrz.checkDigit('740812'), 2);
    expect(Mrz.checkDigit('120415'), 9);
  });

  test('parses TD3, TD2, TD1 specimens', () {
    expectAnna(Mrz.find(td3, now: now), 'TD3', 'L898902C3');
    expectAnna(Mrz.find(td2, now: now), 'TD2', 'D23145890');
    expectAnna(Mrz.find(td1, now: now), 'TD1', 'D23145890');
  });

  test('finds the MRZ among other OCR lines and survives typical OCR noise', () {
    final noisy = [
      'REPUBLIC OF UTOPIA',
      'P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<<<<<<', // trailing fillers dropped
      'L898902C36UTO74O8122F12O4159ZE184226B<<<<<1O', // O instead of 0 in digit fields
    ];
    expectAnna(Mrz.find(noisy, now: now), 'TD3', 'L898902C3');
    expectAnna(Mrz.find(['P<UTOERIKSSON«ANNA<MARIA«<<<<<<<<<<<<<<<<<', td3[1]], now: now), 'TD3', 'L898902C3');
    // Seen on a Pixel 6: ML Kit dropped 11 trailing fillers.
    expectAnna(Mrz.find(['P<UTOERIKSSON<<ANNA<MARIA<<<<<<<<', td3[1]], now: now), 'TD3', 'L898902C3');
  });

  test('rejects anything failing a check digit', () {
    expect(Mrz.find([td3[0], td3[1].replaceFirst('7408122', '7408132')], now: now), isNull); // DOB misread
    expect(Mrz.find([td3[0], td3[1].replaceFirst('L898902C3', 'L898902C8')], now: now), isNull); // doc no misread
    expect(Mrz.find(const ['HELLO WORLD', 'NOT AN MRZ AT ALL'], now: now), isNull);
  });
}
