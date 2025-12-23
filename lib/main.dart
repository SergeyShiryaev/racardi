import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/discount_card.dart';
import 'screens/card_list_screen.dart';

/// Global key to show SnackBars from anywhere in the app
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and register adapters
  await Hive.initFlutter();
  Hive.registerAdapter(DiscountCardAdapter());

  // Open Hive box for storing discount cards
  await Hive.openBox<DiscountCard>('cards');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Racardi Wallet',
      theme: ThemeData(useMaterial3: true),
      scaffoldMessengerKey: rootMessengerKey,
      home: const CardListScreen(),
    );
  }
}
