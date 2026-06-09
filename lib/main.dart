import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'models/discount_card.dart';
import 'screens/card_list_screen.dart';
import 'services/language_service.dart';
import 'app_localizations.dart';

final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(DiscountCardAdapter());

  // Инициализируем LanguageService
  final languageService = LanguageService();
  await languageService.load();

  // 🔹 Миграция: очищаем старую базу если она несовместима
  try {
    await Hive.openBox<DiscountCard>('cards');
    debugPrint('✅ База успешно открыта');
  } catch (e) {
    debugPrint('⚠️ Ошибка при открытии базы: $e');
    debugPrint('🔄 Пытаемся удалить и пересоздать базу...');
    try {
      // Пробуем удалить box
      await Hive.deleteBoxFromDisk('cards');
    } catch (deleteError) {
      debugPrint('   ⚠️ Не удалось удалить: $deleteError (продолжаем...)');
    }
    // Открываем новую базу
    await Hive.openBox<DiscountCard>('cards');
    debugPrint('✅ Новая база создана');
  }

  runApp(MyApp(languageService: languageService));
}

class MyApp extends StatelessWidget {
  final LanguageService languageService;

  const MyApp({
    super.key,
    required this.languageService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageService>.value(
      value: languageService,
      child: Consumer<LanguageService>(
        builder: (context, langService, _) {
          return MaterialApp(
            title: 'Racardi Wallet',
            theme: ThemeData(useMaterial3: true),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(langService.locale),
            navigatorKey: rootNavigatorKey,
            scaffoldMessengerKey: rootMessengerKey,
            home: const CardListScreen(),
          );
        },
      ),
    );
  }
}
