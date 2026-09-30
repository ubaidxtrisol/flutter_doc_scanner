import 'package:flutter/services.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

// Channel shapes from docs/SCANNER_PHASES.md: detection events, recognizeText blocks, process arguments.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Detection parses corners, codes and lines', () {
    final d = Detection.fromMap({
      'mode': 'passport',
      'corners': [0, 0, 1, 0, 1, 1, 0, 1],
      'codes': [
        {'value': 'hi', 'corners': null},
      ],
      'lines': [
        {
          'text': 'P<UTO',
          'box': [.1, .2, .9, .3],
        },
      ],
    });
    expect(d.corners, const [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(0, 1)]);
    expect(d.codes.single.value, 'hi');
    expect(d.lines.single.text, 'P<UTO');
    expect(d.lines.single.box, const Rect.fromLTRB(.1, .2, .9, .3));
    expect(
      Detection.fromMap({
        'mode': 'document',
        'corners': [1, 2],
      }).corners,
      isNull,
    ); // malformed quad
  });

  test('TextBlock parses text, box and lines (lines optional)', () {
    final b = TextBlock.fromMap({
      'text': 'Hello\nworld',
      'box': [.1, .1, .5, .3],
      'lines': [
        {
          'text': 'Hello',
          'box': [.1, .1, .4, .2],
        },
        {
          'text': 'world',
          'box': [.1, .2, .5, .3],
        },
      ],
    });
    expect(b.text, 'Hello\nworld');
    expect(b.box, const Rect.fromLTRB(.1, .1, .5, .3));
    expect([for (final l in b.lines) l.text], ['Hello', 'world']);
    expect(b.lines.last.box.right, .5);
    expect(
      TextBlock.fromMap({
        'text': 'x',
        'box': [0, 0, 1, 1],
      }).lines,
      isEmpty,
    );
  });

  group('channel', () {
    final calls = <MethodCall>[];
    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter_doc_scanner'),
        (call) async {
          calls.add(call);
          return switch (call.method) {
            'recognizeText' when (call.arguments as Map)['script'] == 'klingon' => throw PlatformException(
              code: 'UNSUPPORTED_SCRIPT',
            ),
            'recognizeText' => [
              {
                'text': '你好',
                'box': [.2, .2, .6, .3],
                'lines': [
                  {
                    'text': '你好',
                    'box': [.2, .2, .6, .3],
                  },
                ],
              },
            ],
            _ => null,
          };
        },
      );
    });

    test('recognizeText sends path + script and returns blocks', () async {
      final blocks = await DocScanner.recognizeText('/tmp/page.jpg', script: 'chinese');
      expect(calls.single.method, 'recognizeText');
      expect(calls.single.arguments, {'path': '/tmp/page.jpg', 'script': 'chinese'});
      expect(blocks.single.text, '你好');
      expect(blocks.single.lines.single.box, const Rect.fromLTRB(.2, .2, .6, .3));
      expect((await DocScanner.recognizeText('/tmp/page.jpg')).length, 1);
      expect(calls.last.arguments['script'], 'latin');
      expect(
        DocScanner.recognizeText('/tmp/page.jpg', script: 'klingon'),
        throwsA(isA<PlatformException>().having((e) => e.code, 'code', 'UNSUPPORTED_SCRIPT')),
      );
    });

    test('process sends filter, brightness and contrast', () async {
      await DocScanner.process(
        path: 'a.jpg',
        outPath: 'b.jpg',
        filter: PageFilter.noShadow,
        brightness: .24,
        contrast: -.1,
      );
      final a = calls.single.arguments as Map;
      expect(a['filter'], 'noShadow');
      expect(a['brightness'], .24);
      expect(a['contrast'], -.1);
      expect(a['corners'], isNull);
    });
  });
}
