import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:share_plus/share_plus.dart';

import '../engine.dart';
import '../export/pdf_export.dart';
import '../strings.dart';
import 'mrz.dart';
import 'session.dart';
import 'ui.dart';

/// "01 Oct 2026" in [locale] (see [ScannerStrings.dateLocale]).
String formatDate(DateTime d, String locale) => DateFormat('dd MMM yyyy', locale).format(d);

/// "ANNA MARIA" → "Anna Maria" (MRZ names are upper case; Figma shows names in title case).
String titleCase(String s) => s.split(' ').map((w) => w.isEmpty ? w : w[0] + w.substring(1).toLowerCase()).join(' ');

/// What the user chose on a result screen. Null (Back) returns to the camera with the pages kept.
enum ResultAction { retake, review, save }

/// Renders [pages] to a PDF and opens the share sheet (the export button on 9.3 / 9.4).
Future<void> _share(BuildContext context, List<ScanPage> pages, String name) async {
  try {
    final file = await exportPdf(pages, name);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')]));
  } catch (e) {
    if (context.mounted) showToast(context, context.l10n.exportFailed);
  }
}

/// A rendered page (its current preview), fading in when the render lands.
class PageImage extends StatelessWidget {
  const PageImage(this.page, {super.key, this.fit = BoxFit.contain, this.alignment = Alignment.center});
  final ScanPage page;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final path = page.preview;
    return AnimatedSwitcher(
      duration: fast,
      layoutBuilder: (current, previous) => Stack(fit: StackFit.expand, children: [...previous, ?current]),
      child: path == null
          ? ColoredBox(key: const ValueKey(0), color: Palette.of(context).bgFill)
          : Image(
              key: ValueKey(path),
              image: ResizeImage(FileImage(File(path)), width: 900, height: 900, policy: ResizeImagePolicy.fit),
              fit: fit,
              alignment: alignment,
              gaplessPlayback: true,
            ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// 9.2 Book Result

/// Number of spreads already in [pages] (a split spread is Left + Right, an unsplit one is Spread).
int spreadCount(Iterable<ScanPage> pages) => pages.where((p) => p.spreadStart).length;

/// Figma 9.2: the spread just captured, "Split into two pages", running count, Next Spread / Save Book.
/// Adds the spread's pages to [session] itself. Page-curve flattening and finger removal aren't built (no dewarp /
/// inpainting in the engine yet), so those toggles are left out.
class BookResultScreen extends StatefulWidget {
  const BookResultScreen({
    super.key,
    required this.session,
    required this.photo,
    required this.spread,
    required this.left,
    required this.right,
  });
  final ScanSession session;
  final String photo;
  final List<Offset>? spread;
  final List<Offset> left, right;

  @override
  State<BookResultScreen> createState() => _BookResultScreenState();
}

class _BookResultScreenState extends State<BookResultScreen> {
  late List<ScanPage> pages;
  late ScannerLocalizations l;

  /// Book page number of this spread's left page (counted before the spread is added).
  late final int first;
  bool split = true;

  ScanSession get session => widget.session;

  bool _added = false;

  /// Adds the spread here rather than in initState, where the page labels' language can't be read yet.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    l = context.l10n;
    if (_added) return;
    _added = true;
    first = spreadCount(session.pages) * 2 + 1;
    pages = _make(split: true);
    for (final p in pages) {
      session.add(p);
    }
  }

  List<ScanPage> _make({required bool split}) => split
      ? [
          ScanPage(widget.photo, widget.left, label: l.pageLabelLeft)..spreadStart = true,
          ScanPage(widget.photo, widget.right, label: l.pageLabelRight),
        ]
      : [ScanPage(widget.photo, widget.spread, label: l.pageLabelSpread)..spreadStart = true];

  void _toggle(bool on) {
    HapticFeedback.selectionClick();
    final at = session.pages.indexOf(pages.first);
    for (final p in pages) {
      session.remove(p);
    }
    final next = _make(split: on);
    for (final (i, p) in next.indexed) {
      session.insert(at + i, p);
      session.update(p);
    }
    setState(() {
      split = on;
      pages = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final spreads = spreadCount(session.pages);
        return LightScreen(
          title: l.bookPagesTitle(first, first + 1),
          right: NavText(l.done, onTap: () => Navigator.of(context).pop(ResultAction.review)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: squircleBox(24, color: c.bgFill),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                      key: ValueKey(split),
                      children: [
                        for (final (i, p) in pages.indexed) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                AspectRatio(
                                  aspectRatio: split ? 150 / 210 : 312 / 210,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: Shadows.card,
                                    ),
                                    child: ClipRRect(borderRadius: BorderRadius.circular(4), child: PageImage(p)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _chip(c, split ? l.bookPage(first + i) : l.bookPagesTitle(first, first + 1)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: squircleBox(18, color: c.bgCard, shadows: Shadows.xs),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: squircleBox(10, color: c.brandSoft),
                      child: Icon(IconsaxPlusLinear.document_copy, size: 18, color: c.brand),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l.splitIntoTwo, style: TextStyles.body.copyWith(color: c.textPrimary)),
                    ),
                    ScanToggle(value: split, onChanged: _toggle),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InfoBanner(
                icon: IconsaxPlusLinear.book,
                text: l.spreadsScanned(spreads, spreads * 2),
                fg: c.brand,
                bg: c.brandSoft,
                radius: 16,
              ),
            ],
          ),
          actions: Row(
            children: [
              Expanded(
                child: ScanButton(
                  l.nextSpread,
                  icon: IconsaxPlusLinear.camera,
                  kind: ButtonKind.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ScanButton(
                  l.saveBook,
                  icon: IconsaxPlusLinear.document_download,
                  onPressed: () => Navigator.of(context).pop(ResultAction.save),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(Palette c, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: c.bgCard, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: TextStyles.caption1Medium.copyWith(color: c.textPrimary)),
  );
}

// ---------------------------------------------------------------------------------------------------------------
// 9.3 ID Card Result

enum _IdLayout { stacked, sideBySide, separate }

/// Reads a machine-readable zone from any of [pages] (TD1 on an ID's back, TD3 on a passport). Null if none.
Future<Mrz?> readMrz(Iterable<ScanPage> pages) async {
  for (final p in pages) {
    try {
      final lines = [...(await DocScanner.analyzeFile(p.original, ScanMode.passport)).lines]
        ..sort((a, b) => a.box.top.compareTo(b.box.top));
      final mrz = Mrz.find([for (final l in lines) l.text]);
      if (mrz != null) return mrz;
    } on PlatformException {
      // Try the other side.
    }
  }
  return null;
}

/// Figma 9.3: front + back on the export sheet (Stacked / Side by side / Separate), details read from the card's
/// MRZ when it has one, Retake / Save PDF, export (share).
class IdResultScreen extends StatefulWidget {
  const IdResultScreen({super.key, required this.session, required this.front, required this.back});
  final ScanSession session;
  final ScanPage front, back;

  @override
  State<IdResultScreen> createState() => _IdResultScreenState();
}

class _IdResultScreenState extends State<IdResultScreen> {
  late final group = widget.front.group ?? 'id-${DateTime.now().microsecondsSinceEpoch}';
  late final details = readMrz([widget.back, widget.front]);
  bool exporting = false;

  List<ScanPage> get sides => [widget.front, widget.back];

  _IdLayout get layout => widget.front.group == null
      ? _IdLayout.separate
      : widget.front.sideBySide
      ? _IdLayout.sideBySide
      : _IdLayout.stacked;

  void _setLayout(_IdLayout l) => setState(() {
    for (final p in sides) {
      p
        ..group = l == _IdLayout.separate ? null : group
        ..sideBySide = l == _IdLayout.sideBySide;
    }
  });

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final l = context.l10n;
    return ListenableBuilder(
      listenable: widget.session,
      builder: (context, _) => LightScreen(
        title: l.idCardTitle,
        right: NavCircle(
          icon: IconsaxPlusLinear.export,
          label: l.sharePdf,
          onTap: exporting
              ? null
              : () async {
                  setState(() => exporting = true);
                  await _share(context, sides, l.idCardTitle);
                  if (mounted) setState(() => exporting = false);
                },
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
          children: [
            Container(
              height: 312,
              padding: const EdgeInsets.all(16),
              decoration: squircleBox(24, color: c.bgFill),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(scale: Tween(begin: .96, end: 1.0).animate(a), child: child),
                ),
                child: KeyedSubtree(key: ValueKey(layout), child: _sheet()),
              ),
            ),
            const SizedBox(height: 16),
            Segmented<_IdLayout>(
              options: {
                _IdLayout.stacked: l.layoutStacked,
                _IdLayout.sideBySide: l.layoutSideBySide,
                _IdLayout.separate: l.layoutSeparate,
              },
              value: layout,
              onChanged: _setLayout,
            ),
            const SizedBox(height: 16),
            FutureBuilder<Mrz?>(
              future: details,
              builder: (context, snap) => AnimatedSwitcher(
                duration: fast,
                child: KeyedSubtree(
                  key: ValueKey(snap.connectionState),
                  child: _details(c, snap.connectionState == ConnectionState.done, snap.data),
                ),
              ),
            ),
          ],
        ),
        actions: Row(
          children: [
            Expanded(
              child: ScanButton(
                l.retake,
                icon: IconsaxPlusLinear.camera,
                kind: ButtonKind.secondary,
                onPressed: () => Navigator.of(context).pop(ResultAction.retake),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ScanButton(
                l.savePdf,
                icon: IconsaxPlusLinear.document_download,
                onPressed: () => Navigator.of(context).pop(ResultAction.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(ScanPage p, double width) => Container(
    width: width,
    height: width * 54 / 85.6,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(width / 20), boxShadow: Shadows.card),
    clipBehavior: Clip.antiAlias,
    child: PageImage(p, fit: BoxFit.cover),
  );

  Widget _paper(Widget child, {double? width, double? height}) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: Shadows.raised),
    child: child,
  );

  /// The export sheet(s) in miniature: A4 portrait with the sides stacked, A4 landscape side by side, or one sheet
  /// per side.
  Widget _sheet() => switch (layout) {
    _IdLayout.stacked => Center(
      child: _paper(
        width: 210,
        height: 280,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_card(widget.front, 200), const SizedBox(height: 18), _card(widget.back, 200)],
          ),
        ),
      ),
    ),
    _IdLayout.sideBySide => Center(
      child: _paper(
        width: 321,
        height: 227,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_card(widget.front, 140), const SizedBox(width: 12), _card(widget.back, 140)],
        ),
      ),
    ),
    _IdLayout.separate => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (i, p) in sides.indexed) ...[
          if (i > 0) const SizedBox(width: 14),
          _paper(width: 150, height: 212, Center(child: _card(p, 130))),
        ],
      ],
    ),
  };

  Widget _details(Palette c, bool done, Mrz? m) {
    final l = context.l10n;
    final rows = m == null
        ? const <(String, String)>[]
        : [
            (l.fullName, titleCase('${m.givenNames} ${m.surname}'.trim())),
            (l.idNumber, m.documentNumber),
            (l.dateOfBirth, formatDate(m.birthDate, context.dateLocale)),
          ];
    return Container(
      decoration: squircleBox(18, color: c.bgCard, shadows: Shadows.xs),
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Icon(IconsaxPlusBold.magic_star, size: 16, color: c.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.extractedDetails, style: TextStyles.subheadSemibold.copyWith(color: c.textPrimary)),
                ),
                if (rows.isNotEmpty)
                  Pressable(
                    onTap: () => _copy(rows.map((r) => l.detailLine(r.$1, r.$2)).join('\n'), l.detailsCopied),
                    child: Text(l.copyAllLower, style: TextStyles.footnoteMedium.copyWith(color: c.brand)),
                  ),
              ],
            ),
          ),
          if (!done)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.brand)),
                  const SizedBox(width: 10),
                  Text(l.readingCard, style: TextStyles.subhead.copyWith(color: c.textSecondary)),
                ],
              ),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text(l.noMrzOnCard, style: TextStyles.subhead.copyWith(color: c.textSecondary)),
            )
          else
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label, style: TextStyles.caption1.copyWith(color: c.textSecondary)),
                          Text(value, style: TextStyles.bodyMedium.copyWith(color: c.textPrimary)),
                        ],
                      ),
                    ),
                    Pressable(
                      label: l.copyField(label),
                      scale: .85,
                      onTap: () => _copy(value, l.fieldCopied(label)),
                      child: Icon(IconsaxPlusLinear.copy, size: 18, color: c.textTertiary),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  void _copy(String text, String toast) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    showToast(context, toast);
  }
}

