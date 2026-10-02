// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class ScannerLocalizationsTr extends ScannerLocalizations {
  ScannerLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get close => 'Kapat';

  @override
  String get back => 'Geri';

  @override
  String get undo => 'Geri al';

  @override
  String get cancel => 'İptal';

  @override
  String get done => 'Bitti';

  @override
  String get next => 'İleri';

  @override
  String get retry => 'Yeniden dene';

  @override
  String get retake => 'Yeniden çek';

  @override
  String get review => 'İncele';

  @override
  String get copy => 'Kopyala';

  @override
  String get copied => 'Kopyalandı';

  @override
  String get share => 'Paylaş';

  @override
  String get saving => 'Kaydediliyor…';

  @override
  String get saveToDocuments => 'Belgelere kaydet';

  @override
  String get savePdf => 'PDF\'yi kaydet';

  @override
  String get sharePdf => 'PDF\'yi paylaş';

  @override
  String get settings => 'Ayarlar';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String get tryAgain => 'Tekrar dene';

  @override
  String pageOf(int page, int total) {
    return 'Sayfa $page/$total';
  }

  @override
  String detailLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get tabDocument => 'Belge';

  @override
  String get tabIdCard => 'Kimlik';

  @override
  String get tabPassport => 'Pasaport';

  @override
  String get tabBook => 'Kitap';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'Matematik';

  @override
  String get tabCount => 'Sayma';

  @override
  String get tabMeasure => 'Ölçüm';

  @override
  String get titleScanQr => 'QR tara';

  @override
  String get titleCountObjects => 'Nesneleri say';

  @override
  String get pageLabelPassport => 'Pasaport';

  @override
  String get pageLabelIdDocument => 'Kimlik belgesi';

  @override
  String get pageLabelIdFront => 'Kimlik ön yüz';

  @override
  String get pageLabelIdBack => 'Kimlik arka yüz';

  @override
  String get pageLabelLeft => 'Sol';

  @override
  String get pageLabelRight => 'Sağ';

  @override
  String get pageLabelSpread => 'Çift sayfa';

  @override
  String get pageLabelMath => 'Matematik';

  @override
  String get pageLabelArea => 'Alan';

  @override
  String defaultTitle(String date) {
    return 'Tarama $date';
  }

  @override
  String get titleMathSolutions => 'Matematik çözümleri';

  @override
  String get titleQrCodes => 'QR kodları';

  @override
  String get titleAreaMeasurements => 'Alan ölçümleri';

  @override
  String get titleCountResults => 'Sayım sonuçları';

  @override
  String get mathNeedsAi =>
      'Matematik çözmek için AI gerekir, ancak bu uygulamada ayarlanmamış.';

  @override
  String get mathNoAnswer =>
      'Çözücü bir yanıt bulamadı. Daha net bir fotoğraf deneyin.';

  @override
  String captureFailed(String message) {
    return 'Çekim başarısız: $message';
  }

  @override
  String get measureCaptureFailed => 'Ölçüm alınamadı. Tekrar deneyin.';

  @override
  String get measureCameraStopped => 'Kamera durdu. Tekrar deneyin.';

  @override
  String get measureShapeChanged =>
      'Şekil değişti. Şekli yeniden kapatıp kaydedin.';

  @override
  String get photoAccessDenied =>
      'İçe aktarmak için Ayarlar\'dan fotoğraf erişimine izin verin.';

  @override
  String get imageUnreadable => 'Bu görüntü okunamadı. Başka bir tane deneyin.';

  @override
  String get imageOpenFailed => 'Bu görüntü açılamadı. Başka bir tane deneyin.';

  @override
  String get noCodeInImage => 'Bu görüntüde kod bulunamadı';

  @override
  String get noMrzInImage =>
      'Bu görüntüde okunabilir MRZ yok. Daha net bir fotoğraf deneyin.';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Taranan $count sayfa silinsin mi?',
      one: 'Taranan 1 sayfa silinsin mi?',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'Taramaya devam et';

  @override
  String get discard => 'Sil';

  @override
  String get flashOn => 'Flaş açık';

  @override
  String get flashOff => 'Flaş kapalı';

  @override
  String get showGrid => 'Izgarayı göster';

  @override
  String get hideGrid => 'Izgarayı gizle';

  @override
  String get autoCaptureOn => 'Otomatik çekim açık';

  @override
  String get autoCaptureOff => 'Otomatik çekim kapalı';

  @override
  String get autoBadge => 'OTO';

  @override
  String bookChipLeft(int page) {
    return 'Sol · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'Sağ · $page';
  }

  @override
  String get pointAtSurfaceFirst => 'Önce daireyi bir yüzeye doğrultun';

  @override
  String get idSideFront => '1  Ön yüz';

  @override
  String get idSideBack => '2  Arka yüz';

  @override
  String get pillQr => 'Bir QR koduna veya barkoda doğrultun';

  @override
  String get pillCount => 'Nesnelere doğrultun, sonra deklanşöre dokunun';

  @override
  String get pillMathOff =>
      'Matematik çözmek için AI gerekir, ancak ayarlanmamış';

  @override
  String get pillMath =>
      'Bir matematik sorusuna doğrultun, sonra deklanşöre dokunun';

  @override
  String get pillMrzDetected => 'MRZ algılandı · Sabit tutun';

  @override
  String get pillPassport => 'Fotoğraflı sayfayı çerçevenin içine yerleştirin';

  @override
  String get pillIdFrontSaved => 'Ön yüz kaydedildi · Kartı çevirin';

  @override
  String get pillSaved => 'Kaydedildi';

  @override
  String get pillIdBack => 'Şimdi arka yüzü tarayın';

  @override
  String get pillIdFit => 'Kartı çerçevenin içine sığdırın';

  @override
  String get pillCardDetected => 'Kart algılandı · Sabit tutun';

  @override
  String get pillBook => 'Açık bir kitaba doğrultun';

  @override
  String get pillBookAuto => 'Kitap algılandı · Sayfalar otomatik ayrılır';

  @override
  String get pillBookTap => 'Kitap algılandı · Çekmek için dokunun';

  @override
  String get pillCaptured => 'Çekildi · Sonraki sayfayı yerleştirin';

  @override
  String get pillDocument => 'Bir belgeye doğrultun';

  @override
  String get pillDocumentAuto => 'Belge algılandı · Sabit tutun';

  @override
  String get pillDocumentTap => 'Belge algılandı · Çekmek için dokunun';

  @override
  String get cameraOffTitle => 'Kamera erişimi kapalı';

  @override
  String get cameraOffBody => 'Belge taramak için kamera erişimine izin verin.';

  @override
  String get arUnsupportedTitle => 'AR bu telefonda kullanılamıyor';

  @override
  String get arUnsupportedBody =>
      'Ölçüm için AR için Google Play Hizmetleri gerekir.';

  @override
  String get arInstallTitle => 'AR desteğini yükleyin';

  @override
  String get arInstallBody =>
      'AR için Google Play Hizmetleri\'ni yüklemeyi tamamlayıp tekrar deneyin.';

  @override
  String get arFailedTitle => 'AR başlatılamadı';

  @override
  String get arFailedBody => 'AR kamerası başlatılırken bir sorun oluştu.';

  @override
  String get cameraFailedTitle => 'Kamera kullanılamıyor';

  @override
  String get cameraFailedBody => 'Kamera başlatılırken bir sorun oluştu.';

  @override
  String get importFromGallery => 'Galeriden içe aktar';

  @override
  String get capture => 'Çek';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sayfayı incele',
      one: '1 sayfayı incele',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'Bağlantıyı aç';

  @override
  String get sendEmail => 'E-posta gönder';

  @override
  String get call => 'Ara';

  @override
  String get sendMessage => 'Mesaj';

  @override
  String get openMap => 'Haritayı aç';

  @override
  String get copyPassword => 'Şifreyi kopyala';

  @override
  String get passwordCopied => 'Şifre kopyalandı';

  @override
  String get copyFailed => 'Kopyalanamadı. Tekrar deneyin.';

  @override
  String get noAppCanOpen => 'Bu telefonda bunu açabilecek bir uygulama yok.';

  @override
  String get shareFailed => 'Paylaşım açılamadı. Tekrar deneyin.';

  @override
  String get qrSaveFailed => 'QR kodu kaydedilemedi. Tekrar deneyin.';

  @override
  String get qrTooLong =>
      'QR kodu olarak gösterilemeyecek kadar uzun. İçeriğin tamamı aşağıda.';

  @override
  String get qrGenerated => 'Taranan içerikten oluşturuldu';

  @override
  String get password => 'Şifre';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get codeEmpty => 'Bu kod boş';

  @override
  String get codeEmptyBody => 'Gösterilecek bir şey yok.';

  @override
  String get codeUnreadable => 'Bu kod okunamadı';

  @override
  String get codeNotText => 'Metin olmayan veriler içeriyor.';

  @override
  String get scanAgain => 'Tekrar tara';

  @override
  String get qrCodeImage => 'QR kodu';

  @override
  String qrCardTitle(String kind) {
    return 'QR kodu · $kind';
  }

  @override
  String get qrCardContent => 'İçerik';

  @override
  String get scannedWithDocScan => 'DocScan ile tarandı';

  @override
  String get anotherMath => 'Başka bir soru çöz';

  @override
  String get anotherQr => 'Başka bir kod tara';

  @override
  String get anotherArea => 'Başka bir alan ölç';

  @override
  String get anotherCount => 'Daha fazla nesne say';

  @override
  String get addAnother => 'Bir tane daha ekle';

  @override
  String get addedToScan => 'Taramanıza eklendi';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · şu ana kadar $count sayfa',
      one: '$title · şu ana kadar 1 sayfa',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'Web sitesi';

  @override
  String get qrLink => 'Bağlantı';

  @override
  String get qrPhone => 'Telefon';

  @override
  String get qrNumber => 'Numara';

  @override
  String get qrText => 'Metin';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'Gizli ağ';

  @override
  String get qrNetwork => 'Ağ';

  @override
  String get qrNoName => '(adsız)';

  @override
  String get qrSecurity => 'Güvenlik';

  @override
  String get qrSecurityOpen => 'Yok (açık)';

  @override
  String get qrSecurityUnspecified => 'Belirtilmemiş';

  @override
  String get qrHidden => 'Gizli';

  @override
  String get qrYes => 'Evet';

  @override
  String get qrEapMethod => 'EAP yöntemi';

  @override
  String get qrIdentity => 'Kimlik';

  @override
  String get qrEmail => 'E-posta';

  @override
  String get qrTo => 'Alıcı';

  @override
  String get qrSubject => 'Konu';

  @override
  String get qrMessage => 'Mesaj';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'Konum';

  @override
  String get qrCoordinates => 'Koordinatlar';

  @override
  String get qrPlace => 'Yer';

  @override
  String get qrAltitude => 'Rakım';

  @override
  String get qrContact => 'Kişi';

  @override
  String get qrContactCard => 'Kartvizit';

  @override
  String get qrName => 'Ad';

  @override
  String get qrOrganization => 'Kuruluş';

  @override
  String get qrJobTitle => 'Unvan';

  @override
  String get qrAddress => 'Adres';

  @override
  String get qrNote => 'Not';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'Bu çözülemedi';

  @override
  String get mathSaveFailed => 'Çözüm kaydedilemedi. Tekrar deneyin.';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count adım',
      one: '1 adım',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'AI ile çözüldü';

  @override
  String get mathAnswer => 'Yanıt';

  @override
  String mathCopyProblem(String problem) {
    return 'Soru: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'Yanıt: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'Matematik · $answer';
  }

  @override
  String get mathCardTitle => 'MATEMATİK ÇÖZÜMÜ';

  @override
  String get mathCardContinued => 'MATEMATİK ÇÖZÜMÜ · DEVAMI';

  @override
  String get mathCardProblem => 'SORU';

  @override
  String get mathCardSteps => 'ADIMLAR';

  @override
  String get solvingWithAiLabel => 'AI ile çözülüyor';

  @override
  String get solvingWithAi => 'AI ile çözülüyor…';

  @override
  String get solvingDetail => 'Soru okunuyor ve her adım kontrol ediliyor';

  @override
  String get exportFailed => 'PDF dışa aktarılamadı';

  @override
  String bookPagesTitle(int first, int last) {
    return 'Sayfa $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'Sayfa $page';
  }

  @override
  String get splitIntoTwo => 'İki sayfaya böl';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count çift sayfa tarandı · $pages sayfa',
      one: '1 çift sayfa tarandı · $pages sayfa',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'Sonraki çift sayfa';

  @override
  String get saveBook => 'Kitabı kaydet';

  @override
  String get idCardTitle => 'Kimlik Kartı';

  @override
  String get passportTitle => 'Pasaport';

  @override
  String get idDocumentTitle => 'Kimlik Belgesi';

  @override
  String get layoutStacked => 'Alt alta';

  @override
  String get layoutSideBySide => 'Yan yana';

  @override
  String get layoutSeparate => 'Ayrı';

  @override
  String get fullName => 'Ad soyad';

  @override
  String get idNumber => 'Kimlik numarası';

  @override
  String get dateOfBirth => 'Doğum tarihi';

  @override
  String get extractedDetails => 'Çıkarılan bilgiler';

  @override
  String get copyAllLower => 'Tümünü kopyala';

  @override
  String get copyAll => 'Tümünü Kopyala';

  @override
  String get detailsCopied => 'Bilgiler kopyalandı';

  @override
  String get readingCard => 'Kart okunuyor…';

  @override
  String get noMrzOnCard =>
      'Bu kartta makinece okunabilir bölge yok, bu yüzden doğrulanmış bilgi çıkarılamıyor. Tarama olduğu gibi kaydedildi.';

  @override
  String copyField(String label) {
    return 'Kopyala: $label';
  }

  @override
  String fieldCopied(String label) {
    return '$label kopyalandı';
  }

  @override
  String get passportNo => 'Pasaport no.';

  @override
  String get documentNo => 'Belge no.';

  @override
  String get nationality => 'Uyruk';

  @override
  String get sex => 'Cinsiyet';

  @override
  String get issuingCountry => 'Veren ülke';

  @override
  String get expires => 'Son geçerlilik';

  @override
  String expiredOn(String date) {
    return 'Süresi doldu: $date';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yıl daha geçerli',
      one: '1 yıl daha geçerli',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ay daha geçerli',
      one: '1 ay daha geçerli',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'Süresi bir aydan kısa sürede doluyor';

  @override
  String get mrzVerified => 'MRZ doğrulandı';

  @override
  String pageDeleted(int page) {
    return 'Sayfa $page silindi';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sayfa silindi',
      one: '1 sayfa silindi',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'Kamera';

  @override
  String get addFromPhotos => 'Fotoğraflar';

  @override
  String selectedCount(int count) {
    return '$count seçildi';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sayfa',
      one: '1 Sayfa',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Seç';

  @override
  String get tapToSelect => 'Seçmek için sayfalara dokunun';

  @override
  String get dragToReorder =>
      'Sayfaları yeniden sıralamak için basılı tutup sürükleyin';

  @override
  String get rotateSelected => 'Seçilenleri döndür';

  @override
  String get delete => 'Sil';

  @override
  String deleteCount(int count) {
    return 'Sil ($count)';
  }

  @override
  String get editPages => 'Sayfaları düzenle';

  @override
  String get saveAsPdf => 'PDF olarak kaydet';

  @override
  String rotatePage(int page) {
    return 'Sayfa $page: döndür';
  }

  @override
  String deletePage(int page) {
    return 'Sayfa $page: sil';
  }

  @override
  String get addPage => 'Sayfa ekle';

  @override
  String get cameraOrPhotos => 'Kamera veya Fotoğraflar';

  @override
  String get filterOriginal => 'Orijinal';

  @override
  String get filterMagic => 'Sihirli';

  @override
  String get filterBw => 'S & B';

  @override
  String get filterGray => 'Gri';

  @override
  String get filterNoShadow => 'Gölgesiz';

  @override
  String get filterColor => 'Renkli';

  @override
  String get adjustCrop => 'Kırpmayı ayarla';

  @override
  String get reset => 'Sıfırla';

  @override
  String get rotate => 'Döndür';

  @override
  String get cropAuto => 'Otomatik';

  @override
  String get cropPerspective => 'Perspektif';

  @override
  String get cropFullPage => 'Tam sayfa';

  @override
  String get enhance => 'İyileştir';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter filtresi $count sayfanın tümüne uygulandı';
  }

  @override
  String get brightness => 'Parlaklık';

  @override
  String get contrast => 'Kontrast';

  @override
  String get applyToAll => 'Tümüne uygula';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed => 'Sonuç kaydedilemedi. Tekrar deneyin.';

  @override
  String get objectCount => 'Nesne sayısı';

  @override
  String get countedWithDocScan => 'DocScan ile sayıldı';

  @override
  String countPageLabel(int count) {
    return 'Sayım: $count';
  }

  @override
  String countAdded(int count) {
    return '$count eklendi';
  }

  @override
  String countRemoved(int count) {
    return '$count çıkarıldı';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'nesne',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'Tür';

  @override
  String get roundObjects => 'Yuvarlak nesneler';

  @override
  String get boxes => 'Kutular';

  @override
  String get custom => 'Özel';

  @override
  String get matchedToSample => 'dokunulan örnekle eşleştirildi';

  @override
  String get countAutomatic => 'Otomatik';

  @override
  String get countByHand => 'Elle';

  @override
  String get noChanges => 'Değişiklik yok';

  @override
  String get tapOneObject => 'Benzerlerini saymak için bir nesneye dokunun';

  @override
  String get objectsDetected => 'Algılanan nesneler';

  @override
  String get removeOne => 'Bir tane çıkar';

  @override
  String get addOne => 'Bir tane ekle';

  @override
  String get saveResult => 'Sonucu kaydet';

  @override
  String get areaMeasurement => 'Alan ölçümü';

  @override
  String get measuredNote => 'DocScan AR ile ölçüldü · yakl. ±%5';

  @override
  String areaTitle(String area) {
    return 'Alan · $area';
  }

  @override
  String get area => 'Alan';

  @override
  String get perimeter => 'Çevre';

  @override
  String get sides => 'Kenarlar';

  @override
  String get points => 'Noktalar';

  @override
  String summaryArea(String area) {
    return 'Alan $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nokta',
      one: '1 nokta',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head. Kenarlar $sides';
  }

  @override
  String get hintStartingAr => 'AR başlatılıyor…';

  @override
  String get hintTooDark => 'Çok karanlık · Flaşı açın';

  @override
  String get hintMoveSlower => 'Telefonunuzu daha yavaş hareket ettirin';

  @override
  String get hintMoreDetail => 'Daha fazla ayrıntı içeren bir yüzeye doğrultun';

  @override
  String get hintFindSurface =>
      'Yüzey bulmak için telefonunuzu yavaşça hareket ettirin';

  @override
  String get hintDragCorner => 'Ayarlamak için bir köşeyi sürükleyin';

  @override
  String get hintPointCircle => 'Daireyi bir yüzeye doğrultun';

  @override
  String get hintAimBack => 'Aynı yüzeye tekrar doğrultun';

  @override
  String get hintTapToDrop => 'Nokta bırakmak için + simgesine dokunun';

  @override
  String get hintNextCorner =>
      'Sonraki köşeyi eklemek için + simgesine dokunun';

  @override
  String get hintClose => 'Şekli kapatmak için ilk noktaya dokunun';

  @override
  String get savingMeasurement => 'Ölçüm kaydediliyor';

  @override
  String get saveMeasurement => 'Ölçümü kaydet';

  @override
  String get newMeasurement => 'Yeni ölçüm';

  @override
  String get addPoint => 'Nokta ekle';

  @override
  String get meters => 'Metre';

  @override
  String get feet => 'Fit';
}
