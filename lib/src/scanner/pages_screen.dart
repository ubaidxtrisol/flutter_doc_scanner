import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../export/pdf_export.dart';
import 'editor_screen.dart';
import 'session.dart';
import 'ui.dart';

/// Review grid: reorder (long-press + drag), open the editor, add pages, export.
/// Pops `true` when the user is done with the scan, anything else returns to the camera.
class PagesScreen extends StatefulWidget {
  const PagesScreen({super.key, required this.session});
  final ScanSession session;

  @override
  State<PagesScreen> createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  late final name = TextEditingController(text: 'Scan ${_stamp(DateTime.now())}');
  bool exporting = false;
  File? saved;

  ScanSession get session => widget.session;

  @override
  void initState() {
    super.initState();
    session.addListener(_changed);
  }

  @override
  void dispose() {
    session.removeListener(_changed);
    name.dispose();
    super.dispose();
  }

  // An edit after exporting makes the exported PDF stale.
  void _changed() {
    if (saved != null) setState(() => saved = null);
  }

  static String _stamp(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}.${two(d.minute)}';
  }

  Future<void> _export() async {
    setState(() => exporting = true);
    try {
      final file = await exportPdf(session.pages, name.text);
      setState(() => saved = file);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/pdf')]));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  }

  void _openEditor(int index) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => EditorScreen(session: session, initialIndex: index),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        if (session.pages.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).maybePop();
          });
        }
        return Scaffold(
          backgroundColor: Tone.chrome,
          appBar: AppBar(
            backgroundColor: Tone.chrome,
            foregroundColor: Colors.white,
            titleSpacing: 0,
            title: TextField(
              controller: name,
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: InputBorder.none,
                suffixIcon: Icon(Icons.edit_outlined, size: 18, color: Tone.muted),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(ScanResult(List.of(session.pages), title: name.text, pdf: saved)),
                child: const Text(
                  'Done',
                  style: TextStyle(color: Tone.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: .68,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: session.pages.length,
            itemBuilder: (_, i) => _cell(i),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Add page'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Tone.accent,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: exporting ? null : _export,
                      icon: exporting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(saved == null ? 'Export PDF' : 'Share again'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cell(int i) => LayoutBuilder(
    builder: (context, box) => DragTarget<int>(
      onWillAcceptWithDetails: (d) => d.data != i,
      onAcceptWithDetails: (d) => session.move(d.data, i),
      builder: (context, candidates, _) => LongPressDraggable<int>(
        data: i,
        feedback: SizedBox.fromSize(size: box.biggest, child: _card(i, lifted: true)),
        childWhenDragging: Opacity(opacity: .3, child: _card(i)),
        child: GestureDetector(
          onTap: () => _openEditor(i),
          child: _card(i, highlight: candidates.isNotEmpty),
        ),
      ),
    ),
  );

  Widget _card(int i, {bool lifted = false, bool highlight = false}) {
    final page = session.pages[i];
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: Tone.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: highlight ? Tone.accent : Colors.transparent, width: 2),
                boxShadow: lifted ? const [BoxShadow(color: Colors.black54, blurRadius: 16)] : null,
              ),
              padding: const EdgeInsets.all(6),
              child: page.preview == null
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : Image(
                      image: ResizeImage(
                        FileImage(File(page.preview!)),
                        width: 600,
                        height: 800,
                        policy: ResizeImagePolicy.fit,
                      ),
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            page.label == null ? '${i + 1}' : '${i + 1} · ${page.label}',
            style: const TextStyle(color: Tone.muted, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
