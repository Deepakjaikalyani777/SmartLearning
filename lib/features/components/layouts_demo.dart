import 'package:flutter/material.dart';

import '../../widgets/code_block.dart';
import '../../widgets/demo_scaffold.dart';

class LayoutsDemo extends StatelessWidget {
  const LayoutsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget box(String t, Color c, {double? w, double h = 48}) => Container(
          width: w,
          height: h,
          alignment: Alignment.center,
          color: c,
          child: Text(t, style: const TextStyle(color: Colors.white)),
        );

    return DemoScaffold(
      title: 'Layouts',
      android: 'LinearLayout, FrameLayout, ConstraintLayout, layout_weight',
      flutter: 'Row, Column, Stack, Expanded, Wrap, Align, SizedBox',
      children: [
        const SectionTitle('Row + Expanded (≈ horizontal LinearLayout + weight)'),
        Row(children: [
          box('fixed', Colors.red, w: 70),
          Expanded(flex: 2, child: box('flex 2', Colors.green)),
          Expanded(child: box('flex 1', Colors.blue)),
        ]),
        const CodeBlock('''
Row(children: [
  SizedBox(width: 70, child: ...),
  Expanded(flex: 2, child: ...),
  Expanded(child: ...),
])'''),
        const SectionTitle('Column (≈ vertical LinearLayout)'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            box('1', Colors.purple, h: 32),
            const SizedBox(height: 4), // ≈ layout_marginTop
            box('2', Colors.indigo, h: 32),
          ],
        ),
        const SectionTitle('Stack + Positioned (≈ FrameLayout)'),
        SizedBox(
          height: 140,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [scheme.primary, scheme.tertiary]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Positioned(
                left: 16,
                bottom: 16,
                child: Text('Banner title',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
              const Positioned(
                right: 12,
                top: 12,
                child: Chip(label: Text('NEW')),
              ),
            ],
          ),
        ),
        const SectionTitle('Wrap (≈ FlexboxLayout / ChipGroup)'),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final t in [
              'Kotlin', 'Dart', 'Jetpack', 'Compose', 'Flutter', 'Gradle',
              'Material 3', 'Coroutines'
            ])
              Chip(label: Text(t)),
          ],
        ),
        const SectionTitle('Align / Center (≈ gravity / layout_gravity)'),
        Container(
          height: 100,
          color: scheme.surfaceContainerHighest,
          child: const Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text('bottom|end'),
            ),
          ),
        ),
        const SectionTitle('Responsive (≈ layout-sw600dp)'),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 500;
            return Container(
              padding: const EdgeInsets.all(12),
              color: wide ? Colors.teal.shade100 : Colors.orange.shade100,
              child: Text(
                wide
                    ? 'Wide layout (${constraints.maxWidth.toInt()} dp): '
                        'would show master-detail'
                    : 'Narrow layout (${constraints.maxWidth.toInt()} dp): '
                        'single pane. Rotate the device!',
                style: const TextStyle(color: Colors.black87),
              ),
            );
          },
        ),
        const SectionTitle('Card + ListTile (≈ CardView + item layout)'),
        const Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Jane Developer'),
            subtitle: Text('Android → Flutter'),
            trailing: Icon(Icons.more_vert),
          ),
        ),
      ],
    );
  }
}
