import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/discount_card.dart';
import '../painters/dog_back_painter.dart';
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
  String barcodeSide = 'front'; // 🔹 сторона со штрихкодом

  static const double cardRatio = 1.586;

  // ───────────────── IMAGE RESIZE ─────────────────
  Future<void> _autoDetectBarcode() async {
    if (front == null || back == null) return;

    final detected = await BarcodeService.detectBarcodeWithSide(
      frontImage: front!,
      backImage: back!,
    );

    if (detected != null) {
      setState(() {
        barcodeController.text = detected['value'] ?? '';
        barcodeSide = detected['side'] ?? 'front'; // сохраняем сторону
      });
    }
  }

  Future<File> _saveImagePermanently(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/cards');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final newPath =
        '${imagesDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

    return file.copy(newPath);
  }

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
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
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
              title: Text(l10n.gallery),
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

  Widget imagePreview(File? image, bool isFront) {
    return GestureDetector(
      onTap: () async {
        // 🔹 Короткий тап - сразу открываем камеру и идем в кроп
        final img = await pickAndEditImage(ImageSource.camera);
        if (img != null) {
          setState(() => isFront ? front = img : back = img);
        }
      },
      onLongPress: () {
        // 🔹 Длительное нажатие - показываем меню выбора
        chooseImageSource(isFront);
      },
      child: AspectRatio(
        aspectRatio: cardRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image != null
              ? Image.file(image, fit: BoxFit.cover)
              : Container(
                  color: Colors.grey[200],
                  child: isFront
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: SvgPicture.asset(
                                  'assets/images/dog_sitting.svg'),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'загрузи лицевую сторону',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CustomPaint(
                                painter: DogBackPainter(),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'загрузи обратную сторону',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
        ),
      ),
    );
  }

  // ───────────────── BARCODE SOURCE PICK ─────────────────

  Future<String?> chooseBarcodeSource() async {
    final l10n = AppLocalizations.of(context)!;
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.scanBarcode),
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
              title: Text(l10n.gallery),
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
              title: Text(l10n.editCard),
              onTap: () async {
                final result = await showDialog<String>(
                  context: context,
                  builder: (_) {
                    final controller = TextEditingController();
                    return AlertDialog(
                      title: Text(l10n.selectBarcode),
                      content: const TextField(
                        decoration: InputDecoration(hintText: 'Штрихкод'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text),
                          child: Text(l10n.save),
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
    final l10n = AppLocalizations.of(context)!;
    try {
      // 🔹 Детект из текстового поля
      String? barcodeValue = barcodeController.text.trim().isNotEmpty
          ? barcodeController.text.trim()
          : null;

      String? barcodeType; // формат штрихкода

      // 🔹 Если нет текста и обе стороны выбраны, пробуем детект
      if ((barcodeValue == null || barcodeValue.isEmpty) &&
          front != null &&
          back != null) {
        final detected = await BarcodeService.detectBarcodeWithSide(
          frontImage: front!,
          backImage: back!,
        );

        barcodeValue = detected?['value'];
        barcodeType = detected?['format'];
        barcodeSide = detected?['side'] ?? 'front';
      }

      // 🔹 Если все ещё нет, позволяем пользователю выбрать
      if (barcodeValue == null || barcodeValue.isEmpty) {
        barcodeValue = await chooseBarcodeSource();
        barcodeType ??= 'code128'; // fallback
      }

      if (barcodeValue == null || barcodeValue.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.selectBarcode)),
        );
        return;
      }

      // 🔹 Сохраняем изображения
      String frontPath = '';
      String backPath = '';

      if (front != null) {
        final savedFront = await _saveImagePermanently(front!);
        frontPath = savedFront.path;
        debugPrint('✅ Front image saved: $frontPath');
      }

      if (back != null) {
        final savedBack = await _saveImagePermanently(back!);
        backPath = savedBack.path;
        debugPrint('✅ Back image saved: $backPath');
      }

      // 🔹 Создаём и сохраняем карту в Hive
      final newCard = DiscountCard(
        title: titleController.text.isNotEmpty
            ? titleController.text
            : 'Новая карта',
        primaryBarcode: barcodeValue,
        description: '',
        frontImagePath: frontPath,
        backImagePath: backPath,
        barcodeType: barcodeType ?? 'code128',
        barcodeSide: barcodeSide,
      );

      final box = Hive.box<DiscountCard>('cards');
      await box.add(newCard);

      debugPrint('✅ Card saved to Hive with key: ${newCard.key}');
      debugPrint('✅ Total cards in box: ${box.length}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cardUpdated)),
        );
        Navigator.pop(context);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving card: $e');
      debugPrint('❌ Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.cardSaveFailed}: $e')),
        );
      }
    }
  }

  // ───────────────── UI ─────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCard)),
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
          Text(l10n.frontSide),
          imagePreview(front, true),
          const SizedBox(height: 12),
          Text(l10n.backSide),
          imagePreview(back, false),
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
          const SizedBox(height: 8),
          // 🔹 Auto-detect barcode button
          if (front != null && back != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_fix_high),
                label: Text(l10n.autoDetectBarcode),
                onPressed: () async {
                  await _autoDetectBarcode();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.barcodeDetected),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
          const SizedBox(height: 16),
          Text(l10n.barcodeLocation),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(l10n.front),
                selected: barcodeSide == 'front',
                onSelected: (_) => setState(() => barcodeSide = 'front'),
              ),
              FilterChip(
                label: Text(l10n.back),
                selected: barcodeSide == 'back',
                onSelected: (_) => setState(() => barcodeSide = 'back'),
              ),
              FilterChip(
                label: Text(l10n.both),
                selected: barcodeSide == 'both',
                onSelected: (_) => setState(() => barcodeSide = 'both'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: saveCard,
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
