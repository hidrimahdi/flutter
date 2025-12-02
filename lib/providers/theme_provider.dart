import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('theme_mode');
    if (v == 'light') _mode = ThemeMode.light;
    if (v == 'dark') _mode = ThemeMode.dark;
    notifyListeners();
  }

  Future<void> toggle() async {
    if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.light;
    } else {
      _mode = ThemeMode.dark;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _mode == ThemeMode.dark ? 'dark' : 'light');
  }
}