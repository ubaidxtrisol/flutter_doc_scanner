import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'ui.dart';

/// A4 portrait in logical points: result cards (math, QR, measure, count) are laid out on it, so the exported
/// PDF page looks like a document.
const cardPage = Size(595, 842);

/// Renders [card] offscreen at [size] × [pixelRatio] to a PNG in the cache and returns its path.
///
/// The card inherits [context]'s theme, text style (the host's Inter) and directionality. Everything in it must
/// paint synchronously: pass photos as decoded `ui.Image`s through [RawImage], not `Image.file`.
Future<String> renderCard(BuildContext context, Widget card, {Size size = cardPage, double pixelRatio = 2.5}) async {
  final view = View.of(context);
  final boundary = RenderRepaintBoundary();
  final root = RenderView(
    view: view,
    child: RenderPositionedBox(alignment: Alignment.topLeft, child: boundary),
    configuration: ViewConfiguration(
      logicalConstraints: BoxConstraints.tight(size),
      physicalConstraints: BoxConstraints.tight(size * pixelRatio),
      devicePixelRatio: pixelRatio,
    ),
  );
  final pipeline = PipelineOwner()..rootNode = root;
  root.prepareInitialFrame();
  final build = BuildOwner(focusManager: FocusManager());
  final element = RenderObjectToWidgetAdapter<RenderBox>(
    container: boundary,
    child: InheritedTheme.captureAll(
      context,
      MediaQuery(
        data: MediaQueryData(size: size, devicePixelRatio: pixelRatio, textScaler: TextScaler.noScaling),
        child: Directionality(
          textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
          // The theme's body style (the host's Inter). Not DefaultTextStyle.of(context): callers' contexts often
          // sit above their Scaffold, where it's the red, yellow-underlined "no Material" error style.
          child: Material(
            type: MaterialType.transparency,
            child: SizedBox.fromSize(size: size, child: card),
          ),
        ),
      ),
    ),
  ).attachToRenderTree(build);
  build
    ..buildScope(element)
    ..finalizeTree();
  pipeline
    ..flushLayout()
    ..flushCompositingBits()
    ..flushPaint();
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  try {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final out = File('${(await getTemporaryDirectory()).path}/card_${DateTime.now().microsecondsSinceEpoch}.png');
    await out.writeAsBytes(bytes!.buffer.asUint8List());
    return out.path;
  } finally {
    image.dispose();
  }
}

/// Decodes an image file for [RawImage] in a card, downscaled to at most [maxWidth] px.
Future<ui.Image> decodeForCard(String path, {int maxWidth = 1600}) async {
  final codec = await ui.instantiateImageCodec(
    await File(path).readAsBytes(),
    targetWidth: maxWidth,
    allowUpscaling: false,
  );
  try {
    return (await codec.getNextFrame()).image;
  } finally {
    codec.dispose();
  }
}

/// "Oct 1, 2026 · 14:05" for card footers.
String cardStamp(DateTime t) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String two(int n) => n.toString().padLeft(2, '0');
  return '${m[t.month - 1]} ${t.day}, ${t.year} · ${two(t.hour)}:${two(t.minute)}';
}

/// A4 result card with a photo (count, measure): [title], the photo as large as fits, [details] below it, then a
/// footer with the date and [note]. Always light: it's a printed page, not app chrome.
class PhotoCard extends StatelessWidget {
  const PhotoCard({
    super.key,
    required this.title,
    required this.photo,
    required this.details,
    required this.note,
    required this.time,
  });
  final String title, note;
  final ui.Image photo;
  final Widget details;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    const p = Palette.light;
    final small = TextStyles.caption1.copyWith(color: p.textTertiary);
    return ColoredBox(
      color: p.bgCard,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 36, 40, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: TextStyles.title3.copyWith(color: p.textPrimary)),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: photo.width / photo.height,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: RawImage(image: photo, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            details,
            const SizedBox(height: 20),
            ColoredBox(color: p.borderSubtle, child: const SizedBox(height: 1)),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(cardStamp(time), style: small),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(note, textAlign: TextAlign.end, style: small),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One "label · value" line of a [PhotoCard]'s details, with an optional small [note] after the value.
class CardFact extends StatelessWidget {
  const CardFact(this.label, this.value, {super.key, this.note});
  final String label, value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    const p = Palette.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyles.subhead.copyWith(color: p.textSecondary)),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: value,
                style: TextStyles.subheadSemibold.copyWith(color: p.textPrimary),
                children: [
                  if (note != null)
                    TextSpan(
                      text: '   $note',
                      style: TextStyles.caption1.copyWith(color: p.textTertiary),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
