import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Camera-screen colours (always dark), exact values from the DocScan Figma.
abstract final class Tone {
  static const chrome = Color(0xFF0B0D12);
  static const surface = Color(0xFF1C1F26);

  /// Translucent camera buttons (`rgba(255,255,255,.12)`).
  static const chip = Color(0x1FFFFFFF);

  /// Status pill (`rgba(14,17,22,.7)`).
  static const pill = Color(0xB30E1116);

  /// Inactive mode tab (white 50%).
  static const muted = Color(0x80FFFFFF);

  /// Overlays on the camera: detected quad, brackets, tab dot, detected shutter.
  static const accent = Color(0xFF4F83FF);

  /// `brand/primary` (light): corner handles, badges.
  static const brand = Color(0xFF2F6BFF);

  /// `accent/green` (light): "detected" pill.
  static const success = Color(0xFF16B364);
  static const auto = Color(0xFFFFD60A);
}

/// Light / dark colour tokens for the review, editor and result screens (Figma `Color` collection; mirrors the host
/// app's `AppColors`, which this package must not import). Picked from the ambient [Theme] brightness.
@immutable
class Palette {
  const Palette._({
    required this.bgBase,
    required this.bgCard,
    required this.bgFill,
    required this.bgFillStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.borderSubtle,
    required this.borderStrong,
    required this.brand,
    required this.brandPressed,
    required this.brandSoft,
    required this.green,
    required this.greenSoft,
    required this.orange,
    required this.orangeSoft,
    required this.red,
    required this.redSoft,
    required this.purple,
    required this.purpleSoft,
    required this.teal,
    required this.tealSoft,
  });

  final Color bgBase, bgCard, bgFill, bgFillStrong, textPrimary, textSecondary, textTertiary;
  final Color borderSubtle, borderStrong, brand, brandPressed, brandSoft;
  final Color green, greenSoft, orange, orangeSoft, red, redSoft, purple, purpleSoft, teal, tealSoft;

  static const light = Palette._(
    bgBase: Color(0xFFF4F5F9),
    bgCard: Color(0xFFFFFFFF),
    bgFill: Color(0xFFEEF0F5),
    bgFillStrong: Color(0xFFE3E6ED),
    textPrimary: Color(0xFF0E1116),
    textSecondary: Color(0xFF5B6272),
    textTertiary: Color(0xFF9AA0AE),
    borderSubtle: Color(0xFFE7E9EF),
    borderStrong: Color(0xFFD5D9E2),
    brand: Color(0xFF2F6BFF),
    brandPressed: Color(0xFF1F55E0),
    brandSoft: Color(0xFFEAF0FF),
    green: Color(0xFF16B364),
    greenSoft: Color(0xFFE6F8EF),
    orange: Color(0xFFF97316),
    orangeSoft: Color(0xFFFFF1E6),
    red: Color(0xFFEF4444),
    redSoft: Color(0xFFFDECEC),
    purple: Color(0xFF8B5CF6),
    purpleSoft: Color(0xFFF2ECFF),
    teal: Color(0xFF0EA5A4),
    tealSoft: Color(0xFFE3F7F6),
  );

  static const dark = Palette._(
    bgBase: Color(0xFF0A0C11),
    bgCard: Color(0xFF15181F),
    bgFill: Color(0xFF1E222B),
    bgFillStrong: Color(0xFF2A2F3A),
    textPrimary: Color(0xFFF3F5F9),
    textSecondary: Color(0xFFA0A7B8),
    textTertiary: Color(0xFF626A7C),
    borderSubtle: Color(0xFF232833),
    borderStrong: Color(0xFF343A47),
    brand: Color(0xFF4F83FF),
    brandPressed: Color(0xFF3A6FF0),
    brandSoft: Color(0xFF18223D),
    green: Color(0xFF34D399),
    greenSoft: Color(0xFF10291D),
    orange: Color(0xFFFB923C),
    orangeSoft: Color(0xFF2D1D10),
    red: Color(0xFFF87171),
    redSoft: Color(0xFF2E1616),
    purple: Color(0xFFA78BFA),
    purpleSoft: Color(0xFF241C3B),
    teal: Color(0xFF2DD4BF),
    tealSoft: Color(0xFF0E2827),
  );

