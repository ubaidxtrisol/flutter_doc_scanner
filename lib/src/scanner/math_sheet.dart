import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../math/solver.dart';
import '../scanner.dart';
import '../strings.dart';
import 'card_render.dart';
import 'result_sheets.dart';
import 'session.dart';
import 'ui.dart';

/// Saves result cards as pages: the scanner adds them to the scan (or finishes with them) under [title].
typedef SavePages = Future<void> Function(List<ScanPage> pages, String title);

const _p = Palette.light; // result sheets are always light (Figma 7.4)

/// Figma 7.4: problem type + step count, the problem, green answer card, numbered steps, Copy and Save to Documents.
/// [solve] may return at once (a cached answer); the AI takes seconds, so the sheet opens with a
/// loading state, and Retry after an error calls [solve] again. [photo] (the shutter or gallery photo) goes on the
/// saved card.
Future<void> showMathSheet(
  BuildContext context,
  FutureOr<MathSolution> Function() solve, {
  String? photo,
  SavePages? onSave,
}) => resultSheet(context, (_) => _MathSheet(solve: solve, photo: photo, onSave: onSave));

class _MathSheet extends StatefulWidget {
  const _MathSheet({required this.solve, this.photo, this.onSave});
  final FutureOr<MathSolution> Function() solve;
  final String? photo;
  final SavePages? onSave;

  @override
  State<_MathSheet> createState() => _MathSheetState();
}

class _MathSheetState extends State<_MathSheet> {
  MathSolution? solution;
  Object? error;
  var copied = false, saving = false;
  String? saveError;

  @override
  void initState() {
    super.initState();
    _solve();
  }

  void _solve() {
    final FutureOr<MathSolution> result;
    try {
      result = widget.solve();
    } catch (e) {
      error = e;
      return;
    }
    if (result is MathSolution) {
      solution = result;
      return;
    }
    result.then(
      (s) => mounted ? setState(() => solution = s) : null,
      onError: (Object e) => mounted ? setState(() => error = e) : null,
    );
  }

  void _retry() => setState(() {
    error = null;
    _solve();
  });

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: mathPlainText(solution!, context.l10n)));
    HapticFeedback.lightImpact();
    if (mounted) setState(() => copied = true);
  }

  Future<void> _save() async {
    final (s, save, l) = (solution!, widget.onSave!, context.l10n);
    setState(() {
      saving = true;
      saveError = null;
    });
    ui.Image? photo;
    try {
      if (widget.photo case final path?) {
        try {
          photo = await decodeForCard(path);
        } catch (_) {
          photo = null; // a missing photo shouldn't block saving the solution
        }
      }
      final now = DateTime.now();
      final chunks = mathCardChunks(s.steps.length, photo: photo != null);
      final pages = <ScanPage>[];
      for (final (i, (first, count)) in chunks.indexed) {
        if (!mounted) return;
        final card = MathCard(
          s,
          photo: i == 0 ? photo : null,
          first: first,
          count: count,
          page: i,
          pages: chunks.length,
          time: now,
        );
        pages.add(ScanPage(await renderCard(context, card), null, label: l.pageLabelMath)..kind = ResultKind.math);
      }
      await save(pages, mathTitle(s, l));
      if (mounted) setState(() => saving = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          saving = false;
          saveError = l.mathSaveFailed;
        });
      }
    } finally {
      photo?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedSize(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOutCubic,
    alignment: Alignment.topCenter,
    child: switch ((solution, error)) {
      (_, final e?) => _failed(e),
      (final s?, _) => _solved(s, context.l10n),
      _ => const _Solving(),
    },
  );

  Widget _failed(Object e) => Column(
    key: const ValueKey('failed'),
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: squircleBox(12, color: _p.redSoft),
            child: Icon(IconsaxPlusLinear.cloud_cross, color: _p.red),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.mathFailed, style: TextStyles.headline.copyWith(color: _p.textPrimary)),
                const SizedBox(height: 2),
                Text('$e', style: TextStyles.subhead.copyWith(color: _p.textSecondary)),
              ],
            ),
          ),
        ],
      ),
      // Retry can't help when there is no online solver at all.
      if (Scanner.onlineMath != null) ...[
        const SizedBox(height: 18),
        SizedBox(width: double.infinity, child: sheetFilled(IconsaxPlusLinear.refresh, context.l10n.retry, _retry)),
      ],
    ],
  );

  Widget _solved(MathSolution s, ScannerLocalizations l) => Column(
    key: const ValueKey('solved'),
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .6),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(s, l),
              if (s.problem.isNotEmpty || s.problemTex != null) ...[
                const SizedBox(height: 10),
                mathView(s.problemTex, s.problem, TextStyles.subhead.copyWith(color: _p.textSecondary)),
              ],
              const SizedBox(height: 14),
              _answer(s, l, scroll: true),
              const SizedBox(height: 12),
              for (final (i, step) in s.steps.indexed) _step(i + 1, step, scroll: true),
            ],
          ),
        ),
      ),
      if (saveError case final msg?)
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(msg, style: TextStyles.footnoteMedium.copyWith(color: _p.red)),
        ),
      const SizedBox(height: 16),
      Row(
        children: [
          Pressable(
            label: copied ? l.copied : l.copy,
            onTap: _copy,
            child: Container(
              width: 54,
              height: 54,
              decoration: squircleBox(
                16,
                color: _p.bgCard,
                side: BorderSide(color: _p.borderStrong),
              ),
              child: Icon(
                copied ? IconsaxPlusLinear.copy_success : IconsaxPlusLinear.copy,
                size: 22,
                color: copied ? _p.green : _p.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ScanButton(
              saving ? l.saving : l.saveToDocuments,
              icon: IconsaxPlusLinear.document_download,
              busy: saving,
              onPressed: widget.onSave == null ? null : _save,
              palette: _p,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _header(MathSolution s, ScannerLocalizations l, {double size = 44}) => Row(
  children: [
    Container(
      width: size,
      height: size,
      decoration: squircleBox(12, color: _p.purpleSoft),
      child: Icon(IconsaxPlusLinear.calculator, color: _p.purple, size: size / 2),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.type, style: TextStyles.headline.copyWith(color: _p.textPrimary)),
          const SizedBox(height: 2),
          Text(l.mathSteps(s.steps.length), style: TextStyles.footnoteMedium.copyWith(color: _p.textSecondary)),
        ],
      ),
    ),
    if (s.online) const _AiBadge(),
  ],
);

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: _p.brandSoft, borderRadius: BorderRadius.circular(12)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(IconsaxPlusLinear.magic_star, size: 14, color: _p.brand),
        const SizedBox(width: 4),
        Text(context.l10n.solvedWithAi, style: TextStyles.caption1Medium.copyWith(color: _p.brand)),
      ],
    ),
  );
}

