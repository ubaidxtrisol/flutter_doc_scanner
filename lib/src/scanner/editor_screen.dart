import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../engine.dart';
import 'crop_editor.dart';
import 'session.dart';
import 'ui.dart';

enum _Panel { none, filters, crop }

const _filterNames = {
  PageFilter.original: 'Original',
  PageFilter.magic: 'Magic',
  PageFilter.gray: 'Grayscale',
  PageFilter.bw: 'B&W',
};

/// Per-page editor: swipe between pages, crop (with loupe), rotate, filters, retake, delete.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key, required this.session, required this.initialIndex});
  final ScanSession session;
  final int initialIndex;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final pager = PageController(initialPage: widget.initialIndex);
  late int index = widget.initialIndex;
  final cropArea = GlobalKey();
  _Panel panel = _Panel.none;
  List<Offset>? draft;
  Offset? loupe;
  final thumbs = <PageFilter, String>{};

  ScanSession get session => widget.session;
  ScanPage get page => session.pages[index];

  @override
  void dispose() {
    pager.dispose();
    super.dispose();
  }

  void _edit(void Function(ScanPage p) change) {
    change(page);
    thumbs.clear();
    session.update(page);
    if (panel == _Panel.filters) _loadThumbs();
  }

  Future<void> _loadThumbs() async {
    final p = page;
    final key = Object.hash(p.original, p.rotation, Object.hashAll(p.corners ?? const []));
    final tmp = (await getTemporaryDirectory()).path;
    await Future.wait([
      for (final f in PageFilter.values)
        () async {
          final out = '$tmp/thumb_${key}_${f.name}.jpg';
          if (!File(out).existsSync()) {
            await DocScanner.process(
                path: p.original, outPath: out, corners: p.corners, rotation: p.rotation, filter: f, maxSize: 300);
          }
          if (mounted && p == page) setState(() => thumbs[f] = out);
        }(),
    ]);
  }

  void _applyFilterToAll() {
    for (final p in session.pages) {
      if (p != page && p.filter != page.filter) {
        p.filter = page.filter;
        session.update(p);
      }
    }
    _snack('${_filterNames[page.filter]} applied to all pages');
  }

  void _retake() {
    session.retakeIndex = index;
    Navigator.of(context).popUntil(ModalRoute.withName('scanner'));
  }

  void _delete() {
    final i = index, removed = page;
    session.remove(removed);
    if (session.pages.isEmpty) return Navigator.of(context).pop();
    setState(() => index = math.min(i, session.pages.length - 1));
    thumbs.clear();
    _snack('Page ${i + 1} deleted', undo: () => session.insert(i, removed));
  }

  void _snack(String text, {VoidCallback? undo}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        action: undo == null ? null : SnackBarAction(label: 'Undo', onPressed: undo),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        if (session.pages.isEmpty) return const Scaffold(backgroundColor: Tone.chrome);
        index = index.clamp(0, session.pages.length - 1);
        final crop = panel == _Panel.crop;
        return Scaffold(
          backgroundColor: Tone.chrome,
          appBar: AppBar(
            backgroundColor: Tone.chrome,
            foregroundColor: Colors.white,
            title: Text(crop ? 'Adjust edges' : 'Page ${index + 1} of ${session.pages.length}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            centerTitle: true,
            automaticallyImplyLeading: !crop,
          ),
          body: Column(children: [
            Expanded(child: crop ? _cropView() : _pager()),
            if (panel == _Panel.filters) _filterStrip(),
            SafeArea(top: false, child: crop ? _cropBar() : _toolbar()),
          ]),
        );
      },
    );
  }

  Widget _pager() => PageView.builder(
        controller: pager,
        itemCount: session.pages.length,
        onPageChanged: (i) {
          setState(() => index = i);
          thumbs.clear();
          if (panel == _Panel.filters) _loadThumbs();
        },
        itemBuilder: (_, i) {
          final path = session.pages[i].preview;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: path == null
                ? const Center(child: CircularProgressIndicator())
                : InteractiveViewer(
                    maxScale: 5,
                    child: Center(child: Image.file(File(path), fit: BoxFit.contain, gaplessPlayback: true)),
                  ),
          );
        },
      );

  Widget _cropView() => Stack(key: cropArea, children: [
        Positioned.fill(
          child: RotatedBox(
            quarterTurns: page.rotation ~/ 90,
            child: CropEditor(
              image: ResizeImage(FileImage(File(page.original)), width: 1600, height: 1600, policy: ResizeImagePolicy.fit),
              corners: draft!,
              onChanged: (c) => setState(() => draft = c),
              onDrag: (g) => setState(() => loupe = g),
            ),
          ),
        ),
        if (loupe != null) _loupe(loupe!),
      ]);

  /// Magnifier pinned to the corner opposite the finger, so it's never under the thumb.
  Widget _loupe(Offset global) {
    final box = cropArea.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox();
    const size = 120.0;
    final p = box.globalToLocal(global);
    final left = p.dx < box.size.width / 2 ? box.size.width - size - 16 : 16.0;
    final center = Offset(left + size / 2, 16 + size / 2);
    return Positioned(
      left: left,
      top: 16,
      child: IgnorePointer(
        child: RawMagnifier(
          size: const Size.square(size),
          magnificationScale: 2.2,
          focalPointOffset: p - center,
          decoration: const MagnifierDecoration(
            shape: CircleBorder(side: BorderSide(color: Colors.white, width: 3)),
            shadows: [BoxShadow(color: Colors.black54, blurRadius: 12)],
          ),
          child: const Center(child: Icon(Icons.add, color: Tone.accent, size: 20)),
        ),
      ),
    );
  }

  Widget _cropBar() {
    Widget chip(String label, VoidCallback? onTap) => TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.white, disabledForegroundColor: Colors.white30),
          onPressed: onTap,
          child: Text(label),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(children: [
        chip('Cancel', () => setState(() => panel = _Panel.none)),
        const Spacer(),
        chip('Auto', page.detected == null ? null : () => setState(() => draft = page.detected)),
        chip('Full', () => setState(() => draft = fullPage)),
        const Spacer(),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Tone.accent),
          onPressed: () {
            HapticFeedback.lightImpact();
            _edit((p) => p.corners = draft);
            setState(() => panel = _Panel.none);
          },
          child: const Text('Done'),
        ),
      ]),
    );
  }

  Widget _toolbar() {
    Widget tool(IconData icon, String label, VoidCallback onTap, {bool on = false}) => Expanded(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(children: [
                Icon(icon, color: on ? Tone.accent : Colors.white),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(color: on ? Tone.accent : Colors.white70, fontSize: 12)),
              ]),
            ),
          ),
        );
    return Row(children: [
      tool(Icons.crop_rounded, 'Crop', () {
        setState(() {
          draft = page.corners ?? fullPage;
          panel = _Panel.crop;
        });
      }),
      tool(Icons.rotate_90_degrees_cw_outlined, 'Rotate', () => _edit((p) => p.rotation = (p.rotation + 90) % 360)),
      tool(Icons.auto_fix_high_outlined, 'Filters', on: panel == _Panel.filters, () {
        setState(() => panel = panel == _Panel.filters ? _Panel.none : _Panel.filters);
        if (panel == _Panel.filters) _loadThumbs();
      }),
      tool(Icons.camera_alt_outlined, 'Retake', _retake),
      tool(Icons.delete_outline_rounded, 'Delete', _delete),
    ]);
  }

  Widget _filterStrip() => SizedBox(
        height: 132,
        child: Row(children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final f in PageFilter.values)
                  GestureDetector(
                    onTap: () => _edit((p) => p.filter = f),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(children: [
                        Container(
                          width: 66,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Tone.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: page.filter == f ? Tone.accent : Colors.transparent, width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: thumbs[f] == null
                              ? const Center(child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                              : Image.file(File(thumbs[f]!), fit: BoxFit.cover, gaplessPlayback: true),
                        ),
                        const SizedBox(height: 6),
                        Text(_filterNames[f]!,
                            style: TextStyle(color: page.filter == f ? Tone.accent : Colors.white70, fontSize: 12)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: session.pages.length > 1 ? _applyFilterToAll : null,
            child: const Text('Apply\nto all', textAlign: TextAlign.center),
          ),
        ]),
      );
}
