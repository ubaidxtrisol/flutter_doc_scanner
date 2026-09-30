import 'package:flutter/material.dart';

/// Scanner design tokens, eyeballed from ref/*.png. ponytail: swap for exact Figma variables when available.
abstract final class Tone {
  static const chrome = Color(0xFF0B0D12);
  static const surface = Color(0xFF1C1F26);
  static const chip = Color(0x1FFFFFFF);
  static const pill = Color(0xCC1C1F26);
  static const muted = Color(0xFF8B909A);
  static const accent = Color(0xFF4D7CFE);
  static const success = Color(0xFF1EA85A);
  static const auto = Color(0xFFFFD60A);
}

/// Round translucent icon button from the camera top bar.
class ChipButton extends StatelessWidget {
  const ChipButton({super.key, required this.icon, required this.label, required this.onTap, this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Tone.chip,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(dimension: 40, child: Icon(icon, size: 20, color: color ?? Colors.white)),
          ),
        ),
      );
}

/// Status pill ("Point at a document", "Document detected · Hold still").
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.icon, required this.text, this.color = Tone.pill});
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ]),
      );
}
