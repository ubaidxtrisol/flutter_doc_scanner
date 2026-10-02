// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class ScannerLocalizationsRu extends ScannerLocalizations {
  ScannerLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get undo => 'Отменить';

  @override
  String get cancel => 'Отмена';

  @override
  String get done => 'Готово';

  @override
  String get next => 'Далее';

  @override
  String get retry => 'Повторить';

  @override
  String get retake => 'Переснять';

  @override
  String get review => 'Просмотр';

  @override
  String get copy => 'Копировать';

  @override
  String get copied => 'Скопировано';

  @override
  String get share => 'Поделиться';

  @override
  String get saving => 'Сохранение…';

  @override
  String get saveToDocuments => 'Сохранить в документы';

  @override
  String get savePdf => 'Сохранить PDF';

  @override
  String get sharePdf => 'Поделиться PDF';

  @override
  String get settings => 'Настройки';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get tryAgain => 'Повторить';

  @override
  String pageOf(int page, int total) {
    return 'Страница $page из $total';
  }

  @override
  String detailLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get tabDocument => 'Документ';

  @override
  String get tabIdCard => 'Удостов.';

  @override
  String get tabPassport => 'Паспорт';

  @override
  String get tabBook => 'Книга';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'Матем.';

  @override
  String get tabCount => 'Подсчёт';

  @override
  String get tabMeasure => 'Замер';

  @override
  String get titleScanQr => 'Сканировать QR';

  @override
  String get titleCountObjects => 'Подсчёт предметов';

  @override
  String get pageLabelPassport => 'Паспорт';

  @override
  String get pageLabelIdDocument => 'Удостоверение';

  @override
  String get pageLabelIdFront => 'Лицевая сторона';

  @override
  String get pageLabelIdBack => 'Оборотная сторона';

  @override
  String get pageLabelLeft => 'Левая';

  @override
  String get pageLabelRight => 'Правая';

  @override
  String get pageLabelSpread => 'Разворот';

  @override
  String get pageLabelMath => 'Математика';

  @override
  String get pageLabelArea => 'Площадь';

  @override
  String defaultTitle(String date) {
    return 'Скан $date';
  }

  @override
  String get titleMathSolutions => 'Решения задач';

  @override
  String get titleQrCodes => 'QR-коды';

  @override
  String get titleAreaMeasurements => 'Измерения площади';

  @override
  String get titleCountResults => 'Результаты подсчёта';

  @override
  String get mathNeedsAi =>
      'Для решения задач нужен AI, который не настроен в этом приложении.';

  @override
  String get mathNoAnswer =>
      'Не удалось найти ответ. Попробуйте более чёткое фото.';

  @override
  String captureFailed(String message) {
    return 'Не удалось сделать снимок: $message';
  }

  @override
  String get measureCaptureFailed =>
      'Не удалось сохранить измерение. Повторите попытку.';

  @override
  String get measureCameraStopped => 'Камера остановилась. Повторите попытку.';

  @override
  String get measureShapeChanged =>
      'Фигура изменилась. Замкните её снова и сохраните.';

  @override
  String get photoAccessDenied =>
      'Чтобы импортировать, разрешите доступ к фото в настройках.';

  @override
  String get imageUnreadable =>
      'Не удалось прочитать изображение. Попробуйте другое.';

  @override
  String get imageOpenFailed =>
      'Не удалось открыть изображение. Попробуйте другое.';

  @override
  String get noCodeInImage => 'На изображении не найден код';

  @override
  String get noMrzInImage =>
      'На изображении нет читаемой MRZ. Попробуйте более чёткое фото.';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count отсканированные страницы?',
      many: 'Удалить $count отсканированных страниц?',
      few: 'Удалить $count отсканированные страницы?',
      one: 'Удалить $count отсканированную страницу?',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'Продолжить сканирование';

  @override
  String get discard => 'Удалить';

  @override
  String get flashOn => 'Вспышка вкл.';

  @override
  String get flashOff => 'Вспышка выкл.';

  @override
  String get showGrid => 'Показать сетку';

  @override
  String get hideGrid => 'Скрыть сетку';

  @override
  String get autoCaptureOn => 'Автосъёмка вкл.';

  @override
  String get autoCaptureOff => 'Автосъёмка выкл.';

  @override
  String get autoBadge => 'АВТО';

  @override
  String bookChipLeft(int page) {
    return 'Левая · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'Правая · $page';
  }

  @override
  String get pointAtSurfaceFirst => 'Сначала наведите круг на поверхность';

  @override
  String get idSideFront => '1  Лицевая сторона';

  @override
  String get idSideBack => '2  Оборотная сторона';

  @override
  String get pillQr => 'Наведите на QR-код или штрихкод';

  @override
  String get pillCount => 'Наведите на предметы и нажмите на затвор';

  @override
  String get pillMathOff => 'Для решения задач нужен AI, но он не настроен';

  @override
  String get pillMath => 'Наведите на задачу и нажмите на затвор';

  @override
  String get pillMrzDetected => 'MRZ найдена · Не двигайте камеру';

  @override
  String get pillPassport => 'Поместите страницу с фото в рамку';

  @override
  String get pillIdFrontSaved =>
      'Лицевая сторона сохранена · Переверните карту';

  @override
  String get pillSaved => 'Сохранено';

  @override
  String get pillIdBack => 'Теперь отсканируйте оборотную сторону';

  @override
  String get pillIdFit => 'Поместите карту в рамку';

  @override
  String get pillCardDetected => 'Карта найдена · Не двигайте камеру';

  @override
  String get pillBook => 'Наведите на открытую книгу';

  @override
  String get pillBookAuto =>
      'Книга найдена · Страницы разделяются автоматически';

  @override
  String get pillBookTap => 'Книга найдена · Нажмите, чтобы снять';

  @override
  String get pillCaptured => 'Снято · Положите следующую страницу';

  @override
  String get pillDocument => 'Наведите на документ';

  @override
  String get pillDocumentAuto => 'Документ найден · Не двигайте камеру';

  @override
  String get pillDocumentTap => 'Документ найден · Нажмите, чтобы снять';

  @override
  String get cameraOffTitle => 'Доступ к камере отключён';

  @override
  String get cameraOffBody =>
      'Разрешите доступ к камере, чтобы сканировать документы.';

  @override
  String get arUnsupportedTitle => 'AR недоступна на этом телефоне';

  @override
  String get arUnsupportedBody =>
      'Для измерений нужны Сервисы Google Play для AR.';

  @override
  String get arInstallTitle => 'Установите поддержку AR';

  @override
  String get arInstallBody =>
      'Завершите установку Сервисов Google Play для AR и повторите попытку.';

  @override
  String get arFailedTitle => 'Не удалось запустить AR';

  @override
  String get arFailedBody => 'При запуске AR-камеры что-то пошло не так.';

  @override
  String get cameraFailedTitle => 'Камера недоступна';

  @override
  String get cameraFailedBody => 'При запуске камеры что-то пошло не так.';

  @override
  String get importFromGallery => 'Импорт из галереи';

  @override
  String get capture => 'Снять';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Просмотреть $count страницы',
      many: 'Просмотреть $count страниц',
      few: 'Просмотреть $count страницы',
      one: 'Просмотреть $count страницу',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'Открыть ссылку';

  @override
  String get sendEmail => 'Написать письмо';

  @override
  String get call => 'Позвонить';

  @override
  String get sendMessage => 'Сообщение';

  @override
  String get openMap => 'Открыть карту';

  @override
  String get copyPassword => 'Копировать пароль';

  @override
  String get passwordCopied => 'Пароль скопирован';

  @override
  String get copyFailed => 'Не удалось скопировать. Повторите попытку.';

  @override
  String get noAppCanOpen =>
      'На этом телефоне нет приложения, чтобы открыть это.';

  @override
  String get shareFailed =>
      'Не удалось открыть меню «Поделиться». Повторите попытку.';

  @override
  String get qrSaveFailed => 'Не удалось сохранить QR-код. Повторите попытку.';

  @override
  String get qrTooLong => 'Слишком длинно для QR-кода. Полное содержимое ниже.';

  @override
  String get qrGenerated => 'Создан из отсканированного содержимого';

  @override
  String get password => 'Пароль';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get codeEmpty => 'Код пустой';

  @override
  String get codeEmptyBody => 'В нём нечего показать.';

  @override
  String get codeUnreadable => 'Не удалось прочитать код';

  @override
  String get codeNotText => 'В нём данные, а не текст.';

  @override
  String get scanAgain => 'Сканировать снова';

  @override
  String get qrCodeImage => 'QR-код';

  @override
  String qrCardTitle(String kind) {
    return 'QR-код · $kind';
  }

  @override
  String get qrCardContent => 'Содержимое';

  @override
  String get scannedWithDocScan => 'Отсканировано в DocScan';

  @override
  String get anotherMath => 'Решить другую задачу';

  @override
  String get anotherQr => 'Сканировать другой код';

  @override
  String get anotherArea => 'Измерить другую площадь';

  @override
  String get anotherCount => 'Посчитать ещё';

  @override
  String get addAnother => 'Добавить ещё';

  @override
  String get addedToScan => 'Добавлено в скан';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · пока $count страницы',
      many: '$title · пока $count страниц',
      few: '$title · пока $count страницы',
      one: '$title · пока $count страница',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'Сайт';

  @override
  String get qrLink => 'Ссылка';

  @override
  String get qrPhone => 'Телефон';

  @override
  String get qrNumber => 'Номер';

  @override
  String get qrText => 'Текст';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'Скрытая сеть';

  @override
  String get qrNetwork => 'Сеть';

  @override
  String get qrNoName => '(без имени)';

  @override
  String get qrSecurity => 'Защита';

  @override
  String get qrSecurityOpen => 'Нет (открытая)';

  @override
  String get qrSecurityUnspecified => 'Не указана';

  @override
  String get qrHidden => 'Скрытая';

  @override
  String get qrYes => 'Да';

  @override
  String get qrEapMethod => 'Метод EAP';

  @override
  String get qrIdentity => 'Пользователь';

  @override
  String get qrEmail => 'Эл. почта';

  @override
  String get qrTo => 'Кому';

  @override
  String get qrSubject => 'Тема';

  @override
  String get qrMessage => 'Сообщение';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'Местоположение';

  @override
  String get qrCoordinates => 'Координаты';

  @override
  String get qrPlace => 'Место';

  @override
  String get qrAltitude => 'Высота';

  @override
  String get qrContact => 'Контакт';

  @override
  String get qrContactCard => 'Карточка контакта';

  @override
  String get qrName => 'Имя';

  @override
  String get qrOrganization => 'Организация';

  @override
  String get qrJobTitle => 'Должность';

  @override
  String get qrAddress => 'Адрес';

  @override
  String get qrNote => 'Заметка';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'Не удалось решить';

  @override
  String get mathSaveFailed =>
      'Не удалось сохранить решение. Повторите попытку.';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шага',
      many: '$count шагов',
      few: '$count шага',
      one: '$count шаг',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'Решено с помощью AI';

  @override
  String get mathAnswer => 'Ответ';

  @override
  String mathCopyProblem(String problem) {
    return 'Задача: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'Ответ: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'Математика · $answer';
  }

  @override
  String get mathCardTitle => 'РЕШЕНИЕ ЗАДАЧИ';

  @override
  String get mathCardContinued => 'РЕШЕНИЕ ЗАДАЧИ · ПРОДОЛЖЕНИЕ';

  @override
  String get mathCardProblem => 'ЗАДАЧА';

  @override
  String get mathCardSteps => 'ШАГИ';

  @override
  String get solvingWithAiLabel => 'Решение с помощью AI';

  @override
  String get solvingWithAi => 'Решение с помощью AI…';

  @override
  String get solvingDetail => 'Читаем задачу и проверяем каждый шаг';

  @override
  String get exportFailed => 'Не удалось экспортировать PDF';

  @override
  String bookPagesTitle(int first, int last) {
    return 'Страницы $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'Страница $page';
  }

  @override
  String get splitIntoTwo => 'Разделить на две страницы';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отсканировано $count разворота · страниц: $pages',
      many: 'Отсканировано $count разворотов · страниц: $pages',
      few: 'Отсканировано $count разворота · страниц: $pages',
      one: 'Отсканирован $count разворот · страниц: $pages',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'Следующий разворот';

  @override
  String get saveBook => 'Сохранить книгу';

  @override
  String get idCardTitle => 'Удостоверение';

  @override
  String get passportTitle => 'Паспорт';

  @override
  String get idDocumentTitle => 'Удостоверение личности';

  @override
  String get layoutStacked => 'Друг под другом';

  @override
  String get layoutSideBySide => 'Рядом';

  @override
  String get layoutSeparate => 'Отдельно';

  @override
  String get fullName => 'Полное имя';

  @override
  String get idNumber => 'Номер документа';

  @override
  String get dateOfBirth => 'Дата рождения';

  @override
  String get extractedDetails => 'Извлечённые данные';

  @override
  String get copyAllLower => 'Копировать всё';

  @override
  String get copyAll => 'Копировать всё';

  @override
  String get detailsCopied => 'Данные скопированы';

  @override
  String get readingCard => 'Чтение карты…';

  @override
  String get noMrzOnCard =>
      'На этой карте нет машиночитаемой зоны, поэтому проверенных данных для извлечения нет. Скан сохранён как есть.';

  @override
  String copyField(String label) {
    return 'Копировать: $label';
  }

  @override
  String fieldCopied(String label) {
    return 'Скопировано: $label';
  }

  @override
  String get passportNo => '№ паспорта';

  @override
  String get documentNo => '№ документа';

  @override
  String get nationality => 'Гражданство';

  @override
  String get sex => 'Пол';

  @override
  String get issuingCountry => 'Страна выдачи';

  @override
  String get expires => 'Действует до';

  @override
  String expiredOn(String date) {
    return 'Срок истёк $date';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Действует ещё $count года',
      many: 'Действует ещё $count лет',
      few: 'Действует ещё $count года',
      one: 'Действует ещё $count год',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Действует ещё $count месяца',
      many: 'Действует ещё $count месяцев',
      few: 'Действует ещё $count месяца',
      one: 'Действует ещё $count месяц',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'Истекает менее чем через месяц';

  @override
  String get mrzVerified => 'MRZ проверена';

  @override
  String pageDeleted(int page) {
    return 'Страница $page удалена';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count страницы удалено',
      many: '$count страниц удалено',
      few: '$count страницы удалены',
      one: '$count страница удалена',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'Камера';

  @override
  String get addFromPhotos => 'Фото';

  @override
  String selectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count страницы',
      many: '$count страниц',
      few: '$count страницы',
      one: '$count страница',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Выбрать';

  @override
  String get tapToSelect => 'Нажимайте на страницы, чтобы выбрать их';

  @override
  String get dragToReorder =>
      'Нажмите и удерживайте страницу, чтобы перетащить её';

  @override
  String get rotateSelected => 'Повернуть выбранные';

  @override
  String get delete => 'Удалить';

  @override
  String deleteCount(int count) {
    return 'Удалить ($count)';
  }

  @override
  String get editPages => 'Изменить страницы';

  @override
  String get saveAsPdf => 'Сохранить как PDF';

  @override
  String rotatePage(int page) {
    return 'Повернуть страницу $page';
  }

  @override
  String deletePage(int page) {
    return 'Удалить страницу $page';
  }

  @override
  String get addPage => 'Добавить страницу';

  @override
  String get cameraOrPhotos => 'Камера или фото';

  @override
  String get filterOriginal => 'Оригинал';

  @override
  String get filterMagic => 'Магия';

  @override
  String get filterBw => 'Ч/Б';

  @override
  String get filterGray => 'Серый';

  @override
  String get filterNoShadow => 'Без теней';

  @override
  String get filterColor => 'Цвет';

  @override
  String get adjustCrop => 'Обрезка';

  @override
  String get reset => 'Сбросить';

  @override
  String get rotate => 'Повернуть';

  @override
  String get cropAuto => 'Авто';

  @override
  String get cropPerspective => 'Перспектива';

  @override
  String get cropFullPage => 'Вся страница';

  @override
  String get enhance => 'Улучшить';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter: применено ко всем страницам ($count)';
  }

  @override
  String get brightness => 'Яркость';

  @override
  String get contrast => 'Контраст';

  @override
  String get applyToAll => 'Применить ко всем';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed =>
      'Не удалось сохранить результат. Повторите попытку.';

  @override
  String get objectCount => 'Подсчёт предметов';

  @override
  String get countedWithDocScan => 'Подсчитано в DocScan';

  @override
  String countPageLabel(int count) {
    return 'Подсчёт: $count';
  }

  @override
  String countAdded(int count) {
    return 'Добавлено: $count';
  }

  @override
  String countRemoved(int count) {
    return 'Удалено: $count';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'предмета',
      many: 'предметов',
      few: 'предмета',
      one: 'предмет',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'Тип';

  @override
  String get roundObjects => 'Круглые предметы';

  @override
  String get boxes => 'Коробки';

  @override
  String get custom => 'Свой';

  @override
  String get matchedToSample => 'по выбранному образцу';

  @override
  String get countAutomatic => 'Автоматически';

  @override
  String get countByHand => 'Вручную';

  @override
  String get noChanges => 'Без изменений';

  @override
  String get tapOneObject => 'Нажмите на предмет, чтобы найти похожие';

  @override
  String get objectsDetected => 'Найдено предметов';

  @override
  String get removeOne => 'Убрать один';

  @override
  String get addOne => 'Добавить один';

  @override
  String get saveResult => 'Сохранить результат';

  @override
  String get areaMeasurement => 'Измерение площади';

  @override
  String get measuredNote => 'Измерено в DocScan AR · погрешность ±5%';

  @override
  String areaTitle(String area) {
    return 'Площадь · $area';
  }

  @override
  String get area => 'Площадь';

  @override
  String get perimeter => 'Периметр';

  @override
  String get sides => 'Стороны';

  @override
  String get points => 'Точки';

  @override
  String summaryArea(String area) {
    return 'Площадь $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count точки',
      many: '$count точек',
      few: '$count точки',
      one: '$count точка',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head. Стороны: $sides';
  }

  @override
  String get hintStartingAr => 'Запуск AR…';

  @override
  String get hintTooDark => 'Слишком темно · Включите вспышку';

  @override
  String get hintMoveSlower => 'Перемещайте телефон медленнее';

  @override
  String get hintMoreDetail =>
      'Наведите на поверхность с более выраженной текстурой';

  @override
  String get hintFindSurface =>
      'Медленно перемещайте телефон, чтобы найти поверхность';

  @override
  String get hintDragCorner => 'Перетащите угол, чтобы скорректировать';

  @override
  String get hintPointCircle => 'Наведите круг на поверхность';

  @override
  String get hintAimBack => 'Снова наведите на ту же поверхность';

  @override
  String get hintTapToDrop => 'Нажмите +, чтобы ставить точки';

  @override
  String get hintNextCorner => 'Нажмите +, чтобы добавить следующий угол';

  @override
  String get hintClose => 'Нажмите на первую точку, чтобы замкнуть фигуру';

  @override
  String get savingMeasurement => 'Сохранение измерения';

  @override
  String get saveMeasurement => 'Сохранить измерение';

  @override
  String get newMeasurement => 'Новое измерение';

  @override
  String get addPoint => 'Добавить точку';

  @override
  String get meters => 'Метры';

  @override
  String get feet => 'Футы';
}
