import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../engine.dart';
import 'solver.dart';

/// Base URL of our math backend (the Claude API key lives there, never in the app). Set at build time:
///   flutter run --dart-define=MATH_API_URL=https://math.example.com
/// Contract: docs/SCANNER_PHASES.md, Phase 3 "Cloud path".
const mathApiUrl = String.fromEnvironment('MATH_API_URL');

bool get cloudMathEnabled => mathApiUrl.isNotEmpty;

class CloudMathException implements Exception {
  const CloudMathException(this.message);
  final String message;
  @override
  String toString() => message;
}

final _cache = <String, MathSolution>{};

/// Sends the OCR text (and the photo, downscaled) to the backend. Throws [CloudMathException] with a
/// user-facing message on any failure.
Future<MathSolution> solveInCloud(String text, {String? photo}) async {
  if (!cloudMathEnabled) throw const CloudMathException("This problem needs the online solver, which isn't set up yet.");
  final key = normalizeMath(text);
  final cached = _cache[key];
  if (cached != null) return cached;

  String? image;
  if (photo != null) {
    final small = '${(await getTemporaryDirectory()).path}/math_upload.jpg';
    await DocScanner.process(path: photo, outPath: small, maxSize: 1280);
    image = base64Encode(await File(small).readAsBytes());
  }

  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final req = await client.postUrl(Uri.parse('$mathApiUrl/solve'));
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode({'text': text, 'image': ?image}));
    final res = await req.close().timeout(const Duration(seconds: 15));
    final body = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) throw CloudMathException('The online solver had a problem (${res.statusCode}). Try again.');
    final solution = _parse(text, body);
    _cache[key] = solution;
    return solution;
  } on SocketException {
    throw const CloudMathException('Needs internet for this problem.');
  } on TimeoutException {
    throw const CloudMathException('The online solver took too long. Try again.');
  } finally {
    client.close();
  }
}

/// Validates the backend's `{type, answer, steps: [{title, expr}]}` before trusting it.
MathSolution _parse(String problem, String body) {
  try {
    final j = jsonDecode(body) as Map<String, dynamic>;
    return MathSolution(
      problem: problem,
      type: j['type'] as String,
      answer: j['answer'] as String,
      steps: [
        for (final s in j['steps'] as List) MathStep((s as Map)['title'] as String, s['expr'] as String),
      ],
      online: true,
    );
  } catch (_) {
    throw const CloudMathException('The online solver sent an unreadable answer. Try again.');
  }
}
