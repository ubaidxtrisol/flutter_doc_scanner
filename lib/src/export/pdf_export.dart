import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../engine.dart';
import '../scanner.dart';
import '../scanner/session.dart';

/// Renders every page at print quality and writes `<name>.pdf` to the app documents folder.
/// Each PDF page takes the scan's own aspect ratio at A4 width, so receipts aren't shrunk onto A4;
/// grouped pages (ID front + back) share one A4 sheet at real card size.
Future<File> exportPdf(List<ScanPage> pages, String name) async {
  final tmp = await getTemporaryDirectory();
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final rendered = await Future.wait([
    for (final (i, p) in pages.indexed)
      () async {
        final out = '${tmp.path}/export_${stamp}_$i.jpg';
        await DocScanner.process(
          path: p.original,
          outPath: out,
          corners: p.corners,
          rotation: p.rotation,
          filter: p.filter,
          maxSize: Scanner.exportSize,
          brightness: p.brightness,
          contrast: p.contrast,
        );
        return File(out);
      }(),
  ]);

  final title = name.trim().isEmpty ? 'Scan' : name.trim();
  final doc = pw.Document(title: title);
  // JPEG is embedded as-is, no re-encode.
  final images = [for (final f in rendered) pw.MemoryImage(await f.readAsBytes())];
  for (var i = 0; i < pages.length;) {
    final group = pages[i].group;
    if (group == null) {
      final image = images[i++];
      final width = PdfPageFormat.a4.width;
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(width, width * image.height! / image.width!),
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Image(image, fit: pw.BoxFit.fill),
        ),
      );
      continue;
    }
    final members = <pw.MemoryImage>[];
    final sideBySide = pages[i].sideBySide;
    while (i < pages.length && pages[i].group == group) {
      members.add(images[i++]);
    }
    doc.addPage(
      sideBySide
          ? pw.Page(pageFormat: PdfPageFormat.a4.landscape, build: (_) => _idSheet(members, row: true))
          : pw.Page(pageFormat: PdfPageFormat.a4, build: (_) => _idSheet(members, row: false)),
    );
  }

  final dir = await getApplicationDocumentsDirectory();
  final safe = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  var out = File('${dir.path}/$safe.pdf');
  for (var n = 2; out.existsSync(); n++) {
    out = File('${dir.path}/$safe ($n).pdf');
  }
  await out.writeAsBytes(await doc.save());
  for (final f in rendered) {
    f.delete().ignore();
  }
  return out;
}

/// ID-copy layout: each side at real ID-1 size (85.6 × 54 mm), stacked on portrait A4 or in a row on landscape A4.
pw.Widget _idSheet(List<pw.MemoryImage> sides, {required bool row}) {
  final cards = [
    for (final side in sides)
      pw.Padding(
        padding: row ? const pw.EdgeInsets.symmetric(horizontal: 18) : const pw.EdgeInsets.only(bottom: 36),
        child: side.width! >= side.height!
            ? pw.SizedBox(width: 85.6 * PdfPageFormat.mm, height: 54 * PdfPageFormat.mm, child: pw.Image(side))
            : pw.SizedBox(width: 54 * PdfPageFormat.mm, height: 85.6 * PdfPageFormat.mm, child: pw.Image(side)),
      ),
  ];
  return row
      ? pw.Padding(
          padding: const pw.EdgeInsets.only(top: 48),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: cards,
          ),
        )
      : pw.Padding(
          padding: const pw.EdgeInsets.only(top: 48),
          child: pw.Column(children: cards),
        );
}
