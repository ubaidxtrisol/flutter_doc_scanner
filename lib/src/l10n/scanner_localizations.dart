import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'scanner_localizations_ar.dart';
import 'scanner_localizations_de.dart';
import 'scanner_localizations_en.dart';
import 'scanner_localizations_es.dart';
import 'scanner_localizations_fr.dart';
import 'scanner_localizations_hi.dart';
import 'scanner_localizations_id.dart';
import 'scanner_localizations_pt.dart';
import 'scanner_localizations_ru.dart';
import 'scanner_localizations_tr.dart';
import 'scanner_localizations_ur.dart';
import 'scanner_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of ScannerLocalizations
/// returned by `ScannerLocalizations.of(context)`.
///
/// Applications need to include `ScannerLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/scanner_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: ScannerLocalizations.localizationsDelegates,
///   supportedLocales: ScannerLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the ScannerLocalizations.supportedLocales
/// property.
abstract class ScannerLocalizations {
  ScannerLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static ScannerLocalizations? of(BuildContext context) {
    return Localizations.of<ScannerLocalizations>(
      context,
      ScannerLocalizations,
    );
  }

  static const LocalizationsDelegate<ScannerLocalizations> delegate =
      _ScannerLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @saveToDocuments.
  ///
  /// In en, this message translates to:
  /// **'Save to Documents'**
  String get saveToDocuments;

  /// No description provided for @savePdf.
  ///
  /// In en, this message translates to:
  /// **'Save PDF'**
  String get savePdf;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pageOf(int page, int total);

  /// One copied detail, e.g. 'Nationality: PAK'.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String detailLine(String label, String value);

  /// Scanner mode tab; keep these short.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get tabDocument;

  /// No description provided for @tabIdCard.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get tabIdCard;

  /// No description provided for @tabPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get tabPassport;

  /// No description provided for @tabBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get tabBook;

  /// No description provided for @tabQr.
  ///
  /// In en, this message translates to:
  /// **'QR'**
  String get tabQr;

  /// No description provided for @tabMath.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get tabMath;

  /// No description provided for @tabCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get tabCount;

  /// No description provided for @tabMeasure.
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get tabMeasure;

  /// No description provided for @titleScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get titleScanQr;

  /// No description provided for @titleCountObjects.
  ///
  /// In en, this message translates to:
  /// **'Count Objects'**
  String get titleCountObjects;

  /// No description provided for @pageLabelPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get pageLabelPassport;

  /// No description provided for @pageLabelIdDocument.
  ///
  /// In en, this message translates to:
  /// **'ID document'**
  String get pageLabelIdDocument;

  /// No description provided for @pageLabelIdFront.
  ///
  /// In en, this message translates to:
  /// **'ID front'**
  String get pageLabelIdFront;

  /// No description provided for @pageLabelIdBack.
  ///
  /// In en, this message translates to:
  /// **'ID back'**
  String get pageLabelIdBack;

  /// Short label under a page thumbnail: the left page of a book spread.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get pageLabelLeft;

  /// No description provided for @pageLabelRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get pageLabelRight;

  /// No description provided for @pageLabelSpread.
  ///
  /// In en, this message translates to:
  /// **'Spread'**
  String get pageLabelSpread;

  /// No description provided for @pageLabelMath.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get pageLabelMath;

  /// No description provided for @pageLabelArea.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get pageLabelArea;

  /// Default document name; date is like 2026-09-30 14.05.
  ///
  /// In en, this message translates to:
  /// **'Scan {date}'**
  String defaultTitle(String date);

  /// No description provided for @titleMathSolutions.
  ///
  /// In en, this message translates to:
  /// **'Math solutions'**
  String get titleMathSolutions;

  /// No description provided for @titleQrCodes.
  ///
  /// In en, this message translates to:
  /// **'QR codes'**
  String get titleQrCodes;

  /// No description provided for @titleAreaMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Area measurements'**
  String get titleAreaMeasurements;

  /// No description provided for @titleCountResults.
  ///
  /// In en, this message translates to:
  /// **'Count results'**
  String get titleCountResults;

  /// No description provided for @mathNeedsAi.
  ///
  /// In en, this message translates to:
  /// **'Solving math needs AI, which isn\'t set up in this app.'**
  String get mathNeedsAi;

