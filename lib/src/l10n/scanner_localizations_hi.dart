// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class ScannerLocalizationsHi extends ScannerLocalizations {
  ScannerLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get close => 'बंद करें';

  @override
  String get back => 'वापस';

  @override
  String get undo => 'पहले जैसा करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get done => 'हो गया';

  @override
  String get next => 'आगे';

  @override
  String get retry => 'फिर से कोशिश करें';

  @override
  String get retake => 'फिर से लें';

  @override
  String get review => 'देखें';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get copied => 'कॉपी हो गया';

  @override
  String get share => 'शेयर करें';

  @override
  String get saving => 'सेव हो रहा है…';

  @override
  String get saveToDocuments => 'दस्तावेज़ों में सेव करें';

  @override
  String get savePdf => 'PDF सेव करें';

  @override
  String get sharePdf => 'PDF शेयर करें';

  @override
  String get settings => 'सेटिंग';

  @override
  String get openSettings => 'सेटिंग खोलें';

  @override
  String get tryAgain => 'फिर से कोशिश करें';

  @override
  String pageOf(int page, int total) {
    return '$total में से पेज $page';
  }

  @override
  String detailLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get tabDocument => 'दस्तावेज़';

  @override
  String get tabIdCard => 'ID कार्ड';

  @override
  String get tabPassport => 'पासपोर्ट';

  @override
  String get tabBook => 'किताब';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'गणित';

  @override
  String get tabCount => 'गिनती';

  @override
  String get tabMeasure => 'माप';

  @override
  String get titleScanQr => 'QR स्कैन करें';

  @override
  String get titleCountObjects => 'चीज़ें गिनें';

  @override
  String get pageLabelPassport => 'पासपोर्ट';

  @override
  String get pageLabelIdDocument => 'ID दस्तावेज़';

  @override
  String get pageLabelIdFront => 'ID आगे';

  @override
  String get pageLabelIdBack => 'ID पीछे';

  @override
  String get pageLabelLeft => 'बायां';

  @override
  String get pageLabelRight => 'दायां';

  @override
  String get pageLabelSpread => 'दोनों पेज';

  @override
  String get pageLabelMath => 'गणित';

  @override
  String get pageLabelArea => 'क्षेत्रफल';

  @override
  String defaultTitle(String date) {
    return 'स्कैन $date';
  }

  @override
  String get titleMathSolutions => 'गणित के हल';

  @override
  String get titleQrCodes => 'QR कोड';

  @override
  String get titleAreaMeasurements => 'क्षेत्रफल माप';

  @override
  String get titleCountResults => 'गिनती के नतीजे';

  @override
  String get mathNeedsAi =>
      'गणित हल करने के लिए AI चाहिए, जो इस ऐप में सेट अप नहीं है।';

  @override
  String get mathNoAnswer =>
      'सॉल्वर को जवाब नहीं मिला। ज़्यादा साफ़ फ़ोटो आज़माएं।';

  @override
  String captureFailed(String message) {
    return 'कैप्चर नहीं हो सका: $message';
  }

  @override
  String get measureCaptureFailed =>
      'माप कैप्चर नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get measureCameraStopped => 'कैमरा रुक गया। फिर से कोशिश करें।';

  @override
  String get measureShapeChanged =>
      'आकार बदल गया। इसे फिर से बंद करें, फिर सेव करें।';

  @override
  String get photoAccessDenied =>
      'इंपोर्ट करने के लिए सेटिंग में फ़ोटो ऐक्सेस की अनुमति दें।';

  @override
  String get imageUnreadable => 'वह इमेज पढ़ी नहीं जा सकी। कोई दूसरी आज़माएं।';

  @override
  String get imageOpenFailed => 'वह इमेज खुल नहीं सकी। कोई दूसरी आज़माएं।';

  @override
  String get noCodeInImage => 'उस इमेज में कोई कोड नहीं मिला';

  @override
  String get noMrzInImage =>
      'उस इमेज में पढ़ने लायक MRZ नहीं है। ज़्यादा साफ़ फ़ोटो आज़माएं।';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count स्कैन किए पेज हटाएं?',
      one: '1 स्कैन किया पेज हटाएं?',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'स्कैन जारी रखें';

  @override
  String get discard => 'हटाएं';

  @override
  String get flashOn => 'फ़्लैश चालू';

  @override
  String get flashOff => 'फ़्लैश बंद';

  @override
  String get showGrid => 'ग्रिड दिखाएं';

  @override
  String get hideGrid => 'ग्रिड छिपाएं';

  @override
  String get autoCaptureOn => 'ऑटो कैप्चर चालू';

  @override
  String get autoCaptureOff => 'ऑटो कैप्चर बंद';

  @override
  String get autoBadge => 'ऑटो';

  @override
  String bookChipLeft(int page) {
    return 'बायां · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'दायां · $page';
  }

  @override
  String get pointAtSurfaceFirst => 'पहले गोले को किसी सतह की ओर करें';

  @override
  String get idSideFront => '1  आगे की तरफ़';

  @override
  String get idSideBack => '2  पीछे की तरफ़';

  @override
  String get pillQr => 'QR कोड या बारकोड की ओर कैमरा करें';

  @override
  String get pillCount => 'चीज़ों की ओर कैमरा करें, फिर शटर टैप करें';

  @override
  String get pillMathOff => 'गणित हल करने के लिए AI चाहिए, जो सेट अप नहीं है';

  @override
  String get pillMath => 'गणित के सवाल की ओर कैमरा करें, फिर शटर टैप करें';

  @override
  String get pillMrzDetected => 'MRZ मिला · स्थिर रखें';

  @override
  String get pillPassport => 'फ़ोटो वाला पेज फ़्रेम के अंदर रखें';

  @override
  String get pillIdFrontSaved => 'आगे का हिस्सा सेव हुआ · कार्ड पलटें';

  @override
  String get pillSaved => 'सेव हो गया';

  @override
  String get pillIdBack => 'अब पीछे का हिस्सा स्कैन करें';

  @override
  String get pillIdFit => 'कार्ड को फ़्रेम के अंदर रखें';

  @override
  String get pillCardDetected => 'कार्ड मिला · स्थिर रखें';

  @override
  String get pillBook => 'किसी खुली किताब की ओर कैमरा करें';

  @override
  String get pillBookAuto => 'किताब मिली · पेज अपने-आप अलग होंगे';

  @override
  String get pillBookTap => 'किताब मिली · कैप्चर करने के लिए टैप करें';

  @override
  String get pillCaptured => 'कैप्चर हो गया · अगला पेज रखें';

  @override
  String get pillDocument => 'किसी दस्तावेज़ की ओर कैमरा करें';

  @override
  String get pillDocumentAuto => 'दस्तावेज़ मिला · स्थिर रखें';

  @override
  String get pillDocumentTap => 'दस्तावेज़ मिला · कैप्चर करने के लिए टैप करें';

  @override
  String get cameraOffTitle => 'कैमरा ऐक्सेस बंद है';

  @override
  String get cameraOffBody =>
      'दस्तावेज़ स्कैन करने के लिए कैमरा ऐक्सेस की अनुमति दें।';

  @override
  String get arUnsupportedTitle => 'इस फ़ोन पर AR उपलब्ध नहीं है';

  @override
  String get arUnsupportedBody =>
      'मापने के लिए Google Play Services for AR चाहिए।';

  @override
  String get arInstallTitle => 'AR सपोर्ट इंस्टॉल करें';

  @override
  String get arInstallBody =>
      'Google Play Services for AR इंस्टॉल करना पूरा करें, फिर से कोशिश करें।';

  @override
  String get arFailedTitle => 'AR शुरू नहीं हो सका';

  @override
  String get arFailedBody => 'AR कैमरा शुरू करने में कुछ गड़बड़ हो गई।';

  @override
  String get cameraFailedTitle => 'कैमरा उपलब्ध नहीं है';

  @override
  String get cameraFailedBody => 'कैमरा शुरू करने में कुछ गड़बड़ हो गई।';

  @override
  String get importFromGallery => 'गैलरी से इंपोर्ट करें';

  @override
  String get capture => 'कैप्चर करें';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पेज देखें',
      one: '1 पेज देखें',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'लिंक खोलें';

  @override
  String get sendEmail => 'ईमेल भेजें';

  @override
  String get call => 'कॉल करें';

  @override
  String get sendMessage => 'मैसेज करें';

  @override
  String get openMap => 'मैप खोलें';

  @override
  String get copyPassword => 'पासवर्ड कॉपी करें';

  @override
  String get passwordCopied => 'पासवर्ड कॉपी हो गया';

  @override
  String get copyFailed => 'कॉपी नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get noAppCanOpen => 'इस फ़ोन पर कोई ऐप इसे नहीं खोल सकता।';

  @override
  String get shareFailed => 'शेयरिंग खुल नहीं सकी। फिर से कोशिश करें।';

  @override
  String get qrSaveFailed => 'QR कोड सेव नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get qrTooLong =>
      'QR कोड के रूप में दिखाने के लिए बहुत लंबा है। पूरी सामग्री नीचे है।';

  @override
  String get qrGenerated => 'स्कैन की गई सामग्री से बनाया गया';

  @override
  String get password => 'पासवर्ड';

  @override
  String get showPassword => 'पासवर्ड दिखाएं';

  @override
  String get hidePassword => 'पासवर्ड छिपाएं';

  @override
  String get codeEmpty => 'यह कोड खाली है';

  @override
  String get codeEmptyBody => 'इसमें दिखाने के लिए कुछ नहीं है।';

  @override
  String get codeUnreadable => 'यह कोड पढ़ा नहीं जा सका';

  @override
  String get codeNotText => 'इसमें ऐसा डेटा है जो टेक्स्ट नहीं है।';

  @override
  String get scanAgain => 'फिर से स्कैन करें';

  @override
  String get qrCodeImage => 'QR कोड';

  @override
  String qrCardTitle(String kind) {
    return 'QR कोड · $kind';
  }

  @override
  String get qrCardContent => 'सामग्री';

  @override
  String get scannedWithDocScan => 'DocScan से स्कैन किया गया';

  @override
  String get anotherMath => 'दूसरा सवाल हल करें';

  @override
  String get anotherQr => 'दूसरा कोड स्कैन करें';

  @override
  String get anotherArea => 'दूसरा क्षेत्रफल मापें';

  @override
  String get anotherCount => 'और चीज़ें गिनें';

  @override
  String get addAnother => 'एक और जोड़ें';

  @override
  String get addedToScan => 'आपके स्कैन में जोड़ा गया';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · अब तक $count पेज',
      one: '$title · अब तक 1 पेज',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'वेबसाइट';

  @override
  String get qrLink => 'लिंक';

  @override
  String get qrPhone => 'फ़ोन';

  @override
  String get qrNumber => 'नंबर';

  @override
  String get qrText => 'टेक्स्ट';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'छिपा हुआ नेटवर्क';

  @override
  String get qrNetwork => 'नेटवर्क';

  @override
  String get qrNoName => '(कोई नाम नहीं)';

  @override
  String get qrSecurity => 'सुरक्षा';

  @override
  String get qrSecurityOpen => 'कोई नहीं (खुला)';

  @override
  String get qrSecurityUnspecified => 'तय नहीं';

  @override
  String get qrHidden => 'छिपा हुआ';

  @override
  String get qrYes => 'हां';

  @override
  String get qrEapMethod => 'EAP तरीका';

  @override
  String get qrIdentity => 'पहचान';

  @override
  String get qrEmail => 'ईमेल';

  @override
  String get qrTo => 'प्रति';

  @override
  String get qrSubject => 'विषय';

  @override
  String get qrMessage => 'मैसेज';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'जगह';

  @override
  String get qrCoordinates => 'निर्देशांक';

  @override
  String get qrPlace => 'स्थान';

  @override
  String get qrAltitude => 'ऊंचाई';

  @override
  String get qrContact => 'संपर्क';

  @override
  String get qrContactCard => 'संपर्क कार्ड';

  @override
  String get qrName => 'नाम';

  @override
  String get qrOrganization => 'संगठन';

  @override
  String get qrJobTitle => 'पद';

  @override
  String get qrAddress => 'पता';

  @override
  String get qrNote => 'नोट';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'इसे हल नहीं किया जा सका';

  @override
  String get mathSaveFailed => 'हल सेव नहीं हो सका। फिर से कोशिश करें।';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चरण',
      one: '1 चरण',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'AI से हल किया गया';

  @override
  String get mathAnswer => 'जवाब';

  @override
  String mathCopyProblem(String problem) {
    return 'सवाल: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'जवाब: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'गणित · $answer';
  }

  @override
  String get mathCardTitle => 'गणित का हल';

  @override
  String get mathCardContinued => 'गणित का हल · जारी';

  @override
  String get mathCardProblem => 'सवाल';

  @override
  String get mathCardSteps => 'चरण';

  @override
  String get solvingWithAiLabel => 'AI से हल हो रहा है';

  @override
  String get solvingWithAi => 'AI से हल हो रहा है…';

  @override
  String get solvingDetail => 'सवाल पढ़ा जा रहा है और हर चरण जांचा जा रहा है';

  @override
  String get exportFailed => 'PDF एक्सपोर्ट नहीं हो सकी';

  @override
  String bookPagesTitle(int first, int last) {
    return 'पेज $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'पेज $page';
  }

  @override
  String get splitIntoTwo => 'दो पेजों में बांटें';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जोड़ी पेज स्कैन हुईं · $pages पेज',
      one: '1 जोड़ी पेज स्कैन हुई · $pages पेज',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'अगले दो पेज';

  @override
  String get saveBook => 'किताब सेव करें';

  @override
  String get idCardTitle => 'ID कार्ड';

  @override
  String get passportTitle => 'पासपोर्ट';

  @override
  String get idDocumentTitle => 'ID दस्तावेज़';

  @override
  String get layoutStacked => 'ऊपर-नीचे';

  @override
  String get layoutSideBySide => 'साथ-साथ';

  @override
  String get layoutSeparate => 'अलग-अलग';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get idNumber => 'ID नंबर';

  @override
  String get dateOfBirth => 'जन्म तिथि';

  @override
  String get extractedDetails => 'निकाली गई जानकारी';

  @override
  String get copyAllLower => 'सभी कॉपी करें';

  @override
  String get copyAll => 'सभी कॉपी करें';

  @override
  String get detailsCopied => 'जानकारी कॉपी हो गई';

  @override
  String get readingCard => 'कार्ड पढ़ा जा रहा है…';

  @override
  String get noMrzOnCard =>
      'इस कार्ड पर मशीन से पढ़ा जाने वाला ज़ोन नहीं है, इसलिए निकालने के लिए कोई सत्यापित जानकारी नहीं है। स्कैन जैसा है वैसा सेव किया गया है।';

  @override
  String copyField(String label) {
    return '$label कॉपी करें';
  }

  @override
  String fieldCopied(String label) {
    return '$label कॉपी हो गया';
  }

  @override
  String get passportNo => 'पासपोर्ट नं.';

  @override
  String get documentNo => 'दस्तावेज़ नं.';

  @override
  String get nationality => 'राष्ट्रीयता';

  @override
  String get sex => 'लिंग';

  @override
  String get issuingCountry => 'जारी करने वाला देश';

  @override
  String get expires => 'समाप्ति';

  @override
  String expiredOn(String date) {
    return '$date को समाप्त हो गया';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count साल और मान्य',
      one: '1 साल और मान्य',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count महीने और मान्य',
      one: '1 महीना और मान्य',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'एक महीने से कम में समाप्त होगा';

  @override
  String get mrzVerified => 'MRZ सत्यापित';

  @override
  String pageDeleted(int page) {
    return 'पेज $page मिटाया गया';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पेज मिटाए गए',
      one: '1 पेज मिटाया गया',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'कैमरा';

  @override
  String get addFromPhotos => 'फ़ोटो';

  @override
  String selectedCount(int count) {
    return '$count चुने गए';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count पेज',
      one: '1 पेज',
    );
    return '$_temp0';
  }

  @override
  String get select => 'चुनें';

  @override
  String get tapToSelect => 'पेज चुनने के लिए उन पर टैप करें';

  @override
  String get dragToReorder => 'पेजों का क्रम बदलने के लिए देर तक दबाकर खींचें';

  @override
  String get rotateSelected => 'चुने गए घुमाएं';

  @override
  String get delete => 'मिटाएं';

  @override
  String deleteCount(int count) {
    return '$count मिटाएं';
  }

  @override
  String get editPages => 'पेज बदलें';

  @override
  String get saveAsPdf => 'PDF के रूप में सेव करें';

  @override
  String rotatePage(int page) {
    return 'पेज $page घुमाएं';
  }

  @override
  String deletePage(int page) {
    return 'पेज $page मिटाएं';
  }

  @override
  String get addPage => 'पेज जोड़ें';

  @override
  String get cameraOrPhotos => 'कैमरा या फ़ोटो';

  @override
  String get filterOriginal => 'मूल';

  @override
  String get filterMagic => 'मैजिक';

  @override
  String get filterBw => 'B & W';

  @override
  String get filterGray => 'ग्रे';

  @override
  String get filterNoShadow => 'नो शैडो';

  @override
  String get filterColor => 'कलर';

  @override
  String get adjustCrop => 'क्रॉप एडजस्ट करें';

  @override
  String get reset => 'रीसेट करें';

  @override
  String get rotate => 'घुमाएं';

  @override
  String get cropAuto => 'ऑटो';

  @override
  String get cropPerspective => 'पर्सपेक्टिव';

  @override
  String get cropFullPage => 'पूरा पेज';

  @override
  String get enhance => 'बेहतर बनाएं';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter सभी $count पेज पर लागू किया गया';
  }

  @override
  String get brightness => 'ब्राइटनेस';

  @override
  String get contrast => 'कंट्रास्ट';

  @override
  String get applyToAll => 'सभी पर लागू करें';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed => 'नतीजा सेव नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get objectCount => 'चीज़ों की गिनती';

  @override
  String get countedWithDocScan => 'DocScan से गिना गया';

  @override
  String countPageLabel(int count) {
    return 'गिनती: $count';
  }

  @override
  String countAdded(int count) {
    return '$count जोड़े गए';
  }

  @override
  String countRemoved(int count) {
    return '$count हटाए गए';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'चीज़ें',
      one: 'चीज़',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'प्रकार';

  @override
  String get roundObjects => 'गोल चीज़ें';

  @override
  String get boxes => 'डिब्बे';

  @override
  String get custom => 'कस्टम';

  @override
  String get matchedToSample => 'टैप किए गए नमूने से मिलाया गया';

  @override
  String get countAutomatic => 'अपने-आप';

  @override
  String get countByHand => 'हाथ से';

  @override
  String get noChanges => 'कोई बदलाव नहीं';

  @override
  String get tapOneObject =>
      'उसके जैसी चीज़ें गिनने के लिए एक चीज़ पर टैप करें';

  @override
  String get objectsDetected => 'पहचानी गई चीज़ें';

  @override
  String get removeOne => 'एक हटाएं';

  @override
  String get addOne => 'एक जोड़ें';

  @override
  String get saveResult => 'नतीजा सेव करें';

  @override
  String get areaMeasurement => 'क्षेत्रफल माप';

  @override
  String get measuredNote => 'DocScan AR से मापा गया · लगभग ±5%';

  @override
  String areaTitle(String area) {
    return 'क्षेत्रफल · $area';
  }

  @override
  String get area => 'क्षेत्रफल';

  @override
  String get perimeter => 'परिधि';

  @override
  String get sides => 'भुजाएं';

  @override
  String get points => 'बिंदु';

  @override
  String summaryArea(String area) {
    return 'क्षेत्रफल $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count बिंदु',
      one: '1 बिंदु',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head। भुजाएं $sides';
  }

  @override
  String get hintStartingAr => 'AR शुरू हो रहा है…';

  @override
  String get hintTooDark => 'बहुत अंधेरा है · फ़्लैश चालू करें';

  @override
  String get hintMoveSlower => 'अपना फ़ोन और धीरे हिलाएं';

  @override
  String get hintMoreDetail => 'ज़्यादा डिटेल वाली सतह की ओर कैमरा करें';

  @override
  String get hintFindSurface => 'सतह खोजने के लिए अपना फ़ोन धीरे-धीरे हिलाएं';

  @override
  String get hintDragCorner => 'एडजस्ट करने के लिए कोना खींचें';

  @override
  String get hintPointCircle => 'गोले को किसी सतह की ओर करें';

  @override
  String get hintAimBack => 'वापस उसी सतह की ओर करें';

  @override
  String get hintTapToDrop => 'बिंदु लगाने के लिए + टैप करें';

  @override
  String get hintNextCorner => 'अगला कोना जोड़ने के लिए + टैप करें';

  @override
  String get hintClose => 'आकार बंद करने के लिए पहले बिंदु पर टैप करें';

  @override
  String get savingMeasurement => 'माप सेव हो रहा है';

  @override
  String get saveMeasurement => 'माप सेव करें';

  @override
  String get newMeasurement => 'नया माप';

  @override
  String get addPoint => 'बिंदु जोड़ें';

  @override
  String get meters => 'मीटर';

  @override
  String get feet => 'फ़ुट';
}
