// Animated explainers for the "Basics" concepts.
import 'dart:async';

import 'package:flutter/material.dart';

import '../concept_demos.dart';

// ─────────────────────────── Widget tree ───────────────────────────
class WidgetTreeDemo extends StatefulWidget {
  const WidgetTreeDemo({super.key});
  @override
  State<WidgetTreeDemo> createState() => _WidgetTreeDemoState();
}

class _WidgetTreeDemoState extends State<WidgetTreeDemo> {
  static const _nodes = <(int, String, String)>[
    (0, 'MaterialApp', '<application>'),
    (1, 'Scaffold', 'Activity root / CoordinatorLayout'),
    (2, 'AppBar', 'Toolbar'),
    (2, 'Padding', 'android:padding'),
    (3, 'Column', 'LinearLayout vertical'),
    (4, 'Text', 'TextView'),
    (4, 'Row', 'LinearLayout horizontal'),
    (5, 'Icon', 'ImageView'),
    (5, 'ElevatedButton', 'Button'),
  ];

  int _visible = 0;
  Timer? _timer;

  void _build() {
    _timer?.cancel();
    setState(() => _visible = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 350), (t) {
      if (_visible >= _nodes.length) {
        t.cancel();
        return;
      }
      setState(() => _visible++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ≈ removing callbacks in onDestroy
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoPanel(
      caption: 'Each box is a widget. Padding and Row are widgets too - '
          'there are no "attributes", only nesting.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, (depth, name, android)) in _nodes.indexed)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: i < _visible ? 1 : 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: i < _visible ? Offset.zero : const Offset(0.3, 0),
                child: Padding(
                  padding: EdgeInsets.only(left: depth * 18.0, bottom: 4),
                  child: Row(
                    children: [
                      if (depth > 0)
                        Text('└ ', style: TextStyle(color: scheme.outline)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text('≈ $android',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11, color: scheme.onSurfaceVariant)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: FilledButton.icon(
              onPressed: _build,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Build the tree'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── Stateless vs Stateful ───────────────────────
class StatefulRebuildDemo extends StatefulWidget {
  const StatefulRebuildDemo({super.key});
  @override
  State<StatefulRebuildDemo> createState() => _StatefulRebuildDemoState();
}

class _StatefulRebuildDemoState extends State<StatefulRebuildDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return DemoPanel(
      caption: 'Each tap calls setState() → build() runs again → the box '
          'flashes. The Stateless label receives the same input, so its '
          'output never changes.',
      child: Column(
        children: [
          const _Flash(
            flashKey: 'static',
            label: 'StatelessWidget',
            child: Text('I only show my constructor input: "Hello"'),
          ),
          const SizedBox(height: 12),
          _Flash(
            flashKey: 'count-$_count',
            label: 'StatefulWidget (State.count = $_count)',
            child: Text('build() executed ${_count + 1} time(s)',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => setState(() => _count++),
            icon: const Icon(Icons.add),
            label: const Text('setState(() => count++)'),
          ),
        ],
      ),
    );
  }
}

class _Flash extends StatelessWidget {
  const _Flash({required this.flashKey, required this.label, required this.child});
  final String flashKey;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // A new key restarts the tween → a highlight flash on each rebuild.
    return TweenAnimationBuilder<double>(
      key: ValueKey(flashKey),
      tween: Tween(begin: 1, end: 0),
      duration: const Duration(milliseconds: 700),
      builder: (context, t, _) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.lerp(scheme.surface, Colors.amber, t),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: scheme.primary)),
            const SizedBox(height: 4),
            child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Lifecycle stepper ───────────────────────────
class LifecycleStepperDemo extends StatefulWidget {
  const LifecycleStepperDemo({super.key});
  @override
  State<LifecycleStepperDemo> createState() => _LifecycleStepperDemoState();
}

class _LifecycleStepperDemoState extends State<LifecycleStepperDemo> {
  static const _steps = <(String, String, String)>[
    ('createState()', '(constructor)', 'Framework creates the State object'),
    ('initState()', 'onCreate()', 'Once. Init controllers, subscribe.'),
    ('didChangeDependencies()', 'onConfigurationChanged()',
        'Theme/MediaQuery/Provider changed'),
    ('build()', 'onCreateView() / onResume()', 'Describe UI. MANY times.'),
    ('setState()', 'invalidate()', 'Mark dirty → build() again'),
    ('didUpdateWidget()', 'new arguments', 'Parent passed new config'),
    ('deactivate()', 'onStop()', 'Removed from tree (maybe temporarily)'),
    ('dispose()', 'onDestroy()', 'Gone for good. Clean up!'),
  ];

  int _current = -1;
  Timer? _timer;

  void _play() {
    _timer?.cancel();
    setState(() => _current = 0);
    _timer = Timer.periodic(const Duration(milliseconds: 900), (t) {
      if (_current >= _steps.length - 1) {
        t.cancel();
        return;
      }
      setState(() => _current++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoPanel(
      caption: 'Flutter State methods (left) vs the closest Android callback '
          '(right).',
      child: Column(
        children: [
          for (final (i, (flutter, android, desc)) in _steps.indexed)
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: i == _current
                    ? scheme.primary
                    : (i < _current
                        ? scheme.primaryContainer
                        : scheme.surface),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: i == _current ? scheme.onPrimary : scheme.onSurface,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(flutter,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace')),
                          Text(desc, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                    const Icon(Icons.sync_alt, size: 16),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 110,
                      child: Text(android,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _play,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play lifecycle'),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── App lifecycle states ─────────────────────────
class AppLifecycleStatesDemo extends StatefulWidget {
  const AppLifecycleStatesDemo({super.key});
  @override
  State<AppLifecycleStatesDemo> createState() => _AppLifecycleStatesDemoState();
}

class _AppLifecycleStatesDemoState extends State<AppLifecycleStatesDemo> {
  static const _states = <(AppLifecycleState, String)>[
    (AppLifecycleState.resumed, 'onResume'),
    (AppLifecycleState.inactive, 'onPause'),
    (AppLifecycleState.hidden, 'onStop (hiding)'),
    (AppLifecycleState.paused, 'onStop'),
    (AppLifecycleState.detached, 'onDestroy'),
  ];

  late final AppLifecycleListener _listener;
  AppLifecycleState _simulated = AppLifecycleState.resumed;
  final List<String> _realLog = [];

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: (s) => setState(() {
        _realLog.insert(0, '${TimeOfDay.now().format(context)}  → ${s.name}');
      }),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  Future<void> _simulate(List<AppLifecycleState> path) async {
    for (final s in path) {
      if (!mounted) return;
      setState(() => _simulated = s);
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoPanel(
      caption: 'Try it for real: press Home, then come back - the real log '
          'below records what AppLifecycleListener reports.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final (s, android) in _states)
                AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: s == _simulated ? 1.12 : 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: s == _simulated ? scheme.primary : scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: scheme.primary),
                    ),
                    child: Column(
                      children: [
                        Text(s.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: s == _simulated
                                    ? scheme.onPrimary
                                    : scheme.onSurface)),
                        Text(android,
                            style: TextStyle(
                                fontSize: 10,
                                color: s == _simulated
                                    ? scheme.onPrimary
                                    : scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => _simulate(const [
                  AppLifecycleState.inactive,
                  AppLifecycleState.hidden,
                  AppLifecycleState.paused,
                ]),
                child: const Text('Simulate: Home'),
              ),
              OutlinedButton(
                onPressed: () => _simulate(const [
                  AppLifecycleState.hidden,
                  AppLifecycleState.inactive,
                  AppLifecycleState.resumed,
                ]),
                child: const Text('Simulate: Return'),
              ),
            ],
          ),
          const Divider(height: 24),
          Text('Real events:', style: Theme.of(context).textTheme.labelLarge),
          if (_realLog.isEmpty)
            const Text('(none yet - background the app and return)',
                style: TextStyle(fontSize: 12)),
          for (final line in _realLog.take(8))
            Text(line, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