  /// No description provided for @mathNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'The solver couldn\'t find an answer. Try a clearer photo.'**
  String get mathNoAnswer;

  /// No description provided for @captureFailed.
  ///
  /// In en, this message translates to:
  /// **'Capture failed: {message}'**
  String captureFailed(String message);

  /// No description provided for @measureCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t capture the measurement. Try again.'**
  String get measureCaptureFailed;

  /// No description provided for @measureCameraStopped.
  ///
  /// In en, this message translates to:
  /// **'The camera stopped. Try again.'**
  String get measureCameraStopped;

  /// No description provided for @measureShapeChanged.
  ///
  /// In en, this message translates to:
  /// **'The shape changed. Close it again, then save.'**
  String get measureShapeChanged;

  /// No description provided for @photoAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Allow photo access in Settings to import.'**
  String get photoAccessDenied;

  /// No description provided for @imageUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read that image. Try another one.'**
  String get imageUnreadable;

  /// No description provided for @imageOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that image. Try another one.'**
  String get imageOpenFailed;

  /// No description provided for @noCodeInImage.
  ///
  /// In en, this message translates to:
  /// **'No code found in that image'**
  String get noCodeInImage;

  /// No description provided for @noMrzInImage.
  ///
  /// In en, this message translates to:
  /// **'No readable MRZ in that image. Try a sharper photo.'**
  String get noMrzInImage;

  /// No description provided for @discardPages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Discard 1 scanned page?} other{Discard {count} scanned pages?}}'**
  String discardPages(int count);

  /// No description provided for @keepScanning.
  ///
  /// In en, this message translates to:
  /// **'Keep scanning'**
  String get keepScanning;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @flashOn.
  ///
  /// In en, this message translates to:
  /// **'Flash on'**
  String get flashOn;

  /// No description provided for @flashOff.
  ///
  /// In en, this message translates to:
  /// **'Flash off'**
  String get flashOff;

  /// No description provided for @showGrid.
  ///
  /// In en, this message translates to:
  /// **'Show grid'**
  String get showGrid;

  /// No description provided for @hideGrid.
  ///
  /// In en, this message translates to:
  /// **'Hide grid'**
  String get hideGrid;

  /// No description provided for @autoCaptureOn.
  ///
  /// In en, this message translates to:
  /// **'Auto capture on'**
  String get autoCaptureOn;

  /// No description provided for @autoCaptureOff.
  ///
  /// In en, this message translates to:
  /// **'Auto capture off'**
  String get autoCaptureOff;

  /// Tiny all-caps toggle for auto capture on the camera bar.
  ///
  /// In en, this message translates to:
  /// **'AUTO'**
  String get autoBadge;

  /// Under the left half of the book guide: the page number it gets.
  ///
  /// In en, this message translates to:
  /// **'Left · {page}'**
  String bookChipLeft(int page);

  /// No description provided for @bookChipRight.
  ///
  /// In en, this message translates to:
  /// **'Right · {page}'**
  String bookChipRight(int page);

  /// No description provided for @pointAtSurfaceFirst.
  ///
  /// In en, this message translates to:
  /// **'Point the circle at a surface first'**
  String get pointAtSurfaceFirst;

  /// No description provided for @idSideFront.
  ///
  /// In en, this message translates to:
  /// **'1  Front side'**
  String get idSideFront;

  /// No description provided for @idSideBack.
  ///
  /// In en, this message translates to:
  /// **'2  Back side'**
  String get idSideBack;

  /// No description provided for @pillQr.
  ///
  /// In en, this message translates to:
  /// **'Point at a QR code or barcode'**
  String get pillQr;

  /// No description provided for @pillCount.
  ///
  /// In en, this message translates to:
  /// **'Point at the objects, then tap the shutter'**
  String get pillCount;

  /// No description provided for @pillMathOff.
  ///
  /// In en, this message translates to:
  /// **'Solving math needs AI, which isn\'t set up'**
  String get pillMathOff;

  /// No description provided for @pillMath.
  ///
  /// In en, this message translates to:
  /// **'Point at a math problem, then tap the shutter'**
  String get pillMath;

