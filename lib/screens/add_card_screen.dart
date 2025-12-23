import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/discount_card.dart';
import '../services/barcode_service.dart';
import '../widgets/editable_image_widget.dart';
import 'barcode_scanner_screen.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final ImagePicker picker = ImagePicker();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();

  File? front;
  File? back;

  static const double cardRatio = 1.586;

  // ───────────────── IMAGE RESIZE ─────────────────

  Future<File> _resizeImage(File file) async {
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) return file;

    const maxSize = 1080;

    final resized = img.copyResize(
      decoded,
      width: decoded.width > decoded.height ? maxSize : null,
      height: decoded.height >= decoded.width ? maxSize : null,
    );

    final resizedBytes = img.encodeJpg(resized, quality: 90);

    final dir = await getTemporaryDirectory();
    final outFile = File(
      '${dir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    await outFile.writeAsBytes(resizedBytes);
    return outFile;
  }

  // ───────────────── IMAGE PICK + EDIT ─────────────────

  Future<File?> pickAndEditImage(ImageSource source) async {
    final XFile? picked =
        await picker.pickImage(source: source, imageQuality: 50);

    if (picked == null) return null;

    final File original = File(picked.path);

    // 🔽 уменьшаем фото ДО редактора
    final File resized = await _resizeImage(original);

    final File? edited = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => EditableImage(imageFile: resized),
      ),
    );

    return edited ?? resized;
  }

  void chooseImageSource(bool isFront) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () async {
                Navigator.pop(context);
                final img = await pickAndEditImage(ImageSource.camera);
                if (img != null) {
                  setState(() => isFront ? front = img : back = img);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Галерея'),
              onTap: () async {
                Navigator.pop(context);
                final img = await pickAndEditImage(ImageSource.gallery);
                if (img != null) {
                  setState(() => isFront ? front = img : back = img);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget imagePreview(File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: cardRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image != null
              ? Image.file(image, fit: BoxFit.cover)
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
        ),
      ),
    );
  }

  // ───────────────── BARCODE SOURCE PICK ─────────────────

  Future<String?> chooseBarcodeSource() async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Сканировать камерой'),
              onTap: () async {
                final code = await Navigator.push<String>(
                  sheetContext,
                  MaterialPageRoute(
                    builder: (_) => const BarcodeScannerScreen(),
                  ),
                );
                Navigator.pop(sheetContext, code);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Распознать с фото'),
              onTap: () async {
                final XFile? img =
                    await picker.pickImage(source: ImageSource.gallery);
                if (img == null) {
                  Navigator.pop(sheetContext, null);
                  return;
                }
                final code =
                    await BarcodeService.detectFromImages([File(img.path)]);
                Navigator.pop(sheetContext, code);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Ввести вручную'),
              onTap: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (_) {
                    final controller = TextEditingController();
                    return AlertDialog(
                      title: const Text('Введите штрихкод'),
                      content: TextField(controller: controller),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: const Text('Отмена'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text),
                          child: const Text('Сохранить'),
                        ),
                      ],
                    );
                  },
                );
                Navigator.pop(sheetContext, result);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── SAVE CARD ─────────────────

  Future<void> saveCard() async {
    String? barcode = barcodeController.text.trim().isNotEmpty
        ? barcodeController.text.trim()
        : null;

    barcode ??= await BarcodeService.detectFromImages(
      [if (front != null) front!, if (back != null) back!],
    );

    if (barcode == null || barcode.isEmpty) {
      barcode = await chooseBarcodeSource();
    }

    if (barcode == null || barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Штрихкод не указан')),
      );
      return;
    }

    Hive.box<DiscountCard>('cards').add(
      DiscountCard(
        title: titleController.text,
        primaryBarcode: barcode,
        description: '',
        frontImagePath: front?.path ?? '',
        backImagePath: back?.path ?? '',
      ),
    );

    Navigator.pop(context);
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить карту')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Название'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[а-яА-ЯёЁa-zA-Z0-9\s]'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Лицевая сторона'),
          imagePreview(front, () => chooseImageSource(true)),
          const SizedBox(height: 12),
          const Text('Обратная сторона'),
          imagePreview(back, () => chooseImageSource(false)),
          const SizedBox(height: 12),
          TextField(
            controller: barcodeController,
            decoration: InputDecoration(
              labelText: 'Штрихкод',
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () async {
                  final code = await chooseBarcodeSource();
                  if (code != null) {
                    setState(() => barcodeController.text = code);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveCard,
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
