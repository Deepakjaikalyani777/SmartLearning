// Background work: Isolate.run / compute, Timer (≈ Handler.postDelayed),
// and notes on OS-level background execution.
import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../widgets/code_block.dart';
import '../../widgets/demo_scaffold.dart';

/// Top-level function so it can run in another isolate.
int _fib(int n) => n < 2 ? n : _fib(n - 1) + _fib(n - 2);

class BackgroundDemo extends StatefulWidget {
  const BackgroundDemo({super.key});
  @override
  State<BackgroundDemo> createState() => _BackgroundDemoState();
}

class _BackgroundDemoState extends State<BackgroundDemo> {
  String _isolateResult = '-';
  String _computeResult = '-';
  bool _running = false;
  Timer? _timer;
  int _ticks = 0;

  @override
  void dispose() {
    _timer?.cancel(); // ≈ handler.removeCallbacksAndMessages(null)
    super.dispose();
  }

  Future<void> _runIsolate() async {
    setState(() => _running = true);
    final sw = Stopwatch()..start();
    // ≈ withContext(Dispatchers.Default) { fib(35) }
    final r = await Isolate.run(() => _fib(35));
    if (!mounted) return;
    setState(() {
      _running = false;
      _isolateResult = 'fib(35) = $r in ${sw.elapsedMilliseconds} ms';
    });
  }

  Future<void> _runCompute() async {
    setState(() => _running = true);
    // compute(fn, arg) — older helper, same idea, works on web too.
    final r = await compute(_fib, 32);
    if (!mounted) return;
    setState(() {
      _running = false;
      _computeResult = 'fib(32) = $r';
    });
  }

  void _toggleTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() => _timer = null);
      return;
    }
    // ≈ handler.postDelayed(runnable, 1000) repeating
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _ticks++);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Background Work',
      android: 'Thread / Executor / Coroutines(Default) · Handler · '
          'Service · WorkManager',
      flutter: 'Isolate.run · compute() · Timer · workmanager plugin',
      children: [
        if (_running) const LinearProgressIndicator(),
        Card(
          child: ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('Isolate.run(() => fib(35))'),
            subtitle: Text(_isolateResult),
            trailing: FilledButton(
                onPressed: _running ? null : _runIsolate,
                child: const Text('Run')),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calculate_outlined),
            title: const Text('compute(_fib, 32)'),
            subtitle: Text(_computeResult),
            trailing: FilledButton(
                onPressed: _running ? null : _runCompute,
                child: const Text('Run')),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: const Text('Timer.periodic (≈ Handler.postDelayed)'),
            subtitle: Text('ticks: $_ticks'),
            trailing: OutlinedButton(
                onPressed: _toggleTimer,
                child: Text(_timer == null ? 'Start' : 'Stop')),
          ),
        ),
        const SectionTitle('When the app is CLOSED'),
        const Text(
          'Isolates die with the app process. For work that must run when '
          'the app is in the background or killed, use the native scheduler '
          'through a plugin:',
        ),
        const SizedBox(height: 8),
        const CodeBlock('''
# pubspec.yaml
dependencies:
  workmanager: ^0.5.2   # ≈ androidx.work.WorkManager

// main.dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    await syncData();          // ≈ Worker.doWork()
    return true;               // ≈ Result.success()
  });
}

Workmanager().initialize(callbackDispatcher);
Workmanager().registerPeriodicTask(
  'sync', 'syncTask',
  frequency: const Duration(hours: 1),
  constraints: Constraints(networkType: NetworkType.connected),
);''', label: 'Periodic background sync'),
      ],
    );
  }
}
