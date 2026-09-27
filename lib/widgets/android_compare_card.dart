import 'package:flutter/material.dart';

/// Side-by-side "Android ⇄ Flutter" comparison chip used across the app.
class AndroidCompareCard extends StatelessWidget {
  const AndroidCompareCard({
    super.key,
    required this.android,
    required this.flutter,
    this.note,
  });

  final String android;
  final String flutter;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _Side(
                    icon: Icons.android,
                    color: const Color(0xFF3DDC84),
                    title: 'Android',
                    text: android,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.sync_alt),
                ),
                Expanded(
                  child: _Side(
                    icon: Icons.flutter_dash,
                    color: const Color(0xFF02569B),
                    title: 'Flutter',
                    text: flutter,
                  ),
                ),
              ],
            ),
            if (note != null) ...[
              const Divider(),
              Text(note!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(title,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
