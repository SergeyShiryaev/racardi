import 'package:flutter/material.dart';

class SelectBarcodeScreen extends StatelessWidget {
  final List<String> codes;

  const SelectBarcodeScreen({super.key, required this.codes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выберите штрихкод')),
      body: ListView.builder(
        itemCount: codes.length,
        itemBuilder: (context, index) {
          final code = codes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                code,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => Navigator.pop(context, code),
            ),
          );
        },
      ),
    );
  }
}
