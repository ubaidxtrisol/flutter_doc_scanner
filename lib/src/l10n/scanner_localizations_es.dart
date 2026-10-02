// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class ScannerLocalizationsEs extends ScannerLocalizations {
  ScannerLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get undo => 'Deshacer';

  @override
  String get cancel => 'Cancelar';

  @override
  String get done => 'Listo';

  @override
  String get next => 'Siguiente';

  @override
  String get retry => 'Reintentar';

  @override
  String get retake => 'Repetir';

  @override
  String get review => 'Revisar';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get share => 'Compartir';

  @override
  String get saving => 'Guardando…';

  @override
  String get saveToDocuments => 'Guardar en Documentos';

  @override
  String get savePdf => 'Guardar PDF';

  @override
  String get sharePdf => 'Compartir PDF';

  @override
  String get settings => 'Ajustes';

  @override
  String get openSettings => 'Abrir Ajustes';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String pageOf(int page, int total) {
    return 'Página $page de $total';
  }

  @override
  String detailLine(String label, String value) {
    return '$label: $value';
  }

  @override
  String get tabDocument => 'Documento';

  @override
  String get tabIdCard => 'Tarjeta ID';

  @override
  String get tabPassport => 'Pasaporte';

  @override
  String get tabBook => 'Libro';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'Mates';

  @override
  String get tabCount => 'Contar';

  @override
  String get tabMeasure => 'Medir';

  @override
  String get titleScanQr => 'Escanear QR';

  @override
  String get titleCountObjects => 'Contar objetos';

  @override
  String get pageLabelPassport => 'Pasaporte';

  @override
  String get pageLabelIdDocument => 'Documento de identidad';

  @override
  String get pageLabelIdFront => 'Anverso del documento';

  @override
  String get pageLabelIdBack => 'Reverso del documento';

  @override
  String get pageLabelLeft => 'Izquierda';

  @override
  String get pageLabelRight => 'Derecha';

  @override
  String get pageLabelSpread => 'Doble página';

  @override
  String get pageLabelMath => 'Mates';

  @override
  String get pageLabelArea => 'Área';

  @override
  String defaultTitle(String date) {
    return 'Escaneo $date';
  }

  @override
  String get titleMathSolutions => 'Soluciones de mates';

  @override
  String get titleQrCodes => 'Códigos QR';

  @override
  String get titleAreaMeasurements => 'Mediciones de área';

  @override
  String get titleCountResults => 'Resultados del conteo';

  @override
  String get mathNeedsAi =>
      'Resolver problemas de mates requiere AI, que no está configurada en esta app.';

  @override
  String get mathNoAnswer =>
      'No se encontró una respuesta. Prueba con una foto más nítida.';

  @override
  String captureFailed(String message) {
    return 'Error al capturar: $message';
  }

  @override
  String get measureCaptureFailed =>
      'No se pudo capturar la medición. Inténtalo de nuevo.';

  @override
  String get measureCameraStopped => 'La cámara se detuvo. Inténtalo de nuevo.';

  @override
  String get measureShapeChanged =>
      'La forma cambió. Vuelve a cerrarla y luego guarda.';

  @override
  String get photoAccessDenied =>
      'Permite el acceso a las fotos en Ajustes para importar.';

  @override
  String get imageUnreadable => 'No se pudo leer esa imagen. Prueba con otra.';

  @override
  String get imageOpenFailed => 'No se pudo abrir esa imagen. Prueba con otra.';

  @override
  String get noCodeInImage => 'No se encontró ningún código en esa imagen';

  @override
  String get noMrzInImage =>
      'No hay una MRZ legible en esa imagen. Prueba con una foto más nítida.';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Descartar $count páginas escaneadas?',
      one: '¿Descartar 1 página escaneada?',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'Seguir escaneando';

  @override
  String get discard => 'Descartar';

  @override
  String get flashOn => 'Flash activado';

  @override
  String get flashOff => 'Flash desactivado';

  @override
  String get showGrid => 'Mostrar cuadrícula';

  @override
  String get hideGrid => 'Ocultar cuadrícula';

  @override
  String get autoCaptureOn => 'Captura automática activada';

  @override
  String get autoCaptureOff => 'Captura automática desactivada';

  @override
  String get autoBadge => 'AUTO';

  @override
  String bookChipLeft(int page) {
    return 'Izq. · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'Der. · $page';
  }

  @override
  String get pointAtSurfaceFirst =>
      'Primero apunta el círculo a una superficie';

  @override
  String get idSideFront => '1  Anverso';

  @override
  String get idSideBack => '2  Reverso';

  @override
  String get pillQr => 'Apunta a un código QR o de barras';

  @override
  String get pillCount => 'Apunta a los objetos y toca el obturador';

  @override
  String get pillMathOff =>
      'Resolver mates requiere AI, que no está configurada';

  @override
  String get pillMath => 'Apunta a un problema de mates y toca el obturador';

  @override
  String get pillMrzDetected => 'MRZ detectada · No te muevas';

  @override
  String get pillPassport => 'Coloca la página de la foto dentro del marco';

  @override
  String get pillIdFrontSaved =>
      'Anverso guardado · Dale la vuelta a la tarjeta';

  @override
  String get pillSaved => 'Guardado';

  @override
  String get pillIdBack => 'Ahora escanea el reverso';

  @override
  String get pillIdFit => 'Encaja la tarjeta dentro del marco';

  @override
  String get pillCardDetected => 'Tarjeta detectada · No te muevas';

  @override
  String get pillBook => 'Apunta a un libro abierto';

  @override
  String get pillBookAuto =>
      'Libro detectado · Páginas separadas automáticamente';

  @override
  String get pillBookTap => 'Libro detectado · Toca para capturar';

  @override
  String get pillCaptured => 'Capturado · Coloca la siguiente página';

  @override
  String get pillDocument => 'Apunta a un documento';

  @override
  String get pillDocumentAuto => 'Documento detectado · No te muevas';

  @override
  String get pillDocumentTap => 'Documento detectado · Toca para capturar';

  @override
  String get cameraOffTitle => 'El acceso a la cámara está desactivado';

  @override
  String get cameraOffBody =>
      'Permite el acceso a la cámara para escanear documentos.';

  @override
  String get arUnsupportedTitle => 'La RA no está disponible en este teléfono';

  @override
  String get arUnsupportedBody =>
      'Para medir se necesitan los Servicios de Google Play para RA.';

  @override
  String get arInstallTitle => 'Instalar soporte de RA';

  @override
  String get arInstallBody =>
      'Termina de instalar los Servicios de Google Play para RA y vuelve a intentarlo.';

  @override
  String get arFailedTitle => 'No se pudo iniciar la RA';

  @override
  String get arFailedBody => 'Algo salió mal al iniciar la cámara de RA.';

  @override
  String get cameraFailedTitle => 'Cámara no disponible';

  @override
  String get cameraFailedBody => 'Algo salió mal al iniciar la cámara.';

  @override
  String get importFromGallery => 'Importar de la galería';

  @override
  String get capture => 'Capturar';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Revisar $count páginas',
      one: 'Revisar 1 página',
    );
    return '$_temp0';
  }

  @override
  String get openLink => 'Abrir enlace';

  @override
  String get sendEmail => 'Enviar correo';

  @override
  String get call => 'Llamar';

  @override
  String get sendMessage => 'Mensaje';

  @override
  String get openMap => 'Abrir mapa';

  @override
  String get copyPassword => 'Copiar contraseña';

  @override
  String get passwordCopied => 'Contraseña copiada';

  @override
  String get copyFailed => 'No se pudo copiar. Inténtalo de nuevo.';

  @override
  String get noAppCanOpen => 'Ninguna app de este teléfono puede abrir esto.';

  @override
  String get shareFailed => 'No se pudo abrir Compartir. Inténtalo de nuevo.';

  @override
  String get qrSaveFailed =>
      'No se pudo guardar el código QR. Inténtalo de nuevo.';

  @override
  String get qrTooLong =>
      'Es demasiado largo para mostrarlo como código QR. El contenido completo está abajo.';

  @override
  String get qrGenerated => 'Generado a partir del contenido escaneado';

  @override
  String get password => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get codeEmpty => 'Este código está vacío';

  @override
  String get codeEmptyBody => 'No contiene nada que mostrar.';

  @override
  String get codeUnreadable => 'No se pudo leer este código';

  @override
  String get codeNotText => 'Contiene datos que no son texto.';

  @override
  String get scanAgain => 'Escanear de nuevo';

  @override
  String get qrCodeImage => 'Código QR';

  @override
  String qrCardTitle(String kind) {
    return 'Código QR · $kind';
  }

  @override
  String get qrCardContent => 'Contenido';

  @override
  String get scannedWithDocScan => 'Escaneado con DocScan';

  @override
  String get anotherMath => 'Resolver otro problema';

  @override
  String get anotherQr => 'Escanear otro código';

  @override
  String get anotherArea => 'Medir otra área';

  @override
  String get anotherCount => 'Contar más objetos';

  @override
  String get addAnother => 'Añadir otro';

  @override
  String get addedToScan => 'Añadido a tu escaneo';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · $count páginas hasta ahora',
      one: '$title · 1 página hasta ahora',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'Sitio web';

  @override
  String get qrLink => 'Enlace';

  @override
  String get qrPhone => 'Teléfono';

  @override
  String get qrNumber => 'Número';

  @override
  String get qrText => 'Texto';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'Red oculta';

  @override
  String get qrNetwork => 'Red';

  @override
  String get qrNoName => '(sin nombre)';

  @override
  String get qrSecurity => 'Seguridad';

  @override
  String get qrSecurityOpen => 'Ninguna (abierta)';

  @override
  String get qrSecurityUnspecified => 'Sin especificar';

  @override
  String get qrHidden => 'Oculta';

  @override
  String get qrYes => 'Sí';

  @override
  String get qrEapMethod => 'Método EAP';

  @override
  String get qrIdentity => 'Identidad';

  @override
  String get qrEmail => 'Correo';

  @override
  String get qrTo => 'Para';

  @override
  String get qrSubject => 'Asunto';

  @override
  String get qrMessage => 'Mensaje';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'Ubicación';

  @override
  String get qrCoordinates => 'Coordenadas';

  @override
  String get qrPlace => 'Lugar';

  @override
  String get qrAltitude => 'Altitud';

  @override
  String get qrContact => 'Contacto';

  @override
  String get qrContactCard => 'Tarjeta de contacto';

  @override
  String get qrName => 'Nombre';

  @override
  String get qrOrganization => 'Organización';

  @override
  String get qrJobTitle => 'Cargo';

  @override
  String get qrAddress => 'Dirección';

  @override
  String get qrNote => 'Nota';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'No se pudo resolver';

  @override
  String get mathSaveFailed =>
      'No se pudo guardar la solución. Inténtalo de nuevo.';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'Resuelto con AI';

  @override
  String get mathAnswer => 'Respuesta';

  @override
  String mathCopyProblem(String problem) {
    return 'Problema: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'Respuesta: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'Mates · $answer';
  }

  @override
  String get mathCardTitle => 'SOLUCIÓN MATEMÁTICA';

  @override
  String get mathCardContinued => 'SOLUCIÓN MATEMÁTICA · CONTINUACIÓN';

  @override
  String get mathCardProblem => 'PROBLEMA';

  @override
  String get mathCardSteps => 'PASOS';

  @override
  String get solvingWithAiLabel => 'Resolviendo con AI';

  @override
  String get solvingWithAi => 'Resolviendo con AI…';

  @override
  String get solvingDetail => 'Leyendo el problema y comprobando cada paso';

  @override
  String get exportFailed => 'No se pudo exportar el PDF';

  @override
  String bookPagesTitle(int first, int last) {
    return 'Páginas $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'Página $page';
  }

  @override
  String get splitIntoTwo => 'Dividir en dos páginas';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dobles páginas escaneadas · $pages páginas',
      one: '1 doble página escaneada · $pages páginas',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'Siguiente doble página';

  @override
  String get saveBook => 'Guardar libro';

  @override
  String get idCardTitle => 'Documento de identidad';

  @override
  String get passportTitle => 'Pasaporte';

  @override
  String get idDocumentTitle => 'Documento de identidad';

  @override
  String get layoutStacked => 'Apiladas';

  @override
  String get layoutSideBySide => 'Lado a lado';

  @override
  String get layoutSeparate => 'Separadas';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get idNumber => 'Número de documento';

  @override
  String get dateOfBirth => 'Fecha de nacimiento';

  @override
  String get extractedDetails => 'Datos extraídos';

  @override
  String get copyAllLower => 'Copiar todo';

  @override
  String get copyAll => 'Copiar todo';

  @override
  String get detailsCopied => 'Datos copiados';

  @override
  String get readingCard => 'Leyendo la tarjeta…';

  @override
  String get noMrzOnCard =>
      'Esta tarjeta no tiene zona de lectura mecánica, así que no hay datos verificados que extraer. El escaneo se guarda tal cual.';

  @override
  String copyField(String label) {
    return 'Copiar $label';
  }

  @override
  String fieldCopied(String label) {
    return '$label: copiado';
  }

  @override
  String get passportNo => 'N.º de pasaporte';

  @override
  String get documentNo => 'N.º de documento';

  @override
  String get nationality => 'Nacionalidad';

  @override
  String get sex => 'Sexo';

  @override
  String get issuingCountry => 'País emisor';

  @override
  String get expires => 'Caduca';

  @override
  String expiredOn(String date) {
    return 'Caducó el $date';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Válido $count años más',
      one: 'Válido 1 año más',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Válido $count meses más',
      one: 'Válido 1 mes más',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'Caduca en menos de un mes';

  @override
  String get mrzVerified => 'MRZ verificada';

  @override
  String pageDeleted(int page) {
    return 'Página $page eliminada';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas eliminadas',
      one: '1 página eliminada',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'Cámara';

  @override
  String get addFromPhotos => 'Fotos';

  @override
  String selectedCount(int count) {
    return '$count seleccionadas';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas',
      one: '1 página',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Seleccionar';

  @override
  String get tapToSelect => 'Toca las páginas para seleccionarlas';

  @override
  String get dragToReorder =>
      'Mantén pulsado y arrastra para reordenar las páginas';

  @override
  String get rotateSelected => 'Girar seleccionadas';

  @override
  String get delete => 'Eliminar';

  @override
  String deleteCount(int count) {
    return 'Eliminar $count';
  }

  @override
  String get editPages => 'Editar páginas';

  @override
  String get saveAsPdf => 'Guardar como PDF';

  @override
  String rotatePage(int page) {
    return 'Girar página $page';
  }

  @override
  String deletePage(int page) {
    return 'Eliminar página $page';
  }

  @override
  String get addPage => 'Añadir página';

  @override
  String get cameraOrPhotos => 'Cámara o Fotos';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterMagic => 'Mágico';

  @override
  String get filterBw => 'B/N';

  @override
  String get filterGray => 'Gris';

  @override
  String get filterNoShadow => 'Sin sombras';

  @override
  String get filterColor => 'Color';

  @override
  String get adjustCrop => 'Ajustar recorte';

  @override
  String get reset => 'Restablecer';

  @override
  String get rotate => 'Girar';

  @override
  String get cropAuto => 'Auto';

  @override
  String get cropPerspective => 'Perspectiva';

  @override
  String get cropFullPage => 'Página completa';

  @override
  String get enhance => 'Mejorar';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter aplicado a las $count páginas';
  }

  @override
  String get brightness => 'Brillo';

  @override
  String get contrast => 'Contraste';

  @override
  String get applyToAll => 'Aplicar a todas';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed =>
      'No se pudo guardar el resultado. Inténtalo de nuevo.';

  @override
  String get objectCount => 'Recuento de objetos';

  @override
  String get countedWithDocScan => 'Contado con DocScan';

  @override
  String countPageLabel(int count) {
    return 'Recuento: $count';
  }

  @override
  String countAdded(int count) {
    return '$count añadidos';
  }

  @override
  String countRemoved(int count) {
    return '$count quitados';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'objetos',
      one: 'objeto',
    );
    return '$_temp0';
  }

  @override
  String get countKind => 'Tipo';

  @override
  String get roundObjects => 'Objetos redondos';

  @override
  String get boxes => 'Cajas';

  @override
  String get custom => 'Personalizado';

  @override
  String get matchedToSample => 'según una muestra tocada';

  @override
  String get countAutomatic => 'Automático';

  @override
  String get countByHand => 'A mano';

  @override
  String get noChanges => 'Sin cambios';

  @override
  String get tapOneObject =>
      'Toca un objeto para contar los que se le parezcan';

  @override
  String get objectsDetected => 'Objetos detectados';

  @override
  String get removeOne => 'Quitar uno';

  @override
  String get addOne => 'Añadir uno';

  @override
  String get saveResult => 'Guardar resultado';

  @override
  String get areaMeasurement => 'Medición de área';

  @override
  String get measuredNote => 'Medido con DocScan AR · aprox. ±5 %';

  @override
  String areaTitle(String area) {
    return 'Área · $area';
  }

  @override
  String get area => 'Área';

  @override
  String get perimeter => 'Perímetro';

  @override
  String get sides => 'Lados';

  @override
  String get points => 'Puntos';

  @override
  String summaryArea(String area) {
    return 'Área $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count puntos',
      one: '1 punto',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head. Lados $sides';
  }

  @override
  String get hintStartingAr => 'Iniciando RA…';

  @override
  String get hintTooDark => 'Demasiado oscuro · Enciende el flash';

  @override
  String get hintMoveSlower => 'Mueve el teléfono más despacio';

  @override
  String get hintMoreDetail => 'Apunta a una superficie con más detalle';

  @override
  String get hintFindSurface =>
      'Mueve el teléfono despacio para encontrar una superficie';

  @override
  String get hintDragCorner => 'Arrastra una esquina para ajustar';

  @override
  String get hintPointCircle => 'Apunta el círculo a una superficie';

  @override
  String get hintAimBack => 'Vuelve a apuntar a la misma superficie';

  @override
  String get hintTapToDrop => 'Toca + para colocar puntos';

  @override
  String get hintNextCorner => 'Toca + para añadir la siguiente esquina';

  @override
  String get hintClose => 'Toca el primer punto para cerrar la forma';

  @override
  String get savingMeasurement => 'Guardando medición';

  @override
  String get saveMeasurement => 'Guardar medición';

  @override
  String get newMeasurement => 'Nueva medición';

  @override
  String get addPoint => 'Añadir punto';

  @override
  String get meters => 'Metros';

  @override
  String get feet => 'Pies';
}
