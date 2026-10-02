// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class ScannerLocalizationsPt extends ScannerLocalizations {
  ScannerLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get close => 'Fechar';

  @override
  String get back => 'Voltar';

  @override
  String get undo => 'Desfazer';

  @override
  String get cancel => 'Cancelar';

  @override
  String get done => 'Concluído';

  @override
  String get next => 'Próximo';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get retake => 'Refazer';

  @override
  String get review => 'Revisar';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get share => 'Compartilhar';

  @override
  String get saving => 'Salvando…';

  @override
  String get saveToDocuments => 'Salvar em Documentos';

  @override
  String get savePdf => 'Salvar PDF';

  @override
  String get sharePdf => 'Compartilhar PDF';

  @override
  String get settings => 'Configurações';

  @override
  String get openSettings => 'Abrir Configurações';

  @override
  String get tryAgain => 'Tentar de novo';

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
  String get tabIdCard => 'Identidade';

  @override
  String get tabPassport => 'Passaporte';

  @override
  String get tabBook => 'Livro';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => 'Matemática';

  @override
  String get tabCount => 'Contar';

  @override
  String get tabMeasure => 'Medir';

  @override
  String get titleScanQr => 'Ler QR';

  @override
  String get titleCountObjects => 'Contar objetos';

  @override
  String get pageLabelPassport => 'Passaporte';

  @override
  String get pageLabelIdDocument => 'Documento';

  @override
  String get pageLabelIdFront => 'Frente';

  @override
  String get pageLabelIdBack => 'Verso';

  @override
  String get pageLabelLeft => 'Esquerda';

  @override
  String get pageLabelRight => 'Direita';

  @override
  String get pageLabelSpread => 'Página dupla';

  @override
  String get pageLabelMath => 'Matemática';

  @override
  String get pageLabelArea => 'Área';

  @override
  String defaultTitle(String date) {
    return 'Digitalização $date';
  }

  @override
  String get titleMathSolutions => 'Soluções de matemática';

  @override
  String get titleQrCodes => 'Códigos QR';

  @override
  String get titleAreaMeasurements => 'Medições de área';

  @override
  String get titleCountResults => 'Resultados da contagem';

  @override
  String get mathNeedsAi =>
      'Resolver matemática exige AI, que não está configurada neste app.';

  @override
  String get mathNoAnswer =>
      'Não foi possível encontrar uma resposta. Tente uma foto mais nítida.';

  @override
  String captureFailed(String message) {
    return 'Falha na captura: $message';
  }

  @override
  String get measureCaptureFailed =>
      'Não foi possível capturar a medição. Tente de novo.';

  @override
  String get measureCameraStopped => 'A câmera parou. Tente de novo.';

  @override
  String get measureShapeChanged => 'A forma mudou. Feche-a de novo e salve.';

  @override
  String get photoAccessDenied =>
      'Permita o acesso às fotos nas Configurações para importar.';

  @override
  String get imageUnreadable =>
      'Não foi possível ler essa imagem. Tente outra.';

  @override
  String get imageOpenFailed =>
      'Não foi possível abrir essa imagem. Tente outra.';

  @override
  String get noCodeInImage => 'Nenhum código encontrado nessa imagem';

  @override
  String get noMrzInImage =>
      'Nenhuma MRZ legível nessa imagem. Tente uma foto mais nítida.';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descartar $count páginas digitalizadas?',
      one: 'Descartar 1 página digitalizada?',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => 'Continuar digitalizando';

  @override
  String get discard => 'Descartar';

  @override
  String get flashOn => 'Flash ligado';

  @override
  String get flashOff => 'Flash desligado';

  @override
  String get showGrid => 'Mostrar grade';

  @override
  String get hideGrid => 'Ocultar grade';

  @override
  String get autoCaptureOn => 'Captura automática ligada';

  @override
  String get autoCaptureOff => 'Captura automática desligada';

  @override
  String get autoBadge => 'AUTO';

  @override
  String bookChipLeft(int page) {
    return 'Esquerda · $page';
  }

  @override
  String bookChipRight(int page) {
    return 'Direita · $page';
  }

  @override
  String get pointAtSurfaceFirst =>
      'Aponte o círculo para uma superfície primeiro';

  @override
  String get idSideFront => '1  Frente';

  @override
  String get idSideBack => '2  Verso';

  @override
  String get pillQr => 'Aponte para um código QR ou de barras';

  @override
  String get pillCount => 'Aponte para os objetos e toque no obturador';

  @override
  String get pillMathOff =>
      'Resolver matemática exige AI, que não está configurada';

  @override
  String get pillMath =>
      'Aponte para um problema de matemática e toque no obturador';

  @override
  String get pillMrzDetected => 'MRZ detectada · Mantenha firme';

  @override
  String get pillPassport => 'Posicione a página da foto dentro do quadro';

  @override
  String get pillIdFrontSaved => 'Frente salva · Vire o cartão';

  @override
  String get pillSaved => 'Salvo';

  @override
  String get pillIdBack => 'Agora digitalize o verso';

  @override
  String get pillIdFit => 'Encaixe o cartão dentro do quadro';

  @override
  String get pillCardDetected => 'Cartão detectado · Não se mexa';

  @override
  String get pillBook => 'Aponte para um livro aberto';

  @override
  String get pillBookAuto =>
      'Livro detectado · Páginas separadas automaticamente';

  @override
  String get pillBookTap => 'Livro detectado · Toque para capturar';

  @override
  String get pillCaptured => 'Capturado · Posicione a próxima página';

  @override
  String get pillDocument => 'Aponte para um documento';

  @override
  String get pillDocumentAuto => 'Documento detectado · Não se mexa';

  @override
  String get pillDocumentTap => 'Documento detectado · Toque para capturar';

  @override
  String get cameraOffTitle => 'O acesso à câmera está desativado';

  @override
  String get cameraOffBody =>
      'Permita o acesso à câmera para digitalizar documentos.';

  @override
  String get arUnsupportedTitle => 'AR não está disponível neste celular';

  @override
  String get arUnsupportedBody =>
      'A medição exige o Google Play Services para AR.';

  @override
  String get arInstallTitle => 'Instalar suporte a AR';

  @override
  String get arInstallBody =>
      'Conclua a instalação do Google Play Services para AR e tente de novo.';

  @override
  String get arFailedTitle => 'Não foi possível iniciar o AR';

  @override
  String get arFailedBody => 'Algo deu errado ao iniciar a câmera de AR.';

  @override
  String get cameraFailedTitle => 'Câmera indisponível';

  @override
  String get cameraFailedBody => 'Algo deu errado ao iniciar a câmera.';

  @override
  String get importFromGallery => 'Importar da galeria';

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
  String get openLink => 'Abrir link';

  @override
  String get sendEmail => 'Enviar e-mail';

  @override
  String get call => 'Ligar';

  @override
  String get sendMessage => 'Mensagem';

  @override
  String get openMap => 'Abrir mapa';

  @override
  String get copyPassword => 'Copiar senha';

  @override
  String get passwordCopied => 'Senha copiada';

  @override
  String get copyFailed => 'Não foi possível copiar. Tente de novo.';

  @override
  String get noAppCanOpen => 'Nenhum app neste celular pode abrir isso.';

  @override
  String get shareFailed =>
      'Não foi possível abrir o compartilhamento. Tente de novo.';

  @override
  String get qrSaveFailed =>
      'Não foi possível salvar o código QR. Tente de novo.';

  @override
  String get qrTooLong =>
      'Longo demais para mostrar como código QR. O conteúdo completo está abaixo.';

  @override
  String get qrGenerated => 'Gerado a partir do conteúdo lido';

  @override
  String get password => 'Senha';

  @override
  String get showPassword => 'Mostrar senha';

  @override
  String get hidePassword => 'Ocultar senha';

  @override
  String get codeEmpty => 'Este código está vazio';

  @override
  String get codeEmptyBody => 'Não há nada nele para mostrar.';

  @override
  String get codeUnreadable => 'Não foi possível ler este código';

  @override
  String get codeNotText => 'Ele contém dados que não são texto.';

  @override
  String get scanAgain => 'Ler de novo';

  @override
  String get qrCodeImage => 'Código QR';

  @override
  String qrCardTitle(String kind) {
    return 'Código QR · $kind';
  }

  @override
  String get qrCardContent => 'Conteúdo';

  @override
  String get scannedWithDocScan => 'Digitalizado com DocScan';

  @override
  String get anotherMath => 'Resolver outro problema';

  @override
  String get anotherQr => 'Ler outro código';

  @override
  String get anotherArea => 'Medir outra área';

  @override
  String get anotherCount => 'Contar mais objetos';

  @override
  String get addAnother => 'Adicionar outro';

  @override
  String get addedToScan => 'Adicionado à sua digitalização';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · $count páginas até agora',
      one: '$title · 1 página até agora',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => 'Site';

  @override
  String get qrLink => 'Link';

  @override
  String get qrPhone => 'Telefone';

  @override
  String get qrNumber => 'Número';

  @override
  String get qrText => 'Texto';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => 'Rede oculta';

  @override
  String get qrNetwork => 'Rede';

  @override
  String get qrNoName => '(sem nome)';

  @override
  String get qrSecurity => 'Segurança';

  @override
  String get qrSecurityOpen => 'Nenhuma (aberta)';

  @override
  String get qrSecurityUnspecified => 'Não especificada';

  @override
  String get qrHidden => 'Oculta';

  @override
  String get qrYes => 'Sim';

  @override
  String get qrEapMethod => 'Método EAP';

  @override
  String get qrIdentity => 'Identidade';

  @override
  String get qrEmail => 'E-mail';

  @override
  String get qrTo => 'Para';

  @override
  String get qrSubject => 'Assunto';

  @override
  String get qrMessage => 'Mensagem';

  @override
  String get qrSms => 'SMS';

  @override
  String get qrLocation => 'Local';

  @override
  String get qrCoordinates => 'Coordenadas';

  @override
  String get qrPlace => 'Lugar';

  @override
  String get qrAltitude => 'Altitude';

  @override
  String get qrContact => 'Contato';

  @override
  String get qrContactCard => 'Cartão de contato';

  @override
  String get qrName => 'Nome';

  @override
  String get qrOrganization => 'Organização';

  @override
  String get qrJobTitle => 'Cargo';

  @override
  String get qrAddress => 'Endereço';

  @override
  String get qrNote => 'Observação';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => 'Não foi possível resolver';

  @override
  String get mathSaveFailed =>
      'Não foi possível salvar a solução. Tente de novo.';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passos',
      one: '1 passo',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => 'Resolvido com AI';

  @override
  String get mathAnswer => 'Resposta';

  @override
  String mathCopyProblem(String problem) {
    return 'Problema: $problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return 'Resposta: $answer';
  }

  @override
  String mathTitle(String answer) {
    return 'Matemática · $answer';
  }

  @override
  String get mathCardTitle => 'SOLUÇÃO DE MATEMÁTICA';

  @override
  String get mathCardContinued => 'SOLUÇÃO DE MATEMÁTICA · CONTINUAÇÃO';

  @override
  String get mathCardProblem => 'PROBLEMA';

  @override
  String get mathCardSteps => 'PASSOS';

  @override
  String get solvingWithAiLabel => 'Resolvendo com AI';

  @override
  String get solvingWithAi => 'Resolvendo com AI…';

  @override
  String get solvingDetail => 'Lendo o problema e conferindo cada passo';

  @override
  String get exportFailed => 'Não foi possível exportar o PDF';

  @override
  String bookPagesTitle(int first, int last) {
    return 'Páginas $first–$last';
  }

  @override
  String bookPage(int page) {
    return 'Página $page';
  }

  @override
  String get splitIntoTwo => 'Dividir em duas páginas';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas duplas digitalizadas · $pages páginas',
      one: '1 página dupla digitalizada · $pages páginas',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => 'Próxima dupla';

  @override
  String get saveBook => 'Salvar livro';

  @override
  String get idCardTitle => 'Carteira de identidade';

  @override
  String get passportTitle => 'Passaporte';

  @override
  String get idDocumentTitle => 'Documento de identidade';

  @override
  String get layoutStacked => 'Empilhado';

  @override
  String get layoutSideBySide => 'Lado a lado';

  @override
  String get layoutSeparate => 'Separado';

  @override
  String get fullName => 'Nome completo';

  @override
  String get idNumber => 'Número do documento';

  @override
  String get dateOfBirth => 'Data de nascimento';

  @override
  String get extractedDetails => 'Dados extraídos';

  @override
  String get copyAllLower => 'Copiar tudo';

  @override
  String get copyAll => 'Copiar tudo';

  @override
  String get detailsCopied => 'Dados copiados';

  @override
  String get readingCard => 'Lendo o cartão…';

  @override
  String get noMrzOnCard =>
      'Este cartão não tem zona de leitura mecânica, então não há dados verificados para extrair. A digitalização foi salva como está.';

  @override
  String copyField(String label) {
    return 'Copiar $label';
  }

  @override
  String fieldCopied(String label) {
    return '$label copiado';
  }

  @override
  String get passportNo => 'Nº do passaporte';

  @override
  String get documentNo => 'Nº do documento';

  @override
  String get nationality => 'Nacionalidade';

  @override
  String get sex => 'Sexo';

  @override
  String get issuingCountry => 'País emissor';

  @override
  String get expires => 'Validade';

  @override
  String expiredOn(String date) {
    return 'Expirou em $date';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Válido por mais $count anos',
      one: 'Válido por mais 1 ano',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Válido por mais $count meses',
      one: 'Válido por mais 1 mês',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => 'Expira em menos de um mês';

  @override
  String get mrzVerified => 'MRZ verificada';

  @override
  String pageDeleted(int page) {
    return 'Página $page excluída';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas excluídas',
      one: '1 página excluída',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => 'Câmera';

  @override
  String get addFromPhotos => 'Fotos';

  @override
  String selectedCount(int count) {
    return '$count selecionadas';
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
  String get select => 'Selecionar';

  @override
  String get tapToSelect => 'Toque nas páginas para selecioná-las';

  @override
  String get dragToReorder =>
      'Mantenha pressionado e arraste para reordenar as páginas';

  @override
  String get rotateSelected => 'Girar selecionadas';

  @override
  String get delete => 'Excluir';

  @override
  String deleteCount(int count) {
    return 'Excluir $count';
  }

  @override
  String get editPages => 'Editar páginas';

  @override
  String get saveAsPdf => 'Salvar como PDF';

  @override
  String rotatePage(int page) {
    return 'Girar página $page';
  }

  @override
  String deletePage(int page) {
    return 'Excluir página $page';
  }

  @override
  String get addPage => 'Adicionar página';

  @override
  String get cameraOrPhotos => 'Câmera ou Fotos';

  @override
  String get filterOriginal => 'Original';

  @override
  String get filterMagic => 'Mágico';

  @override
  String get filterBw => 'P & B';

  @override
  String get filterGray => 'Cinza';

  @override
  String get filterNoShadow => 'Sem sombra';

  @override
  String get filterColor => 'Cor';

  @override
  String get adjustCrop => 'Ajustar corte';

  @override
  String get reset => 'Redefinir';

  @override
  String get rotate => 'Girar';

  @override
  String get cropAuto => 'Auto';

  @override
  String get cropPerspective => 'Perspectiva';

  @override
  String get cropFullPage => 'Página inteira';

  @override
  String get enhance => 'Melhorar';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '$filter aplicado a todas as $count páginas';
  }

  @override
  String get brightness => 'Brilho';

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
      'Não foi possível salvar o resultado. Tente de novo.';

  @override
  String get objectCount => 'Contagem de objetos';

  @override
  String get countedWithDocScan => 'Contado com DocScan';

  @override
  String countPageLabel(int count) {
    return 'Contagem: $count';
  }

  @override
  String countAdded(int count) {
    return '$count adicionados';
  }

  @override
  String countRemoved(int count) {
    return '$count removidos';
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
  String get boxes => 'Caixas';

  @override
  String get custom => 'Personalizado';

  @override
  String get matchedToSample => 'comparado a uma amostra tocada';

  @override
  String get countAutomatic => 'Automático';

  @override
  String get countByHand => 'Manual';

  @override
  String get noChanges => 'Sem alterações';

  @override
  String get tapOneObject => 'Toque em um objeto para contar os semelhantes';

  @override
  String get objectsDetected => 'Objetos detectados';

  @override
  String get removeOne => 'Remover um';

  @override
  String get addOne => 'Adicionar um';

  @override
  String get saveResult => 'Salvar resultado';

  @override
  String get areaMeasurement => 'Medição de área';

  @override
  String get measuredNote => 'Medido com DocScan AR · aprox. ±5%';

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
  String get points => 'Pontos';

  @override
  String summaryArea(String area) {
    return 'Área $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pontos',
      one: '1 ponto',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head. Lados $sides';
  }

  @override
  String get hintStartingAr => 'Iniciando AR…';

  @override
  String get hintTooDark => 'Muito escuro · Ligue o flash';

  @override
  String get hintMoveSlower => 'Mova o celular mais devagar';

  @override
  String get hintMoreDetail => 'Aponte para uma superfície com mais detalhes';

  @override
  String get hintFindSurface =>
      'Mova o celular devagar para encontrar uma superfície';

  @override
  String get hintDragCorner => 'Arraste um canto para ajustar';

  @override
  String get hintPointCircle => 'Aponte o círculo para uma superfície';

  @override
  String get hintAimBack => 'Volte a apontar para a mesma superfície';

  @override
  String get hintTapToDrop => 'Toque em + para marcar pontos';

  @override
  String get hintNextCorner => 'Toque em + para adicionar o próximo canto';

  @override
  String get hintClose => 'Toque no primeiro ponto para fechar a forma';

  @override
  String get savingMeasurement => 'Salvando medição';

  @override
  String get saveMeasurement => 'Salvar medição';

  @override
  String get newMeasurement => 'Nova medição';

  @override
  String get addPoint => 'Adicionar ponto';

  @override
  String get meters => 'Metros';

  @override
  String get feet => 'Pés';
}
