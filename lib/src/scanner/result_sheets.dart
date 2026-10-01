import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr/qr.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'card_render.dart';
import 'qr_payload.dart';
import 'session.dart';
import 'ui.dart';

// Result sheets sit over the camera and are always light (Figma 7.3 / 7.4).
const sheetInk = Color(0xFF0E1116); // text/primary
const sheetSub = Color(0xFF5B6272); // text/secondary
const sheetTile = Color(0xFFEAF0FF); // brand/soft
const _p = Palette.light;

/// Saves a result card as a page: the scanner adds it to the scan under [title] and asks to add another or save.
typedef SaveResult = Future<void> Function(ScanPage page, String title);

/// Figma 7.3 result sheet: the decoded content in detail, the code re-generated from it, and Copy / Share / the
/// kind's own action / Save to Documents. The camera keeps running behind it (no dim barrier).
Future<void> showQrSheet(BuildContext context, QrPayload p, {SaveResult? onSave}) =>
    resultSheet(context, (_) => QrSheet(p, onSave: onSave));

class QrSheet extends StatefulWidget {
  const QrSheet(this.payload, {super.key, this.onSave});
  final QrPayload payload;
  final SaveResult? onSave;

  @override
  State<QrSheet> createState() => _QrSheetState();
}

class _QrSheetState extends State<QrSheet> {
  QrPayload get p => widget.payload;
  late final qr = encodeQr(p.raw);
  var copied = false, passwordCopied = false, showPassword = false, saving = false;
  String? problem;

  (IconData, String)? get _primary => switch (p.kind) {
    _ when p.link == null && (p.kind != QrKind.wifi || p.secret == null) => null, // Share is the action
    QrKind.url => (IconsaxPlusLinear.export_3, 'Open Link'),
    QrKind.email => (IconsaxPlusLinear.direct_send, 'Send Email'),
    QrKind.phone => (IconsaxPlusLinear.call, 'Call'),
    QrKind.sms => (IconsaxPlusLinear.message, 'Message'),
    QrKind.geo => (IconsaxPlusLinear.map, 'Open Map'),
    QrKind.wifi => (passwordCopied ? IconsaxPlusLinear.copy_success : IconsaxPlusLinear.key, 'Copy Password'),
    _ => null,
  };

  Future<void> _run(Future<void> Function() action, String failure) async {
    setState(() => problem = null);
    try {
      await action();
    } catch (_) {
      if (mounted) setState(() => problem = failure);
    }
  }

  Future<void> _copy() => _run(() async {
    await Clipboard.setData(ClipboardData(text: p.copyText));
    HapticFeedback.lightImpact();
    if (mounted) setState(() => copied = true);
  }, "Couldn't copy. Try again.");

  Future<void> _open() => _run(() async {
    if (p.kind == QrKind.wifi) {
      await Clipboard.setData(ClipboardData(text: p.secret!));
      HapticFeedback.lightImpact();
      if (mounted) setState(() => passwordCopied = true);
      return;
    }
    var opened = await launchUrl(p.link!, mode: LaunchMode.externalApplication);
    // iOS has no geo: handler; any browser can show the map.
    if (!opened && p.kind == QrKind.geo) {
      final query = p.fields.firstOrNull?.$2 ?? p.display;
      opened = await launchUrl(Uri.https('www.google.com', '/maps/search/', {'api': '1', 'query': query}));
    }
    if (!opened) throw StateError('no handler');
  }, 'No app on this phone can open this.');

  /// The text, plus the generated code as a PNG when there is one.
  Future<void> _share() => _run(() async {
    final image = qr;
    await SharePlus.instance.share(
      ShareParams(
        text: p.kind == QrKind.url ? p.link.toString() : p.raw,
        files: image == null ? null : [XFile(await qrPng(image), mimeType: 'image/png')],
      ),
    );
  }, "Couldn't open sharing. Try again.");

