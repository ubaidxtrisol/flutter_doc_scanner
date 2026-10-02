// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'scanner_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class ScannerLocalizationsZh extends ScannerLocalizations {
  ScannerLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get close => '关闭';

  @override
  String get back => '返回';

  @override
  String get undo => '撤销';

  @override
  String get cancel => '取消';

  @override
  String get done => '完成';

  @override
  String get next => '下一步';

  @override
  String get retry => '重试';

  @override
  String get retake => '重拍';

  @override
  String get review => '查看';

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制';

  @override
  String get share => '分享';

  @override
  String get saving => '正在保存…';

  @override
  String get saveToDocuments => '保存到文档';

  @override
  String get savePdf => '保存 PDF';

  @override
  String get sharePdf => '分享 PDF';

  @override
  String get settings => '设置';

  @override
  String get openSettings => '打开设置';

  @override
  String get tryAgain => '重试';

  @override
  String pageOf(int page, int total) {
    return '第 $page 页，共 $total 页';
  }

  @override
  String detailLine(String label, String value) {
    return '$label：$value';
  }

  @override
  String get tabDocument => '文档';

  @override
  String get tabIdCard => '证件';

  @override
  String get tabPassport => '护照';

  @override
  String get tabBook => '书籍';

  @override
  String get tabQr => 'QR';

  @override
  String get tabMath => '数学';

  @override
  String get tabCount => '计数';

  @override
  String get tabMeasure => '测量';

  @override
  String get titleScanQr => '扫描 QR 码';

  @override
  String get titleCountObjects => '物体计数';

  @override
  String get pageLabelPassport => '护照';

  @override
  String get pageLabelIdDocument => '身份证件';

  @override
  String get pageLabelIdFront => '证件正面';

  @override
  String get pageLabelIdBack => '证件背面';

  @override
  String get pageLabelLeft => '左页';

  @override
  String get pageLabelRight => '右页';

  @override
  String get pageLabelSpread => '跨页';

  @override
  String get pageLabelMath => '数学';

  @override
  String get pageLabelArea => '面积';

  @override
  String defaultTitle(String date) {
    return '扫描 $date';
  }

  @override
  String get titleMathSolutions => '数学解答';

  @override
  String get titleQrCodes => 'QR 码';

  @override
  String get titleAreaMeasurements => '面积测量';

  @override
  String get titleCountResults => '计数结果';

  @override
  String get mathNeedsAi => '解数学题需要 AI，但此应用尚未设置 AI。';

  @override
  String get mathNoAnswer => '未能找到答案。请换一张更清晰的照片。';

  @override
  String captureFailed(String message) {
    return '拍摄失败：$message';
  }

  @override
  String get measureCaptureFailed => '无法获取测量结果，请重试。';

  @override
  String get measureCameraStopped => '相机已停止，请重试。';

  @override
  String get measureShapeChanged => '形状已改变。请重新闭合后再保存。';

  @override
  String get photoAccessDenied => '请在设置中允许访问照片以导入。';

  @override
  String get imageUnreadable => '无法读取该图片，请换一张试试。';

  @override
  String get imageOpenFailed => '无法打开该图片，请换一张试试。';

  @override
  String get noCodeInImage => '图片中未找到二维码或条形码';

  @override
  String get noMrzInImage => '图片中没有可读取的 MRZ。请换一张更清晰的照片。';

  @override
  String discardPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '要舍弃 $count 张已扫描的页面吗？',
    );
    return '$_temp0';
  }

  @override
  String get keepScanning => '继续扫描';

  @override
  String get discard => '舍弃';

  @override
  String get flashOn => '闪光灯已开启';

  @override
  String get flashOff => '闪光灯已关闭';

  @override
  String get showGrid => '显示网格';

  @override
  String get hideGrid => '隐藏网格';

  @override
  String get autoCaptureOn => '自动拍摄已开启';

  @override
  String get autoCaptureOff => '自动拍摄已关闭';

  @override
  String get autoBadge => '自动';

  @override
  String bookChipLeft(int page) {
    return '左 · $page';
  }

  @override
  String bookChipRight(int page) {
    return '右 · $page';
  }

  @override
  String get pointAtSurfaceFirst => '请先将圆圈对准一个平面';

  @override
  String get idSideFront => '1  正面';

  @override
  String get idSideBack => '2  背面';

  @override
  String get pillQr => '对准 QR 码或条形码';

  @override
  String get pillCount => '对准物体，然后点按快门';

  @override
  String get pillMathOff => '解数学题需要 AI，但尚未设置';

  @override
  String get pillMath => '对准数学题，然后点按快门';

  @override
  String get pillMrzDetected => '已检测到 MRZ · 请保持稳定';

  @override
  String get pillPassport => '将照片页放入框内';

  @override
  String get pillIdFrontSaved => '正面已保存 · 请翻转证件';

  @override
  String get pillSaved => '已保存';

  @override
  String get pillIdBack => '现在扫描背面';

  @override
  String get pillIdFit => '将证件放入框内';

  @override
  String get pillCardDetected => '已检测到证件 · 请保持不动';

  @override
  String get pillBook => '对准打开的书';

  @override
  String get pillBookAuto => '已检测到书籍 · 自动分页';

  @override
  String get pillBookTap => '已检测到书籍 · 点按拍摄';

  @override
  String get pillCaptured => '已拍摄 · 请放置下一页';

  @override
  String get pillDocument => '对准文档';

  @override
  String get pillDocumentAuto => '已检测到文档 · 请保持不动';

  @override
  String get pillDocumentTap => '已检测到文档 · 点按拍摄';

  @override
  String get cameraOffTitle => '相机权限已关闭';

  @override
  String get cameraOffBody => '请允许访问相机以扫描文档。';

  @override
  String get arUnsupportedTitle => '此手机不支持 AR';

  @override
  String get arUnsupportedBody => '测量功能需要 Google Play Services for AR。';

  @override
  String get arInstallTitle => '安装 AR 支持';

  @override
  String get arInstallBody => '请完成 Google Play Services for AR 的安装，然后重试。';

  @override
  String get arFailedTitle => 'AR 无法启动';

  @override
  String get arFailedBody => '启动 AR 相机时出错。';

  @override
  String get cameraFailedTitle => '相机不可用';

  @override
  String get cameraFailedBody => '启动相机时出错。';

  @override
  String get importFromGallery => '从相册导入';

  @override
  String get capture => '拍摄';

  @override
  String reviewPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '查看 $count 页',
    );
    return '$_temp0';
  }

  @override
  String get openLink => '打开链接';

  @override
  String get sendEmail => '发送邮件';

  @override
  String get call => '拨打电话';

  @override
  String get sendMessage => '发短信';

  @override
  String get openMap => '打开地图';

  @override
  String get copyPassword => '复制密码';

  @override
  String get passwordCopied => '密码已复制';

  @override
  String get copyFailed => '无法复制，请重试。';

  @override
  String get noAppCanOpen => '此手机上没有可以打开它的应用。';

  @override
  String get shareFailed => '无法打开分享，请重试。';

  @override
  String get qrSaveFailed => '无法保存 QR 码，请重试。';

  @override
  String get qrTooLong => '内容过长，无法显示为 QR 码。完整内容如下。';

  @override
  String get qrGenerated => '根据扫描内容生成';

  @override
  String get password => '密码';

  @override
  String get showPassword => '显示密码';

  @override
  String get hidePassword => '隐藏密码';

  @override
  String get codeEmpty => '此码为空';

  @override
  String get codeEmptyBody => '其中没有可显示的内容。';

  @override
  String get codeUnreadable => '无法读取此码';

  @override
  String get codeNotText => '其中包含非文本数据。';

  @override
  String get scanAgain => '重新扫描';

  @override
  String get qrCodeImage => 'QR 码';

  @override
  String qrCardTitle(String kind) {
    return 'QR 码 · $kind';
  }

  @override
  String get qrCardContent => '内容';

  @override
  String get scannedWithDocScan => '由 DocScan 扫描';

  @override
  String get anotherMath => '再解一道题';

  @override
  String get anotherQr => '再扫一个码';

  @override
  String get anotherArea => '再测一个面积';

  @override
  String get anotherCount => '继续计数其他物体';

  @override
  String get addAnother => '再添加一个';

  @override
  String get addedToScan => '已添加到扫描';

  @override
  String addedSoFar(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title · 目前共 $count 页',
    );
    return '$_temp0';
  }

  @override
  String get qrWebsite => '网站';

  @override
  String get qrLink => '链接';

  @override
  String get qrPhone => '电话';

  @override
  String get qrNumber => '号码';

  @override
  String get qrText => '文本';

  @override
  String get qrWifi => 'Wi-Fi';

  @override
  String get qrHiddenNetwork => '隐藏网络';

  @override
  String get qrNetwork => '网络';

  @override
  String get qrNoName => '（无名称）';

  @override
  String get qrSecurity => '安全性';

  @override
  String get qrSecurityOpen => '无（开放）';

  @override
  String get qrSecurityUnspecified => '未指定';

  @override
  String get qrHidden => '隐藏';

  @override
  String get qrYes => '是';

  @override
  String get qrEapMethod => 'EAP 方法';

  @override
  String get qrIdentity => '身份';

  @override
  String get qrEmail => '电子邮件';

  @override
  String get qrTo => '收件人';

  @override
  String get qrSubject => '主题';

  @override
  String get qrMessage => '内容';

  @override
  String get qrSms => '短信';

  @override
  String get qrLocation => '位置';

  @override
  String get qrCoordinates => '坐标';

  @override
  String get qrPlace => '地点';

  @override
  String get qrAltitude => '海拔';

  @override
  String get qrContact => '联系人';

  @override
  String get qrContactCard => '联系人名片';

  @override
  String get qrName => '姓名';

  @override
  String get qrOrganization => '单位';

  @override
  String get qrJobTitle => '职位';

  @override
  String get qrAddress => '地址';

  @override
  String get qrNote => '备注';

  @override
  String qrSaveTitle(String text) {
    return 'QR · $text';
  }

  @override
  String get mathFailed => '无法解答此题';

  @override
  String get mathSaveFailed => '无法保存解答，请重试。';

  @override
  String mathSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个步骤',
    );
    return '$_temp0';
  }

  @override
  String get solvedWithAi => '由 AI 解答';

  @override
  String get mathAnswer => '答案';

  @override
  String mathCopyProblem(String problem) {
    return '题目：$problem';
  }

  @override
  String mathCopyAnswer(String answer) {
    return '答案：$answer';
  }

  @override
  String mathTitle(String answer) {
    return '数学 · $answer';
  }

  @override
  String get mathCardTitle => '数学解答';

  @override
  String get mathCardContinued => '数学解答 · 续';

  @override
  String get mathCardProblem => '题目';

  @override
  String get mathCardSteps => '步骤';

  @override
  String get solvingWithAiLabel => 'AI 正在解答';

  @override
  String get solvingWithAi => 'AI 正在解答…';

  @override
  String get solvingDetail => '正在读取题目并检查每个步骤';

  @override
  String get exportFailed => '无法导出 PDF';

  @override
  String bookPagesTitle(int first, int last) {
    return '第 $first–$last 页';
  }

  @override
  String bookPage(int page) {
    return '第 $page 页';
  }

  @override
  String get splitIntoTwo => '拆分为两页';

  @override
  String spreadsScanned(int count, int pages) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已扫描 $count 个跨页 · $pages 页',
    );
    return '$_temp0';
  }

  @override
  String get nextSpread => '下一跨页';

  @override
  String get saveBook => '保存书籍';

  @override
  String get idCardTitle => '证件';

  @override
  String get passportTitle => '护照';

  @override
  String get idDocumentTitle => '身份证件';

  @override
  String get layoutStacked => '上下排列';

  @override
  String get layoutSideBySide => '左右并排';

  @override
  String get layoutSeparate => '分开';

  @override
  String get fullName => '姓名';

  @override
  String get idNumber => '证件号码';

  @override
  String get dateOfBirth => '出生日期';

  @override
  String get extractedDetails => '提取的信息';

  @override
  String get copyAllLower => '全部复制';

  @override
  String get copyAll => '全部复制';

  @override
  String get detailsCopied => '信息已复制';

  @override
  String get readingCard => '正在读取证件…';

  @override
  String get noMrzOnCard => '此证件没有机读区，因此没有可提取的已验证信息。扫描件已按原样保存。';

  @override
  String copyField(String label) {
    return '复制$label';
  }

  @override
  String fieldCopied(String label) {
    return '$label已复制';
  }

  @override
  String get passportNo => '护照号码';

  @override
  String get documentNo => '证件号码';

  @override
  String get nationality => '国籍';

  @override
  String get sex => '性别';

  @override
  String get issuingCountry => '签发国家';

  @override
  String get expires => '有效期至';

  @override
  String expiredOn(String date) {
    return '已于 $date 过期';
  }

  @override
  String validYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还有 $count 年有效期',
    );
    return '$_temp0';
  }

  @override
  String validMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还有 $count 个月有效期',
    );
    return '$_temp0';
  }

  @override
  String get expiresSoon => '不到一个月后过期';

  @override
  String get mrzVerified => 'MRZ 已验证';

  @override
  String pageDeleted(int page) {
    return '第 $page 页已删除';
  }

  @override
  String pagesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已删除 $count 页',
    );
    return '$_temp0';
  }

  @override
  String get addFromCamera => '相机';

  @override
  String get addFromPhotos => '照片';

  @override
  String selectedCount(int count) {
    return '已选择 $count 项';
  }

  @override
  String pagesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 页',
    );
    return '$_temp0';
  }

  @override
  String get select => '选择';

  @override
  String get tapToSelect => '点按页面以选择';

  @override
  String get dragToReorder => '长按并拖动以调整页面顺序';

  @override
  String get rotateSelected => '旋转所选项';

  @override
  String get delete => '删除';

  @override
  String deleteCount(int count) {
    return '删除 $count 项';
  }

  @override
  String get editPages => '编辑页面';

  @override
  String get saveAsPdf => '另存为 PDF';

  @override
  String rotatePage(int page) {
    return '旋转第 $page 页';
  }

  @override
  String deletePage(int page) {
    return '删除第 $page 页';
  }

  @override
  String get addPage => '添加页面';

  @override
  String get cameraOrPhotos => '相机或照片';

  @override
  String get filterOriginal => '原图';

  @override
  String get filterMagic => '魔法';

  @override
  String get filterBw => '黑白';

  @override
  String get filterGray => '灰度';

  @override
  String get filterNoShadow => '去阴影';

  @override
  String get filterColor => '彩色';

  @override
  String get adjustCrop => '调整裁剪';

  @override
  String get reset => '重置';

  @override
  String get rotate => '旋转';

  @override
  String get cropAuto => '自动';

  @override
  String get cropPerspective => '透视';

  @override
  String get cropFullPage => '整页';

  @override
  String get enhance => '增强';

  @override
  String filterAppliedToAll(String filter, int count) {
    return '已将$filter应用到全部 $count 页';
  }

  @override
  String get brightness => '亮度';

  @override
  String get contrast => '对比度';

  @override
  String get applyToAll => '应用到全部';

  @override
  String sliderValue(String label, int value) {
    return '$label $value';
  }

  @override
  String get countSaveFailed => '无法保存结果，请重试。';

  @override
  String get objectCount => '物体计数';

  @override
  String get countedWithDocScan => '由 DocScan 计数';

  @override
  String countPageLabel(int count) {
    return '计数：$count';
  }

  @override
  String countAdded(int count) {
    return '已添加 $count 个';
  }

  @override
  String countRemoved(int count) {
    return '已移除 $count 个';
  }

  @override
  String objectsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '个物体',
    );
    return '$_temp0';
  }

  @override
  String get countKind => '类型';

  @override
  String get roundObjects => '圆形物体';

  @override
  String get boxes => '箱子';

  @override
  String get custom => '自定义';

  @override
  String get matchedToSample => '与点按的样本匹配';

  @override
  String get countAutomatic => '自动';

  @override
  String get countByHand => '手动';

  @override
  String get noChanges => '无更改';

  @override
  String get tapOneObject => '点按一个物体以计数同类物体';

  @override
  String get objectsDetected => '检测到的物体';

  @override
  String get removeOne => '减少一个';

  @override
  String get addOne => '增加一个';

  @override
  String get saveResult => '保存结果';

  @override
  String get areaMeasurement => '面积测量';

  @override
  String get measuredNote => '使用 DocScan AR 测量 · 误差约 ±5%';

  @override
  String areaTitle(String area) {
    return '面积 · $area';
  }

  @override
  String get area => '面积';

  @override
  String get perimeter => '周长';

  @override
  String get sides => '边长';

  @override
  String get points => '点';

  @override
  String summaryArea(String area) {
    return '面积 $area';
  }

  @override
  String summaryPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个点',
    );
    return '$_temp0';
  }

  @override
  String summarySides(String head, String sides) {
    return '$head。边长 $sides';
  }

  @override
  String get hintStartingAr => '正在启动 AR…';

  @override
  String get hintTooDark => '太暗了 · 请打开闪光灯';

  @override
  String get hintMoveSlower => '请放慢手机移动速度';

  @override
  String get hintMoreDetail => '请对准纹理更丰富的平面';

  @override
  String get hintFindSurface => '缓慢移动手机以寻找平面';

  @override
  String get hintDragCorner => '拖动角点进行调整';

  @override
  String get hintPointCircle => '将圆圈对准一个平面';

  @override
  String get hintAimBack => '请重新对准同一平面';

  @override
  String get hintTapToDrop => '点按 + 放置点';

  @override
  String get hintNextCorner => '点按 + 添加下一个角点';

  @override
  String get hintClose => '点按第一个点以闭合形状';

  @override
  String get savingMeasurement => '正在保存测量结果';

  @override
  String get saveMeasurement => '保存测量结果';

  @override
  String get newMeasurement => '新测量';

  @override
  String get addPoint => '添加点';

  @override
  String get meters => '米';

  @override
  String get feet => '英尺';
}
