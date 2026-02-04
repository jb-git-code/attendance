import 'package:flutter/material.dart';
import '../services/services.dart';

/// Enum for theme mode options
enum AppThemeMode { light, dark, system }

/// ThemeProvider manages the app's theme state
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  AppThemeMode _themeMode = AppThemeMode.light;
  final LocalStorageService _localStorage;

  ThemeProvider(this._localStorage) {
    _initTheme();
  }

  /// Initialize theme from persistent storage
  void _initTheme() async {
    final savedTheme = _localStorage.getSetting<String>(_themeKey);
    if (savedTheme != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => AppThemeMode.light,
      );
    } else {
      _themeMode = AppThemeMode.light;
    }
    notifyListeners();
  }

  /// Get current theme mode
  AppThemeMode get themeMode => _themeMode;

  /// Check if dark mode is active
  bool get isDarkMode => _themeMode == AppThemeMode.dark;

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _localStorage.saveSetting(_themeKey, mode.toString());
    notifyListeners();
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode == AppThemeMode.dark) {
      await setThemeMode(AppThemeMode.light);
    } else {
      await setThemeMode(AppThemeMode.dark);
    }
  }
}
