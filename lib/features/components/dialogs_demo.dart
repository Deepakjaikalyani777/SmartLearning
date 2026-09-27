// Dialogs & feedback: AlertDialog, choice dialog, bottom sheet, SnackBar,
// progress dialog, popup menu, tooltip.
import 'package:flutter/material.dart';

import '../../widgets/demo_scaffold.dart';

class DialogsDemo extends StatefulWidget {
  const DialogsDemo({super.key});
  @override
  State<DialogsDemo> createState() => _DialogsDemoState();
}

class _DialogsDemoState extends State<DialogsDemo> {
  String _last = 'Nothing yet';

  void _toast(String msg) {
    // SnackBar is the Material replacement for Toast.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _confirm() async {
    // showDialog returns a Future of whatever the dialog pops with.
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Delete file?'),
        content: const Text('≈ MaterialAlertDialogBuilder with '
            'setPositiveButton / setNegativeButton.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    setState(() => _last = 'Confirm dialog → $ok');
  }

  Future<void> _choice() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pick a language (≈ setItems)'),
        children: [
          for (final l in ['Kotlin', 'Java', 'Dart'])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, l),
              child: Text(l),
            ),
        ],
      ),
    );
    setState(() => _last = 'Choice dialog → ${picked ?? 'dismissed'}');
  }

  Future<void> _sheet() async {
    // ≈ BottomSheetDialogFragment
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (icon, label) in [
              (Icons.share, 'Share'),
              (Icons.link, 'Copy link'),
              (Icons.edit, 'Edit'),
            ])
              ListTile(
                leading: Icon(icon),
                title: Text(label),
                onTap: () => Navigator.pop(context, label),
              ),
          ],
        ),
      ),
    );
    setState(() => _last = 'Bottom sheet → ${action ?? 'dismissed'}');
  }

  Future<void> _progress() async {
    // ≈ ProgressDialog (deprecated) / blocking loading overlay
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Loading…'),
            ],
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pop();
    _toast('Finished loading');
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Dialogs & Feedback',
      android: 'AlertDialog, BottomSheetDialogFragment, Toast, Snackbar, '
          'PopupMenu, ProgressBar',
      flutter: 'showDialog, showModalBottomSheet, ScaffoldMessenger.showSnackBar, '
          'PopupMenuButton, CircularProgressIndicator',
      actions: [
        // ≈ onCreateOptionsMenu overflow menu
        PopupMenuButton<String>(
          onSelected: (v) => _toast('Menu: $v'),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'Refresh', child: Text('Refresh')),
            PopupMenuItem(value: 'Help', child: Text('Help')),
          ],
        ),
      ],
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Last result'),
            subtitle: Text(_last),
          ),
        ),
        const SizedBox(height: 8),
        for (final (label, onTap) in <(String, VoidCallback)>[
          ('SnackBar (≈ Toast / Snackbar)', () => _toast('Hello 👋')),
          ('Confirm AlertDialog', _confirm),
          ('Single-choice dialog', _choice),
          ('Modal bottom sheet', _sheet),
          ('Blocking progress dialog', _progress),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FilledButton.tonal(onPressed: onTap, child: Text(label)),
          ),
        const SectionTitle('Progress indicators (≈ ProgressBar)'),
        const LinearProgressIndicator(),
        const SizedBox(height: 12),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularProgressIndicator(),
            CircularProgressIndicator(value: 0.65),
            Tooltip(
              message: 'Long-press tooltip ≈ TooltipCompat',
              child: Icon(Icons.help_outline, size: 36),
            ),
          ],
        ),
      ],
    );
  }
}
