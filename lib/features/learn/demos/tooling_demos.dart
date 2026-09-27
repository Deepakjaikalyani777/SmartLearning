// Animated explainers for tooling / internals concepts.
import 'package:flutter/material.dart';

import '../concept_demos.dart';

// ─────────────────────────── Hot reload race ───────────────────────────
class HotReloadRaceDemo extends StatefulWidget {
  const HotReloadRaceDemo({super.key});
  @override
  State<HotReloadRaceDemo> createState() => _HotReloadRaceDemoState();
}

class _HotReloadRaceDemoState extends State<HotReloadRaceDemo>
    with TickerProviderStateMixin {
  // Relative, illustrative timings (not measurements).
  late final AnimationController _gradle = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 6000));
  late final AnimationController _restart = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000));
  late final AnimationController _reload = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));

  @override
  void dispose() {
    _gradle.dispose();
    _restart.dispose();
    _reload.dispose();
    super.dispose();
  }

  void _race() {
    for (final c in [_gradle, _restart, _reload]) {
      c.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoPanel(
      caption: 'Illustrative, not a benchmark: hot reload swaps code in the '
          'running Dart VM (JIT) and keeps state; a native rebuild compiles, '
          'packages, installs and relaunches.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lane('Gradle build + install (native change)', _gradle, Colors.red,
              'state lost'),
          _lane('Hot restart  (R)', _restart, Colors.orange, 'state lost'),
          _lane('Hot reload  (r) 🔥', _reload, Colors.green, 'state KEPT'),
          const SizedBox(height: 12),
          Center(
            child: FilledButton.icon(
              onPressed: _race,
              icon: const Icon(Icons.flag),
              label: const Text('Save file & race!'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lane(String label, AnimationController c, Color color, String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: c,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(label)),
                if (c.isCompleted)
                  Text('✓ done, $note',
                      style: TextStyle(color: color, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: c.value,
                minHeight: 12,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Three trees ───────────────────────────
class ThreeTreesDemo extends StatefulWidget {
  const ThreeTreesDemo({super.key});
  @override
  State<ThreeTreesDemo> createState() => _ThreeTreesDemoState();
}

class _ThreeTreesDemoState extends State<ThreeTreesDemo> {
  int _widgetGen = 1; // new widget objects every rebuild
  int _elementGen = 1; // replaced only when type/key changes
  bool _useIcon = false;
  String _last = 'Tap a button';

  void _rebuild() => setState(() {
        _widgetGen++;
        _last = 'Same type → Element & RenderObject REUSED, just updated.';
      });

  void _changeType() => setState(() {
        _widgetGen++;
        _elementGen++;
        _useIcon = !_useIcon;
        _last = 'Different type → old Element & RenderObject thrown away, '
            'new ones created (more expensive).';
      });

  @override
  Widget build(BuildContext context) {
    final leaf = _useIcon ? 'Icon' : 'Text';
    final render = _useIcon ? 'RenderParagraph*' : 'RenderParagraph';
    return DemoPanel(
      caption: 'Widgets are rebuilt constantly and cheaply. Elements and '
          'RenderObjects (the "real views") are recycled whenever the widget '
          'type and key match.',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _column('Widget tree\n(blueprints)', [
                ('Container', 'w$_widgetGen'),
                (leaf, 'w$_widgetGen'),
              ], Colors.blue),
              _column('Element tree\n(instances)', [
                ('ContainerElement', 'e1'),
                ('${leaf}Element', 'e$_elementGen'),
              ], Colors.purple),
              _column('Render tree\n(layout/paint)', [
                ('RenderBox', 'r1'),
                (render, 'r$_elementGen'),
              ], Colors.teal),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(_last,
                key: ValueKey(_last), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                  onPressed: _rebuild, child: const Text('setState (same type)')),
              OutlinedButton(
                  onPressed: _changeType, child: const Text('Swap Text ⇄ Icon')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _column(String title, List<(String, String)> nodes, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 12)),
          const SizedBox(height: 6),
          for (final (name, id) in nodes)
            TweenAnimationBuilder<double>(
              key: ValueKey('$name$id'), // new id ⇒ flash
              tween: Tween(begin: 1, end: 0),
              duration: const Duration(milliseconds: 800),
              builder: (context, t, _) => Container(
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.all(6),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.lerp(
                      color.withValues(alpha: 0.12), Colors.amber, t),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(name,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center),
                    Text('#$id',
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 10)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Build modes ───────────────────────────
class BuildModesDemo extends StatefulWidget {
  const BuildModesDemo({super.key});
  @override
  State<BuildModesDemo> createState() => _BuildModesDemoState();
}

enum _Mode { debug, profile, release }

class _BuildModesDemoState extends State<BuildModesDemo> {
  _Mode _mode = _Mode.debug;

  // Relative scores 0..1, illustrative only.
  static const _data = <_Mode, Map<String, double>>{
    _Mode.debug: {
      'Runtime speed': 0.35,
      'Startup speed': 0.3,
      'Dev iteration speed': 1.0,
      'Debuggability': 1.0,
      'Small app size': 0.2,
    },
    _Mode.profile: {
      'Runtime speed': 0.9,
      'Startup speed': 0.85,
      'Dev iteration speed': 0.2,
      'Debuggability': 0.5,
      'Small app size': 0.7,
    },
    _Mode.release: {
      'Runtime speed': 1.0,
      'Startup speed': 1.0,
      'Dev iteration speed': 0.05,
      'Debuggability': 0.05,
      'Small app size': 1.0,
    },
  };

  static const _desc = {
    _Mode.debug: 'JIT · hot reload · asserts · debug banner\n'
        'flutter run',
    _Mode.profile: 'AOT · DevTools performance overlay · real device only\n'
        'flutter run --profile',
    _Mode.release: 'AOT native ARM · tree-shaken · obfuscation-ready\n'
        'flutter build appbundle --release',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoPanel(
      caption: 'Relative, illustrative comparison of the three build modes.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Mode>(
            segments: [
              for (final m in _Mode.values)
                ButtonSegment(value: m, label: Text(m.name)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(_desc[_mode]!,
                key: ValueKey(_mode),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
          const SizedBox(height: 12),
          for (final e in _data[_mode]!.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(width: 130, child: Text(e.key)),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) => Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          height: 14,
                          width: box.maxWidth * e.value,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
