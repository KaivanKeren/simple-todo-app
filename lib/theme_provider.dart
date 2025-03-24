import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Key for storing theme preference
  static const themeKey = 'theme_mode';
  
  // Default to system theme
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;
  
  // Constructor that loads saved theme preference
  ThemeProvider() {
    _loadThemePreference();
  }
  
  // Load theme preference from shared preferences
  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getInt(themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeValue];
    notifyListeners();
  }
  
  // Save theme preference to shared preferences
  void _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeKey, _themeMode.index);
  }
  
  // Toggle between light, dark, and system themes
  void toggleTheme() {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
    }
    _saveThemePreference();
    notifyListeners();
  }
  
  // Set a specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference();
    notifyListeners();
  }
  
  // Check if current theme is dark
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Get system brightness
      final brightness = WidgetsBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}