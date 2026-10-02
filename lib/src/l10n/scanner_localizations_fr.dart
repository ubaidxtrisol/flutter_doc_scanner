// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class ScannerLocalizationsFr extends ScannerLocalizations {
  ScannerLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get undo => 'Annuler';

  @override
  String get cancel => 'Annuler';

  @override
  String get done => 'OK';

  @override
  String get next => 'Suivant';

  @override
  String get retry => 'Réessayer';

  @override
  String get retake => 'Reprendre';

  @override
  String get review => 'Vérifier';

  @override
  String get copy => 'Copier';

  @override
  String get copied => 'Copié';

  @override
  String get share => 'Partager';

  @override
  String get saving => 'Enregistrement…';

  @override
  String get saveToDocuments => 'Enregistrer dans Documents';

  @override
  String get savePdf => 'Enregistrer le PDF';

  @override
  String get sharePdf => 'Partager le PDF';

  @override
  String get settings => 'Paramètres';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String pageOf(int page, int total) {
    return 'Page $page sur $total';
  }

  @override
  String detailLine(String label, String value) {
    return '$label : $value';
  }

  @override
  String get tabDocument => 'Document';

  @override
  String get tabIdCard => 'Carte ID';

  @override
  String get tabPassport => 'Passeport';

  @override
  String get tabBook => 'Livre';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'Maths';

  @override
  String get tabCount => 'Compter';

  @override
  String get tabMeasure => 'Mesurer';

  @override
  String get titleScanQr => 'Scanner un QR';

  @override
  String get titleCountObjects => 'Compter des objets';

  @override
  String get pageLabelPassport => 'Passeport';

  @override
  String get pageLabelIdDocument => 'Pièce d\'identité';

  @override
  String get pageLabelIdFront => 'Recto ID';

  @override
  String get pageLabelIdBack => 'Verso ID';

  @override
  String get pageLabelLeft => 'Gauche';

  @override
  String get pageLabelRight => 'Droite';

  @override
  String get pageLabelSpread => 'Double page';

  @override
  String get pageLabelMath => 'Maths';

  @override
  String get pageLabelArea => 'Surface';

  @override
  String defaultTitle(String date) {
    return 'Scan $date';
  }

  @override
  String get titleMathSolutions => 'Solutions de maths';

  @override
  String get titleQrCodes => 'Codes QR';

  @override
  String get titleAreaMeasurements => 'Mesures de surface';

  @override
  String get titleCountResults => 'Résultats de comptage';

  @override
  String get mathNeedsAi =>
      'La résolution de maths nécessite l\'IA, qui n\'est pas configurée dans cette app.';

  @override
  String get mathNoAnswer =>
      'Aucune réponse trouvée. Essayez avec une photo plus nette.';

  @override
  String captureFailed(String message) {
    return 'Échec de la capture : $message';
  }

  @override
  String get measureCaptureFailed =>
      'Impossible de capturer la mesure. Réessayez.';

  @override
  String get measureCameraStopped => 'La caméra s\'est arrêtée. Réessayez.';

  @override
  String get measureShapeChanged =>
      'La forme a changé. Refermez-la, puis enregistrez.';

  @override
  String get photoAccessDenied =>
      'Autorisez l\'accès aux photos dans les Paramètres pour importer.';

  @override
  String get imageUnreadable =>
      'Impossible de lire cette image. Essayez-en une autre.';

  @override
  String get imageOpenFailed =>
      'Impossible d\'ouvrir cette image. Essayez-en une autre.';

  @override
  String get noCodeInImage => 'Aucun code trouvé dans cette image';

  @override
  String get noMrzInImage =>
      'Aucune MRZ lisible dans cette image. Essayez une photo plus nette.';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count pages scannées ?',
      one: 'Supprimer 1 page scannée ?',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'Continuer le scan';

  @override
  String get discard => 'Supprimer';

  @override
  String get flashOn => 'Flash activé';

  @override
  String get flashOff => 'Flash désactivé';

  @override
  String get showGrid => 'Afficher la grille';

  @override
  String get hideGrid => 'Masquer la grille';

  @override
  String get autoCaptureOn => 'Capture auto activée';

  @override
  String get autoCaptureOff => 'Capture auto désactivée';

  @override
  String get autoBadge => 'AUTO';

  @override
  String bookChipLeft(int page) {
    return 'Gauche · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'Droite · $page';
  }

  @override
  String get pointAtSurfaceFirst =>
      'Pointez d\'abord le cercle vers une surface';

  @override
  String get idSideFront => '1  Recto';

  @override
  String get idSideBack => '2  Verso';

  @override
  String get pillQr => 'Visez un code QR ou un code-barres';

  @override
  String get pillCount => 'Visez les objets, puis appuyez sur le déclencheur';

  @override
  String get pillMathOff =>
      'La résolution de maths nécessite l\'IA, qui n\'est pas configurée';

  @override
  String get pillMath =>
      'Visez un problème de maths, puis appuyez sur le déclencheur';

  @override
  String get pillMrzDetected => 'MRZ détectée · Ne bougez pas';

  @override
  String get pillPassport => 'Placez la page photo dans le cadre';

  @override
  String get pillIdFrontSaved => 'Recto enregistré · Retournez la carte';

  @override
  String get pillSaved => 'Enregistré';

  @override
  String get pillIdBack => 'Scannez maintenant le verso';

  @override
  String get pillIdFit => 'Placez la carte dans le cadre';

  @override
  String get pillCardDetected => 'Carte détectée · Ne bougez pas';

  @override
  String get pillBook => 'Visez un livre ouvert';

  @override
  String get pillBookAuto => 'Livre détecté · Pages séparées automatiquement';

  @override
  String get pillBookTap => 'Livre détecté · Appuyez pour capturer';

  @override
  String get pillCaptured => 'Capturé · Placez la page suivante';

  @override
  String get pillDocument => 'Visez un document';

  @override
  String get pillDocumentAuto => 'Document détecté · Ne bougez pas';

  @override
  String get pillDocumentTap => 'Document détecté · Appuyez pour capturer';

  @override
  String get cameraOffTitle => 'L\'accès à la caméra est désactivé';

  @override
  String get cameraOffBody =>
      'Autorisez l\'accès à la caméra pour scanner des documents.';

  @override
  String get arUnsupportedTitle =>
      'La RA n\'est pas disponible sur ce téléphone';

  @override
  String get arUnsupportedBody =>
      'La mesure nécessite les Services Google Play pour la RA.';

  @override
  String get arInstallTitle => 'Installer la prise en charge de la RA';

  @override
  String get arInstallBody =>
      'Terminez l\'installation des Services Google Play pour la RA, puis réessayez.';

  @override
  String get arFailedTitle => 'Impossible de démarrer la RA';

  @override
  String get arFailedBody =>
      'Un problème est survenu au démarrage de la caméra RA.';

  @override
  String get cameraFailedTitle => 'Caméra indisponible';

  @override
  String get cameraFailedBody =>
      'Un problème est survenu au démarrage de la caméra.';

  @override
  String get importFromGallery => 'Importer depuis la galerie';

  @override
  String get capture => 'Capturer';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vérifier $count pages',
      one: 'Vérifier 1 page',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'Ouvrir le lien';

  @override
  String get sendEmail => 'Envoyer un e-mail';

  @override
  String get call => 'Appeler';

  @override
  String get sendMessage => 'Message';

  @override
  String get openMap => 'Ouvrir le plan';

  @override
  String get copyPassword => 'Copier le mot de passe';

  @override
  String get passwordCopied => 'Mot de passe copié';

  @override
  String get copyFailed => 'Copie impossible. Réessayez.';

  @override
  String get noAppCanOpen => 'Aucune app de ce téléphone ne peut ouvrir ceci.';

  @override
  String get shareFailed => 'Impossible d\'ouvrir le partage. Réessayez.';

  @override
  String get qrSaveFailed => 'Impossible d\'enregistrer le code QR. Réessayez.';

  @override
  String get qrTooLong =>
      'Trop long pour être affiché en code QR. Le contenu complet figure ci-dessous.';

  @override
  String get qrGenerated => 'Généré à partir du contenu scanné';

  @override
  String get password => 'Mot de passe';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get codeEmpty => 'Ce code est vide';

  @override
  String get codeEmptyBody => 'Il ne contient rien à afficher.';

  @override
  String get codeUnreadable => 'Impossible de lire ce code';

  @override
  String get codeNotText => 'Il contient des données qui ne sont pas du texte.';

  @override
  String get scanAgain => 'Scanner à nouveau';

  @override
  String get qrCodeImage => 'Code QR';

  @override
  String qrCardTitle(String kind) {
    return 'Code QR · $kind';
  }

  @override
  String get qrCardContent => 'Contenu';

  @override
  String get scannedWithDocScan => 'Scanné avec DocScan';

  @override
  String get anotherMath => 'Résoudre un autre problème';

  @override
  String get anotherQr => 'Scanner un autre code';

  @override
  String get anotherArea => 'Mesurer une autre surface';

  @override
  String get anotherCount => 'Compter d\'autres objets';

  @override
  String get addAnother => 'Ajouter un autre';

  @override
  String get addedToScan => 'Ajouté à votre scan';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · $count pages pour l\'instant',
      one: '$title · 1 page pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'Site web';

  @override
  String get qrLink => 'Lien';

  @override
  String get qrPhone => 'Téléphone';

  @override
  String get qrNumber => 'Numéro';

  @override
  String get qrText => 'Texte';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'Réseau masqué';

  @override
  String get qrNetwork => 'Réseau';

  @override
  String get qrNoName => '(sans nom)';

  @override
  String get qrSecurity => 'Sécurité';

  @override
  String get qrSecurityOpen => 'Aucune (ouvert)';

  @override
  String get qrSecurityUnspecified => 'Non précisée';

  @override
  String get qrHidden => 'Masqué';

  @override
  String get qrYes => 'Oui';

  @override
  String get qrEapMethod => 'Méthode EAP';

  @override
  String get qrIdentity => 'Identité';

  @override
  String get qrEmail => 'E-mail';

  @override
  String get qrTo => 'À';

  @override
  String get qrSubject => 'Objet';

  @override
  String get qrMessage => 'Message';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'Position';

  @override
  String get qrCoordinates => 'Coordonnées';

  @override
  String get qrPlace => 'Lieu';

  @override
  String get qrAltitude => 'Altitude';

  @override
  String get qrContact => 'Contact';

  @override
  String get qrContactCard => 'Fiche contact';

  @override
  String get qrName => 'Nom';

  @override
  String get qrOrganization => 'Organisation';

  @override
  String get qrJobTitle => 'Poste';

  @override
  String get qrAddress => 'Adresse';

  @override
  String get qrNote => 'Note';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'Impossible de résoudre ce problème';

  @override
  String get mathSaveFailed =>
      'Impossible d\'enregistrer la solution. Réessayez.';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'Résolu avec l\'IA';

  @override
  String get mathAnswer => 'Réponse';

  @override
  String mathCopyProblem(String problem) {
    return 'Problème : $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'Réponse : $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'Maths · $answer';
  }

  @override
  String get mathCardTitle => 'SOLUTION DE MATHS';

  @override
  String get mathCardContinued => 'SOLUTION DE MATHS · SUITE';

  @override
  String get mathCardProblem => 'PROBLÈME';

  @override
  String get mathCardSteps => 'ÉTAPES';

  @override
  String get solvingWithAiLabel => 'Résolution avec l\'IA';

  @override
  String get solvingWithAi => 'Résolution avec l\'IA…';

  @override
  String get solvingDetail =>
      'Lecture du problème et vérification de chaque étape';

  @override
  String get exportFailed => 'Impossible d\'exporter le PDF';

  @override
  String bookPagesTitle(int first, int last) {
    return 'Pages $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'Page $page';
  }

  @override
  String get splitIntoTwo => 'Diviser en deux pages';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doubles pages scannées · $pages pages',
      one: '1 double page scannée · $pages pages',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'Double page suivante';

  @override
  String get saveBook => 'Enregistrer le livre';

  @override
  String get idCardTitle => 'Carte d\'identité';

  @override
  String get passportTitle => 'Passeport';

  @override
  String get idDocumentTitle => 'Pièce d\'identité';

  @override
  String get layoutStacked => 'Empilé';

  @override
  String get layoutSideBySide => 'Côte à côte';

  @override
  String get layoutSeparate => 'Séparé';

  @override
  String get fullName => 'Nom complet';

  @override
  String get idNumber => 'Numéro d\'identité';

  @override
  String get dateOfBirth => 'Date de naissance';

  @override
  String get extractedDetails => 'Informations extraites';

  @override
  String get copyAllLower => 'Tout copier';

  @override
  String get copyAll => 'Tout copier';

  @override
  String get detailsCopied => 'Informations copiées';

  @override
  String get readingCard => 'Lecture de la carte…';

  @override
  String get noMrzOnCard =>
      'Cette carte n\'a pas de zone de lecture automatique : aucune donnée vérifiée à extraire. Le scan est enregistré tel quel.';

  @override
  String copyField(String label) {
    return 'Copier : $label';
  }

  @override
  String fieldCopied(String label) {
    return '$label copié';
  }

  @override
  String get passportNo => 'N° de passeport';

  @override
  String get documentNo => 'N° de document';

  @override
  String get nationality => 'Nationalité';

  @override
  String get sex => 'Sexe';

  @override
  String get issuingCountry => 'Pays de délivrance';

  @override
  String get expires => 'Expire le';

  @override
  String expiredOn(String date) {
    return 'Expiré le $date';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Valide encore $count ans',
      one: 'Valide encore 1 an',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Valide encore $count mois',
      one: 'Valide encore 1 mois',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'Expire dans moins d\'un mois';

  @override
  String get mrzVerified => 'MRZ vérifiée';

  @override
  String pageDeleted(int page) {
    return 'Page $page supprimée';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages supprimées',
      one: '1 page supprimée',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'Caméra';

  @override
  String get addFromPhotos => 'Photos';

  @override
  String selectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Sélectionner';

  @override
  String get tapToSelect => 'Appuyez sur les pages pour les sélectionner';

  @override
  String get dragToReorder =>
      'Appuyez de manière prolongée et faites glisser pour réorganiser';

  @override
  String get rotateSelected => 'Faire pivoter la sélection';

  @override
  String get delete => 'Supprimer';

  @override
  String deleteCount(int count) {
    return 'Supprimer $count';
  }

  @override
  String get editPages => 'Modifier les pages';

  @override
  String get saveAsPdf => 'Enregistrer en PDF';

  @override
  String rotatePage(int page) {
    return 'Faire pivoter la page $page';
  }

  @override
  String deletePage(int page) {
    return 'Supprimer la page $page';
  }

  @override
  String get addPage => 'Ajouter une page';

  @override
  String get cameraOrPhotos => 'Caméra ou Photos';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterMagic => 'Magique';

  @override
  String get filterBw => 'N & B';

  @override
  String get filterGray => 'Gris';

  @override
  String get filterNoShadow => 'Sans ombre';

  @override
  String get filterColor => 'Couleur';

  @override
  String get adjustCrop => 'Ajuster le recadrage';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get rotate => 'Pivoter';

  @override
  String get cropAuto => 'Auto';

  @override
  String get cropPerspective => 'Perspective';

  @override
  String get cropFullPage => 'Page entière';

  @override
  String get enhance => 'Améliorer';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter appliqué aux $count pages';
  }

  @override
  String get brightness => 'Luminosité';

  @override
  String get contrast => 'Contraste';

  @override
  String get applyToAll => 'Appliquer à tout';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed =>
      'Impossible d\'enregistrer le résultat. Réessayez.';

  @override
  String get objectCount => 'Nombre d\'objets';

  @override
  String get countedWithDocScan => 'Compté avec DocScan';

  @override
  String countPageLabel(int count) {
    return 'Comptage : $count';
  }

  @override
  String countAdded(int count) {
    return '$count ajouté(s)';
  }

  @override
  String countRemoved(int count) {
    return '$count retiré(s)';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'objets',
      one: 'objet',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'Type';

  @override
  String get roundObjects => 'Objets ronds';

  @override
  String get boxes => 'Boîtes';

  @override
  String get custom => 'Personnalisé';

  @override
  String get matchedToSample => 'correspondant à l\'échantillon touché';

  @override
  String get countAutomatic => 'Automatique';

  @override
  String get countByHand => 'Manuel';

  @override
  String get noChanges => 'Aucune modification';

  @override
  String get tapOneObject =>
      'Touchez un objet pour compter ceux qui lui ressemblent';

  @override
  String get objectsDetected => 'Objets détectés';

  @override
  String get removeOne => 'En retirer un';

  @override
  String get addOne => 'En ajouter un';

  @override
  String get saveResult => 'Enregistrer le résultat';

  @override
  String get areaMeasurement => 'Mesure de surface';

  @override
  String get measuredNote => 'Mesuré avec DocScan RA · env. ±5 %';

  @override
  String areaTitle(String area) {
    return 'Surface · $area';
  }

  @override
  String get area => 'Surface';

  @override
  String get perimeter => 'Périmètre';

  @override
  String get sides => 'Côtés';

  @override
  String get points => 'Points';

  @override
  String summaryArea(String area) {
    return 'Surface $area';
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
    return '$head. Côtés $sides';
  }

  @override
  String get hintStartingAr => 'Démarrage de la RA…';

  @override
  String get hintTooDark => 'Trop sombre · Activez le flash';

  @override
  String get hintMoveSlower => 'Déplacez votre téléphone plus lentement';

  @override
  String get hintMoreDetail => 'Visez une surface plus détaillée';

  @override
  String get hintFindSurface =>
      'Déplacez lentement votre téléphone pour trouver une surface';

  @override
  String get hintDragCorner => 'Faites glisser un coin pour ajuster';

  @override
  String get hintPointCircle => 'Pointez le cercle vers une surface';

  @override
  String get hintAimBack => 'Visez à nouveau la même surface';

  @override
  String get hintTapToDrop => 'Appuyez sur + pour placer des points';

  @override
  String get hintNextCorner => 'Appuyez sur + pour ajouter le coin suivant';

  @override
  String get hintClose => 'Touchez le premier point pour fermer la forme';

  @override
  String get savingMeasurement => 'Enregistrement de la mesure';

  @override
  String get saveMeasurement => 'Enregistrer la mesure';

  @override
  String get newMeasurement => 'Nouvelle mesure';

  @override
  String get addPoint => 'Ajouter un point';

  @override
  String get meters => 'Mètres';

  @override
  String get feet => 'Pieds';
}
