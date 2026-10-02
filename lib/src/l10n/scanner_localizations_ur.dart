// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class ScannerLocalizationsUr extends ScannerLocalizations {
  ScannerLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get close => 'بند کریں';

  @override
  String get back => 'واپس';

  @override
  String get undo => 'کالعدم کریں';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get done => 'ہو گیا';

  @override
  String get next => 'اگلا';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get retake => 'دوبارہ لیں';

  @override
  String get review => 'جائزہ';

  @override
  String get copy => 'کاپی کریں';

  @override
  String get copied => 'کاپی ہو گیا';

  @override
  String get share => 'شیئر کریں';

  @override
  String get saving => 'محفوظ ہو رہا ہے…';

  @override
  String get saveToDocuments => 'دستاویزات میں محفوظ کریں';

  @override
  String get savePdf => 'PDF محفوظ کریں';

  @override
  String get sharePdf => 'PDF شیئر کریں';

  @override
  String get settings => 'ترتیبات';

  @override
  String get openSettings => 'ترتیبات کھولیں';

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String pageOf(int page, int total) {
    return 'صفحہ $page از $total';
  }

  @override
  String detailLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get tabDocument => 'دستاویز';

  @override
  String get tabIdCard => 'شناختی کارڈ';

  @override
  String get tabPassport => 'پاسپورٹ';

  @override
  String get tabBook => 'کتاب';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'ریاضی';

  @override
  String get tabCount => 'گنتی';

  @override
  String get tabMeasure => 'پیمائش';

  @override
  String get titleScanQr => 'QR اسکین کریں';

  @override
  String get titleCountObjects => 'اشیاء گنیں';

  @override
  String get pageLabelPassport => 'پاسپورٹ';

  @override
  String get pageLabelIdDocument => 'شناختی دستاویز';

  @override
  String get pageLabelIdFront => 'کارڈ کا سامنا';

  @override
  String get pageLabelIdBack => 'کارڈ کی پشت';

  @override
  String get pageLabelLeft => 'بایاں';

  @override
  String get pageLabelRight => 'دایاں';

  @override
  String get pageLabelSpread => 'دو صفحے';

  @override
  String get pageLabelMath => 'ریاضی';

  @override
  String get pageLabelArea => 'رقبہ';

  @override
  String defaultTitle(String date) {
    return 'اسکین $date';
  }

  @override
  String get titleMathSolutions => 'ریاضی کے حل';

  @override
  String get titleQrCodes => 'QR کوڈز';

  @override
  String get titleAreaMeasurements => 'رقبے کی پیمائشیں';

  @override
  String get titleCountResults => 'گنتی کے نتائج';

  @override
  String get mathNeedsAi =>
      'ریاضی حل کرنے کے لیے AI درکار ہے، جو اس ایپ میں سیٹ اپ نہیں ہے۔';

  @override
  String get mathNoAnswer =>
      'حل کرنے والا جواب نہیں ڈھونڈ سکا۔ زیادہ واضح تصویر آزمائیں۔';

  @override
  String captureFailed(String message) {
    return 'تصویر نہیں لی جا سکی: $message';
  }

  @override
  String get measureCaptureFailed =>
      'پیمائش محفوظ نہیں ہو سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get measureCameraStopped => 'کیمرا رک گیا۔ دوبارہ کوشش کریں۔';

  @override
  String get measureShapeChanged =>
      'شکل بدل گئی۔ اسے دوبارہ بند کریں، پھر محفوظ کریں۔';

  @override
  String get photoAccessDenied =>
      'امپورٹ کرنے کے لیے ترتیبات میں تصاویر تک رسائی کی اجازت دیں۔';

  @override
  String get imageUnreadable => 'یہ تصویر پڑھی نہیں جا سکی۔ کوئی اور آزمائیں۔';

  @override
  String get imageOpenFailed => 'یہ تصویر کھل نہیں سکی۔ کوئی اور آزمائیں۔';

  @override
  String get noCodeInImage => 'اس تصویر میں کوئی کوڈ نہیں ملا';

  @override
  String get noMrzInImage =>
      'اس تصویر میں پڑھنے کے قابل MRZ نہیں ہے۔ زیادہ صاف تصویر آزمائیں۔';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اسکین شدہ صفحات ضائع کریں؟',
      one: '1 اسکین شدہ صفحہ ضائع کریں؟',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'اسکین جاری رکھیں';

  @override
  String get discard => 'ضائع کریں';

  @override
  String get flashOn => 'فلیش آن';

  @override
  String get flashOff => 'فلیش آف';

  @override
  String get showGrid => 'گرڈ دکھائیں';

  @override
  String get hideGrid => 'گرڈ چھپائیں';

  @override
  String get autoCaptureOn => 'خودکار کیپچر آن';

  @override
  String get autoCaptureOff => 'خودکار کیپچر آف';

  @override
  String get autoBadge => 'آٹو';

  @override
  String bookChipLeft(int page) {
    return 'بایاں · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'دایاں · $page';
  }

  @override
  String get pointAtSurfaceFirst => 'پہلے دائرے کو کسی سطح کی طرف کریں';

  @override
  String get idSideFront => '1  سامنے کا رخ';

  @override
  String get idSideBack => '2  پچھلا رخ';

  @override
  String get pillQr => 'QR کوڈ یا بارکوڈ کی طرف کیمرا کریں';

  @override
  String get pillCount => 'اشیاء کی طرف کیمرا کریں، پھر شٹر دبائیں';

  @override
  String get pillMathOff =>
      'ریاضی حل کرنے کے لیے AI درکار ہے، جو سیٹ اپ نہیں ہے';

  @override
  String get pillMath => 'ریاضی کے سوال کی طرف کیمرا کریں، پھر شٹر دبائیں';

  @override
  String get pillMrzDetected => 'MRZ مل گیا · ساکن رکھیں';

  @override
  String get pillPassport => 'تصویر والا صفحہ فریم کے اندر رکھیں';

  @override
  String get pillIdFrontSaved => 'سامنے کا رخ محفوظ · کارڈ پلٹیں';

  @override
  String get pillSaved => 'محفوظ ہو گیا';

  @override
  String get pillIdBack => 'اب پچھلا رخ اسکین کریں';

  @override
  String get pillIdFit => 'کارڈ کو فریم کے اندر رکھیں';

  @override
  String get pillCardDetected => 'کارڈ مل گیا · ساکن رکھیں';

  @override
  String get pillBook => 'کھلی کتاب کی طرف کیمرا کریں';

  @override
  String get pillBookAuto => 'کتاب مل گئی · صفحات خودبخود الگ ہوں گے';

  @override
  String get pillBookTap => 'کتاب مل گئی · کیپچر کے لیے ٹیپ کریں';

  @override
  String get pillCaptured => 'کیپچر ہو گیا · اگلا صفحہ رکھیں';

  @override
  String get pillDocument => 'دستاویز کی طرف کیمرا کریں';

  @override
  String get pillDocumentAuto => 'دستاویز مل گئی · ساکن رکھیں';

  @override
  String get pillDocumentTap => 'دستاویز مل گئی · کیپچر کے لیے ٹیپ کریں';

  @override
  String get cameraOffTitle => 'کیمرا تک رسائی بند ہے';

  @override
  String get cameraOffBody =>
      'دستاویزات اسکین کرنے کے لیے کیمرا تک رسائی کی اجازت دیں۔';

  @override
  String get arUnsupportedTitle => 'اس فون پر AR دستیاب نہیں';

  @override
  String get arUnsupportedBody =>
      'پیمائش کے لیے Google Play Services for AR درکار ہے۔';

  @override
  String get arInstallTitle => 'AR سپورٹ انسٹال کریں';

  @override
  String get arInstallBody =>
      'Google Play Services for AR کی انسٹالیشن مکمل کریں، پھر دوبارہ کوشش کریں۔';

  @override
  String get arFailedTitle => 'AR شروع نہیں ہو سکا';

  @override
  String get arFailedBody => 'AR کیمرا شروع کرتے وقت کچھ غلط ہو گیا۔';

  @override
  String get cameraFailedTitle => 'کیمرا دستیاب نہیں';

  @override
  String get cameraFailedBody => 'کیمرا شروع کرتے وقت کچھ غلط ہو گیا۔';

  @override
  String get importFromGallery => 'گیلری سے امپورٹ کریں';

  @override
  String get capture => 'کیپچر';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحات کا جائزہ لیں',
      one: '1 صفحے کا جائزہ لیں',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'لنک کھولیں';

  @override
  String get sendEmail => 'ای میل بھیجیں';

  @override
  String get call => 'کال کریں';

  @override
  String get sendMessage => 'پیغام';

  @override
  String get openMap => 'نقشہ کھولیں';

  @override
  String get copyPassword => 'پاس ورڈ کاپی کریں';

  @override
  String get passwordCopied => 'پاس ورڈ کاپی ہو گیا';

  @override
  String get copyFailed => 'کاپی نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get noAppCanOpen => 'اس فون پر کوئی ایپ اسے نہیں کھول سکتی۔';

  @override
  String get shareFailed => 'شیئرنگ نہیں کھل سکی۔ دوبارہ کوشش کریں۔';

  @override
  String get qrSaveFailed => 'QR کوڈ محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get qrTooLong =>
      'QR کوڈ کے طور پر دکھانے کے لیے بہت طویل ہے۔ مکمل مواد نیچے ہے۔';

  @override
  String get qrGenerated => 'اسکین شدہ مواد سے بنایا گیا';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get showPassword => 'پاس ورڈ دکھائیں';

  @override
  String get hidePassword => 'پاس ورڈ چھپائیں';

  @override
  String get codeEmpty => 'یہ کوڈ خالی ہے';

  @override
  String get codeEmptyBody => 'اس میں دکھانے کے لیے کچھ نہیں ہے۔';

  @override
  String get codeUnreadable => 'یہ کوڈ پڑھا نہیں جا سکا';

  @override
  String get codeNotText => 'اس میں ایسا ڈیٹا ہے جو متن نہیں ہے۔';

  @override
  String get scanAgain => 'دوبارہ اسکین کریں';

  @override
  String get qrCodeImage => 'QR کوڈ';

  @override
  String qrCardTitle(String kind) {
    return 'QR کوڈ · $kind';
  }

  @override
  String get qrCardContent => 'مواد';

  @override
  String get scannedWithDocScan => 'DocScan سے اسکین کیا گیا';

  @override
  String get anotherMath => 'ایک اور سوال حل کریں';

  @override
  String get anotherQr => 'ایک اور کوڈ اسکین کریں';

  @override
  String get anotherArea => 'ایک اور رقبہ ناپیں';

  @override
  String get anotherCount => 'مزید اشیاء گنیں';

  @override
  String get addAnother => 'ایک اور شامل کریں';

  @override
  String get addedToScan => 'آپ کے اسکین میں شامل کر دیا گیا';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · اب تک $count صفحات',
      one: '$title · اب تک 1 صفحہ',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'ویب سائٹ';

  @override
  String get qrLink => 'لنک';

  @override
  String get qrPhone => 'فون';

  @override
  String get qrNumber => 'نمبر';

  @override
  String get qrText => 'متن';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'پوشیدہ نیٹ ورک';

  @override
  String get qrNetwork => 'نیٹ ورک';

  @override
  String get qrNoName => '(کوئی نام نہیں)';

  @override
  String get qrSecurity => 'سیکیورٹی';

  @override
  String get qrSecurityOpen => 'کوئی نہیں (کھلا)';

  @override
  String get qrSecurityUnspecified => 'متعین نہیں';

  @override
  String get qrHidden => 'پوشیدہ';

  @override
  String get qrYes => 'ہاں';

  @override
  String get qrEapMethod => 'EAP طریقہ';

  @override
  String get qrIdentity => 'شناخت';

  @override
  String get qrEmail => 'ای میل';

  @override
  String get qrTo => 'بنام';

  @override
  String get qrSubject => 'موضوع';

  @override
  String get qrMessage => 'پیغام';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'مقام';

  @override
  String get qrCoordinates => 'کوآرڈینیٹس';

  @override
  String get qrPlace => 'جگہ';

  @override
  String get qrAltitude => 'بلندی';

  @override
  String get qrContact => 'رابطہ';

  @override
  String get qrContactCard => 'رابطہ کارڈ';

  @override
  String get qrName => 'نام';

  @override
  String get qrOrganization => 'ادارہ';

  @override
  String get qrJobTitle => 'عہدہ';

  @override
  String get qrAddress => 'پتہ';

  @override
  String get qrNote => 'نوٹ';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'یہ حل نہیں ہو سکا';

  @override
  String get mathSaveFailed => 'حل محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مراحل',
      one: '1 مرحلہ',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'AI سے حل کیا گیا';

  @override
  String get mathAnswer => 'جواب';

  @override
  String mathCopyProblem(String problem) {
    return 'سوال: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'جواب: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'ریاضی · $answer';
  }

  @override
  String get mathCardTitle => 'ریاضی کا حل';

  @override
  String get mathCardContinued => 'ریاضی کا حل · جاری';

  @override
  String get mathCardProblem => 'سوال';

  @override
  String get mathCardSteps => 'مراحل';

  @override
  String get solvingWithAiLabel => 'AI سے حل ہو رہا ہے';

  @override
  String get solvingWithAi => 'AI سے حل ہو رہا ہے…';

  @override
  String get solvingDetail =>
      'سوال پڑھا جا رہا ہے اور ہر مرحلہ جانچا جا رہا ہے';

  @override
  String get exportFailed => 'PDF ایکسپورٹ نہیں ہو سکی';

  @override
  String bookPagesTitle(int first, int last) {
    return 'صفحات $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'صفحہ $page';
  }

  @override
  String get splitIntoTwo => 'دو صفحات میں تقسیم کریں';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اسپریڈز اسکین ہوئے · $pages صفحات',
      one: '1 اسپریڈ اسکین ہوا · $pages صفحات',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'اگلا اسپریڈ';

  @override
  String get saveBook => 'کتاب محفوظ کریں';

  @override
  String get idCardTitle => 'شناختی کارڈ';

  @override
  String get passportTitle => 'پاسپورٹ';

  @override
  String get idDocumentTitle => 'شناختی دستاویز';

  @override
  String get layoutStacked => 'اوپر نیچے';

  @override
  String get layoutSideBySide => 'ساتھ ساتھ';

  @override
  String get layoutSeparate => 'الگ الگ';

  @override
  String get fullName => 'پورا نام';

  @override
  String get idNumber => 'شناختی نمبر';

  @override
  String get dateOfBirth => 'تاریخ پیدائش';

  @override
  String get extractedDetails => 'نکالی گئی تفصیلات';

  @override
  String get copyAllLower => 'سب کاپی کریں';

  @override
  String get copyAll => 'سب کاپی کریں';

  @override
  String get detailsCopied => 'تفصیلات کاپی ہو گئیں';

  @override
  String get readingCard => 'کارڈ پڑھا جا رہا ہے…';

  @override
  String get noMrzOnCard =>
      'اس کارڈ پر مشین سے پڑھنے کے قابل زون نہیں ہے، اس لیے نکالنے کے لیے کوئی تصدیق شدہ معلومات نہیں۔ اسکین جوں کا توں محفوظ کر دیا گیا ہے۔';

  @override
  String copyField(String label) {
    return '$label کاپی کریں';
  }

  @override
  String fieldCopied(String label) {
    return '$label کاپی ہو گیا';
  }

  @override
  String get passportNo => 'پاسپورٹ نمبر';

  @override
  String get documentNo => 'دستاویز نمبر';

  @override
  String get nationality => 'قومیت';

  @override
  String get sex => 'جنس';

  @override
  String get issuingCountry => 'جاری کرنے والا ملک';

  @override
  String get expires => 'میعاد ختم';

  @override
  String expiredOn(String date) {
    return 'میعاد $date کو ختم ہو گئی';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مزید $count سال کے لیے کارآمد',
      one: 'مزید 1 سال کے لیے کارآمد',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مزید $count ماہ کے لیے کارآمد',
      one: 'مزید 1 ماہ کے لیے کارآمد',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'ایک ماہ سے کم میں میعاد ختم';

  @override
  String get mrzVerified => 'MRZ تصدیق شدہ';

  @override
  String pageDeleted(int page) {
    return 'صفحہ $page حذف ہو گیا';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحات حذف ہو گئے',
      one: '1 صفحہ حذف ہو گیا',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'کیمرا';

  @override
  String get addFromPhotos => 'تصاویر';

  @override
  String selectedCount(int count) {
    return '$count منتخب';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحات',
      one: '1 صفحہ',
    );
    return '$_temp0';
  }

  @override
  String get select => 'منتخب کریں';

  @override
  String get tapToSelect => 'صفحات منتخب کرنے کے لیے ان پر ٹیپ کریں';

  @override
  String get dragToReorder =>
      'ترتیب بدلنے کے لیے صفحات کو دبا کر رکھیں اور گھسیٹیں';

  @override
  String get rotateSelected => 'منتخب گھمائیں';

  @override
  String get delete => 'حذف کریں';

  @override
  String deleteCount(int count) {
    return '$count حذف کریں';
  }

  @override
  String get editPages => 'صفحات میں ترمیم کریں';

  @override
  String get saveAsPdf => 'PDF کے طور پر محفوظ کریں';

  @override
  String rotatePage(int page) {
    return 'صفحہ $page گھمائیں';
  }

  @override
  String deletePage(int page) {
    return 'صفحہ $page حذف کریں';
  }

  @override
  String get addPage => 'صفحہ شامل کریں';

  @override
  String get cameraOrPhotos => 'کیمرا یا تصاویر';

  @override
  String get filterOriginal => 'اصل';

  @override
  String get filterMagic => 'میجک';

  @override
  String get filterBw => 'سیاہ و سفید';

  @override
  String get filterGray => 'گرے';

  @override
  String get filterNoShadow => 'بغیر سایہ';

  @override
  String get filterColor => 'رنگین';

  @override
  String get adjustCrop => 'کراپ ایڈجسٹ کریں';

  @override
  String get reset => 'ری سیٹ';

  @override
  String get rotate => 'گھمائیں';

  @override
  String get cropAuto => 'آٹو';

  @override
  String get cropPerspective => 'پرسپیکٹو';

  @override
  String get cropFullPage => 'پورا صفحہ';

  @override
  String get enhance => 'بہتر بنائیں';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter تمام $count صفحات پر لاگو ہو گیا';
  }

  @override
  String get brightness => 'چمک';

  @override
  String get contrast => 'کنٹراسٹ';

  @override
  String get applyToAll => 'سب پر لاگو کریں';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed => 'نتیجہ محفوظ نہیں ہو سکا۔ دوبارہ کوشش کریں۔';

  @override
  String get objectCount => 'اشیاء کی گنتی';

  @override
  String get countedWithDocScan => 'DocScan سے گنا گیا';

  @override
  String countPageLabel(int count) {
    return 'گنتی: $count';
  }

  @override
  String countAdded(int count) {
    return '$count شامل کیے';
  }

  @override
  String countRemoved(int count) {
    return '$count ہٹائے';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اشیاء',
      one: 'شے',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'قسم';

  @override
  String get roundObjects => 'گول اشیاء';

  @override
  String get boxes => 'ڈبے';

  @override
  String get custom => 'حسب ضرورت';

  @override
  String get matchedToSample => 'ٹیپ کیے گئے نمونے سے ملایا گیا';

  @override
  String get countAutomatic => 'خودکار';

  @override
  String get countByHand => 'ہاتھ سے';

  @override
  String get noChanges => 'کوئی تبدیلی نہیں';

  @override
  String get tapOneObject => 'ملتی جلتی اشیاء گننے کے لیے ایک شے پر ٹیپ کریں';

  @override
  String get objectsDetected => 'اشیاء کی شناخت ہو گئی';

  @override
  String get removeOne => 'ایک ہٹائیں';

  @override
  String get addOne => 'ایک شامل کریں';

  @override
  String get saveResult => 'نتیجہ محفوظ کریں';

  @override
  String get areaMeasurement => 'رقبے کی پیمائش';

  @override
  String get measuredNote => 'DocScan AR سے ناپا گیا · تقریباً ±5%';

  @override
  String areaTitle(String area) {
    return 'رقبہ · $area';
  }

  @override
  String get area => 'رقبہ';

  @override
  String get perimeter => 'احاطہ';

  @override
  String get sides => 'اطراف';

  @override
  String get points => 'پوائنٹس';

  @override
  String summaryArea(String area) {
    return 'رقبہ $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پوائنٹس',
      one: '1 پوائنٹ',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head۔ اطراف $sides';
  }

  @override
  String get hintStartingAr => 'AR شروع ہو رہا ہے…';

  @override
  String get hintTooDark => 'بہت اندھیرا ہے · فلیش آن کریں';

  @override
  String get hintMoveSlower => 'فون کو زیادہ آہستہ حرکت دیں';

  @override
  String get hintMoreDetail => 'زیادہ تفصیل والی سطح کی طرف کیمرا کریں';

  @override
  String get hintFindSurface => 'سطح ڈھونڈنے کے لیے فون کو آہستہ حرکت دیں';

  @override
  String get hintDragCorner => 'ایڈجسٹ کرنے کے لیے کونا گھسیٹیں';

  @override
  String get hintPointCircle => 'دائرے کو کسی سطح کی طرف کریں';

  @override
  String get hintAimBack => 'دوبارہ اسی سطح کی طرف کریں';

  @override
  String get hintTapToDrop => 'پوائنٹس لگانے کے لیے + پر ٹیپ کریں';

  @override
  String get hintNextCorner => 'اگلا کونا شامل کرنے کے لیے + پر ٹیپ کریں';

  @override
  String get hintClose => 'شکل بند کرنے کے لیے پہلے پوائنٹ پر ٹیپ کریں';

  @override
  String get savingMeasurement => 'پیمائش محفوظ ہو رہی ہے';

  @override
  String get saveMeasurement => 'پیمائش محفوظ کریں';

  @override
  String get newMeasurement => 'نئی پیمائش';

  @override
  String get addPoint => 'پوائنٹ شامل کریں';

  @override
  String get meters => 'میٹر';

  @override
  String get feet => 'فٹ';
}
