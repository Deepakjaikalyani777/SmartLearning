// Animated explainers for architecture / async / platform concepts.
import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

import '../concept_demos.dart';

// ─────────────────────── notifyListeners() flow ───────────────────────
class NotifyListenersDemo extends StatefulWidget {
  const NotifyListenersDemo({super.key});
  @override
  State<NotifyListenersDemo> createState() => _NotifyListenersDemoState();
}

class _NotifyListenersDemoState extends State<NotifyListenersDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _delivered = _value);
      }
    });

  int _value = 0; // state inside the "ViewModel"
  int _delivered = 0; // what the listeners currently show

  static const _listeners = ['AppBar badge', 'Cart screen', 'Checkout btn'];

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _notify() {
    setState(() => _value++);
    _pulse.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoPanel(
      caption: 'ChangeNotifier (≈ ViewModel) calls notifyListeners() - every '
          'widget that did context.watch<T>() (≈ observe) rebuilds.',
      child: SizedBox(
        height: 260,
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            const top = 20.0;
            const bottom = 190.0;
            final sources = [w * 0.17, w * 0.5, w * 0.83];
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Notifier box
                Positioned(
                  left: w / 2 - 90,
                  top: top,
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('CartProvider',
                            style: TextStyle(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.bold)),
                        Text('count = $_value',
                            style: TextStyle(color: scheme.onPrimary)),
                      ],
                    ),
                  ),
                ),
                // Travelling dots
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, _) {
                    if (!_pulse.isAnimating) return const SizedBox.shrink();
                    final t = Curves.easeInOut.transform(_pulse.value);
                    return Stack(
                      children: [
                        for (final x in sources)
                          Positioned(
                            left: w / 2 + (x - w / 2) * t - 8,
                            top: top + 55 + (bottom - top - 60) * t,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                // Listeners
                for (final (i, name) in _listeners.indexed)
                  Positioned(
                    left: sources[i] - 50,
                    top: bottom,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey('$name-$_delivered'),
                      tween: Tween(begin: 1, end: 0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, t, _) => Container(
                        width: 100,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Color.lerp(
                              scheme.secondaryContainer, Colors.amber, t),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 11)),
                            Text('$_delivered',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 110,
                  child: Center(
                    child: FilledButton.icon(
                      onPressed: _notify,
                      icon: const Icon(Icons.campaign),
                      label: const Text('add() → notifyListeners()'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────── Event loop ───────────────────────────
class EventLoopDemo extends StatefulWidget {
  const EventLoopDemo({super.key});
  @override
  State<EventLoopDemo> createState() => _EventLoopDemoState();
}

class _EventLoopDemoState extends State<EventLoopDemo> {
  final List<(String, Color)> _log = [];
  StreamSubscription<int>? _sub;
  int? _tick;

  void _add(String msg, Color c) {
    if (mounted) setState(() => _log.add((msg, c)));
  }

  void _run() {
    setState(_log.clear);
    _add('1. sync: main code starts', Colors.blue);
    Future(() => _add('4. event queue: Future(() {...})', Colors.orange));
    scheduleMicrotask(() => _add('3. microtask queue: runs before events',
        Colors.purple));
    Future.delayed(const Duration(seconds: 1),
        () => _add('5. after 1s: Future.delayed (≈ delay(1000))', Colors.green));
    _add('2. sync: main code ends', Colors.blue);
  }

  void _toggleStream() {
    if (_sub != null) {
      _sub!.cancel();
      setState(() {
        _sub = null;
        _tick = null;
      });
      return;
    }
    // Stream ≈ Flow. listen ≈ collect.
    _sub = Stream.periodic(const Duration(milliseconds: 500), (i) => i)
        .listen((i) => setState(() => _tick = i));
    setState(() {});
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoPanel(
      caption: 'Dart runs one event loop: all sync code first, then '
          'microtasks, then events (timers, I/O). Like Android\'s main Looper.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _run,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Run: guess the print order'),
          ),
          const SizedBox(height: 8),
          for (final (i, (msg, color)) in _log.indexed)
            TweenAnimationBuilder<double>(
              key: ValueKey('$i$msg'),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 400),
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.translate(
                    offset: Offset(-30 * (1 - t), 0), child: child),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  border: Border(left: BorderSide(color: color, width: 4)),
                ),
                child: Text(msg, style: const TextStyle(fontFamily: 'monospace')),
              ),
            ),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(_tick == null
                    ? 'Stream (≈ Flow) stopped'
                    : 'Stream emitted: $_tick'),
              ),
              OutlinedButton(
                onPressed: _toggleStream,
                child: Text(_sub == null ? 'listen()' : 'cancel()'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Isolate vs jank ───────────────────────────

/// Deliberately slow CPU work. Top-level so it can be sent to an isolate.
int countPrimes(int limit) {
  var count = 0;
  for (var n = 2; n < limit; n++) {
    var prime = true;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) {
        prime = false;
        break;
      }
    }
    if (prime) count++;
  }
  return count;
}

class IsolateJankDemo extends StatefulWidget {
  const IsolateJankDemo({super.key});
  @override
  State<IsolateJankDemo> createState() => _IsolateJankDemoState();
}

class _IsolateJankDemoState extends State<IsolateJankDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();
  String _result = 'Watch the spinner while you tap a button.';
  bool _busy = false;
  static const _limit = 4000000;

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _onMain() async {
    setState(() {
      _busy = true;
      _result = 'Working on the UI isolate... (UI frozen = ANR territory)';
    });
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final sw = Stopwatch()..start();
    final primes = countPrimes(_limit); // blocks the event loop!
    setState(() {
      _busy = false;
      _result = 'Main isolate: $primes primes in ${sw.elapsedMilliseconds} ms '
          '- did you see the spinner freeze? 🥶';
    });
  }

  Future<void> _onIsolate() async {
    setState(() {
      _busy = true;
      _result = 'Working in a background isolate... UI stays smooth';
    });
    final sw = Stopwatch()..start();
    final primes = await Isolate.run(() => countPrimes(_limit));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = 'Isolate.run: $primes primes in ${sw.elapsedMilliseconds} ms '
          '- spinner never stopped 😎';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoPanel(
      caption: 'Isolate.run ≈ withContext(Dispatchers.Default). Separate '
          'memory, communicates by messages.',
      child: Column(
        children: [
          RotationTransition(
            turns: _spin,
            child: const FlutterLogo(size: 64),
          ),
          const SizedBox(height: 12),
          Text(_result, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _onMain,
                icon: const Icon(Icons.warning_amber),
                label: const Text('Run on UI isolate'),
              ),
              FilledButton.icon(
                onPressed: _busy ? null : _onIsolate,
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Isolate.run()'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Platform channel ───────────────────────────
class ChannelMessageDemo extends StatefulWidget {
  const ChannelMessageDemo({super.key});
  @override
  State<ChannelMessageDemo> createState() => _ChannelMessageDemoState();
}

class _ChannelMessageDemoState extends State<ChannelMessageDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DemoPanel(
      caption: 'invokeMethod() serialises the call, sends it over the '
          'channel, Kotlin handles it and replies via result.success(). '
          'Try the real one in Components → Platform Channel.',
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: LayoutBuilder(builder: (context, box) {
              final w = box.maxWidth;
              return AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final v = _c.value;
                  // 0→0.45 request travels right, 0.45→0.55 native works,
                  // 0.55→1 response travels left
                  final goingRight = v < 0.5;
                  final p = goingRight
                      ? Curves.easeInOut.transform((v / 0.45).clamp(0, 1))
                      : Curves.easeInOut
                          .transform(((v - 0.55) / 0.45).clamp(0, 1));
                  final x = goingRight ? 90 + (w - 250) * p : w - 160 - (w - 250) * p;
                  return Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 40,
                        child: _endpoint('Dart', Icons.flutter_dash,
                            const Color(0xFF02569B)),
                      ),
                      Positioned(
                        right: 0,
                        top: 40,
                        child: _endpoint('Kotlin', Icons.android,
                            const Color(0xFF3DDC84)),
                      ),
                      Positioned(
                        left: 90,
                        right: 90,
                        top: 74,
                        child: Container(height: 3, color: scheme.outline),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 120,
                        child: Center(
                          child: Text("MethodChannel('learn.flutter/battery')",
                              style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  color: scheme.onSurfaceVariant)),
                        ),
                      ),
                      if (_c.isAnimating)
                        Positioned(
                          left: x,
                          top: 58,
                          child: Container(
                            width: 70,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: goingRight ? Colors.blue : Colors.green,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              goingRight ? 'getBattery' : '85 %',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            }),
          ),
          FilledButton.icon(
            onPressed: () => _c.forward(from: 0),
            icon: const Icon(Icons.send),
            label: const Text('invokeMethod()'),
          ),
        ],
      ),
    );
  }

  Widget _endpoint(String label, IconData icon, Color color) => Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
