import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final PreferredSizeWidget? bottom;

  final VoidCallback? onImportExport;
  final VoidCallback? onToggleTheme;
  final VoidCallback? onSendExportByMail;

  AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.bottom,
    this.onImportExport,
    this.onToggleTheme,
    this.onSendExportByMail,
  });

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        bottom: bottom,
      ),
      drawer: Drawer(
        child: SafeArea(
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
                title: const Text('Тема приложения'),
                onTap: () {
                  Navigator.pop(context);
                  onToggleTheme?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Импорт / Экспорт 1'),
                onTap: () {
                  Navigator.pop(context);
                  onImportExport?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Отправить экспорт по почте'),
                onTap: () {
                  Navigator.pop(context);
                  onSendExportByMail?.call();
                },
              ),
              
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
      ),
      body: body,
    );
  }
}
