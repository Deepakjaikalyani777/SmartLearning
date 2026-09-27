// Navigation demo: pass data forward (Intent extras) and get a result back
// (startActivityForResult / ActivityResultLauncher).
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../widgets/demo_scaffold.dart';

class NavigationDemo extends StatefulWidget {
  const NavigationDemo({super.key});
  @override
  State<NavigationDemo> createState() => _NavigationDemoState();
}

class _NavigationDemoState extends State<NavigationDemo> {
  final _controller = TextEditingController(text: 'Hello from screen A');
  String _result = '(nothing yet)';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openForResult() async {
    // ≈ launcher.launch(intent.putExtra("message", ...))
    final result = await Navigator.pushNamed<String>(
      context,
      AppRoutes.navigationDetail,
      arguments: _controller.text,
    );
    if (!mounted) return;
    setState(() => _result = result ?? '(back pressed, no result)');
  }

  void _openDirect() {
    // Anonymous route - no registration needed ≈ explicit Intent
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NavigationDetailPage(message: 'Direct push!'),
        fullscreenDialog: true, // slides up, shows ✕ instead of ←
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Navigation',
      android: 'startActivity(Intent) · putExtra · ActivityResultLauncher · '
          'finish()',
      flutter: 'Navigator.push / pushNamed(arguments:) · await result · '
          'Navigator.pop(result)',
      children: [
        TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Extra to send (≈ intent.putExtra)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _openForResult,
          icon: const Icon(Icons.open_in_new),
          label: const Text('pushNamed() and await result'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _openDirect,
          icon: const Icon(Icons.fullscreen),
          label: const Text('push() a full-screen dialog route'),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.reply),
            title: const Text('Result returned (≈ onActivityResult)'),
            subtitle: Text(_result),
          ),
        ),
      ],
    );
  }
}

/// "Screen B" — receives an argument and can return a result.
class NavigationDetailPage extends StatelessWidget {
  const NavigationDetailPage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    // PopScope ≈ OnBackPressedCallback. Here we allow pop but log it.
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        debugPrint('Back pressed. didPop=$didPop result=$result');
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Screen B')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Received extra:'),
              Text(message, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              for (final choice in ['👍 Approved', '👎 Rejected', '🤔 Maybe'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilledButton.tonal(
                    // ≈ setResult(RESULT_OK, data); finish()
                    onPressed: () => Navigator.pop(context, choice),
                    child: Text('Return "$choice"'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
