// Lifecycle demo: logs real State lifecycle callbacks of a child widget
// and real app lifecycle events. ≈ overriding every Activity callback and
// printing to Logcat.
import 'package:flutter/material.dart';

import '../../widgets/demo_scaffold.dart';

class LifecycleDemo extends StatefulWidget {
  const LifecycleDemo({super.key});
  @override
  State<LifecycleDemo> createState() => _LifecycleDemoState();
}

class _LifecycleDemoState extends State<LifecycleDemo> {
  final _log = <String>[];
  bool _showChild = true;
  int _config = 0;
  late final AppLifecycleListener _appListener;

  void _add(String line) {
    // Called from child lifecycle methods; defer setState to after the
    // current frame so we never call setState during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _log.insert(0, line));
    });
  }

  @override
  void initState() {
    super.initState();
    _appListener = AppLifecycleListener(
      onStateChange: (s) => _add('🟣 APP  → ${s.name}'),
    );
  }

  @override
  void dispose() {
    _appListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Lifecycle',
      android: 'onCreate · onStart · onResume · onPause · onStop · onDestroy '
          '(Logcat)',
      flutter: 'initState · didChangeDependencies · build · didUpdateWidget · '
          'dispose · AppLifecycleListener',
      note: 'Toggle the child, change its config, rotate the device, or press '
          'Home and come back. Watch the log.',
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () => setState(() => _showChild = !_showChild),
              child: Text(_showChild ? 'Remove child' : 'Insert child'),
            ),
            OutlinedButton(
              onPressed: () => setState(() => _config++),
              child: const Text('Pass new config'),
            ),
            TextButton(
              onPressed: () => setState(_log.clear),
              child: const Text('Clear log'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: _showChild
              ? _LoggingChild(config: _config, log: _add)
              : const SizedBox(height: 0, width: double.infinity),
        ),
        const SectionTitle('Log (newest first) ≈ Logcat'),
        Container(
          height: 280,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: _log.length,
            itemBuilder: (_, i) => Text(
              _log[i],
              style: const TextStyle(
                  color: Color(0xFFA6E3A1),
                  fontFamily: 'monospace',
                  fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoggingChild extends StatefulWidget {
  const _LoggingChild({required this.config, required this.log});
  final int config;
  final void Function(String) log;

  // Logging here is for teaching only - normally createState() has no logic.
  @override
  // ignore: no_logic_in_create_state
  State<_LoggingChild> createState() {
    log('⚪ createState()');
    return _LoggingChildState();
  }
}

class _LoggingChildState extends State<_LoggingChild> {
  int _builds = 0;

  @override
  void initState() {
    super.initState();
    widget.log('🟢 initState()            ≈ onCreate');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.log('🔵 didChangeDependencies() ≈ onConfigurationChanged');
  }

  @override
  void didUpdateWidget(covariant _LoggingChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.log('🟡 didUpdateWidget(${oldWidget.config} → ${widget.config})');
  }

  @override
  void deactivate() {
    widget.log('🟠 deactivate()            ≈ onStop');
    super.deactivate();
  }

  @override
  void dispose() {
    widget.log('🔴 dispose()               ≈ onDestroy');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _builds++;
    widget.log('⚙️ build() #$_builds');
    // MediaQuery dependency → rotation triggers didChangeDependencies.
    final orientation = MediaQuery.orientationOf(context);
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: ListTile(
        leading: const Icon(Icons.child_care),
        title: Text('Child widget · config=${widget.config}'),
        subtitle: Text('Orientation: ${orientation.name} · builds: $_builds'),
      ),
    );
  }
}
