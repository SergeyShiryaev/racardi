import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:racardi/main.dart';
import '../app_localizations.dart';
import '../painters/lying_dog_painter.dart';
import '../services/export_import_service.dart';
import '../services/language_service.dart';


void _showAboutDialog() {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;
  
  final l10n = AppLocalizations.of(ctx)!;
  
  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.racardiWallet,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.version,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(painter: LyingDogPainter()),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: ctx,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.info),
                      content: Text(l10n.aboutInfo),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(l10n.close),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(l10n.info, style: const TextStyle(fontSize: 9)),
              ),
            ),
            Flexible(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  showLicensePage(
                    context: ctx,
                    applicationName: l10n.racardiWallet,
                    applicationVersion: '1.1.1',
                  );
                },
                child: Text(l10n.licenses, style: const TextStyle(fontSize: 9)),
              ),
            ),
            Flexible(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.close, style: const TextStyle(fontSize: 9)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _showLanguageDialog() {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;
  
  final languageService = ctx.read<LanguageService>();
  final currentLocale = languageService.locale;
  final l10n = AppLocalizations.of(ctx)!;
  
  final supportedLocales = [
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'en', 'name': 'English'},
  ];
  
  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      title: Text(l10n.language),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...supportedLocales.map((langInfo) => RadioListTile<String>(
            title: Text(langInfo['name']!),
            value: langInfo['code']!,
            groupValue: currentLocale,
            onChanged: (value) {
              if (value != null) {
                languageService.setLocale(value);
                Navigator.pop(ctx);
              }
            },
          )),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.close),
        ),
      ],
    ),
  );
}

class SettingsDrawer extends StatelessWidget {
  final VoidCallback? onShowColumnsDialog;

  const SettingsDrawer({super.key, this.onShowColumnsDialog});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Drawer(
      child: Stack(
        children: [
          /// 🐕 ФОН - СОБАКА С МОЛОТКОМ И КНИГОЙ
          Center(
            child: Opacity(
              opacity: 0.25,
              child: CustomPaint(
                painter: LyingDogPainter(),
                size: const Size(64, 64),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.settings,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // --- ЯЗЫК ---
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              onTap: () {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) => _showLanguageDialog());
              },
            ),

            // --- ОТПРАВКА ПО EMAIL ---
            ListTile(
              leading: const Icon(Icons.email_sharp),
              title: Text(l10n.share),
              onTap: () async {
                Navigator.pop(context);

                try {
                  await ExportImportService.exportAndShareZip();

                  rootMessengerKey.currentState?.showSnackBar(
                    SnackBar(content: Text(l10n.exportSent)),
                  );
                } catch (e) {
                  rootMessengerKey.currentState?.showSnackBar(
                    SnackBar(content: Text('${l10n.exportErrorSend}: $e')),
                  );
                }
              },
            ),

            // --- ИМПОРТ / ЭКСПОРТ ---
            ListTile(
              leading: const Icon(Icons.import_export),
              title: Text(l10n.importExport),
              onTap: () async {
                // закрываем drawer
                Navigator.pop(context);

                // ждём анимацию закрытия
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l10n.importExport),
                    content: Text(
                      l10n.exportChooseAction,
                    ),
                    actions: [
                      // --- ЭКСПОРТ ---
                      TextButton(
                        child: Text(l10n.export),
                        onPressed: () async {
                          try {
                            await ExportImportService.exportToZip();

                            rootMessengerKey.currentState?.showSnackBar(
                              SnackBar(content: Text(l10n.exportCompleted)),
                            );
                          } catch (e) {
                            rootMessengerKey.currentState?.showSnackBar(
                              SnackBar(content: Text('${l10n.exportError}: $e')),
                            );
                          }
                        },
                      ),

                      // --- ИМПОРТ ---
                      TextButton(
                        child: Text(l10n.import),
                        onPressed: () async {
                          try {
                            final File? zip =
                                await ExportImportService.pickZip();
                            if (zip == null) return;

                            await ExportImportService.importFromZip(zip);

                            rootMessengerKey.currentState?.showSnackBar(
                              SnackBar(content: Text(l10n.exportCompleted)),
                            );
                          } catch (e) {
                            rootMessengerKey.currentState?.showSnackBar(
                              SnackBar(content: Text('${l10n.exportError}: $e')),
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

            // --- КОЛИЧЕСТВО КОЛОНОК ---
            if (onShowColumnsDialog != null)
              ListTile(
                leading: const Icon(Icons.view_agenda),
                title: Text(l10n.columnsCount),
                onTap: () {
                  Navigator.pop(context);
                  onShowColumnsDialog?.call();
                },
              ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.about),
              onTap: () {
                Navigator.pop(context);
                WidgetsBinding.instance.addPostFrameCallback((_) => _showAboutDialog());
              },
            ),
          ],
        ),
        ),
        ],
      ),
    );
  }
}

