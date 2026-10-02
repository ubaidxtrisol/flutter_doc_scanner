// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class ScannerLocalizationsAr extends ScannerLocalizations {
  ScannerLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get undo => 'تراجع';

  @override
  String get cancel => 'إلغاء';

  @override
  String get done => 'تم';

  @override
  String get next => 'التالي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get retake => 'إعادة الالتقاط';

  @override
  String get review => 'مراجعة';

  @override
  String get copy => 'نسخ';

  @override
  String get copied => 'تم النسخ';

  @override
  String get share => 'مشاركة';

  @override
  String get saving => 'جارٍ الحفظ…';

  @override
  String get saveToDocuments => 'حفظ في المستندات';

  @override
  String get savePdf => 'حفظ PDF';

  @override
  String get sharePdf => 'مشاركة PDF';

  @override
  String get settings => 'الإعدادات';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String pageOf(int page, int total) {
    return 'صفحة $page من $total';
  }

  @override
  String detailLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get tabDocument => 'مستند';

  @override
  String get tabIdCard => 'بطاقة هوية';

  @override
  String get tabPassport => 'جواز سفر';

  @override
  String get tabBook => 'كتاب';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'رياضيات';

  @override
  String get tabCount => 'عدّ';

  @override
  String get tabMeasure => 'قياس';

  @override
  String get titleScanQr => 'مسح رمز QR';

  @override
  String get titleCountObjects => 'عدّ الأشياء';

  @override
  String get pageLabelPassport => 'جواز السفر';

  @override
  String get pageLabelIdDocument => 'وثيقة الهوية';

  @override
  String get pageLabelIdFront => 'وجه الهوية';

  @override
  String get pageLabelIdBack => 'ظهر الهوية';

  @override
  String get pageLabelLeft => 'يسار';

  @override
  String get pageLabelRight => 'يمين';

  @override
  String get pageLabelSpread => 'صفحتان متقابلتان';

  @override
  String get pageLabelMath => 'رياضيات';

  @override
  String get pageLabelArea => 'مساحة';

  @override
  String defaultTitle(String date) {
    return 'مسح $date';
  }

  @override
  String get titleMathSolutions => 'حلول رياضية';

  @override
  String get titleQrCodes => 'رموز QR';

  @override
  String get titleAreaMeasurements => 'قياسات المساحة';

  @override
  String get titleCountResults => 'نتائج العدّ';

  @override
  String get mathNeedsAi =>
      'يتطلب حل المسائل الرياضية AI، وهو غير مُعدّ في هذا التطبيق.';

  @override
  String get mathNoAnswer => 'تعذّر على أداة الحل إيجاد إجابة. جرّب صورة أوضح.';

  @override
  String captureFailed(String message) {
    return 'تعذّر الالتقاط: $message';
  }

  @override
  String get measureCaptureFailed => 'تعذّر التقاط القياس. حاول مرة أخرى.';

  @override
  String get measureCameraStopped => 'توقفت الكاميرا. حاول مرة أخرى.';

  @override
  String get measureShapeChanged => 'تغيّر الشكل. أغلقه مرة أخرى، ثم احفظ.';

  @override
  String get photoAccessDenied =>
      'اسمح بالوصول إلى الصور من الإعدادات للاستيراد.';

  @override
  String get imageUnreadable => 'تعذّرت قراءة هذه الصورة. جرّب صورة أخرى.';

  @override
  String get imageOpenFailed => 'تعذّر فتح هذه الصورة. جرّب صورة أخرى.';

  @override
  String get noCodeInImage => 'لم يتم العثور على رمز في هذه الصورة';

  @override
  String get noMrzInImage =>
      'لا توجد منطقة MRZ مقروءة في هذه الصورة. جرّب صورة أوضح.';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تجاهل $count صفحة ممسوحة؟',
      many: 'تجاهل $count صفحة ممسوحة؟',
      few: 'تجاهل $count صفحات ممسوحة؟',
      two: 'تجاهل الصفحتين الممسوحتين؟',
      one: 'تجاهل الصفحة الممسوحة؟',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'متابعة المسح';

  @override
  String get discard => 'تجاهل';

  @override
  String get flashOn => 'الفلاش مُشغّل';

  @override
  String get flashOff => 'الفلاش متوقف';

  @override
  String get showGrid => 'إظهار الشبكة';

  @override
  String get hideGrid => 'إخفاء الشبكة';

  @override
  String get autoCaptureOn => 'الالتقاط التلقائي مُشغّل';

  @override
  String get autoCaptureOff => 'الالتقاط التلقائي متوقف';

  @override
  String get autoBadge => 'تلقائي';

  @override
  String bookChipLeft(int page) {
    return 'يسار · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'يمين · $page';
  }

  @override
  String get pointAtSurfaceFirst => 'وجّه الدائرة نحو سطح أولًا';

  @override
  String get idSideFront => '1  الوجه الأمامي';

  @override
  String get idSideBack => '2  الوجه الخلفي';

  @override
  String get pillQr => 'وجّه الكاميرا نحو رمز QR أو باركود';

  @override
  String get pillCount => 'وجّه الكاميرا نحو الأشياء، ثم اضغط زر الالتقاط';

  @override
  String get pillMathOff => 'يتطلب حل المسائل الرياضية AI، وهو غير مُعدّ';

  @override
  String get pillMath => 'وجّه الكاميرا نحو مسألة رياضية، ثم اضغط زر الالتقاط';

  @override
  String get pillMrzDetected => 'تم رصد MRZ · ثبّت الهاتف';

  @override
  String get pillPassport => 'ضع صفحة الصورة داخل الإطار';

  @override
  String get pillIdFrontSaved => 'تم حفظ الوجه الأمامي · اقلب البطاقة';

  @override
  String get pillSaved => 'تم الحفظ';

  @override
  String get pillIdBack => 'امسح الآن الوجه الخلفي';

  @override
  String get pillIdFit => 'ضع البطاقة داخل الإطار';

  @override
  String get pillCardDetected => 'تم رصد البطاقة · لا تحرّك الهاتف';

  @override
  String get pillBook => 'وجّه الكاميرا نحو كتاب مفتوح';

  @override
  String get pillBookAuto => 'تم رصد الكتاب · تُقسَّم الصفحات تلقائيًا';

  @override
  String get pillBookTap => 'تم رصد الكتاب · اضغط للالتقاط';

  @override
  String get pillCaptured => 'تم الالتقاط · ضع الصفحة التالية';

  @override
  String get pillDocument => 'وجّه الكاميرا نحو مستند';

  @override
  String get pillDocumentAuto => 'تم رصد المستند · لا تحرّك الهاتف';

  @override
  String get pillDocumentTap => 'تم رصد المستند · اضغط للالتقاط';

  @override
  String get cameraOffTitle => 'الوصول إلى الكاميرا متوقف';

  @override
  String get cameraOffBody => 'اسمح بالوصول إلى الكاميرا لمسح المستندات.';

  @override
  String get arUnsupportedTitle => 'الواقع المعزز غير متاح على هذا الهاتف';

  @override
  String get arUnsupportedBody =>
      'يتطلب القياس خدمات Google Play للواقع المعزز.';

  @override
  String get arInstallTitle => 'تثبيت دعم الواقع المعزز';

  @override
  String get arInstallBody =>
      'أكمل تثبيت خدمات Google Play للواقع المعزز، ثم حاول مرة أخرى.';

  @override
  String get arFailedTitle => 'تعذّر تشغيل الواقع المعزز';

  @override
  String get arFailedBody => 'حدث خطأ أثناء تشغيل كاميرا الواقع المعزز.';

  @override
  String get cameraFailedTitle => 'الكاميرا غير متاحة';

  @override
  String get cameraFailedBody => 'حدث خطأ أثناء تشغيل الكاميرا.';

  @override
  String get importFromGallery => 'استيراد من المعرض';

  @override
  String get capture => 'التقاط';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'مراجعة $count صفحة',
      many: 'مراجعة $count صفحة',
      few: 'مراجعة $count صفحات',
      two: 'مراجعة صفحتين',
      one: 'مراجعة صفحة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'فتح الرابط';

  @override
  String get sendEmail => 'إرسال بريد إلكتروني';

  @override
  String get call => 'اتصال';

  @override
  String get sendMessage => 'رسالة';

  @override
  String get openMap => 'فتح الخريطة';

  @override
  String get copyPassword => 'نسخ كلمة المرور';

  @override
  String get passwordCopied => 'تم نسخ كلمة المرور';

  @override
  String get copyFailed => 'تعذّر النسخ. حاول مرة أخرى.';

  @override
  String get noAppCanOpen => 'لا يوجد تطبيق على هذا الهاتف يمكنه فتح هذا.';

  @override
  String get shareFailed => 'تعذّر فتح المشاركة. حاول مرة أخرى.';

  @override
  String get qrSaveFailed => 'تعذّر حفظ رمز QR. حاول مرة أخرى.';

  @override
  String get qrTooLong =>
      'المحتوى أطول من أن يُعرض كرمز QR. المحتوى الكامل أدناه.';

  @override
  String get qrGenerated => 'تم إنشاؤه من المحتوى الممسوح';

  @override
  String get password => 'كلمة المرور';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get codeEmpty => 'هذا الرمز فارغ';

  @override
  String get codeEmptyBody => 'لا يوجد فيه ما يمكن عرضه.';

  @override
  String get codeUnreadable => 'تعذّرت قراءة هذا الرمز';

  @override
  String get codeNotText => 'يحتوي على بيانات ليست نصًا.';

  @override
  String get scanAgain => 'المسح مرة أخرى';

  @override
  String get qrCodeImage => 'رمز QR';

  @override
  String qrCardTitle(String kind) {
    return 'رمز QR · $kind';
  }

  @override
  String get qrCardContent => 'المحتوى';

  @override
  String get scannedWithDocScan => 'تم المسح باستخدام DocScan';

  @override
  String get anotherMath => 'حل مسألة أخرى';

  @override
  String get anotherQr => 'مسح رمز آخر';

  @override
  String get anotherArea => 'قياس مساحة أخرى';

  @override
  String get anotherCount => 'عدّ المزيد من الأشياء';

  @override
  String get addAnother => 'إضافة المزيد';

  @override
  String get addedToScan => 'تمت الإضافة إلى المسح';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · $count صفحة حتى الآن',
      many: '$title · $count صفحة حتى الآن',
      few: '$title · $count صفحات حتى الآن',
      two: '$title · صفحتان حتى الآن',
      one: '$title · صفحة واحدة حتى الآن',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'موقع ويب';

  @override
  String get qrLink => 'رابط';

  @override
  String get qrPhone => 'هاتف';

  @override
  String get qrNumber => 'الرقم';

  @override
  String get qrText => 'نص';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'شبكة مخفية';

  @override
  String get qrNetwork => 'الشبكة';

  @override
  String get qrNoName => '(بلا اسم)';

  @override
  String get qrSecurity => 'الأمان';

  @override
  String get qrSecurityOpen => 'بلا (مفتوحة)';

  @override
  String get qrSecurityUnspecified => 'غير محدد';

  @override
  String get qrHidden => 'مخفية';

  @override
  String get qrYes => 'نعم';

  @override
  String get qrEapMethod => 'طريقة EAP';

  @override
  String get qrIdentity => 'الهوية';

  @override
  String get qrEmail => 'البريد الإلكتروني';

  @override
  String get qrTo => 'إلى';

  @override
  String get qrSubject => 'الموضوع';

  @override
  String get qrMessage => 'الرسالة';

  @override
  String get qrSms => 'رسالة SMS';

  @override
  String get qrLocation => 'الموقع';

  @override
  String get qrCoordinates => 'الإحداثيات';

  @override
  String get qrPlace => 'المكان';

  @override
  String get qrAltitude => 'الارتفاع';

  @override
  String get qrContact => 'جهة اتصال';

  @override
  String get qrContactCard => 'بطاقة جهة الاتصال';

  @override
  String get qrName => 'الاسم';

  @override
  String get qrOrganization => 'المؤسسة';

  @override
  String get qrJobTitle => 'المسمى الوظيفي';

  @override
  String get qrAddress => 'العنوان';

  @override
  String get qrNote => 'ملاحظة';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'تعذّر حل هذه المسألة';

  @override
  String get mathSaveFailed => 'تعذّر حفظ الحل. حاول مرة أخرى.';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خطوة',
      many: '$count خطوة',
      few: '$count خطوات',
      two: 'خطوتان',
      one: 'خطوة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'تم الحل باستخدام AI';

  @override
  String get mathAnswer => 'الإجابة';

  @override
  String mathCopyProblem(String problem) {
    return 'المسألة: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'الإجابة: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'رياضيات · $answer';
  }

  @override
  String get mathCardTitle => 'حل رياضي';

  @override
  String get mathCardContinued => 'حل رياضي · تابع';

  @override
  String get mathCardProblem => 'المسألة';

  @override
  String get mathCardSteps => 'الخطوات';

  @override
  String get solvingWithAiLabel => 'جارٍ الحل باستخدام AI';

  @override
  String get solvingWithAi => 'جارٍ الحل باستخدام AI…';

  @override
  String get solvingDetail => 'قراءة المسألة والتحقق من كل خطوة';

  @override
  String get exportFailed => 'تعذّر تصدير ملف PDF';

  @override
  String bookPagesTitle(int first, int last) {
    return 'الصفحات $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'صفحة $page';
  }

  @override
  String get splitIntoTwo => 'تقسيم إلى صفحتين';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم مسح $count زوج من الصفحات المتقابلة · $pages صفحة',
      many: 'تم مسح $count زوجًا من الصفحات المتقابلة · $pages صفحة',
      few: 'تم مسح $count أزواج من الصفحات المتقابلة · $pages صفحة',
      two: 'تم مسح زوجين من الصفحات المتقابلة · $pages صفحة',
      one: 'تم مسح زوج واحد من الصفحات المتقابلة · $pages صفحة',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'الصفحتان التاليتان';

  @override
  String get saveBook => 'حفظ الكتاب';

  @override
  String get idCardTitle => 'بطاقة هوية';

  @override
  String get passportTitle => 'جواز سفر';

  @override
  String get idDocumentTitle => 'وثيقة هوية';

  @override
  String get layoutStacked => 'متراصّة';

  @override
  String get layoutSideBySide => 'جنبًا إلى جنب';

  @override
  String get layoutSeparate => 'منفصلة';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get idNumber => 'رقم الهوية';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get extractedDetails => 'التفاصيل المستخرجة';

  @override
  String get copyAllLower => 'نسخ الكل';

  @override
  String get copyAll => 'نسخ الكل';

  @override
  String get detailsCopied => 'تم نسخ التفاصيل';

  @override
  String get readingCard => 'جارٍ قراءة البطاقة…';

  @override
  String get noMrzOnCard =>
      'لا تحتوي هذه البطاقة على منطقة مقروءة آليًا، لذا لا توجد بيانات موثّقة لاستخراجها. تم حفظ المسح كما هو.';

  @override
  String copyField(String label) {
    return 'نسخ $label';
  }

  @override
  String fieldCopied(String label) {
    return 'تم نسخ $label';
  }

  @override
  String get passportNo => 'رقم الجواز';

  @override
  String get documentNo => 'رقم الوثيقة';

  @override
  String get nationality => 'الجنسية';

  @override
  String get sex => 'الجنس';

  @override
  String get issuingCountry => 'بلد الإصدار';

  @override
  String get expires => 'تاريخ الانتهاء';

  @override
  String expiredOn(String date) {
    return 'انتهت في $date';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'صالحة لـ $count سنة أخرى',
      many: 'صالحة لـ $count سنة أخرى',
      few: 'صالحة لـ $count سنوات أخرى',
      two: 'صالحة لسنتين أخريين',
      one: 'صالحة لسنة واحدة أخرى',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'صالحة لـ $count شهر آخر',
      many: 'صالحة لـ $count شهرًا آخر',
      few: 'صالحة لـ $count أشهر أخرى',
      two: 'صالحة لشهرين آخرين',
      one: 'صالحة لشهر واحد آخر',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'تنتهي خلال أقل من شهر';

  @override
  String get mrzVerified => 'تم التحقق من MRZ';

  @override
  String pageDeleted(int page) {
    return 'تم حذف الصفحة $page';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم حذف $count صفحة',
      many: 'تم حذف $count صفحة',
      few: 'تم حذف $count صفحات',
      two: 'تم حذف صفحتين',
      one: 'تم حذف صفحة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'الكاميرا';

  @override
  String get addFromPhotos => 'الصور';

  @override
  String selectedCount(int count) {
    return 'تم تحديد $count';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحة',
      many: '$count صفحة',
      few: '$count صفحات',
      two: 'صفحتان',
      one: 'صفحة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get select => 'تحديد';

  @override
  String get tapToSelect => 'اضغط على الصفحات لتحديدها';

  @override
  String get dragToReorder => 'اضغط مطولًا واسحب لإعادة ترتيب الصفحات';

  @override
  String get rotateSelected => 'تدوير المحدد';

  @override
  String get delete => 'حذف';

  @override
  String deleteCount(int count) {
    return 'حذف $count';
  }

  @override
  String get editPages => 'تعديل الصفحات';

  @override
  String get saveAsPdf => 'حفظ كملف PDF';

  @override
  String rotatePage(int page) {
    return 'تدوير الصفحة $page';
  }

  @override
  String deletePage(int page) {
    return 'حذف الصفحة $page';
  }

  @override
  String get addPage => 'إضافة صفحة';

  @override
  String get cameraOrPhotos => 'الكاميرا أو الصور';

  @override
  String get filterOriginal => 'الأصلي';

  @override
  String get filterMagic => 'سحري';

  @override
  String get filterBw => 'أبيض وأسود';

  @override
  String get filterGray => 'رمادي';

  @override
  String get filterNoShadow => 'بلا ظلال';

  @override
  String get filterColor => 'ملوّن';

  @override
  String get adjustCrop => 'ضبط القص';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get rotate => 'تدوير';

  @override
  String get cropAuto => 'تلقائي';

  @override
  String get cropPerspective => 'المنظور';

  @override
  String get cropFullPage => 'الصفحة كاملة';

  @override
  String get enhance => 'تحسين';

  @override
  String filterAppliedToAll(String filter, int count) {
    return 'تم تطبيق $filter على كل الصفحات ($count)';
  }

  @override
  String get brightness => 'السطوع';

  @override
  String get contrast => 'التباين';

  @override
  String get applyToAll => 'تطبيق على الكل';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed => 'تعذّر حفظ النتيجة. حاول مرة أخرى.';

  @override
  String get objectCount => 'عدد الأشياء';

  @override
  String get countedWithDocScan => 'تم العدّ باستخدام DocScan';

  @override
  String countPageLabel(int count) {
    return 'العدد: $count';
  }

  @override
  String countAdded(int count) {
    return 'تمت إضافة $count';
  }

  @override
  String countRemoved(int count) {
    return 'تمت إزالة $count';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شيء',
      many: 'شيئًا',
      few: 'أشياء',
      two: 'شيئان',
      one: 'شيء',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'النوع';

  @override
  String get roundObjects => 'أشياء دائرية';

  @override
  String get boxes => 'صناديق';

  @override
  String get custom => 'مخصص';

  @override
  String get matchedToSample => 'مطابقة لعيّنة تم الضغط عليها';

  @override
  String get countAutomatic => 'تلقائي';

  @override
  String get countByHand => 'يدوي';

  @override
  String get noChanges => 'لا تغييرات';

  @override
  String get tapOneObject => 'اضغط على شيء واحد لعدّ الأشياء المشابهة له';

  @override
  String get objectsDetected => 'الأشياء المرصودة';

  @override
  String get removeOne => 'إزالة واحد';

  @override
  String get addOne => 'إضافة واحد';

  @override
  String get saveResult => 'حفظ النتيجة';

  @override
  String get areaMeasurement => 'قياس المساحة';

  @override
  String get measuredNote => 'تم القياس باستخدام DocScan AR · تقريبًا ±5%';

  @override
  String areaTitle(String area) {
    return 'مساحة · $area';
  }

  @override
  String get area => 'المساحة';

  @override
  String get perimeter => 'المحيط';

  @override
  String get sides => 'الأضلاع';

  @override
  String get points => 'النقاط';

  @override
  String summaryArea(String area) {
    return 'المساحة $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نقطة',
      many: '$count نقطة',
      few: '$count نقاط',
      two: 'نقطتان',
      one: 'نقطة واحدة',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head. الأضلاع $sides';
  }

  @override
  String get hintStartingAr => 'جارٍ تشغيل الواقع المعزز…';

  @override
  String get hintTooDark => 'الإضاءة خافتة جدًا · شغّل الفلاش';

  @override
  String get hintMoveSlower => 'حرّك هاتفك ببطء أكثر';

  @override
  String get hintMoreDetail => 'وجّه الكاميرا نحو سطح فيه تفاصيل أكثر';

  @override
  String get hintFindSurface => 'حرّك هاتفك ببطء للعثور على سطح';

  @override
  String get hintDragCorner => 'اسحب زاوية لضبطها';

  @override
  String get hintPointCircle => 'وجّه الدائرة نحو سطح';

  @override
  String get hintAimBack => 'وجّه الكاميرا مجددًا نحو السطح نفسه';

  @override
  String get hintTapToDrop => 'اضغط + لوضع النقاط';

  @override
  String get hintNextCorner => 'اضغط + لإضافة الزاوية التالية';

  @override
  String get hintClose => 'اضغط على النقطة الأولى لإغلاق الشكل';

  @override
  String get savingMeasurement => 'جارٍ حفظ القياس';

  @override
  String get saveMeasurement => 'حفظ القياس';

  @override
  String get newMeasurement => 'قياس جديد';

  @override
  String get addPoint => 'إضافة نقطة';

  @override
  String get meters => 'متر';

  @override
  String get feet => 'قدم';
}
