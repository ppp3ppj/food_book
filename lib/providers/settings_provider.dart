import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

/// Settings state provider
class SettingsNotifier extends Notifier<SettingsModel> {
  SharedPreferences? _prefsCache;

  @override
  SettingsModel build() {
    _loadSettings();
    return SettingsModel();
  }

  /// Get cached SharedPreferences instance
  Future<SharedPreferences> get _prefs async {
    _prefsCache ??= await SharedPreferences.getInstance();
    return _prefsCache!;
  }

  /// Load settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await _prefs;
      final headerText = prefs.getString('menuHeaderText') ?? 'เมนูอาหารวันนี้';
      final footerNote = prefs.getString('menuFooterNote') ?? '';

      state = SettingsModel(
        menuHeaderText: headerText,
        menuFooterNote: footerNote,
      );
    } catch (e) {
      print('❌ Error loading settings: $e');
    }
  }

  /// Update header text
  Future<void> updateHeaderText(String text) async {
    try {
      final prefs = await _prefs;
      await prefs.setString('menuHeaderText', text);
      state = state.copyWith(menuHeaderText: text);
    } catch (e) {
      print('❌ Error saving header text: $e');
    }
  }

  /// Update footer note
  Future<void> updateFooterNote(String note) async {
    try {
      final prefs = await _prefs;
      await prefs.setString('menuFooterNote', note);
      state = state.copyWith(menuFooterNote: note);
    } catch (e) {
      print('❌ Error saving footer note: $e');
    }
  }
}

/// Settings provider
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsModel>(() {
  return SettingsNotifier();
});
