import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool scanned = false; // чтобы один раз считать

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканировать штрихкод')),
      body: MobileScanner(
        onDetect: (capture) {
          if (scanned) return; // уже считано

          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final code = barcodes.first.rawValue;
            if (code != null) {
              scanned = true;
              Navigator.pop(context, code); // возвращаем в TextField
            }
          }
        },
      ),
    );
  }
}
