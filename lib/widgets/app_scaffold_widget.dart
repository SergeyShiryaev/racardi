import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import '../services/language_service.dart';
import '../painters/lying_dog_painter.dart';
import '../painters/happy_dog_painter.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final PreferredSizeWidget? bottom;

  final VoidCallback? onImportExport;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onSendExportByMail;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.bottom,
    this.onImportExport,
    this.onToggleTheme,
    this.onSendExportByMail,
  });

  @override
  Widget build(BuildContext context) {
    final languageService = context.read<LanguageService>();
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: bottom,
      ),
      drawer: Drawer(
        child: Stack(
          children: [
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
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Настройки',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: Text(l10n.theme),
                onTap: () {
                  Navigator.pop(context);
                  onToggleTheme?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                onTap: () {
                  Navigator.pop(context);
                  _showLanguageDialog(context, languageService);
                },
              ),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: Text(l10n.importExport),
                onTap: () {
                  Navigator.pop(context);
                  onImportExport?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: Text(l10n.sendExportMail),
                onTap: () {
                  Navigator.pop(context);
                  onSendExportByMail?.call();
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(AppLocalizations.of(context)!.about),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Racardi Wallet',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Версия 1.1.0',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
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
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text(l10n.info),
                                      content: Text(l10n.aboutInfo),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(l10n.close),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text(l10n.info, style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                            Flexible(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  showLicensePage(
                                    context: context,
                                    applicationName: 'Racardi Wallet',
                                    applicationVersion: '1.1.0',
                                  );
                                },
                                child: const Text('Лицензии', style: TextStyle(fontSize: 10)),
                              ),
                            ),
                            Flexible(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l10n.close, style: const TextStyle(fontSize: 10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        ],
      ),
    ),
      body: body,
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageService languageService) {
    final currentLocale = languageService.locale;
    final supportedLocales = [
      {'code': 'ru', 'name': 'Русский'},
      {'code': 'en', 'name': 'English'},
    ];
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.language),
        content: Stack(
          children: [
            Opacity(
              opacity: 0.6,
              child: CustomPaint(
                painter: HappyDogPainter(),
              ),
            ),
            RadioGroup<String>(
              groupValue: currentLocale,
              onChanged: (value) {
                if (value != null) {
                  languageService.setLocale(value);
                  Navigator.pop(context);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: supportedLocales.map((langInfo) {
                  return RadioListTile<String>(
                    title: Text(langInfo['name']!),
                    value: langInfo['code']!,
                    tileColor: Colors.white.withValues(alpha: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
