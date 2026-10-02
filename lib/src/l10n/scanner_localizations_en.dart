// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class ScannerLocalizationsEn extends ScannerLocalizations {
  ScannerLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get undo => 'Undo';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get retry => 'Retry';

  @override
  String get retake => 'Retake';

  @override
  String get review => 'Review';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get share => 'Share';

  @override
  String get saving => 'Saving…';

  @override
  String get saveToDocuments => 'Save to Documents';

  @override
  String get savePdf => 'Save PDF';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get settings => 'Settings';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get tryAgain => 'Try again';

  @override
  String pageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String detailLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get tabDocument => 'Document';

  @override
  String get tabIdCard => 'ID Card';

  @override
  String get tabPassport => 'Passport';

  @override
  String get tabBook => 'Book';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'Math';

  @override
  String get tabCount => 'Count';

  @override
  String get tabMeasure => 'Measure';

  @override
  String get titleScanQr => 'Scan QR';

  @override
  String get titleCountObjects => 'Count Objects';

  @override
  String get pageLabelPassport => 'Passport';

  @override
  String get pageLabelIdDocument => 'ID document';

  @override
  String get pageLabelIdFront => 'ID front';

  @override
  String get pageLabelIdBack => 'ID back';

  @override
  String get pageLabelLeft => 'Left';

  @override
  String get pageLabelRight => 'Right';

  @override
  String get pageLabelSpread => 'Spread';

  @override
  String get pageLabelMath => 'Math';

  @override
  String get pageLabelArea => 'Area';

  @override
  String defaultTitle(String date) {
    return 'Scan $date';
  }

  @override
  String get titleMathSolutions => 'Math solutions';

  @override
  String get titleQrCodes => 'QR codes';

  @override
  String get titleAreaMeasurements => 'Area measurements';

  @override
  String get titleCountResults => 'Count results';

  @override
  String get mathNeedsAi =>
      'Solving math needs AI, which isn\'t set up in this app.';

  @override
  String get mathNoAnswer =>
      'The solver couldn\'t find an answer. Try a clearer photo.';

  @override
  String captureFailed(String message) {
    return 'Capture failed: $message';
  }

  @override
  String get measureCaptureFailed =>
      'Couldn\'t capture the measurement. Try again.';

  @override
  String get measureCameraStopped => 'The camera stopped. Try again.';

  @override
  String get measureShapeChanged =>
      'The shape changed. Close it again, then save.';

  @override
  String get photoAccessDenied => 'Allow photo access in Settings to import.';

  @override
  String get imageUnreadable => 'Couldn\'t read that image. Try another one.';

  @override
  String get imageOpenFailed => 'Couldn\'t open that image. Try another one.';

  @override
  String get noCodeInImage => 'No code found in that image';

  @override
  String get noMrzInImage =>
      'No readable MRZ in that image. Try a sharper photo.';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Discard $count scanned pages?',
      one: 'Discard 1 scanned page?',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'Keep scanning';

  @override
  String get discard => 'Discard';

  @override
  String get flashOn => 'Flash on';

  @override
  String get flashOff => 'Flash off';

  @override
  String get showGrid => 'Show grid';

  @override
  String get hideGrid => 'Hide grid';

  @override
  String get autoCaptureOn => 'Auto capture on';

  @override
  String get autoCaptureOff => 'Auto capture off';

  @override
  String get autoBadge => 'AUTO';

  @override
  String bookChipLeft(int page) {
    return 'Left · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'Right · $page';
  }

  @override
  String get pointAtSurfaceFirst => 'Point the circle at a surface first';

  @override
  String get idSideFront => '1  Front side';

  @override
  String get idSideBack => '2  Back side';

  @override
  String get pillQr => 'Point at a QR code or barcode';

  @override
  String get pillCount => 'Point at the objects, then tap the shutter';

  @override
  String get pillMathOff => 'Solving math needs AI, which isn\'t set up';

  @override
  String get pillMath => 'Point at a math problem, then tap the shutter';

  @override
  String get pillMrzDetected => 'MRZ detected · Hold steady';

  @override
  String get pillPassport => 'Place the photo page inside the frame';

  @override
  String get pillIdFrontSaved => 'Front saved · Flip the card';

  @override
  String get pillSaved => 'Saved';

  @override
  String get pillIdBack => 'Now scan the back side';

  @override
  String get pillIdFit => 'Fit the card inside the frame';

  @override
  String get pillCardDetected => 'Card detected · Hold still';

  @override
  String get pillBook => 'Point at an open book';

  @override
  String get pillBookAuto => 'Book detected · Pages split automatically';

  @override
  String get pillBookTap => 'Book detected · Tap to capture';

  @override
  String get pillCaptured => 'Captured · Place the next page';

  @override
  String get pillDocument => 'Point at a document';

  @override
  String get pillDocumentAuto => 'Document detected · Hold still';

  @override
  String get pillDocumentTap => 'Document detected · Tap to capture';

  @override
  String get cameraOffTitle => 'Camera access is off';

  @override
  String get cameraOffBody => 'Allow camera access to scan documents.';

  @override
  String get arUnsupportedTitle => 'AR isn\'t available on this phone';

  @override
  String get arUnsupportedBody =>
      'Measuring needs Google Play Services for AR.';

  @override
  String get arInstallTitle => 'Install AR support';

  @override
  String get arInstallBody =>
      'Finish installing Google Play Services for AR, then try again.';

  @override
  String get arFailedTitle => 'AR couldn\'t start';

  @override
  String get arFailedBody => 'Something went wrong starting the AR camera.';

  @override
  String get cameraFailedTitle => 'Camera unavailable';

  @override
  String get cameraFailedBody => 'Something went wrong starting the camera.';

  @override
  String get importFromGallery => 'Import from gallery';

  @override
  String get capture => 'Capture';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Review $count pages',
      one: 'Review 1 page',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'Open Link';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get call => 'Call';

  @override
  String get sendMessage => 'Message';

  @override
  String get openMap => 'Open Map';

  @override
  String get copyPassword => 'Copy Password';

  @override
  String get passwordCopied => 'Password Copied';

  @override
  String get copyFailed => 'Couldn\'t copy. Try again.';

  @override
  String get noAppCanOpen => 'No app on this phone can open this.';

  @override
  String get shareFailed => 'Couldn\'t open sharing. Try again.';

  @override
  String get qrSaveFailed => 'Couldn\'t save the QR code. Try again.';

  @override
  String get qrTooLong =>
      'Too long to show as a QR code. The full content is below.';

  @override
  String get qrGenerated => 'Generated from the scanned content';

  @override
  String get password => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get codeEmpty => 'This code is empty';

  @override
  String get codeEmptyBody => 'There is nothing in it to show.';

  @override
  String get codeUnreadable => 'Couldn\'t read this code';

  @override
  String get codeNotText => 'It holds data that isn\'t text.';

  @override
  String get scanAgain => 'Scan Again';

  @override
  String get qrCodeImage => 'QR code';

  @override
  String qrCardTitle(String kind) {
    return 'QR Code · $kind';
  }

  @override
  String get qrCardContent => 'Content';

  @override
  String get scannedWithDocScan => 'Scanned with DocScan';

  @override
  String get anotherMath => 'Solve another problem';

  @override
  String get anotherQr => 'Scan another code';

  @override
  String get anotherArea => 'Measure another area';

  @override
  String get anotherCount => 'Count more objects';

  @override
  String get addAnother => 'Add another';

  @override
  String get addedToScan => 'Added to your scan';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · $count pages so far',
      one: '$title · 1 page so far',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'Website';

  @override
  String get qrLink => 'Link';

  @override
  String get qrPhone => 'Phone';

  @override
  String get qrNumber => 'Number';

  @override
  String get qrText => 'Text';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'Hidden network';

  @override
  String get qrNetwork => 'Network';

  @override
  String get qrNoName => '(no name)';

  @override
  String get qrSecurity => 'Security';

  @override
  String get qrSecurityOpen => 'None (open)';

  @override
  String get qrSecurityUnspecified => 'Not specified';

  @override
  String get qrHidden => 'Hidden';

  @override
  String get qrYes => 'Yes';

  @override
  String get qrEapMethod => 'EAP method';

  @override
  String get qrIdentity => 'Identity';

  @override
  String get qrEmail => 'Email';

  @override
  String get qrTo => 'To';

  @override
  String get qrSubject => 'Subject';

  @override
  String get qrMessage => 'Message';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'Location';

  @override
  String get qrCoordinates => 'Coordinates';

  @override
  String get qrPlace => 'Place';

  @override
  String get qrAltitude => 'Altitude';

  @override
  String get qrContact => 'Contact';

  @override
  String get qrContactCard => 'Contact card';

  @override
  String get qrName => 'Name';

  @override
  String get qrOrganization => 'Organization';

  @override
  String get qrJobTitle => 'Job title';

  @override
  String get qrAddress => 'Address';

  @override
  String get qrNote => 'Note';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'Couldn\'t solve this';

  @override
  String get mathSaveFailed => 'Couldn\'t save the solution. Try again.';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'Solved with AI';

  @override
  String get mathAnswer => 'Answer';

  @override
  String mathCopyProblem(String problem) {
    return 'Problem: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'Answer: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'Math · $answer';
  }

  @override
  String get mathCardTitle => 'MATH SOLUTION';

  @override
  String get mathCardContinued => 'MATH SOLUTION · CONTINUED';

  @override
  String get mathCardProblem => 'PROBLEM';

  @override
  String get mathCardSteps => 'STEPS';

  @override
  String get solvingWithAiLabel => 'Solving with AI';

  @override
  String get solvingWithAi => 'Solving with AI…';

  @override
  String get solvingDetail => 'Reading the problem and checking each step';

  @override
  String get exportFailed => 'Couldn\'t export the PDF';

  @override
  String bookPagesTitle(int first, int last) {
    return 'Pages $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'Page $page';
  }

  @override
  String get splitIntoTwo => 'Split into two pages';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spreads scanned · $pages pages',
      one: '1 spread scanned · $pages pages',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'Next Spread';

  @override
  String get saveBook => 'Save Book';

  @override
  String get idCardTitle => 'ID Card';

  @override
  String get passportTitle => 'Passport';

  @override
  String get idDocumentTitle => 'ID Document';

  @override
  String get layoutStacked => 'Stacked';

  @override
  String get layoutSideBySide => 'Side by side';

  @override
  String get layoutSeparate => 'Separate';

  @override
  String get fullName => 'Full name';

  @override
  String get idNumber => 'ID number';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get extractedDetails => 'Extracted details';

  @override
  String get copyAllLower => 'Copy all';

  @override
  String get copyAll => 'Copy All';

  @override
  String get detailsCopied => 'Details copied';

  @override
  String get readingCard => 'Reading the card…';

  @override
  String get noMrzOnCard =>
      'This card has no machine-readable zone, so there\'s nothing verified to extract. The scan is saved as is.';

  @override
  String copyField(String label) {
    return 'Copy $label';
  }

  @override
  String fieldCopied(String label) {
    return '$label copied';
  }

  @override
  String get passportNo => 'Passport no.';

  @override
  String get documentNo => 'Document no.';

  @override
  String get nationality => 'Nationality';

  @override
  String get sex => 'Sex';

  @override
  String get issuingCountry => 'Issuing country';

  @override
  String get expires => 'Expires';

  @override
  String expiredOn(String date) {
    return 'Expired on $date';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Valid for $count more years',
      one: 'Valid for 1 more year',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Valid for $count more months',
      one: 'Valid for 1 more month',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'Expires in less than a month';

  @override
  String get mrzVerified => 'MRZ verified';

  @override
  String pageDeleted(int page) {
    return 'Page $page deleted';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages deleted',
      one: '1 page deleted',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'Camera';

  @override
  String get addFromPhotos => 'Photos';

  @override
  String selectedCount(int count) {
    return '$count Selected';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pages',
      one: '1 Page',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Select';

  @override
  String get tapToSelect => 'Tap pages to select them';

  @override
  String get dragToReorder => 'Long-press and drag to reorder pages';

  @override
  String get rotateSelected => 'Rotate selected';

  @override
  String get delete => 'Delete';

  @override
  String deleteCount(int count) {
    return 'Delete $count';
  }

  @override
  String get editPages => 'Edit pages';

  @override
  String get saveAsPdf => 'Save as PDF';

  @override
  String rotatePage(int page) {
    return 'Rotate page $page';
  }

  @override
  String deletePage(int page) {
    return 'Delete page $page';
  }

  @override
  String get addPage => 'Add page';

  @override
  String get cameraOrPhotos => 'Camera or Photos';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterMagic => 'Magic';

  @override
  String get filterBw => 'B & W';

  @override
  String get filterGray => 'Gray';

  @override
  String get filterNoShadow => 'No Shadow';

  @override
  String get filterColor => 'Color';

  @override
  String get adjustCrop => 'Adjust Crop';

  @override
  String get reset => 'Reset';

  @override
  String get rotate => 'Rotate';

  @override
  String get cropAuto => 'Auto';

  @override
  String get cropPerspective => 'Perspective';

  @override
  String get cropFullPage => 'Full page';

  @override
  String get enhance => 'Enhance';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter applied to all $count pages';
  }

  @override
  String get brightness => 'Brightness';

  @override
  String get contrast => 'Contrast';

  @override
  String get applyToAll => 'Apply to all';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed => 'Couldn\'t save the result. Try again.';

  @override
  String get objectCount => 'Object count';

  @override
  String get countedWithDocScan => 'Counted with DocScan';

  @override
  String countPageLabel(int count) {
    return 'Count: $count';
  }

  @override
  String countAdded(int count) {
    return '$count added';
  }

  @override
  String countRemoved(int count) {
    return '$count removed';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'objects',
      one: 'object',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'Kind';

  @override
  String get roundObjects => 'Round objects';

  @override
  String get boxes => 'Boxes';

  @override
  String get custom => 'Custom';

  @override
  String get matchedToSample => 'matched to a tapped sample';

  @override
  String get countAutomatic => 'Automatic';

  @override
  String get countByHand => 'By hand';

  @override
  String get noChanges => 'No changes';

  @override
  String get tapOneObject => 'Tap one object to count ones like it';

  @override
  String get objectsDetected => 'Objects detected';

  @override
  String get removeOne => 'Remove one';

  @override
  String get addOne => 'Add one';

  @override
  String get saveResult => 'Save Result';

  @override
  String get areaMeasurement => 'Area measurement';

  @override
  String get measuredNote => 'Measured with DocScan AR · approx. ±5%';

  @override
  String areaTitle(String area) {
    return 'Area · $area';
  }

  @override
  String get area => 'Area';

  @override
  String get perimeter => 'Perimeter';

  @override
  String get sides => 'Sides';

  @override
  String get points => 'Points';

  @override
  String summaryArea(String area) {
    return 'Area $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head. Sides $sides';
  }

  @override
  String get hintStartingAr => 'Starting AR…';

  @override
  String get hintTooDark => 'Too dark · Turn on the flash';

  @override
  String get hintMoveSlower => 'Move your phone more slowly';

  @override
  String get hintMoreDetail => 'Point at a surface with more detail';

  @override
  String get hintFindSurface => 'Move your phone slowly to find a surface';

  @override
  String get hintDragCorner => 'Drag a corner to adjust';

  @override
  String get hintPointCircle => 'Point the circle at a surface';

  @override
  String get hintAimBack => 'Aim back at the same surface';

  @override
  String get hintTapToDrop => 'Tap + to drop points';

  @override
  String get hintNextCorner => 'Tap + to add the next corner';

  @override
  String get hintClose => 'Tap the first point to close the shape';

  @override
  String get savingMeasurement => 'Saving measurement';

  @override
  String get saveMeasurement => 'Save measurement';

  @override
  String get newMeasurement => 'New measurement';

  @override
  String get addPoint => 'Add point';

  @override
  String get meters => 'Meters';

  @override
  String get feet => 'Feet';
}