  /// No description provided for @pillMrzDetected.
  ///
  /// In en, this message translates to:
  /// **'MRZ detected · Hold steady'**
  String get pillMrzDetected;

  /// No description provided for @pillPassport.
  ///
  /// In en, this message translates to:
  /// **'Place the photo page inside the frame'**
  String get pillPassport;

  /// No description provided for @pillIdFrontSaved.
  ///
  /// In en, this message translates to:
  /// **'Front saved · Flip the card'**
  String get pillIdFrontSaved;

  /// No description provided for @pillSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get pillSaved;

  /// No description provided for @pillIdBack.
  ///
  /// In en, this message translates to:
  /// **'Now scan the back side'**
  String get pillIdBack;

  /// No description provided for @pillIdFit.
  ///
  /// In en, this message translates to:
  /// **'Fit the card inside the frame'**
  String get pillIdFit;

  /// No description provided for @pillCardDetected.
  ///
  /// In en, this message translates to:
  /// **'Card detected · Hold still'**
  String get pillCardDetected;

  /// No description provided for @pillBook.
  ///
  /// In en, this message translates to:
  /// **'Point at an open book'**
  String get pillBook;

  /// No description provided for @pillBookAuto.
  ///
  /// In en, this message translates to:
  /// **'Book detected · Pages split automatically'**
  String get pillBookAuto;

  /// No description provided for @pillBookTap.
  ///
  /// In en, this message translates to:
  /// **'Book detected · Tap to capture'**
  String get pillBookTap;

  /// No description provided for @pillCaptured.
  ///
  /// In en, this message translates to:
  /// **'Captured · Place the next page'**
  String get pillCaptured;

  /// No description provided for @pillDocument.
  ///
  /// In en, this message translates to:
  /// **'Point at a document'**
  String get pillDocument;

  /// No description provided for @pillDocumentAuto.
  ///
  /// In en, this message translates to:
  /// **'Document detected · Hold still'**
  String get pillDocumentAuto;

  /// No description provided for @pillDocumentTap.
  ///
  /// In en, this message translates to:
  /// **'Document detected · Tap to capture'**
  String get pillDocumentTap;

  /// No description provided for @cameraOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off'**
  String get cameraOffTitle;

  /// No description provided for @cameraOffBody.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to scan documents.'**
  String get cameraOffBody;

  /// No description provided for @arUnsupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'AR isn\'t available on this phone'**
  String get arUnsupportedTitle;

  /// No description provided for @arUnsupportedBody.
  ///
  /// In en, this message translates to:
  /// **'Measuring needs Google Play Services for AR.'**
  String get arUnsupportedBody;

  /// No description provided for @arInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Install AR support'**
  String get arInstallTitle;

  /// No description provided for @arInstallBody.
  ///
  /// In en, this message translates to:
  /// **'Finish installing Google Play Services for AR, then try again.'**
  String get arInstallBody;

  /// No description provided for @arFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'AR couldn\'t start'**
  String get arFailedTitle;

  /// No description provided for @arFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong starting the AR camera.'**
  String get arFailedBody;

  /// No description provided for @cameraFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get cameraFailedTitle;

  /// No description provided for @cameraFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong starting the camera.'**
  String get cameraFailedBody;

