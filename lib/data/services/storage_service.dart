// storage_service.dart — wraps SharedPreferences.
// ≈ android.content.SharedPreferences / Jetpack DataStore.
// NOTE: not for secrets! Use flutter_secure_storage (Keystore-backed).
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async =>
      StorageService._(await SharedPreferences.getInstance());

  static const _kDarkMode = 'dark_mode';
  static const _kNotes = 'notes';
  static const _kCounter = 'counter';

  bool? get darkMode => _prefs.getBool(_kDarkMode);
  Future<void> setDarkMode(bool? value) async {
    if (value == null) {
      await _prefs.remove(_kDarkMode);
    } else {
      await _prefs.setBool(_kDarkMode, value);
    }
  }

  List<String> get notes => _prefs.getStringList(_kNotes) ?? <String>[];
  Future<void> setNotes(List<String> notes) =>
      _prefs.setStringList(_kNotes, notes);

  int get counter => _prefs.getInt(_kCounter) ?? 0;
  Future<void> setCounter(int value) => _prefs.setInt(_kCounter, value);
}
