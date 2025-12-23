import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeService extends ChangeNotifier {
  static const _key = 'isDark';
  bool _isDark = false;

  bool get isDark => _isDark;

  Future<void> load() async {
    final box = await Hive.openBox('settings');
    _isDark = box.get(_key, defaultValue: false);
    notifyListeners();
  }

  void toggle() {
    _isDark = !_isDark;
    Hive.box('settings').put(_key, _isDark);
    notifyListeners();
  }

  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;
}
