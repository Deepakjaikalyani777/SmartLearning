// Streams: StreamBuilder over a periodic stream, and a StreamController
// used as an event bus (≈ SharedFlow / Channel).
import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/demo_scaffold.dart';

class StreamsDemo extends StatefulWidget {
  const StreamsDemo({super.key});
  @override
  State<StreamsDemo> createState() => _StreamsDemoState();
}

class _StreamsDemoState extends State<StreamsDemo> {
  // ≈ flow { repeat(11) { emit(10 - it); delay(1000) } }
  Stream<int> _countdown() =>
      Stream.periodic(const Duration(seconds: 1), (i) => 10 - i).take(11);

  late Stream<int> _timer = _countdown();

  // ≈ MutableSharedFlow<String>()
  final _chat = StreamController<String>.broadcast();
  final _messages = <String>[];
  late final StreamSubscription<String> _sub;
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ≈ lifecycleScope.launch { chat.collect { ... } }
    _sub = _chat.stream.listen((m) => setState(() => _messages.insert(0, m)));
  }

  @override
  void dispose() {
    _sub.cancel(); // ≈ job.cancel()
    _chat.close();
    _input.dispose();
    super.dispose();
  }

  void _send() {
    if (_input.text.trim().isEmpty) return;
    _chat.add(_input.text.trim()); // ≈ sharedFlow.emit(...)
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Streams',
      android: 'Kotlin Flow / StateFlow / SharedFlow / LiveData',
      flutter: 'Stream / StreamController / StreamBuilder',
      children: [
        const SectionTitle('StreamBuilder countdown (≈ collectAsState)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<int>(
              stream: _timer,
              builder: (context, snap) {
                final done = snap.connectionState == ConnectionState.done;
                final value = snap.data ?? 10;
                return Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (c, a) =>
                          ScaleTransition(scale: a, child: c),
                      child: Text(
                        done ? '🚀' : '$value',
                        key: ValueKey('$done$value'),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    Text('state: ${snap.connectionState.name}'),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => setState(() => _timer = _countdown()),
                      child: const Text('Restart'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SectionTitle('StreamController.broadcast (≈ SharedFlow)'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                decoration: const InputDecoration(
                  hintText: 'Emit an event…',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
          ],
        ),
        const SizedBox(height: 8),
        for (final m in _messages)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(m),
            ),
          ),
      ],
    );
  }
}
