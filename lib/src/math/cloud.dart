import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../engine.dart';
import '../scanner.dart';
import '../strings.dart';
import 'solver.dart';

/// User-facing failure of the online solver.
class CloudMathException implements Exception {
  const CloudMathException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Solves the math problem in [photo] through the host's [Scanner.onlineMath] (an AI model), with the photo
/// downscaled to ≤ 1280 px. No OCR text is sent: the AI reads the problem from the photo. The module holds no keys.
Future<MathSolution> solveInCloud(String photo, ScannerLocalizations l) async {
  final solve = Scanner.onlineMath;
  if (solve == null) {
    throw CloudMathException(l.mathNeedsAi);
  }
  String? small;
  try {
    small = '${(await getTemporaryDirectory()).path}/math_${DateTime.now().microsecondsSinceEpoch}.jpg';
    await DocScanner.process(path: photo, outPath: small, maxSize: 1280);
  } catch (_) {
    small = null; // send the full photo rather than nothing
  }
  try {
    final solution = await solve('', small ?? photo);
    if (solution.answer.trim().isEmpty) {
      throw CloudMathException(l.mathNoAnswer);
    }
    return solution;
  } on CloudMathException {
    rethrow;
  } catch (e) {
    // The host's errors are user-facing (e.g. "Needs an internet connection.").
    throw CloudMathException(e.toString());
  } finally {
    if (small != null) File(small).delete().ignore();
  }
}