  /// No description provided for @importFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Import from gallery'**
  String get importFromGallery;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @reviewPages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Review 1 page} other{Review {count} pages}}'**
  String reviewPages(int count);

  /// No description provided for @openLink.
  ///
  /// In en, this message translates to:
  /// **'Open Link'**
  String get openLink;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Button: write a text message to the scanned number.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get sendMessage;

  /// No description provided for @openMap.
  ///
  /// In en, this message translates to:
  /// **'Open Map'**
  String get openMap;

  /// No description provided for @copyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy Password'**
  String get copyPassword;

  /// No description provided for @passwordCopied.
  ///
  /// In en, this message translates to:
  /// **'Password Copied'**
  String get passwordCopied;

  /// No description provided for @copyFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t copy. Try again.'**
  String get copyFailed;

  /// No description provided for @noAppCanOpen.
  ///
  /// In en, this message translates to:
  /// **'No app on this phone can open this.'**
  String get noAppCanOpen;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open sharing. Try again.'**
  String get shareFailed;

  /// No description provided for @qrSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the QR code. Try again.'**
  String get qrSaveFailed;

  /// No description provided for @qrTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long to show as a QR code. The full content is below.'**
  String get qrTooLong;

  /// No description provided for @qrGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated from the scanned content'**
  String get qrGenerated;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @codeEmpty.
  ///
  /// In en, this message translates to:
  /// **'This code is empty'**
  String get codeEmpty;

  /// No description provided for @codeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'There is nothing in it to show.'**
  String get codeEmptyBody;

  /// No description provided for @codeUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t read this code'**
  String get codeUnreadable;

  /// No description provided for @codeNotText.
  ///
  /// In en, this message translates to:
  /// **'It holds data that isn\'t text.'**
  String get codeNotText;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get scanAgain;

  /// No description provided for @qrCodeImage.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCodeImage;

  /// Saved QR page title, kind is e.g. 'Website'.
  ///
  /// In en, this message translates to:
  /// **'QR Code · {kind}'**
  String qrCardTitle(String kind);

  /// No description provided for @qrCardContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get qrCardContent;

  /// No description provided for @scannedWithDocScan.
  ///
  /// In en, this message translates to:
  /// **'Scanned with DocScan'**
  String get scannedWithDocScan;

  /// No description provided for @anotherMath.
  ///
  /// In en, this message translates to:
  /// **'Solve another problem'**
  String get anotherMath;

  /// No description provided for @anotherQr.
  ///
  /// In en, this message translates to:
  /// **'Scan another code'**
  String get anotherQr;

  /// No description provided for @anotherArea.
  ///
  /// In en, this message translates to:
  /// **'Measure another area'**
  String get anotherArea;

  /// No description provided for @anotherCount.
  ///
  /// In en, this message translates to:
  /// **'Count more objects'**
  String get anotherCount;

  /// No description provided for @addAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another'**
  String get addAnother;

  /// No description provided for @addedToScan.
  ///
  /// In en, this message translates to:
  /// **'Added to your scan'**
  String get addedToScan;

  /// No description provided for @addedSoFar.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{title} · 1 page so far} other{{title} · {count} pages so far}}'**
  String addedSoFar(String title, int count);

  /// No description provided for @qrWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get qrWebsite;

  /// No description provided for @qrLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get qrLink;

  /// No description provided for @qrPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get qrPhone;

  /// No description provided for @qrNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get qrNumber;

  /// No description provided for @qrText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get qrText;

  /// No description provided for @qrWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get qrWifi;

  /// No description provided for @qrHiddenNetwork.
  ///
  /// In en, this message translates to:
  /// **'Hidden network'**
  String get qrHiddenNetwork;

  /// No description provided for @qrNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get qrNetwork;

  /// No description provided for @qrNoName.
  ///
  /// In en, this message translates to:
  /// **'(no name)'**
  String get qrNoName;

  /// No description provided for @qrSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get qrSecurity;

  /// No description provided for @qrSecurityOpen.
  ///
  /// In en, this message translates to:
  /// **'None (open)'**
  String get qrSecurityOpen;

  /// No description provided for @qrSecurityUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get qrSecurityUnspecified;

  /// No description provided for @qrHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get qrHidden;

  /// No description provided for @qrYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get qrYes;

  /// No description provided for @qrEapMethod.
  ///
  /// In en, this message translates to:
  /// **'EAP method'**
  String get qrEapMethod;

  /// No description provided for @qrIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get qrIdentity;

  /// No description provided for @qrEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get qrEmail;

  /// No description provided for @qrTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get qrTo;

  /// No description provided for @qrSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get qrSubject;

  /// Field label: the text of an email or SMS.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get qrMessage;

  /// No description provided for @qrSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get qrSms;

  /// No description provided for @qrLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get qrLocation;

  /// No description provided for @qrCoordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get qrCoordinates;

  /// No description provided for @qrPlace.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get qrPlace;

  /// No description provided for @qrAltitude.
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get qrAltitude;

  /// No description provided for @qrContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get qrContact;

  /// No description provided for @qrContactCard.
  ///
  /// In en, this message translates to:
  /// **'Contact card'**
  String get qrContactCard;

  /// No description provided for @qrName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get qrName;

  /// No description provided for @qrOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get qrOrganization;

  /// No description provided for @qrJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get qrJobTitle;

  /// No description provided for @qrAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get qrAddress;

  /// No description provided for @qrNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get qrNote;

  /// Saved document name for a QR code.
  ///
  /// In en, this message translates to:
  /// **'QR · {text}'**
  String qrSaveTitle(String text);

  /// No description provided for @mathFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t solve this'**
  String get mathFailed;

  /// No description provided for @mathSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the solution. Try again.'**
  String get mathSaveFailed;

  /// No description provided for @mathSteps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 step} other{{count} steps}}'**
  String mathSteps(int count);

  /// No description provided for @solvedWithAi.
  ///
  /// In en, this message translates to:
  /// **'Solved with AI'**
  String get solvedWithAi;

  /// No description provided for @mathAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get mathAnswer;

  /// No description provided for @mathCopyProblem.
  ///
  /// In en, this message translates to:
  /// **'Problem: {problem}'**
  String mathCopyProblem(String problem);

  /// No description provided for @mathCopyAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer: {answer}'**
  String mathCopyAnswer(String answer);

  /// Saved document name for a math solution.
  ///
  /// In en, this message translates to:
  /// **'Math · {answer}'**
  String mathTitle(String answer);

  /// No description provided for @mathCardTitle.
  ///
  /// In en, this message translates to:
  /// **'MATH SOLUTION'**
  String get mathCardTitle;

  /// No description provided for @mathCardContinued.
  ///
  /// In en, this message translates to:
  /// **'MATH SOLUTION · CONTINUED'**
  String get mathCardContinued;

  /// No description provided for @mathCardProblem.
  ///
  /// In en, this message translates to:
  /// **'PROBLEM'**
  String get mathCardProblem;

  /// No description provided for @mathCardSteps.
  ///
  /// In en, this message translates to:
  /// **'STEPS'**
  String get mathCardSteps;

  /// No description provided for @solvingWithAiLabel.
  ///
  /// In en, this message translates to:
  /// **'Solving with AI'**
  String get solvingWithAiLabel;

  /// No description provided for @solvingWithAi.
  ///
  /// In en, this message translates to:
  /// **'Solving with AI…'**
  String get solvingWithAi;

  /// No description provided for @solvingDetail.
  ///
  /// In en, this message translates to:
  /// **'Reading the problem and checking each step'**
  String get solvingDetail;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t export the PDF'**
  String get exportFailed;

  /// No description provided for @bookPagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pages {first}–{last}'**
  String bookPagesTitle(int first, int last);

  /// No description provided for @bookPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String bookPage(int page);

  /// No description provided for @splitIntoTwo.
  ///
  /// In en, this message translates to:
  /// **'Split into two pages'**
  String get splitIntoTwo;

  /// No description provided for @spreadsScanned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 spread scanned · {pages} pages} other{{count} spreads scanned · {pages} pages}}'**
  String spreadsScanned(int count, int pages);

  /// No description provided for @nextSpread.
  ///
  /// In en, this message translates to:
  /// **'Next Spread'**
  String get nextSpread;

  /// No description provided for @saveBook.
  ///
  /// In en, this message translates to:
  /// **'Save Book'**
  String get saveBook;

  /// No description provided for @idCardTitle.
  ///
  /// In en, this message translates to:
  /// **'ID Card'**
  String get idCardTitle;

  /// No description provided for @passportTitle.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passportTitle;

  /// No description provided for @idDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'ID Document'**
  String get idDocumentTitle;

  /// No description provided for @layoutStacked.
  ///
  /// In en, this message translates to:
  /// **'Stacked'**
  String get layoutStacked;

  /// No description provided for @layoutSideBySide.
  ///
  /// In en, this message translates to:
  /// **'Side by side'**
  String get layoutSideBySide;

  /// No description provided for @layoutSeparate.
  ///
  /// In en, this message translates to:
  /// **'Separate'**
  String get layoutSeparate;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID number'**
  String get idNumber;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @extractedDetails.
  ///
  /// In en, this message translates to:
  /// **'Extracted details'**
  String get extractedDetails;

  /// No description provided for @copyAllLower.
  ///
  /// In en, this message translates to:
  /// **'Copy all'**
  String get copyAllLower;

  /// No description provided for @copyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy All'**
  String get copyAll;

  /// No description provided for @detailsCopied.
  ///
  /// In en, this message translates to:
  /// **'Details copied'**
  String get detailsCopied;

  /// No description provided for @readingCard.
  ///
  /// In en, this message translates to:
  /// **'Reading the card…'**
  String get readingCard;

  /// No description provided for @noMrzOnCard.
  ///
  /// In en, this message translates to:
  /// **'This card has no machine-readable zone, so there\'s nothing verified to extract. The scan is saved as is.'**
  String get noMrzOnCard;

  /// No description provided for @copyField.
  ///
  /// In en, this message translates to:
  /// **'Copy {label}'**
  String copyField(String label);

  /// No description provided for @fieldCopied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String fieldCopied(String label);

  /// No description provided for @passportNo.
  ///
  /// In en, this message translates to:
  /// **'Passport no.'**
  String get passportNo;

  /// No description provided for @documentNo.
  ///
  /// In en, this message translates to:
  /// **'Document no.'**
  String get documentNo;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @issuingCountry.
  ///
  /// In en, this message translates to:
  /// **'Issuing country'**
  String get issuingCountry;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @expiredOn.
  ///
  /// In en, this message translates to:
  /// **'Expired on {date}'**
  String expiredOn(String date);

  /// No description provided for @validYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Valid for 1 more year} other{Valid for {count} more years}}'**
  String validYears(int count);

  /// No description provided for @validMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Valid for 1 more month} other{Valid for {count} more months}}'**
  String validMonths(int count);

  /// No description provided for @expiresSoon.
  ///
  /// In en, this message translates to:
  /// **'Expires in less than a month'**
  String get expiresSoon;

  /// No description provided for @mrzVerified.
  ///
  /// In en, this message translates to:
  /// **'MRZ verified'**
  String get mrzVerified;

  /// No description provided for @pageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Page {page} deleted'**
  String pageDeleted(int page);

  /// No description provided for @pagesDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page deleted} other{{count} pages deleted}}'**
  String pagesDeleted(int count);

  /// No description provided for @addFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get addFromCamera;

  /// No description provided for @addFromPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get addFromPhotos;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String selectedCount(int count);

  /// No description provided for @pagesTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Page} other{{count} Pages}}'**
  String pagesTitle(int count);

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap pages to select them'**
  String get tapToSelect;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Long-press and drag to reorder pages'**
  String get dragToReorder;

  /// No description provided for @rotateSelected.
  ///
  /// In en, this message translates to:
  /// **'Rotate selected'**
  String get rotateSelected;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteCount.
  ///
  /// In en, this message translates to:
  /// **'Delete {count}'**
  String deleteCount(int count);

  /// No description provided for @editPages.
  ///
  /// In en, this message translates to:
  /// **'Edit pages'**
  String get editPages;

  /// No description provided for @saveAsPdf.
  ///
  /// In en, this message translates to:
  /// **'Save as PDF'**
  String get saveAsPdf;

  /// No description provided for @rotatePage.
  ///
  /// In en, this message translates to:
  /// **'Rotate page {page}'**
  String rotatePage(int page);

  /// No description provided for @deletePage.
  ///
  /// In en, this message translates to:
  /// **'Delete page {page}'**
  String deletePage(int page);

  /// No description provided for @addPage.
  ///
  /// In en, this message translates to:
  /// **'Add page'**
  String get addPage;

  /// No description provided for @cameraOrPhotos.
  ///
  /// In en, this message translates to:
  /// **'Camera or Photos'**
  String get cameraOrPhotos;

  /// No description provided for @filterOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get filterOriginal;

  /// No description provided for @filterMagic.
  ///
  /// In en, this message translates to:
  /// **'Magic'**
  String get filterMagic;

  /// No description provided for @filterBw.
  ///
  /// In en, this message translates to:
  /// **'B & W'**
  String get filterBw;

  /// No description provided for @filterGray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get filterGray;

  /// No description provided for @filterNoShadow.
  ///
  /// In en, this message translates to:
  /// **'No Shadow'**
  String get filterNoShadow;

  /// No description provided for @filterColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get filterColor;

  /// No description provided for @adjustCrop.
  ///
  /// In en, this message translates to:
  /// **'Adjust Crop'**
  String get adjustCrop;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @rotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotate;

  /// Crop tool: use the automatically detected page edges.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get cropAuto;

  /// No description provided for @cropPerspective.
  ///
  /// In en, this message translates to:
  /// **'Perspective'**
  String get cropPerspective;

  /// No description provided for @cropFullPage.
  ///
  /// In en, this message translates to:
  /// **'Full page'**
  String get cropFullPage;

  /// No description provided for @enhance.
  ///
  /// In en, this message translates to:
  /// **'Enhance'**
  String get enhance;

  /// No description provided for @filterAppliedToAll.
  ///
  /// In en, this message translates to:
  /// **'{filter} applied to all {count} pages'**
  String filterAppliedToAll(String filter, int count);

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @contrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get contrast;

  /// No description provided for @applyToAll.
  ///
  /// In en, this message translates to:
  /// **'Apply to all'**
  String get applyToAll;

  /// Screen reader value of a slider, e.g. 'Brightness 50'.
  ///
  /// In en, this message translates to:
  /// **'{label} {value}'**
  String sliderValue(String label, int value);

  /// No description provided for @countSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the result. Try again.'**
  String get countSaveFailed;

  /// No description provided for @objectCount.
  ///
  /// In en, this message translates to:
  /// **'Object count'**
  String get objectCount;

  /// No description provided for @countedWithDocScan.
  ///
  /// In en, this message translates to:
  /// **'Counted with DocScan'**
  String get countedWithDocScan;

  /// Saved count's document name.
  ///
  /// In en, this message translates to:
  /// **'Count: {count}'**
  String countPageLabel(int count);

  /// No description provided for @countAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} added'**
  String countAdded(int count);

  /// No description provided for @countRemoved.
  ///
  /// In en, this message translates to:
  /// **'{count} removed'**
  String countRemoved(int count);

  /// Word after a big number on the saved count card.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{object} other{objects}}'**
  String objectsUnit(int count);

  /// No description provided for @countKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get countKind;

  /// No description provided for @roundObjects.
  ///
  /// In en, this message translates to:
  /// **'Round objects'**
  String get roundObjects;

  /// No description provided for @boxes.
  ///
  /// In en, this message translates to:
  /// **'Boxes'**
  String get boxes;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @matchedToSample.
  ///
  /// In en, this message translates to:
  /// **'matched to a tapped sample'**
  String get matchedToSample;

  /// No description provided for @countAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get countAutomatic;

  /// No description provided for @countByHand.
  ///
  /// In en, this message translates to:
  /// **'By hand'**
  String get countByHand;

  /// No description provided for @noChanges.
  ///
  /// In en, this message translates to:
  /// **'No changes'**
  String get noChanges;

  /// No description provided for @tapOneObject.
  ///
  /// In en, this message translates to:
  /// **'Tap one object to count ones like it'**
  String get tapOneObject;

  /// No description provided for @objectsDetected.
  ///
  /// In en, this message translates to:
  /// **'Objects detected'**
  String get objectsDetected;

  /// No description provided for @removeOne.
  ///
  /// In en, this message translates to:
  /// **'Remove one'**
  String get removeOne;

  /// No description provided for @addOne.
  ///
  /// In en, this message translates to:
  /// **'Add one'**
  String get addOne;

  /// No description provided for @saveResult.
  ///
  /// In en, this message translates to:
  /// **'Save Result'**
  String get saveResult;

  /// No description provided for @areaMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Area measurement'**
  String get areaMeasurement;

  /// No description provided for @measuredNote.
  ///
  /// In en, this message translates to:
  /// **'Measured with DocScan AR · approx. ±5%'**
  String get measuredNote;

  /// Saved document name for a measurement.
  ///
  /// In en, this message translates to:
  /// **'Area · {area}'**
  String areaTitle(String area);

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @perimeter.
  ///
  /// In en, this message translates to:
  /// **'Perimeter'**
  String get perimeter;

  /// No description provided for @sides.
  ///
  /// In en, this message translates to:
  /// **'Sides'**
  String get sides;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @summaryArea.
  ///
  /// In en, this message translates to:
  /// **'Area {area}'**
  String summaryArea(String area);

  /// No description provided for @summaryPoints.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 point} other{{count} points}}'**
  String summaryPoints(int count);

  /// Screen reader summary: head is the area or point count, sides a list of lengths.
  ///
  /// In en, this message translates to:
  /// **'{head}. Sides {sides}'**
  String summarySides(String head, String sides);

  /// No description provided for @hintStartingAr.
  ///
  /// In en, this message translates to:
  /// **'Starting AR…'**
  String get hintStartingAr;

  /// No description provided for @hintTooDark.
  ///
  /// In en, this message translates to:
  /// **'Too dark · Turn on the flash'**
  String get hintTooDark;

  /// No description provided for @hintMoveSlower.
  ///
  /// In en, this message translates to:
  /// **'Move your phone more slowly'**
  String get hintMoveSlower;

  /// No description provided for @hintMoreDetail.
  ///
  /// In en, this message translates to:
  /// **'Point at a surface with more detail'**
  String get hintMoreDetail;

  /// No description provided for @hintFindSurface.
  ///
  /// In en, this message translates to:
  /// **'Move your phone slowly to find a surface'**
  String get hintFindSurface;

  /// No description provided for @hintDragCorner.
  ///
  /// In en, this message translates to:
  /// **'Drag a corner to adjust'**
  String get hintDragCorner;

  /// No description provided for @hintPointCircle.
  ///
  /// In en, this message translates to:
  /// **'Point the circle at a surface'**
  String get hintPointCircle;

  /// No description provided for @hintAimBack.
  ///
  /// In en, this message translates to:
  /// **'Aim back at the same surface'**
  String get hintAimBack;

  /// No description provided for @hintTapToDrop.
  ///
  /// In en, this message translates to:
  /// **'Tap + to drop points'**
  String get hintTapToDrop;

  /// No description provided for @hintNextCorner.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the next corner'**
  String get hintNextCorner;

  /// No description provided for @hintClose.
  ///
  /// In en, this message translates to:
  /// **'Tap the first point to close the shape'**
  String get hintClose;

  /// No description provided for @savingMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Saving measurement'**
  String get savingMeasurement;

  /// No description provided for @saveMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Save measurement'**
  String get saveMeasurement;

  /// No description provided for @newMeasurement.
  ///
  /// In en, this message translates to:
  /// **'New measurement'**
  String get newMeasurement;

  /// No description provided for @addPoint.
  ///
  /// In en, this message translates to:
  /// **'Add point'**
  String get addPoint;

  /// No description provided for @meters.
  ///
  /// In en, this message translates to:
  /// **'Meters'**
  String get meters;

  /// No description provided for @feet.
  ///
  /// In en, this message translates to:
  /// **'Feet'**
  String get feet;
}

class _ScannerLocalizationsDelegate
    extends LocalizationsDelegate<ScannerLocalizations> {
  const _ScannerLocalizationsDelegate();

  @override
  Future<ScannerLocalizations> load(Locale locale) {
    return SynchronousFuture<ScannerLocalizations>(
      lookupScannerLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'id',
    'pt',
    'ru',
    'tr',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_ScannerLocalizationsDelegate old) => false;
}

ScannerLocalizations lookupScannerLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return ScannerLocalizationsAr();
    case 'de':
      return ScannerLocalizationsDe();
    case 'en':
      return ScannerLocalizationsEn();
    case 'es':
      return ScannerLocalizationsEs();
    case 'fr':
      return ScannerLocalizationsFr();
    case 'hi':
      return ScannerLocalizationsHi();
    case 'id':
      return ScannerLocalizationsId();
    case 'pt':
      return ScannerLocalizationsPt();
    case 'ru':
      return ScannerLocalizationsRu();
    case 'tr':
      return ScannerLocalizationsTr();
    case 'ur':
      return ScannerLocalizationsUr();
    case 'zh':
      return ScannerLocalizationsZh();
  }

  throw FlutterError(
    'ScannerLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