Widget _answer(MathSolution s, ScannerLocalizations l, {required bool scroll}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  decoration: squircleBox(16, color: _p.greenSoft),
  child: Row(
    children: [
      Text(l.mathAnswer, style: TextStyles.subheadSemibold.copyWith(color: _p.green)),
      const SizedBox(width: 16),
      Expanded(
        child: Align(
          alignment: Alignment.centerRight,
          child: mathView(
            s.answerTex,
            s.answer,
            const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Tone.success),
            scroll: scroll,
            reverse: true,
          ),
        ),
      ),
    ],
  ),
);

Widget _step(int n, MathStep step, {required bool scroll}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 26,
        height: 26,
        margin: const EdgeInsets.only(top: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: _p.brandSoft, shape: BoxShape.circle),
        child: Text('$n', style: TextStyles.footnoteSemibold.copyWith(color: _p.brand)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (step.title.isNotEmpty) ...[
              Text(step.title, style: TextStyles.footnoteMedium.copyWith(color: _p.textSecondary)),
              const SizedBox(height: 4),
            ],
            mathView(step.tex, step.expr, TextStyles.headline.copyWith(color: _p.textPrimary), scroll: scroll),
          ],
        ),
      ),
    ],
  ),
);

/// [tex] rendered as math (falls back to [text] if it doesn't parse), or [text] in the same style when there's
/// no LaTeX. Too-wide math scrolls sideways ([scroll], the sheet) or shrinks (the card).
Widget mathView(String? tex, String text, TextStyle style, {bool scroll = true, bool reverse = false}) {
  final plain = Text(text, style: style);
  if (tex == null) return plain;
  // Regular weight: a bold style turns KaTeX's italic variables into upright bold.
  final math = Math.tex(
    tex,
    textStyle: style.copyWith(fontWeight: FontWeight.w400),
    onErrorFallback: (_) => plain,
  );
  return scroll
      ? SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: reverse, child: math)
      : FittedBox(
          fit: BoxFit.scaleDown,
          alignment: reverse ? Alignment.centerRight : Alignment.centerLeft,
          child: math,
        );
}

/// The solution as plain text, for Copy.
String mathPlainText(MathSolution s, ScannerLocalizations l) => [
  if (s.problem.isNotEmpty) l.mathCopyProblem(s.problem),
  l.mathCopyAnswer(s.answer),
  '',
  for (final (i, step) in s.steps.indexed)
    step.title.isEmpty ? '${i + 1}. ${step.expr}' : '${i + 1}. ${step.title}\n   ${step.expr}',
].join('\n');

