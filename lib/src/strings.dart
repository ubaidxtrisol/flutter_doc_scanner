import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'l10n/scanner_localizations.dart';

export 'l10n/scanner_localizations.dart';

/// English strings: the fallback when the host doesn't register [ScannerLocalizations.delegate] or its language
/// has no scanner translation yet, and the default for code without a [BuildContext].
final scannerEnglish = lookupScannerLocalizations(const Locale('en'));

extension ScannerStrings on BuildContext {
  /// The scanner's strings in the app's language, English when there are none.
  ScannerLocalizations get l10n => ScannerLocalizations.of(this) ?? scannerEnglish;

  /// Locale for `intl` date formats: the app's, if its date symbols are loaded (the host's
  /// `GlobalMaterialLocalizations` loads them), else English.
  String get dateLocale {
    final tag = Localizations.maybeLocaleOf(this)?.toString() ?? 'en';
    return DateFormat.localeExists(tag) ? tag : 'en';
  }
}