  Future<void> _save() async {
    final save = widget.onSave!;
    setState(() {
      saving = true;
      problem = null;
    });
    try {
      final path = await renderCard(context, QrCard(p, qr: qr, time: DateTime.now()));
      if (!mounted) return; // dismissed while rendering
      await save(ScanPage(path, null, label: p.saveTitle), p.saveTitle);
      if (mounted) setState(() => saving = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          problem = "Couldn't save the QR code. Try again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!p.readable) return _unreadable(context);
    final primary = _primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .6),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const SizedBox(height: 16),
                _code(),
                if (p.fields.isNotEmpty || p.secret != null) ...[const SizedBox(height: 16), _details()],
                if (p.kind == QrKind.text) ...[const SizedBox(height: 16), _fullText()],
              ],
            ),
          ),
        ),
        if (problem case final msg?)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(msg, style: TextStyles.footnoteMedium.copyWith(color: _p.red)),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            sheetSquare(
              copied ? IconsaxPlusLinear.copy_success : IconsaxPlusLinear.copy,
              copied ? 'Copied' : 'Copy',
              _copy,
              color: copied ? _p.green : null,
            ),
            const SizedBox(width: 12),
            if (primary != null) ...[
              sheetSquare(IconsaxPlusLinear.export_1, 'Share', _share),
              const SizedBox(width: 12),
              Expanded(child: sheetFilled(primary.$1, passwordCopied ? 'Password Copied' : primary.$2, _open)),
            ] else
              Expanded(child: sheetFilled(IconsaxPlusLinear.export_1, 'Share', _share)),
          ],
        ),
        if (widget.onSave != null) ...[
          const SizedBox(height: 12),
          ScanButton(
            saving ? 'Saving…' : 'Save to Documents',
            icon: IconsaxPlusLinear.document_download,
            kind: ButtonKind.tonal,
            busy: saving,
            onPressed: _save,
            palette: _p,
          ),
        ],
      ],
    );
  }

  Widget _header() => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: squircleBox(12, color: _p.brandSoft),
        child: Icon(qrIcon(p.kind), color: _p.brand, size: 22),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plain text is shown in full below, so its header is just the kind.
            if (p.kind == QrKind.text)
              Text(p.title, style: TextStyles.headline.copyWith(color: _p.textPrimary))
            else ...[
              Text(p.title, style: TextStyles.footnoteMedium.copyWith(color: _p.textSecondary)),
              const SizedBox(height: 2),
              Text(
                p.display,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.headline.copyWith(color: _p.textPrimary),
              ),
            ],
          ],
        ),
      ),
    ],
  );

  Widget _code() {
    final image = qr;
    if (image == null) {
      return InfoBanner(
        icon: IconsaxPlusLinear.info_circle,
        text: 'Too long to show as a QR code. The full content is below.',
        fg: _p.textSecondary,
        bg: _p.bgFill,
      );
    }
    return Column(
      children: [
        Container(
          width: 168,
          height: 168,
          decoration: squircleBox(
            16,
            color: Colors.white,
            side: BorderSide(color: _p.borderSubtle),
          ),
          child: QrCodeView(image),
        ),
        const SizedBox(height: 6),
        Text('Generated from the scanned content', style: TextStyles.caption1.copyWith(color: _p.textTertiary)),
      ],
    );
  }

  Widget _details() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: squircleBox(16, color: _p.bgBase),
    child: Column(
      children: [
        for (final (i, (label, value)) in p.fields.indexed) ...[
          if (i > 0) Divider(height: 1, color: _p.borderSubtle),
          _row(label, SelectableText(value, style: TextStyles.subhead.copyWith(color: _p.textPrimary))),
        ],
        if (p.secret case final password?) ...[
          if (p.fields.isNotEmpty) Divider(height: 1, color: _p.borderSubtle),
          _row(
            'Password',
            Row(
              children: [
                Expanded(
                  child: showPassword
                      ? SelectableText(password, style: TextStyles.subhead.copyWith(color: _p.textPrimary))
                      : Text(
                          '•' * password.length.clamp(8, 16),
                          style: TextStyles.subhead.copyWith(color: _p.textPrimary),
                        ),
                ),
                Pressable(
                  label: showPassword ? 'Hide password' : 'Show password',
                  onTap: () => setState(() => showPassword = !showPassword),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      showPassword ? IconsaxPlusLinear.eye_slash : IconsaxPlusLinear.eye,
                      size: 20,
                      color: _p.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );

  Widget _row(String label, Widget value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 11),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyles.subhead.copyWith(color: _p.textSecondary)),
        ),
        const SizedBox(width: 8),
        Expanded(child: value),
      ],
    ),
  );

  Widget _fullText() => Container(
    padding: const EdgeInsets.all(14),
    decoration: squircleBox(16, color: _p.bgBase),
    child: SelectableText(p.raw, style: TextStyles.subhead.copyWith(color: _p.textPrimary)),
  );

  Widget _unreadable(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 56,
        height: 56,
        decoration: squircleBox(16, color: _p.bgFill),
        child: Icon(IconsaxPlusLinear.scan_barcode, color: _p.textSecondary, size: 26),
      ),
      const SizedBox(height: 12),
      Text(
        p.raw.trim().isEmpty ? 'This code is empty' : "Couldn't read this code",
        style: TextStyles.headline.copyWith(color: _p.textPrimary),
      ),
      const SizedBox(height: 4),
      Text(
        p.raw.trim().isEmpty ? 'There is nothing in it to show.' : "It holds data that isn't text.",
        textAlign: TextAlign.center,
        style: TextStyles.subhead.copyWith(color: _p.textSecondary),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: sheetFilled(IconsaxPlusLinear.scan, 'Scan Again', () => Navigator.of(context).pop()),
      ),
    ],
  );
}