/// "Math · x = 5": the saved document's name, about 40 characters at most.
String mathTitle(MathSolution s, [ScannerLocalizations? l]) {
  final t = (l ?? scannerEnglish).mathTitle(s.answer.replaceAll(RegExp(r'\s+'), ' ').trim());
  return t.length <= 40 ? t : '${t.substring(0, 39).trimRight()}…';
}

/// Steps per A4 card as (first index, count): the first page also holds the photo, problem and answer.
/// ponytail: fixed caps, not measured; [MathCard] shrinks a page that still overflows (very tall steps).
List<(int, int)> mathCardChunks(int steps, {required bool photo}) {
  final out = <(int, int)>[];
  var first = 0, cap = photo ? 4 : 6;
  do {
    out.add((first, math.min(cap, steps - first)));
    first += cap;
    cap = 9;
  } while (first < steps);
  return out;
}

/// One A4 page of the saved solution (see [renderCard]): header, the photo, problem and answer on the first page,
/// steps [first]..[first]+[count], and a footer with the time and page number.
class MathCard extends StatelessWidget {
  const MathCard(
    this.s, {
    super.key,
    this.photo,
    required this.first,
    required this.count,
    required this.page,
    required this.pages,
    required this.time,
  });
  final MathSolution s;
  final ui.Image? photo;
  final int first, count, page, pages;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final width = cardPage.width - 80;
    final l = context.l10n;
    final label = TextStyles.caption2Semibold.copyWith(color: _p.textTertiary, letterSpacing: .8);
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(page == 0 ? l.mathCardTitle : l.mathCardContinued, style: label),
                      const SizedBox(height: 10),
                      _header(s, l, size: 40),
                      Divider(height: 28, color: _p.borderSubtle),
                      if (page == 0) ...[
                        if (photo case final img?) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ColoredBox(
                              color: _p.bgFill,
                              child: SizedBox(
                                width: width,
                                height: math.min(170, width * img.height / img.width),
                                child: RawImage(image: img, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (s.problem.isNotEmpty || s.problemTex != null) ...[
                          Text(l.mathCardProblem, style: label),
                          const SizedBox(height: 6),
                          mathView(
                            s.problemTex,
                            s.problem,
                            TextStyles.bodyMedium.copyWith(color: _p.textPrimary),
                            scroll: false,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _answer(s, l, scroll: false),
                        const SizedBox(height: 18),
                      ],
                      Text(l.mathCardSteps, style: label),
                      const SizedBox(height: 4),
                      for (var i = first; i < first + count; i++) _step(i + 1, s.steps[i], scroll: false),
                    ],
                  ),
                ),
              ),
            ),
            Divider(height: 20, color: _p.borderSubtle),
            Row(
              children: [
                Expanded(
                  child: Text(
                    cardStamp(time, context.dateLocale),
                    style: TextStyles.caption1.copyWith(color: _p.textTertiary),
                  ),
                ),
                if (pages > 1)
                  Text(l.pageOf(page + 1, pages), style: TextStyles.caption1.copyWith(color: _p.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Solving with AI…" with a pulsing sparkle and shimmering placeholder lines.
class _Solving extends StatefulWidget {
  const _Solving();

  @override
  State<_Solving> createState() => _SolvingState();
}

class _SolvingState extends State<_Solving> with SingleTickerProviderStateMixin {
  late final pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: context.l10n.solvingWithAiLabel,
    child: AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        double wave(double phase) => .5 - .5 * math.cos(2 * math.pi * (pulse.value - phase));
        return Column(
          key: const ValueKey('solving'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: squircleBox(12, color: _p.brandSoft),
                  child: Transform.scale(
                    scale: .85 + .3 * wave(0),
                    child: Transform.rotate(
                      angle: .25 * math.sin(2 * math.pi * pulse.value),
                      child: Icon(IconsaxPlusLinear.magic_star, color: _p.brand),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.solvingWithAi, style: TextStyles.headline.copyWith(color: _p.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.solvingDetail,
                        style: TextStyles.footnoteMedium.copyWith(color: _p.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            for (final (i, w) in const [1.0, .72, .86].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FractionallySizedBox(
                  widthFactor: w,
                  child: Container(
                    height: i == 0 ? 54 : 14,
                    decoration: BoxDecoration(
                      color: Color.lerp(_p.bgFill, _p.bgFillStrong, wave(i * .18)),
                      borderRadius: BorderRadius.circular(i == 0 ? 16 : 7),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
