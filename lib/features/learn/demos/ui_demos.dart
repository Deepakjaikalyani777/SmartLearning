// Animated explainers for the "UI" concepts.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../concept_demos.dart';

// ─────────────────────────── Layout playground ───────────────────────────
class LayoutPlaygroundDemo extends StatefulWidget {
  const LayoutPlaygroundDemo({super.key});
  @override
  State<LayoutPlaygroundDemo> createState() => _LayoutPlaygroundDemoState();
}

enum _Kind { row, column, stack }

class _LayoutPlaygroundDemoState extends State<LayoutPlaygroundDemo> {
  _Kind _kind = _Kind.row;
  MainAxisAlignment _main = MainAxisAlignment.start;
  double _weight = 1; // flex of the middle box

  static const _colors = [Colors.red, Colors.green, Colors.blue];

  @override
  Widget build(BuildContext context) {
    return DemoPanel(
      caption: 'Row ≈ horizontal LinearLayout, Column ≈ vertical, '
          'Stack ≈ FrameLayout. The slider is layout_weight (Expanded.flex).',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Kind>(
            segments: const [
              ButtonSegment(value: _Kind.row, label: Text('Row')),
              ButtonSegment(value: _Kind.column, label: Text('Column')),
              ButtonSegment(value: _Kind.stack, label: Text('Stack')),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: 8),
          if (_kind != _Kind.stack)
            Wrap(
              spacing: 6,
              children: [
                for (final m in [
                  MainAxisAlignment.start,
                  MainAxisAlignment.center,
                  MainAxisAlignment.spaceBetween,
                  MainAxisAlignment.spaceEvenly,
                ])
                  ChoiceChip(
                    label: Text(m.name, style: const TextStyle(fontSize: 11)),
                    selected: _main == m,
                    onSelected: (_) => setState(() => _main = m),
                  ),
              ],
            ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, a) =>
                  ScaleTransition(scale: a, child: child),
              child: KeyedSubtree(
                key: ValueKey('$_kind-$_main'),
                child: _buildLayout(),
              ),
            ),
          ),
          if (_kind == _Kind.row) ...[
            const SizedBox(height: 8),
            Text('Green box: Expanded(flex: ${_weight.round()})  '
                '≈ layout_weight="${_weight.round()}"'),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              value: _weight,
              onChanged: (v) => setState(() => _weight = v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _box(int i, {double size = 50}) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        alignment: Alignment.center,
        color: _colors[i].withValues(alpha: 0.8),
        child: Text('${i + 1}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      );

  Widget _buildLayout() {
    switch (_kind) {
      case _Kind.row:
        return Row(
          mainAxisAlignment: _main,
          children: [
            _box(0),
            if (_main == MainAxisAlignment.start)
              Expanded(
                flex: _weight.round(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 50,
                  color: _colors[1].withValues(alpha: 0.8),
                  alignment: Alignment.center,
                  child: const Text('Expanded',
                      style: TextStyle(color: Colors.white)),
                ),
              )
            else
              _box(1),
            if (_main == MainAxisAlignment.start)
              Expanded(flex: 1, child: _box(2))
            else
              _box(2),
          ],
        );
      case _Kind.column:
        return Column(
          mainAxisAlignment: _main,
          children: [_box(0), _box(1), _box(2)],
        );
      case _Kind.stack:
        return Stack(
          alignment: Alignment.center,
          children: [
            _box(0, size: 150),
            _box(1, size: 100),
            _box(2, size: 50),
            const Positioned(
              right: 8,
              top: 8,
              child: Chip(label: Text('Positioned')),
            ),
          ],
        );
    }
  }
}

// ─────────────────────────── Recycling list ───────────────────────────
class RecyclingListDemo extends StatefulWidget {
  const RecyclingListDemo({super.key});
  @override
  State<RecyclingListDemo> createState() => _RecyclingListDemoState();
}

class _RecyclingListDemoState extends State<RecyclingListDemo> {
  static const _total = 10000;
  int _builds = 0;
  int _shownBuilds = 0;

  final _listKey = GlobalKey<AnimatedListState>();
  final List<int> _animated = [1, 2, 3];
  int _next = 4;

  void _add() {
    _animated.insert(0, _next++);
    _listKey.currentState!.insertItem(0);
  }

  void _remove() {
    if (_animated.isEmpty) return;
    final removed = _animated.removeAt(0);
    _listKey.currentState!.removeItem(
      0,
      (context, anim) => _animatedTile(removed, anim),
    );
  }

  Widget _animatedTile(int v, Animation<double> anim) => SizeTransition(
        sizeFactor: anim,
        child: FadeTransition(
          opacity: anim,
          child: Card(
            child: ListTile(dense: true, title: Text('Item #$v')),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return DemoPanel(
      caption: 'ListView.builder only builds rows that are on screen - just '
          'like RecyclerView recycling ViewHolders.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('$_total items in the list. itemBuilder calls so far: '
              '$_shownBuilds'),
          const SizedBox(height: 6),
          SizedBox(
            height: 200,
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) {
                // Update the counter outside of build ≈ an OnScrollListener.
                if (_shownBuilds != _builds) {
                  setState(() => _shownBuilds = _builds);
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _total,
                itemExtent: 44,
                itemBuilder: (context, i) {
                  _builds++;
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors
                          .primaries[i % Colors.primaries.length]
                          .withValues(alpha: 0.7),
                      child: Text('${i % 100}',
                          style: const TextStyle(fontSize: 10)),
                    ),
                    title: Text('Row $i  ≈ onBindViewHolder($i)'),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 24),
          const Text('AnimatedList ≈ notifyItemInserted / notifyItemRemoved'),
          const SizedBox(height: 6),
          Row(
            children: [
              FilledButton.tonal(onPressed: _add, child: const Text('Insert')),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: _remove, child: const Text('Remove')),
            ],
          ),
          SizedBox(
            height: 180,
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _animated.length,
              itemBuilder: (context, i, anim) =>
                  _animatedTile(_animated[i], anim),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Back stack ───────────────────────────
class BackStackDemo extends StatefulWidget {
  const BackStackDemo({super.key});
  @override
  State<BackStackDemo> createState() => _BackStackDemoState();
}

class _BackStackDemoState extends State<BackStackDemo> {
  final List<String> _stack = ['HomeScreen'];
  static const _names = ['DetailScreen', 'EditScreen', 'SettingsScreen',
      'ProfileScreen', 'AboutScreen'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoPanel(
      caption: 'Navigator keeps a stack of routes. The top card is what the '
          'user sees. The system Back button calls pop().',
      child: Column(
        children: [
          SizedBox(
            height: 230,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                for (final (i, name) in _stack.indexed)
                  AnimatedPositioned(
                    key: ValueKey('$i-$name'),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    bottom: i * 30.0,
                    left: 20.0 + i * 6,
                    right: 20.0 + i * 6,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 350),
                      builder: (context, t, child) => Opacity(
                        opacity: t,
                        child: Transform.translate(
                            offset: Offset(0, -40 * (1 - t)), child: child),
                      ),
                      child: Card(
                        elevation: 2.0 + i,
                        color: i == _stack.length - 1
                            ? scheme.primaryContainer
                            : scheme.surfaceContainer,
                        child: SizedBox(
                          height: 70,
                          child: Center(
                            child: Text(
                              i == _stack.length - 1 ? '👀 $name (visible)' : name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Stack depth: ${_stack.length}   '
              '(Android: Activity back stack / NavController)'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                onPressed: _stack.length > 5
                    ? null
                    : () => setState(() =>
                        _stack.add(_names[(_stack.length - 1) % _names.length])),
                child: const Text('push()'),
              ),
              OutlinedButton(
                onPressed: _stack.length == 1
                    ? null
                    : () => setState(() => _stack.removeLast()),
                child: const Text('pop()'),
              ),
              TextButton(
                onPressed: () => setState(() => _stack
                  ..clear()
                  ..add('HomeScreen')),
                child: const Text('popUntil(first)'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── Implicit vs explicit animation ───────────────────────
class ImplicitExplicitDemo extends StatefulWidget {
  const ImplicitExplicitDemo({super.key});
  @override
  State<ImplicitExplicitDemo> createState() => _ImplicitExplicitDemoState();
}

class _ImplicitExplicitDemoState extends State<ImplicitExplicitDemo>
    with SingleTickerProviderStateMixin {
  bool _big = false;
  // Explicit: we own the controller ≈ ValueAnimator
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  Curve _curve = Curves.easeInOut;

  static const _curves = <String, Curve>{
    'linear': Curves.linear,
    'easeInOut': Curves.easeInOut,
    'bounceOut': Curves.bounceOut,
    'elasticOut': Curves.elasticOut,
  };

  @override
  void dispose() {
    _controller.dispose(); // must dispose ≈ animator.cancel()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoPanel(
      caption: 'Top: implicit (just change a value). Bottom: explicit '
          '(you drive an AnimationController with a Curve ≈ Interpolator).',
      child: Column(
        children: [
          const Text('IMPLICIT - AnimatedContainer',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 140,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: _curve,
                width: _big ? 200 : 80,
                height: _big ? 120 : 80,
                decoration: BoxDecoration(
                  color: _big ? scheme.primary : scheme.tertiary,
                  borderRadius: BorderRadius.circular(_big ? 8 : 40),
                ),
              ),
            ),
          ),
          FilledButton.tonal(
            onPressed: () => setState(() => _big = !_big),
            child: const Text('setState(() => big = !big)'),
          ),
          const Divider(height: 32),
          const Text('EXPLICIT - AnimationController + Tween + Curve',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 6,
            children: [
              for (final e in _curves.entries)
                ChoiceChip(
                  label: Text(e.key),
                  selected: _curve == e.value,
                  onSelected: (_) => setState(() => _curve = e.value),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _curve.transform(_controller.value);
                return Align(
                  alignment: Alignment(-1 + 2 * t, 0),
                  child: Transform.rotate(angle: t * 2 * math.pi, child: child),
                );
              },
              child: const FlutterLogo(size: 50),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              FilledButton(
                  onPressed: () => _controller.forward(from: 0),
                  child: const Text('forward()')),
              OutlinedButton(
                  onPressed: () => _controller.reverse(),
                  child: const Text('reverse()')),
              OutlinedButton(
                  onPressed: () => _controller.repeat(reverse: true),
                  child: const Text('repeat()')),
              TextButton(
                  onPressed: () => _controller.stop(),
                  child: const Text('stop()')),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Theme preview ───────────────────────────
class ThemePreviewDemo extends StatefulWidget {
  const ThemePreviewDemo({super.key});
  @override
  State<ThemePreviewDemo> createState() => _ThemePreviewDemoState();
}

class _ThemePreviewDemoState extends State<ThemePreviewDemo> {
  Color _seed = Colors.indigo;
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      colorSchemeSeed: _seed,
      brightness: _dark ? Brightness.dark : Brightness.light,
    );
    return DemoPanel(
      caption: 'One seed colour generates the whole Material 3 ColorScheme. '
          'AnimatedTheme cross-fades between themes.',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final c in [
                Colors.indigo,
                Colors.teal,
                Colors.deepOrange,
                Colors.pink,
                Colors.green,
              ])
                GestureDetector(
                  onTap: () => setState(() => _seed = c),
                  child: CircleAvatar(
                    backgroundColor: c,
                    radius: _seed == c ? 18 : 14,
                    child: _seed == c
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
            ],
          ),
          SwitchListTile(
            title: const Text('Dark theme (values-night)'),
            value: _dark,
            onChanged: (v) => setState(() => _dark = v),
          ),
          AnimatedTheme(
            data: theme,
            duration: const Duration(milliseconds: 500),
            child: Builder(
              // Builder gives a context BELOW AnimatedTheme so
              // Theme.of(context) sees the new theme.
              builder: (context) {
                final s = Theme.of(context).colorScheme;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: s.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: s.primary,
                        child: Text('AppBar (colorPrimary)',
                            style: TextStyle(color: s.onPrimary)),
                      ),
                      const SizedBox(height: 8),
                      Text('Body text (textColorPrimary)',
                          style: TextStyle(color: s.onSurface)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          FilledButton(
                              onPressed: () {}, child: const Text('Filled')),
                          const SizedBox(width: 8),
                          OutlinedButton(
                              onPressed: () {}, child: const Text('Outlined')),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