IconData qrIcon(QrKind kind) => switch (kind) {
  QrKind.url => IconsaxPlusLinear.global,
  QrKind.wifi => IconsaxPlusLinear.wifi,
  QrKind.email => IconsaxPlusLinear.sms,
  QrKind.phone => IconsaxPlusLinear.call,
  QrKind.sms => IconsaxPlusLinear.message,
  QrKind.geo => IconsaxPlusLinear.location,
  QrKind.contact => IconsaxPlusLinear.profile,
  QrKind.text => IconsaxPlusLinear.document_text,
};

/// [data] re-encoded as a QR code (byte mode, UTF-8) at error correction M (15%, the usual level for printed
/// codes), or L when it's too long for M. Null when it doesn't fit even a version-40 code.
QrImage? encodeQr(String data) {
  if (data.isEmpty) return null;
  for (final level in [QrErrorCorrectLevel.M, QrErrorCorrectLevel.L]) {
    try {
      return QrImage(QrCode.fromData(data: data, errorCorrectLevel: level));
    } catch (_) {
      // InputTooLongException: try the next level
    }
  }
  return null;
}

/// A QR code with its 4-module quiet zone, dark on white, modules snapped to whole device pixels.
class QrCodeView extends StatelessWidget {
  const QrCodeView(this.image, {super.key});
  final QrImage image;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'QR code',
    image: true,
    child: AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(painter: QrPainter(image, MediaQuery.devicePixelRatioOf(context))),
    ),
  );
}

class QrPainter extends CustomPainter {
  QrPainter(this.image, this.pixelRatio);
  final QrImage image;
  final double pixelRatio;
  static const quiet = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final n = image.moduleCount + 2 * quiet;
    final m = (size.shortestSide * pixelRatio / n).floorToDouble() / pixelRatio;
    if (m <= 0) return;
    final origin = Offset(size.width - m * n, size.height - m * n) / 2 + Offset(quiet * m, quiet * m);
    // One path of horizontal runs: a single fill leaves no hairline seams between neighbouring modules.
    final path = Path();
    for (var r = 0; r < image.moduleCount; r++) {
      for (var c = 0; c < image.moduleCount; c++) {
        if (!image.isDark(r, c)) continue;
        final start = c;
        while (c + 1 < image.moduleCount && image.isDark(r, c + 1)) {
          c++;
        }
        path.addRect(Rect.fromLTWH(origin.dx + start * m, origin.dy + r * m, (c - start + 1) * m, m));
      }
    }
    canvas
      ..drawRect(Offset.zero & size, Paint()..color = Colors.white)
      ..drawPath(path, Paint()..color = _p.textPrimary);
  }

  @override
  bool shouldRepaint(QrPainter old) => old.image != image || old.pixelRatio != pixelRatio;
}

/// The code as a ~1000 px PNG in the cache (for sharing); returns its path.
Future<String> qrPng(QrImage image) async {
  final n = image.moduleCount + 2 * QrPainter.quiet;
  final side = (1000 ~/ n).clamp(4, 40) * n;
  final recorder = ui.PictureRecorder();
  QrPainter(image, 1).paint(Canvas(recorder), Size.square(side.toDouble()));
  final picture = recorder.endRecording();
  final png = await picture.toImage(side, side);
  picture.dispose();
  try {
    final bytes = await png.toByteData(format: ui.ImageByteFormat.png);
    final out = File('${(await getTemporaryDirectory()).path}/qr_${DateTime.now().microsecondsSinceEpoch}.png');
    await out.writeAsBytes(bytes!.buffer.asUint8List());
    return out.path;
  } finally {
    png.dispose();
  }
}

/// The saved QR page (A4, see [renderCard]): title, the generated code, the parsed fields, the raw content and a
/// footer. Without a code (too long to encode) it is a text-only card.
class QrCard extends StatelessWidget {
  const QrCard(this.payload, {super.key, required this.qr, required this.time});
  final QrPayload payload;
  final QrImage? qr;
  final DateTime time;

  /// Field rows on the card; the rest is still in the raw content. Keeps the page from overflowing.
  static const maxRows = 8;

