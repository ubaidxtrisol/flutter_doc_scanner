// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class ScannerLocalizationsDe extends ScannerLocalizations {
  ScannerLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get undo => 'Rückgängig';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get done => 'Fertig';

  @override
  String get next => 'Weiter';

  @override
  String get retry => 'Wiederholen';

  @override
  String get retake => 'Neu aufnehmen';

  @override
  String get review => 'Prüfen';

  @override
  String get copy => 'Kopieren';

  @override
  String get copied => 'Kopiert';

  @override
  String get share => 'Teilen';

  @override
  String get saving => 'Wird gespeichert…';

  @override
  String get saveToDocuments => 'In Dokumenten speichern';

  @override
  String get savePdf => 'PDF speichern';

  @override
  String get sharePdf => 'PDF teilen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String pageOf(int page, int total) {
    return 'Seite $page von $total';
  }

  @override
  String detailLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get tabDocument => 'Dokument';

  @override
  String get tabIdCard => 'Ausweis';

  @override
  String get tabPassport => 'Reisepass';

  @override
  String get tabBook => 'Buch';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'Mathe';

  @override
  String get tabCount => 'Zählen';

  @override
  String get tabMeasure => 'Messen';

  @override
  String get titleScanQr => 'QR scannen';

  @override
  String get titleCountObjects => 'Objekte zählen';

  @override
  String get pageLabelPassport => 'Reisepass';

  @override
  String get pageLabelIdDocument => 'Ausweisdokument';

  @override
  String get pageLabelIdFront => 'Ausweis vorne';

  @override
  String get pageLabelIdBack => 'Ausweis hinten';

  @override
  String get pageLabelLeft => 'Links';

  @override
  String get pageLabelRight => 'Rechts';

  @override
  String get pageLabelSpread => 'Doppelseite';

  @override
  String get pageLabelMath => 'Mathe';

  @override
  String get pageLabelArea => 'Fläche';

  @override
  String defaultTitle(String date) {
    return 'Scan $date';
  }

  @override
  String get titleMathSolutions => 'Mathe-Lösungen';

  @override
  String get titleQrCodes => 'QR-Codes';

  @override
  String get titleAreaMeasurements => 'Flächenmessungen';

  @override
  String get titleCountResults => 'Zählergebnisse';

  @override
  String get mathNeedsAi =>
      'Zum Lösen von Matheaufgaben wird AI benötigt, die in dieser App nicht eingerichtet ist.';

  @override
  String get mathNoAnswer =>
      'Es wurde keine Lösung gefunden. Versuche es mit einem schärferen Foto.';

  @override
  String captureFailed(String message) {
    return 'Aufnahme fehlgeschlagen: $message';
  }

  @override
  String get measureCaptureFailed =>
      'Die Messung konnte nicht erfasst werden. Versuche es erneut.';

  @override
  String get measureCameraStopped =>
      'Die Kamera wurde gestoppt. Versuche es erneut.';

  @override
  String get measureShapeChanged =>
      'Die Form hat sich geändert. Schließe sie erneut und speichere dann.';

  @override
  String get photoAccessDenied =>
      'Erlaube in den Einstellungen den Zugriff auf Fotos, um zu importieren.';

  @override
  String get imageUnreadable =>
      'Das Bild konnte nicht gelesen werden. Versuche ein anderes.';

  @override
  String get imageOpenFailed =>
      'Das Bild konnte nicht geöffnet werden. Versuche ein anderes.';

  @override
  String get noCodeInImage => 'Kein Code im Bild gefunden';

  @override
  String get noMrzInImage =>
      'Keine lesbare MRZ im Bild. Versuche es mit einem schärferen Foto.';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gescannte Seiten verwerfen?',
      one: '1 gescannte Seite verwerfen?',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'Weiter scannen';

  @override
  String get discard => 'Verwerfen';

  @override
  String get flashOn => 'Blitz an';

  @override
  String get flashOff => 'Blitz aus';

  @override
  String get showGrid => 'Raster einblenden';

  @override
  String get hideGrid => 'Raster ausblenden';

  @override
  String get autoCaptureOn => 'Automatische Aufnahme an';

  @override
  String get autoCaptureOff => 'Automatische Aufnahme aus';

  @override
  String get autoBadge => 'AUTO';

  @override
  String bookChipLeft(int page) {
    return 'Links · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'Rechts · $page';
  }

  @override
  String get pointAtSurfaceFirst => 'Richte den Kreis zuerst auf eine Fläche';

  @override
  String get idSideFront => '1  Vorderseite';

  @override
  String get idSideBack => '2  Rückseite';

  @override
  String get pillQr => 'Auf einen QR-Code oder Barcode richten';

  @override
  String get pillCount => 'Auf die Objekte richten und Auslöser tippen';

  @override
  String get pillMathOff =>
      'Zum Lösen von Matheaufgaben wird AI benötigt, die nicht eingerichtet ist';

  @override
  String get pillMath => 'Auf eine Matheaufgabe richten und Auslöser tippen';

  @override
  String get pillMrzDetected => 'MRZ erkannt · Ruhig halten';

  @override
  String get pillPassport => 'Lege die Bildseite in den Rahmen';

  @override
  String get pillIdFrontSaved => 'Vorderseite gespeichert · Karte umdrehen';

  @override
  String get pillSaved => 'Gespeichert';

  @override
  String get pillIdBack => 'Scanne jetzt die Rückseite';

  @override
  String get pillIdFit => 'Lege die Karte in den Rahmen';

  @override
  String get pillCardDetected => 'Karte erkannt · Ruhig halten';

  @override
  String get pillBook => 'Auf ein aufgeschlagenes Buch richten';

  @override
  String get pillBookAuto => 'Buch erkannt · Seiten werden automatisch geteilt';

  @override
  String get pillBookTap => 'Buch erkannt · Zum Aufnehmen tippen';

  @override
  String get pillCaptured => 'Aufgenommen · Nächste Seite auflegen';

  @override
  String get pillDocument => 'Auf ein Dokument richten';

  @override
  String get pillDocumentAuto => 'Dokument erkannt · Ruhig halten';

  @override
  String get pillDocumentTap => 'Dokument erkannt · Zum Aufnehmen tippen';

  @override
  String get cameraOffTitle => 'Kamerazugriff ist deaktiviert';

  @override
  String get cameraOffBody =>
      'Erlaube den Kamerazugriff, um Dokumente zu scannen.';

  @override
  String get arUnsupportedTitle => 'AR ist auf diesem Gerät nicht verfügbar';

  @override
  String get arUnsupportedBody =>
      'Zum Messen werden die Google Play-Dienste für AR benötigt.';

  @override
  String get arInstallTitle => 'AR-Unterstützung installieren';

  @override
  String get arInstallBody =>
      'Schließe die Installation der Google Play-Dienste für AR ab und versuche es erneut.';

  @override
  String get arFailedTitle => 'AR konnte nicht gestartet werden';

  @override
  String get arFailedBody =>
      'Beim Starten der AR-Kamera ist ein Fehler aufgetreten.';

  @override
  String get cameraFailedTitle => 'Kamera nicht verfügbar';

  @override
  String get cameraFailedBody =>
      'Beim Starten der Kamera ist ein Fehler aufgetreten.';

  @override
  String get importFromGallery => 'Aus Galerie importieren';

  @override
  String get capture => 'Aufnehmen';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten prüfen',
      one: '1 Seite prüfen',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'Link öffnen';

  @override
  String get sendEmail => 'E-Mail senden';

  @override
  String get call => 'Anrufen';

  @override
  String get sendMessage => 'SMS';

  @override
  String get openMap => 'Karte öffnen';

  @override
  String get copyPassword => 'Passwort kopieren';

  @override
  String get passwordCopied => 'Passwort kopiert';

  @override
  String get copyFailed => 'Kopieren fehlgeschlagen. Versuche es erneut.';

  @override
  String get noAppCanOpen => 'Keine App auf diesem Gerät kann das öffnen.';

  @override
  String get shareFailed =>
      'Teilen konnte nicht geöffnet werden. Versuche es erneut.';

  @override
  String get qrSaveFailed =>
      'Der QR-Code konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get qrTooLong =>
      'Zu lang für einen QR-Code. Der vollständige Inhalt steht unten.';

  @override
  String get qrGenerated => 'Aus dem gescannten Inhalt erstellt';

  @override
  String get password => 'Passwort';

  @override
  String get showPassword => 'Passwort anzeigen';

  @override
  String get hidePassword => 'Passwort ausblenden';

  @override
  String get codeEmpty => 'Dieser Code ist leer';

  @override
  String get codeEmptyBody => 'Er enthält nichts, was angezeigt werden kann.';

  @override
  String get codeUnreadable => 'Dieser Code konnte nicht gelesen werden';

  @override
  String get codeNotText => 'Er enthält Daten, die kein Text sind.';

  @override
  String get scanAgain => 'Erneut scannen';

  @override
  String get qrCodeImage => 'QR-Code';

  @override
  String qrCardTitle(String kind) {
    return 'QR-Code · $kind';
  }

  @override
  String get qrCardContent => 'Inhalt';

  @override
  String get scannedWithDocScan => 'Gescannt mit DocScan';

  @override
  String get anotherMath => 'Weitere Aufgabe lösen';

  @override
  String get anotherQr => 'Weiteren Code scannen';

  @override
  String get anotherArea => 'Weitere Fläche messen';

  @override
  String get anotherCount => 'Weitere Objekte zählen';

  @override
  String get addAnother => 'Weitere hinzufügen';

  @override
  String get addedToScan => 'Zu deinem Scan hinzugefügt';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · bisher $count Seiten',
      one: '$title · bisher 1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'Website';

  @override
  String get qrLink => 'Link';

  @override
  String get qrPhone => 'Telefon';

  @override
  String get qrNumber => 'Nummer';

  @override
  String get qrText => 'Text';

  @override
  String get qrWifi => 'WLAN';

  @override
  String get qrHiddenNetwork => 'Verborgenes Netzwerk';

  @override
  String get qrNetwork => 'Netzwerk';

  @override
  String get qrNoName => '(kein Name)';

  @override
  String get qrSecurity => 'Sicherheit';

  @override
  String get qrSecurityOpen => 'Keine (offen)';

  @override
  String get qrSecurityUnspecified => 'Nicht angegeben';

  @override
  String get qrHidden => 'Verborgen';

  @override
  String get qrYes => 'Ja';

  @override
  String get qrEapMethod => 'EAP-Methode';

  @override
  String get qrIdentity => 'Identität';

  @override
  String get qrEmail => 'E-Mail';

  @override
  String get qrTo => 'An';

  @override
  String get qrSubject => 'Betreff';

  @override
  String get qrMessage => 'Nachricht';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'Standort';

  @override
  String get qrCoordinates => 'Koordinaten';

  @override
  String get qrPlace => 'Ort';

  @override
  String get qrAltitude => 'Höhe';

  @override
  String get qrContact => 'Kontakt';

  @override
  String get qrContactCard => 'Visitenkarte';

  @override
  String get qrName => 'Name';

  @override
  String get qrOrganization => 'Organisation';

  @override
  String get qrJobTitle => 'Position';

  @override
  String get qrAddress => 'Adresse';

  @override
  String get qrNote => 'Notiz';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'Konnte nicht gelöst werden';

  @override
  String get mathSaveFailed =>
      'Die Lösung konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Schritte',
      one: '1 Schritt',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'Mit AI gelöst';

  @override
  String get mathAnswer => 'Lösung';

  @override
  String mathCopyProblem(String problem) {
    return 'Aufgabe: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'Lösung: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'Mathe · $answer';
  }

  @override
  String get mathCardTitle => 'MATHE-LÖSUNG';

  @override
  String get mathCardContinued => 'MATHE-LÖSUNG · FORTSETZUNG';

  @override
  String get mathCardProblem => 'AUFGABE';

  @override
  String get mathCardSteps => 'SCHRITTE';

  @override
  String get solvingWithAiLabel => 'Wird mit AI gelöst';

  @override
  String get solvingWithAi => 'Wird mit AI gelöst…';

  @override
  String get solvingDetail => 'Aufgabe wird gelesen und jeder Schritt geprüft';

  @override
  String get exportFailed => 'Die PDF konnte nicht exportiert werden';

  @override
  String bookPagesTitle(int first, int last) {
    return 'Seiten $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'Seite $page';
  }

  @override
  String get splitIntoTwo => 'In zwei Seiten teilen';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Doppelseiten gescannt · $pages Seiten',
      one: '1 Doppelseite gescannt · $pages Seiten',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'Nächste Doppelseite';

  @override
  String get saveBook => 'Buch speichern';

  @override
  String get idCardTitle => 'Ausweis';

  @override
  String get passportTitle => 'Reisepass';

  @override
  String get idDocumentTitle => 'Ausweisdokument';

  @override
  String get layoutStacked => 'Untereinander';

  @override
  String get layoutSideBySide => 'Nebeneinander';

  @override
  String get layoutSeparate => 'Getrennt';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get idNumber => 'Ausweisnummer';

  @override
  String get dateOfBirth => 'Geburtsdatum';

  @override
  String get extractedDetails => 'Ausgelesene Daten';

  @override
  String get copyAllLower => 'Alle kopieren';

  @override
  String get copyAll => 'Alle kopieren';

  @override
  String get detailsCopied => 'Daten kopiert';

  @override
  String get readingCard => 'Karte wird gelesen…';

  @override
  String get noMrzOnCard =>
      'Diese Karte hat keine maschinenlesbare Zone, daher lassen sich keine geprüften Daten auslesen. Der Scan wird unverändert gespeichert.';

  @override
  String copyField(String label) {
    return '$label kopieren';
  }

  @override
  String fieldCopied(String label) {
    return '$label kopiert';
  }

  @override
  String get passportNo => 'Passnummer';

  @override
  String get documentNo => 'Dokumentnummer';

  @override
  String get nationality => 'Staatsangehörigkeit';

  @override
  String get sex => 'Geschlecht';

  @override
  String get issuingCountry => 'Ausstellungsland';

  @override
  String get expires => 'Gültig bis';

  @override
  String expiredOn(String date) {
    return 'Abgelaufen am $date';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Jahre gültig',
      one: 'Noch 1 Jahr gültig',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Monate gültig',
      one: 'Noch 1 Monat gültig',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'Läuft in weniger als einem Monat ab';

  @override
  String get mrzVerified => 'MRZ geprüft';

  @override
  String pageDeleted(int page) {
    return 'Seite $page gelöscht';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten gelöscht',
      one: '1 Seite gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'Kamera';

  @override
  String get addFromPhotos => 'Fotos';

  @override
  String selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Auswählen';

  @override
  String get tapToSelect => 'Tippe auf Seiten, um sie auszuwählen';

  @override
  String get dragToReorder =>
      'Gedrückt halten und ziehen, um Seiten neu anzuordnen';

  @override
  String get rotateSelected => 'Auswahl drehen';

  @override
  String get delete => 'Löschen';

  @override
  String deleteCount(int count) {
    return '$count löschen';
  }

  @override
  String get editPages => 'Seiten bearbeiten';

  @override
  String get saveAsPdf => 'Als PDF speichern';

  @override
  String rotatePage(int page) {
    return 'Seite $page drehen';
  }

  @override
  String deletePage(int page) {
    return 'Seite $page löschen';
  }

  @override
  String get addPage => 'Seite hinzufügen';

  @override
  String get cameraOrPhotos => 'Kamera oder Fotos';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterMagic => 'Magie';

  @override
  String get filterBw => 'S/W';

  @override
  String get filterGray => 'Grau';

  @override
  String get filterNoShadow => 'Ohne Schatten';

  @override
  String get filterColor => 'Farbe';

  @override
  String get adjustCrop => 'Zuschnitt anpassen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get rotate => 'Drehen';

  @override
  String get cropAuto => 'Auto';

  @override
  String get cropPerspective => 'Perspektive';

  @override
  String get cropFullPage => 'Ganze Seite';

  @override
  String get enhance => 'Verbessern';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter auf alle $count Seiten angewendet';
  }

  @override
  String get brightness => 'Helligkeit';

  @override
  String get contrast => 'Kontrast';

  @override
  String get applyToAll => 'Auf alle anwenden';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed =>
      'Das Ergebnis konnte nicht gespeichert werden. Versuche es erneut.';

  @override
  String get objectCount => 'Anzahl Objekte';

  @override
  String get countedWithDocScan => 'Gezählt mit DocScan';

  @override
  String countPageLabel(int count) {
    return 'Anzahl: $count';
  }

  @override
  String countAdded(int count) {
    return '$count hinzugefügt';
  }

  @override
  String countRemoved(int count) {
    return '$count entfernt';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Objekte',
      one: 'Objekt',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'Art';

  @override
  String get roundObjects => 'Runde Objekte';

  @override
  String get boxes => 'Kartons';

  @override
  String get custom => 'Eigene';

  @override
  String get matchedToSample => 'mit angetipptem Muster abgeglichen';

  @override
  String get countAutomatic => 'Automatisch';

  @override
  String get countByHand => 'Manuell';

  @override
  String get noChanges => 'Keine Änderungen';

  @override
  String get tapOneObject => 'Tippe auf ein Objekt, um ähnliche zu zählen';

  @override
  String get objectsDetected => 'Erkannte Objekte';

  @override
  String get removeOne => 'Eins entfernen';

  @override
  String get addOne => 'Eins hinzufügen';

  @override
  String get saveResult => 'Ergebnis speichern';

  @override
  String get areaMeasurement => 'Flächenmessung';

  @override
  String get measuredNote => 'Gemessen mit DocScan AR · ca. ±5 %';

  @override
  String areaTitle(String area) {
    return 'Fläche · $area';
  }

  @override
  String get area => 'Fläche';

  @override
  String get perimeter => 'Umfang';

  @override
  String get sides => 'Seiten';

  @override
  String get points => 'Punkte';

  @override
  String summaryArea(String area) {
    return 'Fläche $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Punkte',
      one: '1 Punkt',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head. Seiten $sides';
  }

  @override
  String get hintStartingAr => 'AR wird gestartet…';

  @override
  String get hintTooDark => 'Zu dunkel · Blitz einschalten';

  @override
  String get hintMoveSlower => 'Bewege dein Handy langsamer';

  @override
  String get hintMoreDetail => 'Richte es auf eine Fläche mit mehr Details';

  @override
  String get hintFindSurface =>
      'Bewege dein Handy langsam, um eine Fläche zu finden';

  @override
  String get hintDragCorner => 'Zum Anpassen eine Ecke ziehen';

  @override
  String get hintPointCircle => 'Richte den Kreis auf eine Fläche';

  @override
  String get hintAimBack => 'Richte es wieder auf dieselbe Fläche';

  @override
  String get hintTapToDrop => 'Tippe auf +, um Punkte zu setzen';

  @override
  String get hintNextCorner => 'Tippe auf +, um die nächste Ecke hinzuzufügen';

  @override
  String get hintClose =>
      'Tippe auf den ersten Punkt, um die Form zu schließen';

  @override
  String get savingMeasurement => 'Messung wird gespeichert';

  @override
  String get saveMeasurement => 'Messung speichern';

  @override
  String get newMeasurement => 'Neue Messung';

  @override
  String get addPoint => 'Punkt hinzufügen';

  @override
  String get meters => 'Meter';

  @override
  String get feet => 'Fuß';
}
