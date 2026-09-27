// ConceptDetailScreen — tabbed detail page for one concept.
// ≈ an Activity with TabLayout + ViewPager2 hosting 3 fragments.
import 'package:flutter/material.dart';

import '../../widgets/code_block.dart';
import 'concept_demos.dart';
import 'concepts_data.dart';

class ConceptDetailScreen extends StatelessWidget {
  const ConceptDetailScreen({super.key, required this.concept});

  final Concept concept;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Hero(
                tag: 'concept-${concept.id}',
                child: Icon(concept.icon),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(concept.title, overflow: TextOverflow.ellipsis)),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.lightbulb_outline), text: 'Learn'),
              Tab(icon: Icon(Icons.play_circle_outline), text: 'Animate'),
              Tab(icon: Icon(Icons.compare_arrows), text: 'Compare'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _LearnTab(concept: concept),
            _AnimateTab(concept: concept),
            _CompareTab(concept: concept),
          ],
        ),
      ),
    );
  }
}

class _LearnTab extends StatelessWidget {
  const _LearnTab({required this.concept});
  final Concept concept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // "Big idea" callout, Head-First style
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  concept.oneLiner,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final (i, para) in concept.explanation.indexed)
          _AnimatedEntry(
            delay: Duration(milliseconds: 120 * i),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    child: Text('${i + 1}', style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(para, style: theme.textTheme.bodyLarge)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        _Callout(
          emoji: '🧠',
          title: 'BRAIN POWER',
          text: concept.brainPower,
          color: theme.colorScheme.secondaryContainer,
        ),
        const SizedBox(height: 12),
        _Callout(
          emoji: '📌',
          title: 'BULLET POINTS',
          text: concept.takeaways.map((t) => '• $t').join('\n'),
          color: theme.colorScheme.primaryContainer,
        ),
      ],
    );
  }
}

class _AnimateTab extends StatelessWidget {
  const _AnimateTab({required this.concept});
  final Concept concept;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Watch it happen',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Interactive explainer - tap the buttons.',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        ConceptDemo(kind: concept.demo),
      ],
    );
  }
}

class _CompareTab extends StatelessWidget {
  const _CompareTab({required this.concept});
  final Concept concept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Table(
            columnWidths: const {0: FlexColumnWidth(), 1: FlexColumnWidth()},
            border: TableBorder.symmetric(
              inside: BorderSide(color: theme.dividerColor),
            ),
            children: [
              TableRow(
                decoration:
                    BoxDecoration(color: theme.colorScheme.primaryContainer),
                children: const [
                  _Cell('🤖 Android', bold: true),
                  _Cell('💙 Flutter', bold: true),
                ],
              ),
              for (final (a, f) in concept.comparison)
                TableRow(children: [_Cell(a), _Cell(f, mono: true)]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CodeBlock(concept.androidCode, label: 'Android (Kotlin / XML)'),
        const SizedBox(height: 8),
        CodeBlock(concept.flutterCode, label: 'Flutter (Dart)'),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, {this.bold = false, this.mono = false});
  final String text;
  final bool bold;
  final bool mono;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontFamily: mono ? 'monospace' : null,
            fontSize: 13,
          ),
        ),
      );
}

class _Callout extends StatelessWidget {
  const _Callout({
    required this.emoji,
    required this.title,
    required this.text,
    required this.color,
  });

  final String emoji;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$emoji  $title',
              style: const TextStyle(
                  fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(height: 1.4)),
        ],
      ),
    );
  }
}

/// Fades + slides a child in after [delay]. Uses TweenAnimationBuilder
/// (an implicit animation that runs once when first built).
class _AnimatedEntry extends StatelessWidget {
  const _AnimatedEntry({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450) + delay,
      curve: Interval(
        delay.inMilliseconds / (450 + delay.inMilliseconds),
        1,
        curve: Curves.easeOut,
      ),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 20 * (1 - t)), child: child),
      ),
      child: child,
    );
  }
}
