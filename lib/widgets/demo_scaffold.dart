import 'package:flutter/material.dart';

import 'android_compare_card.dart';

/// Common screen frame for every component demo: an AppBar, an
/// "Android equivalent" banner, then the demo content.
class DemoScaffold extends StatelessWidget {
  const DemoScaffold({
    super.key,
    required this.title,
    required this.android,
    required this.flutter,
    required this.children,
    this.note,
    this.actions,
    this.floatingActionButton,
  });

  final String title;
  final String android;
  final String flutter;
  final String? note;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      floatingActionButton: floatingActionButton,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AndroidCompareCard(android: android, flutter: flutter, note: note),
          const SizedBox(height: 8),
          ...children,
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Small bold section title.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}