// ---------------------------------------------------------------------------------------------------------------
// 9.4 Passport Result

/// Figma 9.4: holder (page photo), name, "MRZ verified", detail tiles, validity banner, Copy All / Save PDF.
/// Every field comes from the check-digit-verified MRZ. TD3 has no issue date, so the Figma "Issued" tile shows the
/// issuing country instead. Pops true when the user saves.
class PassportResultScreen extends StatefulWidget {
  const PassportResultScreen({super.key, required this.mrz, this.page, this.now});
  final Mrz mrz;

  /// The captured data page (null if the photo failed; the MRZ read is still valid).
  final ScanPage? page;
  final DateTime? now;

  @override
  State<PassportResultScreen> createState() => _PassportResultScreenState();
}

class _PassportResultScreenState extends State<PassportResultScreen> {
  bool exporting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.page;
    if (p != null && p.preview == null) {
      p.render().then((_) => mounted ? setState(() {}) : null, onError: (_) {});
    }
  }

  List<(String, String)> _fields(ScannerLocalizations l, String locale) {
    final m = widget.mrz;
    return [
      (m.format == 'TD3' ? l.passportNo : l.documentNo, m.documentNumber),
      (l.nationality, m.nationality),
      (l.dateOfBirth, formatDate(m.birthDate, locale)),
      (l.sex, m.sex),
      (l.issuingCountry, m.issuingCountry),
      (l.expires, formatDate(m.expiryDate, locale)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final l = context.l10n;
    final m = widget.mrz;
    final fields = _fields(l, context.dateLocale);
    final now = widget.now ?? DateTime.now();
    final expired = m.expiryDate.isBefore(now);
    final months =
        (m.expiryDate.year - now.year) * 12 + m.expiryDate.month - now.month - (m.expiryDate.day < now.day ? 1 : 0);
    final validity = expired
        ? l.expiredOn(formatDate(m.expiryDate, context.dateLocale))
        : months >= 12
        ? l.validYears(months ~/ 12)
        : months >= 1
        ? l.validMonths(months)
        : l.expiresSoon;
    final page = widget.page;
    return LightScreen(
      title: m.format == 'TD3' ? l.passportTitle : l.idDocumentTitle,
      right: NavCircle(
        icon: IconsaxPlusLinear.export,
        label: l.sharePdf,
        onTap: page == null || exporting
            ? null
            : () async {
                setState(() => exporting = true);
                await _share(context, [page], l.passportTitle);
                if (mounted) setState(() => exporting = false);
              },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
        children: [
          Appear(
            index: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: squircleBox(22, color: c.bgCard, shadows: Shadows.card),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 80,
                    decoration: squircleBox(10, color: c.bgFill),
                    clipBehavior: Clip.antiAlias,
                    // The data page, left-aligned: the holder's photo sits on the left of an ICAO data page.
                    child: page == null
                        ? Icon(IconsaxPlusBold.user, size: 32, color: c.textTertiary)
                        : PageImage(page, fit: BoxFit.cover, alignment: Alignment.centerLeft),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.surname, style: TextStyles.title3.copyWith(color: c.textPrimary)),
                        const SizedBox(height: 4),
                        Text(titleCase(m.givenNames), style: TextStyles.subhead.copyWith(color: c.textSecondary)),
                        const SizedBox(height: 4),
                        Container(
                          height: 24,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(color: c.greenSoft, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(IconsaxPlusBold.verify, size: 14, color: c.green),
                              const SizedBox(width: 4),
                              Text(l.mrzVerified, style: TextStyles.caption1Medium.copyWith(color: c.green)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final (i, (label, value)) in fields.indexed)
                    Appear(
                      index: i + 1,
                      child: Container(
                        width: w,
                        padding: const EdgeInsets.all(14),
                        decoration: squircleBox(16, color: c.bgCard, shadows: Shadows.xs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: TextStyles.caption1.copyWith(color: c.textSecondary)),
                            const SizedBox(height: 2),
                            Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyles.subheadSemibold.copyWith(color: c.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Appear(
            index: 7,
            child: InfoBanner(
              icon: IconsaxPlusLinear.calendar,
              text: validity,
              fg: expired ? c.red : c.orange,
              bg: expired ? c.redSoft : c.orangeSoft,
              radius: 16,
            ),
          ),
        ],
      ),
      actions: Row(
        children: [
          Expanded(
            child: ScanButton(
              l.copyAll,
              icon: IconsaxPlusLinear.copy,
              kind: ButtonKind.secondary,
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text: [
                      l.detailLine(l.qrName, '${m.givenNames} ${m.surname}'.trim()),
                      for (final (label, v) in fields) l.detailLine(label, v),
                    ].join('\n'),
                  ),
                );
                HapticFeedback.lightImpact();
                showToast(context, l.detailsCopied);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ScanButton(
              l.savePdf,
              icon: IconsaxPlusLinear.document_download,
              onPressed: page == null ? null : () => Navigator.of(context).pop(true),
            ),
          ),
        ],
      ),
    );
  }
}
