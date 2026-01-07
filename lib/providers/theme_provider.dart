import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_themes.dart';

/// Theme state class
class ThemeState {
  final AppThemeMode currentTheme;

  const ThemeState({required this.currentTheme});

  ThemeState copyWith({AppThemeMode? currentTheme}) {
    return ThemeState(currentTheme: currentTheme ?? this.currentTheme);
  }
}

/// Theme notifier to manage app theme
class ThemeNotifier extends Notifier<ThemeState> {
  static const String _themeKey = 'app_theme';

  @override
  ThemeState build() {
    _loadTheme();
    return const ThemeState(currentTheme: AppThemeMode.warmCalming);
  }

  /// Load saved theme from shared preferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_themeKey);

      if (themeName != null) {
        final theme = AppThemeMode.values.firstWhere(
          (e) => e.name == themeName,
          orElse: () => AppThemeMode.warmCalming,
        );
        state = ThemeState(currentTheme: theme);
      }
    } catch (e) {
      // If loading fails, keep default theme
    }
  }

  /// Change theme and save to preferences
  Future<void> setTheme(AppThemeMode theme) async {
    state = ThemeState(currentTheme: theme);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, theme.name);
    } catch (e) {
      // Silently fail if saving doesn't work
    }
  }
}

/// Theme provider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