  @override
  Widget build(BuildContext context) {
    final p = payload;
    final rows = [
      ...p.fields,
      // Hidden in the sheet until tapped, but the user chose to save this code, so the card shows the password.
      if (p.secret case final password?) ('Password', password),
    ].take(maxRows);
    final code = qr;
    return ColoredBox(
      color: _p.bgCard,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 44, 48, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: squircleBox(12, color: _p.brandSoft),
                  child: Icon(qrIcon(p.kind), color: _p.brand, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('QR Code · ${p.title}', style: TextStyles.title3.copyWith(color: _p.textPrimary)),
                      Text(
                        p.display,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.subhead.copyWith(color: _p.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (code != null) ...[
              Center(child: SizedBox.square(dimension: 200, child: QrCodeView(code))),
              const SizedBox(height: 20),
            ],
            for (final (label, value) in rows)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: _p.borderSubtle)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(label, style: TextStyles.footnoteMedium.copyWith(color: _p.textSecondary)),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.footnoteMedium.copyWith(color: _p.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) {
                  // Content: as many lines as the page has room for, then "…".
                  final style = TextStyles.caption1.copyWith(color: _p.textPrimary);
                  final lines = ((box.maxHeight - 18 - 6 - 24) / 16).floor();
                  if (lines < 1) return const SizedBox.shrink();
                  final raw = p.raw.trim();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Content', style: TextStyles.footnoteSemibold.copyWith(color: _p.textSecondary)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: squircleBox(12, color: _p.bgBase),
                        child: Text(
                          raw.length > 6000 ? '${raw.substring(0, 6000)}…' : raw,
                          maxLines: lines,
                          overflow: TextOverflow.ellipsis,
                          style: style,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Divider(height: 1, color: _p.borderSubtle),
            const SizedBox(height: 10),
            DefaultTextStyle.merge(
              style: TextStyles.caption1.copyWith(color: _p.textTertiary),
              child: Row(children: [Text(cardStamp(time)), const Spacer(), const Text('Scanned with DocScan')]),
            ),
          ],
        ),
      ),
    );
  }
}

/// Light bottom sheet over the camera (no dim barrier), grabber on top.
Future<T?> resultSheet<T>(BuildContext context, WidgetBuilder body) => showModalBottomSheet<T>(
  context: context,
  barrierColor: Colors.transparent,
  backgroundColor: Colors.white,
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  builder: (context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 18),
          body(context),
        ],
      ),
    ),
  ),
);

Widget sheetOutlined(IconData icon, String label, VoidCallback onTap) =>
    ScanButton(label, icon: icon, kind: ButtonKind.secondary, onPressed: onTap, palette: Palette.light);

Widget sheetFilled(IconData icon, String label, VoidCallback onTap) =>
    ScanButton(label, icon: icon, onPressed: onTap, palette: Palette.light);

/// 54 pt outlined icon button for the light sheets (Copy, Share). [label] is its accessibility label.
Widget sheetSquare(IconData icon, String label, VoidCallback onTap, {Color? color}) => Pressable(
  label: label,
  onTap: onTap,
  child: Container(
    width: 54,
    height: 54,
    decoration: squircleBox(
      16,
      color: _p.bgCard,
      side: BorderSide(color: _p.borderStrong),
    ),
    child: Icon(icon, size: 22, color: color ?? _p.textPrimary),
  ),
);

/// What to do after a result card joins the scan.
enum AddedAction { another, review, save }

/// After a result card (math, QR, area, count) joins the scan: add another, review the pages, or save the PDF.
/// Dismissing it means "add another".
Future<AddedAction?> showAddedSheet(BuildContext context, {required String title, required int pages}) {
  final another = switch (title.split(RegExp('[ :]')).first) {
    'Math' => 'Solve another problem',
    'QR' => 'Scan another code',
    'Area' => 'Measure another area',
    'Count' => 'Count more objects',
    _ => 'Add another',
  };
  return resultSheet<AddedAction>(
    context,
    (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: squircleBox(12, color: Tone.success.withValues(alpha: .12)),
              child: const Icon(IconsaxPlusLinear.tick_circle, color: Tone.success, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Added to your scan', style: TextStyles.headline.copyWith(color: _p.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    '$title · $pages page${pages == 1 ? '' : 's'} so far',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.footnoteMedium.copyWith(color: _p.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        sheetFilled(IconsaxPlusLinear.add, another, () => Navigator.of(context).pop(AddedAction.another)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: sheetOutlined(
                IconsaxPlusLinear.eye,
                'Review',
                () => Navigator.of(context).pop(AddedAction.review),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: sheetOutlined(
                IconsaxPlusLinear.document_download,
                'Save PDF',
                () => Navigator.of(context).pop(AddedAction.save),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
