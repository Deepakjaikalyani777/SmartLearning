// ThemeProvider — a ChangeNotifier ≈ AndroidX ViewModel exposing LiveData.
// notifyListeners() ≈ liveData.value = newValue
import 'package:flutter/material.dart';

import '../data/services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage) {
    final saved = _storage.darkMode;
    _mode = saved == null
        ? ThemeMode.system
        : (saved ? ThemeMode.dark : ThemeMode.light);
  }

  final StorageService _storage;
  late ThemeMode _mode;

  ThemeMode get themeMode => _mode;

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    _storage.setDarkMode(switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => null,
    });
    notifyListeners();
  }
}
