// A reusable "custom view". In Android you'd extend View or write a
// <merge> layout; in Flutter you just compose a new Widget class.
import 'package:flutter/material.dart';

class CodeBlock extends StatelessWidget {
  const CodeBlock(this.code, {super.key, this.label});

  final String code;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.85),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Text(
                label!,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              code.trim(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.4,
                color: Color(0xFFCDD6F4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
