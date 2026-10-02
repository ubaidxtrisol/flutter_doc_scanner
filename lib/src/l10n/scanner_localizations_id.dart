// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class ScannerLocalizationsId extends ScannerLocalizations {
  ScannerLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get undo => 'Urungkan';

  @override
  String get cancel => 'Batal';

  @override
  String get done => 'Selesai';

  @override
  String get next => 'Berikutnya';

  @override
  String get retry => 'Coba lagi';

  @override
  String get retake => 'Ambil ulang';

  @override
  String get review => 'Tinjau';

  @override
  String get copy => 'Salin';

  @override
  String get copied => 'Disalin';

  @override
  String get share => 'Bagikan';

  @override
  String get saving => 'Menyimpan…';

  @override
  String get saveToDocuments => 'Simpan ke Dokumen';

  @override
  String get savePdf => 'Simpan PDF';

  @override
  String get sharePdf => 'Bagikan PDF';

  @override
  String get settings => 'Setelan';

  @override
  String get openSettings => 'Buka Setelan';

  @override
  String get tryAgain => 'Coba lagi';

  @override
  String pageOf(int page, int total) {
    return 'Halaman $page dari $total';
  }

  @override
  String detailLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get tabDocument => 'Dokumen';

  @override
  String get tabIdCard => 'Kartu ID';

  @override
  String get tabPassport => 'Paspor';

  @override
  String get tabBook => 'Buku';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'Matematika';

  @override
  String get tabCount => 'Hitung';

  @override
  String get tabMeasure => 'Ukur';

  @override
  String get titleScanQr => 'Pindai QR';

  @override
  String get titleCountObjects => 'Hitung Objek';

  @override
  String get pageLabelPassport => 'Paspor';

  @override
  String get pageLabelIdDocument => 'Dokumen ID';

  @override
  String get pageLabelIdFront => 'ID depan';

  @override
  String get pageLabelIdBack => 'ID belakang';

  @override
  String get pageLabelLeft => 'Kiri';

  @override
  String get pageLabelRight => 'Kanan';

  @override
  String get pageLabelSpread => 'Dua halaman';

  @override
  String get pageLabelMath => 'Matematika';

  @override
  String get pageLabelArea => 'Luas';

  @override
  String defaultTitle(String date) {
    return 'Pindaian $date';
  }

  @override
  String get titleMathSolutions => 'Solusi matematika';

  @override
  String get titleQrCodes => 'Kode QR';

  @override
  String get titleAreaMeasurements => 'Pengukuran luas';

  @override
  String get titleCountResults => 'Hasil hitungan';

  @override
  String get mathNeedsAi =>
      'Menyelesaikan soal matematika memerlukan AI, yang belum disiapkan di aplikasi ini.';

  @override
  String get mathNoAnswer =>
      'Pemecah soal tidak menemukan jawaban. Coba foto yang lebih jelas.';

  @override
  String captureFailed(String message) {
    return 'Gagal mengambil gambar: $message';
  }

  @override
  String get measureCaptureFailed =>
      'Tidak dapat mengambil pengukuran. Coba lagi.';

  @override
  String get measureCameraStopped => 'Kamera berhenti. Coba lagi.';

  @override
  String get measureShapeChanged =>
      'Bentuknya berubah. Tutup lagi bentuknya, lalu simpan.';

  @override
  String get photoAccessDenied =>
      'Izinkan akses foto di Setelan untuk mengimpor.';

  @override
  String get imageUnreadable =>
      'Tidak dapat membaca gambar itu. Coba gambar lain.';

  @override
  String get imageOpenFailed =>
      'Tidak dapat membuka gambar itu. Coba gambar lain.';

  @override
  String get noCodeInImage => 'Tidak ada kode di gambar itu';

  @override
  String get noMrzInImage =>
      'Tidak ada MRZ yang dapat dibaca di gambar itu. Coba foto yang lebih tajam.';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Buang $count halaman yang dipindai?',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'Lanjutkan memindai';

  @override
  String get discard => 'Buang';

  @override
  String get flashOn => 'Lampu kilat aktif';

  @override
  String get flashOff => 'Lampu kilat nonaktif';

  @override
  String get showGrid => 'Tampilkan kisi';

  @override
  String get hideGrid => 'Sembunyikan kisi';

  @override
  String get autoCaptureOn => 'Ambil otomatis aktif';

  @override
  String get autoCaptureOff => 'Ambil otomatis nonaktif';

  @override
  String get autoBadge => 'OTOMATIS';

  @override
  String bookChipLeft(int page) {
    return 'Kiri · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'Kanan · $page';
  }

  @override
  String get pointAtSurfaceFirst =>
      'Arahkan lingkaran ke permukaan terlebih dahulu';

  @override
  String get idSideFront => '1  Sisi depan';

  @override
  String get idSideBack => '2  Sisi belakang';

  @override
  String get pillQr => 'Arahkan ke kode QR atau barcode';

  @override
  String get pillCount => 'Arahkan ke objek, lalu ketuk tombol rana';

  @override
  String get pillMathOff =>
      'Menyelesaikan soal matematika memerlukan AI, yang belum disiapkan';

  @override
  String get pillMath => 'Arahkan ke soal matematika, lalu ketuk tombol rana';

  @override
  String get pillMrzDetected => 'MRZ terdeteksi · Tahan dengan stabil';

  @override
  String get pillPassport => 'Letakkan halaman foto di dalam bingkai';

  @override
  String get pillIdFrontSaved => 'Sisi depan disimpan · Balik kartunya';

  @override
  String get pillSaved => 'Disimpan';

  @override
  String get pillIdBack => 'Sekarang pindai sisi belakang';

  @override
  String get pillIdFit => 'Paskan kartu di dalam bingkai';

  @override
  String get pillCardDetected => 'Kartu terdeteksi · Tahan dengan diam';

  @override
  String get pillBook => 'Arahkan ke buku yang terbuka';

  @override
  String get pillBookAuto => 'Buku terdeteksi · Halaman dipisahkan otomatis';

  @override
  String get pillBookTap => 'Buku terdeteksi · Ketuk untuk mengambil';

  @override
  String get pillCaptured => 'Diambil · Letakkan halaman berikutnya';

  @override
  String get pillDocument => 'Arahkan ke dokumen';

  @override
  String get pillDocumentAuto => 'Dokumen terdeteksi · Tahan dengan diam';

  @override
  String get pillDocumentTap => 'Dokumen terdeteksi · Ketuk untuk mengambil';

  @override
  String get cameraOffTitle => 'Akses kamera nonaktif';

  @override
  String get cameraOffBody => 'Izinkan akses kamera untuk memindai dokumen.';

  @override
  String get arUnsupportedTitle => 'AR tidak tersedia di ponsel ini';

  @override
  String get arUnsupportedBody =>
      'Pengukuran memerlukan Layanan Google Play untuk AR.';

  @override
  String get arInstallTitle => 'Instal dukungan AR';

  @override
  String get arInstallBody =>
      'Selesaikan penginstalan Layanan Google Play untuk AR, lalu coba lagi.';

  @override
  String get arFailedTitle => 'AR tidak dapat dimulai';

  @override
  String get arFailedBody => 'Terjadi kesalahan saat memulai kamera AR.';

  @override
  String get cameraFailedTitle => 'Kamera tidak tersedia';

  @override
  String get cameraFailedBody => 'Terjadi kesalahan saat memulai kamera.';

  @override
  String get importFromGallery => 'Impor dari galeri';

  @override
  String get capture => 'Ambil';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tinjau $count halaman',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'Buka Tautan';

  @override
  String get sendEmail => 'Kirim Email';

  @override
  String get call => 'Telepon';

  @override
  String get sendMessage => 'SMS';

  @override
  String get openMap => 'Buka Peta';

  @override
  String get copyPassword => 'Salin Sandi';

  @override
  String get passwordCopied => 'Sandi Disalin';

  @override
  String get copyFailed => 'Tidak dapat menyalin. Coba lagi.';

  @override
  String get noAppCanOpen =>
      'Tidak ada aplikasi di ponsel ini yang dapat membukanya.';

  @override
  String get shareFailed => 'Tidak dapat membuka berbagi. Coba lagi.';

  @override
  String get qrSaveFailed => 'Tidak dapat menyimpan kode QR. Coba lagi.';

  @override
  String get qrTooLong =>
      'Terlalu panjang untuk ditampilkan sebagai kode QR. Isi lengkapnya ada di bawah.';

  @override
  String get qrGenerated => 'Dibuat dari isi yang dipindai';

  @override
  String get password => 'Sandi';

  @override
  String get showPassword => 'Tampilkan sandi';

  @override
  String get hidePassword => 'Sembunyikan sandi';

  @override
  String get codeEmpty => 'Kode ini kosong';

  @override
  String get codeEmptyBody => 'Tidak ada isi yang dapat ditampilkan.';

  @override
  String get codeUnreadable => 'Tidak dapat membaca kode ini';

  @override
  String get codeNotText => 'Kode ini berisi data yang bukan teks.';

  @override
  String get scanAgain => 'Pindai Lagi';

  @override
  String get qrCodeImage => 'Kode QR';

  @override
  String qrCardTitle(String kind) {
    return 'Kode QR · $kind';
  }

  @override
  String get qrCardContent => 'Isi';

  @override
  String get scannedWithDocScan => 'Dipindai dengan DocScan';

  @override
  String get anotherMath => 'Selesaikan soal lain';

  @override
  String get anotherQr => 'Pindai kode lain';

  @override
  String get anotherArea => 'Ukur luas lain';

  @override
  String get anotherCount => 'Hitung objek lain';

  @override
  String get addAnother => 'Tambah lagi';

  @override
  String get addedToScan => 'Ditambahkan ke pindaian Anda';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · $count halaman sejauh ini',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'Situs web';

  @override
  String get qrLink => 'Tautan';

  @override
  String get qrPhone => 'Telepon';

  @override
  String get qrNumber => 'Nomor';

  @override
  String get qrText => 'Teks';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'Jaringan tersembunyi';

  @override
  String get qrNetwork => 'Jaringan';

  @override
  String get qrNoName => '(tanpa nama)';

  @override
  String get qrSecurity => 'Keamanan';

  @override
  String get qrSecurityOpen => 'Tidak ada (terbuka)';

  @override
  String get qrSecurityUnspecified => 'Tidak ditentukan';

  @override
  String get qrHidden => 'Tersembunyi';

  @override
  String get qrYes => 'Ya';

  @override
  String get qrEapMethod => 'Metode EAP';

  @override
  String get qrIdentity => 'Identitas';

  @override
  String get qrEmail => 'Email';

  @override
  String get qrTo => 'Kepada';

  @override
  String get qrSubject => 'Subjek';

  @override
  String get qrMessage => 'Pesan';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'Lokasi';

  @override
  String get qrCoordinates => 'Koordinat';

  @override
  String get qrPlace => 'Tempat';

  @override
  String get qrAltitude => 'Ketinggian';

  @override
  String get qrContact => 'Kontak';

  @override
  String get qrContactCard => 'Kartu kontak';

  @override
  String get qrName => 'Nama';

  @override
  String get qrOrganization => 'Organisasi';

  @override
  String get qrJobTitle => 'Jabatan';

  @override
  String get qrAddress => 'Alamat';

  @override
  String get qrNote => 'Catatan';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'Tidak dapat menyelesaikan soal ini';

  @override
  String get mathSaveFailed => 'Tidak dapat menyimpan solusi. Coba lagi.';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count langkah',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'Diselesaikan dengan AI';

  @override
  String get mathAnswer => 'Jawaban';

  @override
  String mathCopyProblem(String problem) {
    return 'Soal: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'Jawaban: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'Matematika · $answer';
  }

  @override
  String get mathCardTitle => 'SOLUSI MATEMATIKA';

  @override
  String get mathCardContinued => 'SOLUSI MATEMATIKA · LANJUTAN';

  @override
  String get mathCardProblem => 'SOAL';

  @override
  String get mathCardSteps => 'LANGKAH';

  @override
  String get solvingWithAiLabel => 'Menyelesaikan dengan AI';

  @override
  String get solvingWithAi => 'Menyelesaikan dengan AI…';

  @override
  String get solvingDetail => 'Membaca soal dan memeriksa setiap langkah';

  @override
  String get exportFailed => 'Tidak dapat mengekspor PDF';

  @override
  String bookPagesTitle(int first, int last) {
    return 'Halaman $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'Halaman $page';
  }

  @override
  String get splitIntoTwo => 'Pisahkan menjadi dua halaman';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bentangan dipindai · $pages halaman',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'Bentangan Berikutnya';

  @override
  String get saveBook => 'Simpan Buku';

  @override
  String get idCardTitle => 'Kartu ID';

  @override
  String get passportTitle => 'Paspor';

  @override
  String get idDocumentTitle => 'Dokumen ID';

  @override
  String get layoutStacked => 'Bertumpuk';

  @override
  String get layoutSideBySide => 'Berdampingan';

  @override
  String get layoutSeparate => 'Terpisah';

  @override
  String get fullName => 'Nama lengkap';

  @override
  String get idNumber => 'Nomor ID';

  @override
  String get dateOfBirth => 'Tanggal lahir';

  @override
  String get extractedDetails => 'Detail yang diekstrak';

  @override
  String get copyAllLower => 'Salin semua';

  @override
  String get copyAll => 'Salin Semua';

  @override
  String get detailsCopied => 'Detail disalin';

  @override
  String get readingCard => 'Membaca kartu…';

  @override
  String get noMrzOnCard =>
      'Kartu ini tidak memiliki zona yang dapat dibaca mesin, jadi tidak ada data terverifikasi yang dapat diekstrak. Pindaian disimpan apa adanya.';

  @override
  String copyField(String label) {
    return 'Salin $label';
  }

  @override
  String fieldCopied(String label) {
    return '$label disalin';
  }

  @override
  String get passportNo => 'No. paspor';

  @override
  String get documentNo => 'No. dokumen';

  @override
  String get nationality => 'Kewarganegaraan';

  @override
  String get sex => 'Jenis kelamin';

  @override
  String get issuingCountry => 'Negara penerbit';

  @override
  String get expires => 'Berlaku hingga';

  @override
  String expiredOn(String date) {
    return 'Kedaluwarsa pada $date';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Berlaku $count tahun lagi',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Berlaku $count bulan lagi',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'Kedaluwarsa dalam kurang dari sebulan';

  @override
  String get mrzVerified => 'MRZ terverifikasi';

  @override
  String pageDeleted(int page) {
    return 'Halaman $page dihapus';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count halaman dihapus',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'Kamera';

  @override
  String get addFromPhotos => 'Foto';

  @override
  String selectedCount(int count) {
    return '$count Dipilih';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Halaman',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Pilih';

  @override
  String get tapToSelect => 'Ketuk halaman untuk memilihnya';

  @override
  String get dragToReorder =>
      'Tekan lama dan seret untuk mengurutkan ulang halaman';

  @override
  String get rotateSelected => 'Putar yang dipilih';

  @override
  String get delete => 'Hapus';

  @override
  String deleteCount(int count) {
    return 'Hapus $count';
  }

  @override
  String get editPages => 'Edit halaman';

  @override
  String get saveAsPdf => 'Simpan sebagai PDF';

  @override
  String rotatePage(int page) {
    return 'Putar halaman $page';
  }

  @override
  String deletePage(int page) {
    return 'Hapus halaman $page';
  }

  @override
  String get addPage => 'Tambah halaman';

  @override
  String get cameraOrPhotos => 'Kamera atau Foto';

  @override
  String get filterOriginal => 'Asli';

  @override
  String get filterMagic => 'Ajaib';

  @override
  String get filterBw => 'H & P';

  @override
  String get filterGray => 'Abu-abu';

  @override
  String get filterNoShadow => 'Tanpa Bayangan';

  @override
  String get filterColor => 'Warna';

  @override
  String get adjustCrop => 'Sesuaikan Potongan';

  @override
  String get reset => 'Reset';

  @override
  String get rotate => 'Putar';

  @override
  String get cropAuto => 'Otomatis';

  @override
  String get cropPerspective => 'Perspektif';

  @override
  String get cropFullPage => 'Halaman penuh';

  @override
  String get enhance => 'Sempurnakan';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter diterapkan ke semua $count halaman';
  }

  @override
  String get brightness => 'Kecerahan';

  @override
  String get contrast => 'Kontras';

  @override
  String get applyToAll => 'Terapkan ke semua';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed => 'Tidak dapat menyimpan hasil. Coba lagi.';

  @override
  String get objectCount => 'Jumlah objek';

  @override
  String get countedWithDocScan => 'Dihitung dengan DocScan';

  @override
  String countPageLabel(int count) {
    return 'Jumlah: $count';
  }

  @override
  String countAdded(int count) {
    return '$count ditambahkan';
  }

  @override
  String countRemoved(int count) {
    return '$count dihapus';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'objek',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'Jenis';

  @override
  String get roundObjects => 'Objek bulat';

  @override
  String get boxes => 'Kotak';

  @override
  String get custom => 'Kustom';

  @override
  String get matchedToSample => 'dicocokkan dengan sampel yang diketuk';

  @override
  String get countAutomatic => 'Otomatis';

  @override
  String get countByHand => 'Manual';

  @override
  String get noChanges => 'Tidak ada perubahan';

  @override
  String get tapOneObject =>
      'Ketuk satu objek untuk menghitung objek yang serupa';

  @override
  String get objectsDetected => 'Objek terdeteksi';

  @override
  String get removeOne => 'Kurangi satu';

  @override
  String get addOne => 'Tambah satu';

  @override
  String get saveResult => 'Simpan Hasil';

  @override
  String get areaMeasurement => 'Pengukuran luas';

  @override
  String get measuredNote => 'Diukur dengan DocScan AR · kira-kira ±5%';

  @override
  String areaTitle(String area) {
    return 'Luas · $area';
  }

  @override
  String get area => 'Luas';

  @override
  String get perimeter => 'Keliling';

  @override
  String get sides => 'Sisi';

  @override
  String get points => 'Titik';

  @override
  String summaryArea(String area) {
    return 'Luas $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titik',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head. Sisi $sides';
  }

  @override
  String get hintStartingAr => 'Memulai AR…';

  @override
  String get hintTooDark => 'Terlalu gelap · Nyalakan lampu kilat';

  @override
  String get hintMoveSlower => 'Gerakkan ponsel lebih lambat';

  @override
  String get hintMoreDetail =>
      'Arahkan ke permukaan yang lebih banyak detailnya';

  @override
  String get hintFindSurface =>
      'Gerakkan ponsel perlahan untuk menemukan permukaan';

  @override
  String get hintDragCorner => 'Seret sudut untuk menyesuaikan';

  @override
  String get hintPointCircle => 'Arahkan lingkaran ke permukaan';

  @override
  String get hintAimBack => 'Arahkan kembali ke permukaan yang sama';

  @override
  String get hintTapToDrop => 'Ketuk + untuk menempatkan titik';

  @override
  String get hintNextCorner => 'Ketuk + untuk menambahkan sudut berikutnya';

  @override
  String get hintClose => 'Ketuk titik pertama untuk menutup bentuk';

  @override
  String get savingMeasurement => 'Menyimpan pengukuran';

  @override
  String get saveMeasurement => 'Simpan pengukuran';

  @override
  String get newMeasurement => 'Pengukuran baru';

  @override
  String get addPoint => 'Tambah titik';

  @override
  String get meters => 'Meter';

  @override
  String get feet => 'Kaki';
}
