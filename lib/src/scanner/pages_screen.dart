import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../strings.dart';
import 'editor_screen.dart';
import 'session.dart';
import 'ui.dart';

/// Figma 3.5 Multi-page Review: reorder (long-press + drag), rotate / delete per page, multi-select, add pages from
/// the camera or Photos, edit, and Save as PDF (pops a [ScanResult]; the host saves it). Back returns to the camera.
class PagesScreen extends StatefulWidget {
  const PagesScreen({super.key, required this.session, this.onAddFromPhotos});
  final ScanSession session;

  /// Imports gallery photos into the session (the camera screen's import for the current mode).
  final Future<void> Function()? onAddFromPhotos;

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  final selected = <ScanPage>{};
  bool selecting = false;

  ScanSession get session => widget.session;

  void _open(int i) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CropScreen(session: session, index: i),
    ),
  );

  void _rotate(Iterable<ScanPage> pages) {
    HapticFeedback.selectionClick();
    for (final p in pages) {
      p.rotation = (p.rotation + 90) % 360;
      session.update(p);
    }
  }

  void _delete(List<ScanPage> pages) {
    HapticFeedback.mediumImpact();
    final removed = [for (final p in pages) (session.pages.indexOf(p), p)]..sort((a, b) => a.$1.compareTo(b.$1));
    for (final (_, p) in removed) {
      session.remove(p);
    }
    setState(() {
      selected.clear();
      selecting = false;
    });
    showToast(
      context,
      removed.length == 1 ? context.l10n.pageDeleted(removed.single.$1 + 1) : context.l10n.pagesDeleted(removed.length),
      undo: () {
        for (final (i, p) in removed) {
          session.insert(i, p);
        }
      },
    );
  }

  Future<void> _addPage() async {
    final c = Palette.of(context);
    final choice = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: c.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        Widget row(IconData icon, String label, bool photos) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: squircleBox(12, color: c.brandSoft),
            child: Icon(icon, size: 20, color: c.brand),
          ),
          title: Text(label, style: TextStyles.body.copyWith(color: c.textPrimary)),
          onTap: () => Navigator.pop(context, photos),
        );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                row(IconsaxPlusLinear.camera, context.l10n.addFromCamera, false),
                if (widget.onAddFromPhotos != null) row(IconsaxPlusLinear.gallery, context.l10n.addFromPhotos, true),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || choice == null) return;
    if (choice) return widget.onAddFromPhotos!();
    Navigator.of(context).pop(); // back to the camera
  }

  @override
  Widget build(BuildContext context) {
    final c = Palette.of(context);
    final l = context.l10n;
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final n = session.pages.length;
        if (n == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).maybePop();
          });
        }
        selected.removeWhere((p) => !session.pages.contains(p));
        return LightScreen(
          title: selecting ? l.selectedCount(selected.length) : l.pagesTitle(n),
          right: NavText(
            selecting ? l.cancel : l.select,
            onTap: () {
              setState(() {
                selecting = !selecting;
                selected.clear();
              });
            },
          ),
          body: LayoutBuilder(
            builder: (context, box) {
              final w = (box.maxWidth - 40 - 13) / 2;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
                children: [
                  InfoBanner(
                    icon: IconsaxPlusLinear.info_circle,
                    text: selecting ? l.tapToSelect : l.dragToReorder,
                    fg: c.brand,
                    bg: c.brandSoft,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 13,
                    runSpacing: 14,
                    children: [
                      for (var i = 0; i < n; i++) Appear(key: ValueKey(session.pages[i]), index: i, child: _cell(i, w)),
                      if (!selecting) Appear(index: n, child: _addCard(c, w)),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: AnimatedSwitcher(
            duration: fast,
            child: selecting
                ? Row(
                    key: const ValueKey('select'),
                    children: [
                      SquareButton(
                        icon: IconsaxPlusLinear.rotate_right_1,
                        label: l.rotateSelected,
                        onTap: selected.isEmpty ? null : () => _rotate(selected),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ScanButton(
                          selected.isEmpty ? l.delete : l.deleteCount(selected.length),
                          icon: IconsaxPlusLinear.trash,
                          kind: ButtonKind.danger,
                          onPressed: selected.isEmpty ? null : () => _delete([...selected]),
                        ),
                      ),
                    ],
                  )
                : Row(
                    key: const ValueKey('save'),
                    children: [
                      SquareButton(
                        icon: IconsaxPlusLinear.edit_2,
                        label: l.editPages,
                        onTap: () => Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (_) => EnhanceScreen(session: session, initialIndex: 0))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ScanButton(
                          l.saveAsPdf,
                          icon: IconsaxPlusLinear.document_download,
                          onPressed: () => Navigator.of(
                            context,
                          ).pop(ScanResult(List.of(session.pages), title: scanTitle(session.pages, l))),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _cell(int i, double w) {
    final page = session.pages[i];
    final card = SizedBox(width: w, child: _card(i));
    if (selecting) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => selected.contains(page) ? selected.remove(page) : selected.add(page));
        },
        child: card,
      );
    }
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) => d.data != i,
      onAcceptWithDetails: (d) {
        HapticFeedback.selectionClick();
        session.move(d.data, i);
      },
      builder: (context, candidates, _) => LongPressDraggable<int>(
        data: i,
        onDragStarted: HapticFeedback.mediumImpact,
        feedback: Material(
          type: MaterialType.transparency,
          child: Transform.rotate(
            angle: .03,
            child: SizedBox(width: w, child: _card(i, lifted: true)),
          ),
        ),
        childWhenDragging: Opacity(opacity: .35, child: card),
        child: GestureDetector(
          onTap: () => _open(i),
          child: SizedBox(
            width: w,
            child: _card(i, lifted: candidates.isNotEmpty),
          ),
        ),
      ),
    );
  }

  Widget _card(int i, {bool lifted = false}) {
    final c = Palette.of(context);
    final page = session.pages[i];
    final on = lifted || selected.contains(page);
    final image = page.preview;
    return AnimatedContainer(
      duration: fast,
      padding: EdgeInsets.all(on ? 8 : 10),
      decoration: squircleBox(
        20,
        color: c.bgCard,
        side: on ? BorderSide(color: c.brand, width: 2) : BorderSide.none,
        shadows: on ? Shadows.raised : Shadows.xs,
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 150 / 196,
            child: Container(
              decoration: squircleBox(12, color: c.bgFill),
              padding: const EdgeInsets.all(12),
              child: image == null
                  ? const Center(
                      child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), boxShadow: Shadows.card),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image(
                            image: ResizeImage(
                              FileImage(File(image)),
                              width: 450,
                              height: 600,
                              policy: ResizeImagePolicy.fit,
                            ),
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: fast,
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: on ? c.brand : c.bgFill, shape: BoxShape.circle),
                  child: Text(
                    '${i + 1}',
                    style: TextStyles.caption1Medium.copyWith(color: on ? Colors.white : c.textPrimary),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    page.label ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles.caption1.copyWith(color: c.textSecondary),
                  ),
                ),
                if (!selecting) ...[
                  _icon(
                    IconsaxPlusLinear.rotate_right_1,
                    context.l10n.rotatePage(i + 1),
                    c.textPrimary,
                    () => _rotate([page]),
                  ),
                  const SizedBox(width: 10),
                  _icon(IconsaxPlusLinear.trash, context.l10n.deletePage(i + 1), c.red, () => _delete([page])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _icon(IconData icon, String label, Color color, VoidCallback onTap) => Pressable(
    label: label,
    scale: .85,
    onTap: onTap,
    child: SizedBox(width: 26, height: 26, child: Icon(icon, size: 18, color: color)),
  );

  Widget _addCard(Palette c, double w) => Pressable(
    label: context.l10n.addPage,
    onTap: _addPage,
    child: SizedBox(
      width: w,
      height: w * 250 / 170,
      child: CustomPaint(
        painter: _DashedBorder(c.brand, c.brandSoft),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: c.brand, shape: BoxShape.circle),
              child: const Icon(IconsaxPlusLinear.add, size: 26, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(context.l10n.addPage, style: TextStyles.subheadSemibold.copyWith(color: c.brand)),
            const SizedBox(height: 10),
            Text(context.l10n.cameraOrPhotos, style: TextStyles.caption1.copyWith(color: c.textSecondary)),
          ],
        ),
      ),
    ),
  );
}

/// Figma "Add Page": brand-soft fill, 1.5 pt dashed brand outline, r20.
class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color, this.fill);
  final Color color, fill;

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20)).deflate(.75);
    canvas.drawRRect(r, Paint()..color = fill);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in (Path()..addRRect(r)).computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color || old.fill != fill;
}
