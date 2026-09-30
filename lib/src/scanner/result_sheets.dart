import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../math/solver.dart';
import 'qr_payload.dart';
import 'ui.dart';

// Result sheets sit over the camera and are always light (Figma 7.3 / 7.4).
const _ink = Color(0xFF0E1116); // text/primary
const _sub = Color(0xFF5B6272); // text/secondary
const _tile = Color(0xFFEAF0FF); // brand/soft

/// Figma 7.3 result sheet. The camera keeps running behind it (no dim barrier).
Future<void> showQrSheet(BuildContext context, QrPayload p) {
  final (icon, action) = switch (p.kind) {
    QrKind.url => (Icons.language_rounded, 'Open Link'),
    QrKind.email => (Icons.mail_outline_rounded, 'Send Email'),
    QrKind.phone => (Icons.call_outlined, 'Call'),
    QrKind.sms => (Icons.sms_outlined, 'Message'),
    QrKind.geo => (Icons.place_outlined, 'Open Map'),
    QrKind.wifi => (Icons.wifi_rounded, 'Copy Password'),
    QrKind.contact => (Icons.person_outline_rounded, 'Share'),
    QrKind.text => (Icons.notes_rounded, 'Share'),
  };
  Future<void> primary() async {
    if (p.link != null) {
      await launchUrl(p.link!, mode: LaunchMode.externalApplication);
    } else if (p.kind == QrKind.wifi) {
      await Clipboard.setData(ClipboardData(text: p.secret ?? ''));
    } else {
      await SharePlus.instance.share(ShareParams(text: p.raw));
    }
  }

  return _sheet(context, (context) {
    var copied = false;
    return StatefulBuilder(
      builder: (context, setState) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: _tile, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Tone.brand),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: const TextStyle(color: _sub, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      p.display,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _outlined(
                  copied ? Icons.check_rounded : Icons.copy_rounded,
                  copied ? 'Copied' : 'Copy',
                  () async {
                    await Clipboard.setData(ClipboardData(text: p.kind == QrKind.url ? p.link.toString() : p.raw));
                    HapticFeedback.lightImpact();
                    setState(() => copied = true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _filled(p.link != null ? Icons.ios_share_rounded : Icons.arrow_forward_rounded, action, primary),
              ),
            ],
          ),
        ],
      ),
    );
  });
}

/// Figma 7.4: problem type + step count, green answer card, numbered steps. [solving] may take a few
/// seconds (cloud), so the sheet opens at once with a spinner.
Future<void> showMathSheet(BuildContext context, Future<MathSolution> solving) => _sheet(
  context,
  (context) => FutureBuilder<MathSolution>(
    future: solving,
    builder: (context, snap) {
      if (snap.hasError) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded, color: _sub),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${snap.error}', style: const TextStyle(color: _ink, fontSize: 15)),
              ),
            ],
          ),
        );
      }
      final s = snap.data;
      if (s == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('Solving…', style: TextStyle(color: _sub, fontSize: 15)),
            ],
          ),
        );
      }
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .6),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: const Color(0xFFF1EDFE), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.calculate_outlined, color: Color(0xFF7C5CFC), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.type,
                      style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (s.online) const Icon(Icons.cloud_done_outlined, size: 16, color: _sub),
                  if (s.online) const SizedBox(width: 6),
                  Text(
                    '${s.steps.length} step${s.steps.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: _sub, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(s.problem, style: const TextStyle(color: _sub, fontSize: 13)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(color: const Color(0xFFE7F6EC), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const Text('Answer', style: TextStyle(color: Tone.success, fontSize: 15)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          s.answer,
                          style: const TextStyle(color: Tone.success, fontSize: 28, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final (i, step) in s.steps.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        margin: const EdgeInsets.only(top: 2),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: _tile, shape: BoxShape.circle),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(color: Tone.brand, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.title, style: const TextStyle(color: _sub, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(
                              step.expr,
                              style: const TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  ),
);

Future<T?> _sheet<T>(BuildContext context, WidgetBuilder body) => showModalBottomSheet<T>(
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

Widget _outlined(IconData icon, String label, VoidCallback onTap) =>
    ScanButton(label, icon: icon, kind: ButtonKind.secondary, onPressed: onTap, palette: Palette.light);

Widget _filled(IconData icon, String label, VoidCallback onTap) =>
    ScanButton(label, icon: icon, onPressed: onTap, palette: Palette.light);
