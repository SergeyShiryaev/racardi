import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:ui' as ui;

class LanguageService extends ChangeNotifier {
  static const _key = 'locale';
  static const _boxName = 'settings';
  late String _locale;

  String get locale => _locale;

  /// Инициализировать сервис
  Future<void> load() async {
    try {
      final box = await Hive.openBox(_boxName);
      
      // Сначала проверяем сохраненный язык
      final saved = box.get(_key, defaultValue: null);
      
      if (saved != null) {
        _locale = saved;
        debugPrint('✅ LanguageService: загружен язык из Hive: $_locale');
      } else {
        // Если нет сохраненного, пытаемся получить из локали системы
        _locale = _getSystemLocale();
        await box.put(_key, _locale);
        debugPrint('✅ LanguageService: установлен языковой код из системы: $_locale');
      }
    } catch (e) {
      debugPrint('❌ LanguageService.load() ошибка: $e');
      _locale = 'en';
    }
    
    notifyListeners();
  }

  /// Установить новый язык
  Future<void> setLocale(String newLocale) async {
    try {
      _locale = newLocale;
      final box = await Hive.openBox(_boxName);
      await box.put(_key, _locale);
      debugPrint('✅ LanguageService: язык сохранен в Hive: $_locale');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ LanguageService.setLocale() ошибка: $e');
    }
  }

  /// Получить языковой код из системной локали
  String _getSystemLocale() {
    final systemLocale = ui.window.locale.languageCode;
    debugPrint('🔍 LanguageService: система использует: $systemLocale');
    
    // Поддерживаем русский и английский
    if (systemLocale == 'ru') {
      return 'ru';
    }
    
    return 'en';
  }
}
