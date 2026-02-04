import 'package:flutter/material.dart';
import '../services/services.dart';

/// Enum for theme mode options
enum AppThemeMode { light, dark, system }

/// ThemeProvider manages the app's theme state
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  late AppThemeMode _themeMode;
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
        orElse: () => AppThemeMode.system,
      );
    } else {
      _themeMode = AppThemeMode.system;
    }
    notifyListeners();
  }

  /// Get current theme mode
  AppThemeMode get themeMode => _themeMode;

  /// Get current brightness based on theme mode and system settings
  Brightness? getBrightness(BuildContext context) {
    if (_themeMode == AppThemeMode.system) {
      return null; // Let system determine brightness
    } else if (_themeMode == AppThemeMode.dark) {
      return Brightness.dark;
    } else {
      return Brightness.light;
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _localStorage.saveSetting(_themeKey, mode.toString());
    notifyListeners();
  }

  /// Toggle between light and dark theme (cycles: light -> dark -> light)
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case AppThemeMode.light:
        await setThemeMode(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        await setThemeMode(AppThemeMode.light);
        break;
      case AppThemeMode.system:
        // If on system, switch to light
        await setThemeMode(AppThemeMode.light);
        break;
    }
  }

  /// Check if dark mode is currently active
  bool get isDarkMode {
    if (_themeMode == AppThemeMode.dark) {
      return true;
    } else if (_themeMode == AppThemeMode.system) {
      // This would need context to determine, handled by MaterialApp
      return false; // Default to light when system mode
    }
    return false;
  }
}