  static Palette of(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? dark : light;
}

/// Figma text styles. No font family: Inter comes from the host theme.
abstract final class TextStyles {
  static TextStyle _s(double size, double line, FontWeight w, double tracking) => TextStyle(
    fontSize: size,
    height: line / size,
    fontWeight: w,
    letterSpacing: tracking,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static final title3 = _s(20, 25, FontWeight.w600, -0.45);
  static final headline = _s(17, 22, FontWeight.w600, -0.43);
  static final body = _s(17, 22, FontWeight.w400, -0.43);
  static final bodyMedium = _s(17, 22, FontWeight.w500, -0.43);
  static final subhead = _s(15, 20, FontWeight.w400, -0.23);
  static final subheadSemibold = _s(15, 20, FontWeight.w600, -0.23);
  static final footnoteMedium = _s(13, 18, FontWeight.w500, -0.08);
  static final footnoteSemibold = _s(13, 18, FontWeight.w600, -0.08);
  static final caption1 = _s(12, 16, FontWeight.w400, 0);
  static final caption1Medium = _s(12, 16, FontWeight.w500, 0);
  static final caption2Semibold = _s(11, 13, FontWeight.w600, 0.06);
}

/// Figma effect styles.
abstract final class Shadows {
  static const xs = [BoxShadow(color: Color(0x0A0F1729), offset: Offset(0, 1), blurRadius: 2)];
  static const card = [
    BoxShadow(color: Color(0x0A0F1729), offset: Offset(0, 1), blurRadius: 3),
    BoxShadow(color: Color(0x0F0F1729), offset: Offset(0, 8), blurRadius: 24, spreadRadius: -4),
  ];
  static const raised = [
    BoxShadow(color: Color(0x0F0F1729), offset: Offset(0, 2), blurRadius: 6),
    BoxShadow(color: Color(0x1A0F1729), offset: Offset(0, 16), blurRadius: 40, spreadRadius: -8),
  ];
  static const brand = [
    BoxShadow(color: Color(0x472F6BFF), offset: Offset(0, 10), blurRadius: 24, spreadRadius: -6),
    BoxShadow(color: Color(0x2E2F6BFF), offset: Offset(0, 2), blurRadius: 6),
  ];
}

/// Iconsax glyphs used by the scanner. The package's chevron names differ from Figma's.
abstract final class Icons2 {
  static const back = IconsaxPlusLinear.arrow_left_1;
  static const flash = IconsaxPlusLinear.flash_1;
  static const flashOn = IconsaxPlusBold.flash_1;
}

/// Continuous corners at Figma's 60% smoothing.
ShapeBorder squircle(double r, {BorderSide side = BorderSide.none}) => SmoothRectangleBorder(
  borderRadius: SmoothBorderRadius(cornerRadius: r, cornerSmoothing: .6),
  side: side,
);

ShapeDecoration squircleBox(double r, {Color? color, BorderSide side = BorderSide.none, List<BoxShadow>? shadows}) =>
    ShapeDecoration(
      color: color,
      shape: squircle(r, side: side),
      shadows: shadows,
    );

const fast = Duration(milliseconds: 200);

/// [AnimatedDefaultTextStyle] that merges into the inherited style, so the host's font (Inter) is kept.
class AnimatedStyle extends StatelessWidget {
  const AnimatedStyle({super.key, required this.style, required this.child});
  final TextStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      AnimatedDefaultTextStyle(duration: fast, style: DefaultTextStyle.of(context).style.merge(style), child: child);
}

/// Tap target with the design's press feedback (scale 0.97).
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.onTap, required this.child, this.label, this.scale = .97});
  final VoidCallback? onTap;
  final Widget child;
  final String? label;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  final pressed = ValueNotifier(false);

  @override
  void dispose() {
    pressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: on,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: on ? (_) => pressed.value = true : null,
        onTapUp: on ? (_) => pressed.value = false : null,
        onTapCancel: on ? () => pressed.value = false : null,
        child: ValueListenableBuilder(
          valueListenable: pressed,
          builder: (_, p, child) => AnimatedScale(
            scale: p ? widget.scale : 1,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: child,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Round translucent icon button from the camera top bar (40 pt, icon 20).
class ChipButton extends StatelessWidget {
  const ChipButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.size = 20,
    this.angle = 0,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double size;

  /// Rotation in radians (Figma draws "close" as `add` turned 45°).
  final double angle;

  @override
  Widget build(BuildContext context) => Pressable(
    label: label,
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(color: Tone.chip, shape: BoxShape.circle),
      child: Transform.rotate(
        angle: angle,
        child: Icon(icon, size: size, color: color ?? Colors.white),
      ),
    ),
  );
}

/// Status pill ("Point at a document", "Document detected · Hold still"): Footnote Medium, r16.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.icon, required this.text, this.color = Tone.pill});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: fast,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.footnoteMedium.copyWith(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

/// Small dark chip on imagery ("Page 1 of 3", "Left · 1"): Caption 1 Medium, r12.
class ImageChip extends StatelessWidget {
  const ImageChip(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Tone.pill, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: TextStyles.caption1Medium.copyWith(color: Colors.white)),
  );
}

enum ButtonKind { primary, secondary, tonal, danger }

/// Figma `Button` Large: 54 high, r16, Headline label, optional 22 pt icon.
class ScanButton extends StatelessWidget {
  const ScanButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.kind = ButtonKind.primary,
    this.busy = false,
    this.palette,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonKind kind;
  final bool busy;

  /// Fixed colours for surfaces that ignore the theme (the light result sheets over the camera).
  final Palette? palette;

  @override
  Widget build(BuildContext context) {
    final c = palette ?? Palette.of(context);
    final (fill, fg) = switch (kind) {
      ButtonKind.primary => (c.brand, Colors.white),
      ButtonKind.secondary => (c.bgCard, c.textPrimary),
      ButtonKind.tonal => (c.brandSoft, c.brand),
      ButtonKind.danger => (c.redSoft, c.red),
    };
    final enabled = onPressed != null && !busy;
    return AnimatedOpacity(
      opacity: onPressed == null ? .4 : 1,
      duration: fast,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: squircleBox(
            16,
            color: fill,
            side: kind == ButtonKind.secondary ? BorderSide(color: c.borderStrong) : BorderSide.none,
            shadows: kind == ButtonKind.primary && enabled ? Shadows.brand : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
              else if (icon != null)
                Icon(icon, size: 22, color: fg),
              if (busy || icon != null) const SizedBox(width: 8),
              Flexible(
                child: AnimatedSwitcher(
                  duration: fast,
                  child: Text(
                    label,
                    key: ValueKey(label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.headline.copyWith(color: fg),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Square card-coloured icon button (54 pt "edit", 48 pt crop tools).
class SquareButton extends StatelessWidget {
  const SquareButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.size = 54,
    this.selected = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Pressable(
      label: label,
      onTap: onTap,
      child: AnimatedContainer(
        duration: fast,
        width: size,
        height: size,
        decoration: squircleBox(
          16,
          color: selected ? c.brandSoft : c.bgCard,
          side: selected ? BorderSide(color: c.brand, width: 1.5) : BorderSide.none,
          shadows: selected ? null : Shadows.xs,
        ),
        child: Icon(icon, size: 22, color: selected ? c.brand : c.textPrimary),
      ),
    );
  }
}

/// Round card-coloured 40 pt nav button (Back, rotate, export).
class NavCircle extends StatelessWidget {
  const NavCircle({super.key, required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Pressable(
      label: label,
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: c.bgCard, shape: BoxShape.circle, boxShadow: Shadows.xs),
        child: Icon(icon, size: 20, color: c.textPrimary),
      ),
    );
  }
}

/// Brand text action in the nav bar ("Reset", "Select", "Done").
class NavText extends StatelessWidget {
  const NavText(this.text, {super.key, required this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: AnimatedSwitcher(
        duration: fast,
        child: Text(
          text,
          key: ValueKey(text),
          style: TextStyles.headline.copyWith(color: Palette.of(context).brand),
        ),
      ),
    ),
  );
}

/// Light screen shell (Figma 3.3–3.5, 9.2–9.4): `bg/base`, 52 pt nav bar (back · title · [right]), body, and a
/// bottom action row 10 pt above the home indicator.
class LightScreen extends StatelessWidget {
  const LightScreen({super.key, required this.title, required this.body, this.right, this.actions, this.onBack});
  final String title;
  final Widget body;
  final Widget? right;
  final Widget? actions;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: c.bgBase,
        body: SafeArea(
          bottom: actions == null,
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: NavCircle(
                            icon: Icons2.back,
                            label: 'Back',
                            onTap: onBack ?? () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: fast,
                          child: Text(
                            title,
                            key: ValueKey(title),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.headline.copyWith(color: c.textPrimary),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 88,
                        child: Align(alignment: Alignment.centerRight, child: right),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
        // As the bottom bar, so toasts float above the buttons instead of covering them.
        bottomNavigationBar: actions == null
            ? null
            : SafeArea(
                top: false,
                child: Padding(padding: const EdgeInsets.fromLTRB(20, 10, 20, 10), child: actions),
              ),
      ),
    );
  }
}

/// Soft-tinted info row ("Long-press and drag to reorder pages", "Valid for 5 more years").
class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.text,
    required this.fg,
    required this.bg,
    this.radius = 14,
  });
  final IconData icon;
  final String text;
  final Color fg, bg;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: squircleBox(radius, color: bg),
    child: Row(
      children: [
        Icon(icon, size: 18, color: fg),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: TextStyles.footnoteMedium.copyWith(color: fg)),
        ),
      ],
    ),
  );
}

/// Figma `Segmented`: `bg/fill` track r12, 3 pt inset, selected = card + Shadow/XS, sliding.
class Segmented<T> extends StatelessWidget {
  const Segmented({super.key, required this.options, required this.value, required this.onChanged});
  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final keys = options.keys.toList();
    final i = keys.indexOf(value);
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: squircleBox(12, color: c.bgFill),
      child: LayoutBuilder(
        builder: (context, box) {
          final w = (box.maxWidth - 2 * (keys.length - 1)) / keys.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: i * (w + 2),
                top: 0,
                bottom: 0,
                width: w,
                child: DecoratedBox(
                  decoration: squircleBox(9, color: c.bgCard, shadows: Shadows.xs),
                ),
              ),
              Row(
                children: [
                  for (final (j, k) in keys.indexed) ...[
                    if (j > 0) const SizedBox(width: 2),
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: k == value,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (k != value) HapticFeedback.selectionClick();
                            onChanged(k);
                          },
                          child: Center(
                            child: AnimatedStyle(
                              style: k == value
                                  ? TextStyles.footnoteSemibold.copyWith(color: c.textPrimary)
                                  : TextStyles.footnoteMedium.copyWith(color: c.textSecondary),
                              child: Text(options[k]!, maxLines: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// iOS-style switch (51×31): on = brand, off = `bg/fill-strong`.
class ScanToggle extends StatelessWidget {
  const ScanToggle({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      applyCupertinoTheme: false,
      activeTrackColor: c.brand,
      inactiveTrackColor: c.bgFillStrong,
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }
}

/// Short fade + rise for list items appearing one after another ([index] staggers by 50 ms).
class Appear extends StatelessWidget {
  const Appear({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + 50 * index.clamp(0, 8)),
      curve: Interval(index.clamp(0, 8) * 50 / (280 + 50 * index.clamp(0, 8)), 1, curve: Curves.easeOutCubic),
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}

/// Short confirmation toast (snack bar) in the design's pill style.
void showToast(BuildContext context, String text, {VoidCallback? undo}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text, style: TextStyles.footnoteMedium.copyWith(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xE60E1116),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        action: undo == null ? null : SnackBarAction(label: 'Undo', textColor: Tone.accent, onPressed: undo),
      ),
    );
}
