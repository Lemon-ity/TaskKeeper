import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  void setDark(bool value) {
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggle() {
    setDark(!isDark);
  }
}
