// Local storage with SharedPreferences (via StorageService).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/services/storage_service.dart';
import '../../widgets/code_block.dart';
import '../../widgets/demo_scaffold.dart';

class StorageDemo extends StatefulWidget {
  const StorageDemo({super.key});
  @override
  State<StorageDemo> createState() => _StorageDemoState();
}

class _StorageDemoState extends State<StorageDemo> {
  late final StorageService _storage;
  late int _counter;
  late List<String> _notes;
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    // context.read is allowed in initState (listen: false).
    _storage = context.read<StorageService>();
    _counter = _storage.counter;
    _notes = _storage.notes;
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() => _counter++);
    _storage.setCounter(_counter); // ≈ prefs.edit().putInt(...).apply()
  }

  void _addNote() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() => _notes = [..._notes, text]);
    _storage.setNotes(_notes);
    _input.clear();
  }

  void _deleteNote(int i) {
    setState(() => _notes = [..._notes]..removeAt(i));
    _storage.setNotes(_notes);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Local Storage',
      android: 'SharedPreferences / DataStore · Room (SQLite) · files',
      flutter: 'shared_preferences · sqflite / drift / Hive · path_provider',
      note: 'Kill the app and reopen - the values survive. Never store '
          'tokens/passwords here: use flutter_secure_storage (Keystore).',
      children: [
        Card(
          child: ListTile(
            title: const Text('Persistent counter'),
            subtitle: Text('Value: $_counter'),
            trailing: FilledButton(
                onPressed: _increment, child: const Text('+1')),
          ),
        ),
        const SectionTitle('Persistent notes (List<String>)'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                decoration: const InputDecoration(
                  hintText: 'Write a note…',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addNote(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _addNote, icon: const Icon(Icons.add)),
          ],
        ),
        const SizedBox(height: 8),
        if (_notes.isEmpty) const Text('No notes saved yet.'),
        for (final (i, n) in _notes.indexed)
          Card(
            child: ListTile(
              leading: const Icon(Icons.sticky_note_2_outlined),
              title: Text(n),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteNote(i),
              ),
            ),
          ),
        const SectionTitle('The code'),
        const CodeBlock('''
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('counter', 5);      // putInt().apply()
final c = prefs.getInt('counter') ?? 0; // getInt(key, 0)''',
            label: 'Dart'),
      ],
    );
  }
}
