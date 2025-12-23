import 'dart:io';

import 'package:flutter/material.dart';
import 'package:racardi/main.dart';

import '../services/export_import_service.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Настройки',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // --- ТЕМА ---
            /*
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Тема приложения'),
              onTap: () {
                Navigator.pop(context);
                // TODO: переключение темы
              },
            ),
            */
            // --- ОТПРАВКА ПО EMAIL ---
            ListTile(
              leading: const Icon(Icons.email_sharp),
              title: const Text('Поделиться'),
              onTap: () async {
                Navigator.pop(context);

                try {
                  await ExportImportService.exportAndShareZip();

                  rootMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('Экспорт отправлен по почте')),
                  );
                } catch (e) {
                  rootMessengerKey.currentState?.showSnackBar(
                    SnackBar(content: Text('Ошибка отправки: $e')),
                  );
                }
              },
            ),

            // --- ИМПОРТ / ЭКСПОРТ ---
            ListTile(
              leading: const Icon(Icons.import_export),
              title: const Text('Импорт / Экспорт 2'),
              onTap: () async {
                // закрываем drawer
                Navigator.pop(context);

                // ждём анимацию закрытия
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Импорт / Экспорт 3'),
                    content: const Text(
                      'Выберите действие для сохранения или загрузки данных',
                    ),
                    actions: [
                      // --- ЭКСПОРТ ---
                      TextButton(
                        child: const Text('Экспорт'),
                        onPressed: () async {
                          // ✅ закрываем Drawer ПРАВИЛЬНО
                          //Navigator.of(context, rootNavigator: true).pop();

                          try {
                            await ExportImportService.exportToZip();

                            rootMessengerKey.currentState?.showSnackBar(
                              const SnackBar(content: Text('Экспорт завершён')),
                            );
                          } catch (e) {
                            rootMessengerKey.currentState?.showSnackBar(
                              SnackBar(content: Text('Ошибка экспорта: $e')),
                            );
                          }
                        },
                      ),

                      // --- ИМПОРТ ---
                      TextButton(
                        child: const Text('Импорт'),
                        onPressed: () async {
                          try {
                            final File? zip =
                                await ExportImportService.pickZip();
                            if (zip == null) return;

                            await ExportImportService.importFromZip(zip);

                            rootMessengerKey.currentState?.showSnackBar(
                              const SnackBar(content: Text('Экспорт завершён')),
                            );
                          } catch (e) {
                            rootMessengerKey.currentState?.showSnackBar(
                              SnackBar(content: Text('Ошибка экспорта: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
                await Future.delayed(const Duration(milliseconds: 300));

                if (!context.mounted) return;
              },
            ),

            const Spacer(),

            // --- О ПРИЛОЖЕНИИ ---
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('О приложении'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Racardi Wallet',
                  applicationVersion: '1.1.0',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
