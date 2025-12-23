import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/discount_card.dart';
import '../services/barcode_service.dart';
import '../widgets/editable_image_widget.dart';
import 'barcode_scanner_screen.dart';

class EditCardScreen extends StatefulWidget {
  final DiscountCard card;
  const EditCardScreen({super.key, required this.card});

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final ImagePicker picker = ImagePicker();
  late TextEditingController titleController;
  late TextEditingController barcodeController;

  late File front;
  late File back;

  static const double cardRatio = 1.586;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.card.title);
    barcodeController = TextEditingController(text: widget.card.primaryBarcode);
    front = File(widget.card.frontImagePath);
    back = File(widget.card.backImagePath);
  }

  Future<File?> pickAndEditImage(ImageSource source, File file) async {
    final XFile? img = await picker.pickImage(source: source, imageQuality: 90);
    if (img == null) return null;

    final File newFile = File(img.path);
    final File? edited = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => EditableImage(imageFile: newFile)),
    );
    return edited ?? newFile;
  }

  Future<void> editFront(ImageSource source) async {
    final File? result = await pickAndEditImage(source, front);
    if (result != null) setState(() => front = result);
  }

  Future<void> editBack(ImageSource source) async {
    final File? result = await pickAndEditImage(source, back);
    if (result != null) setState(() => back = result);
  }

  void chooseSource(bool isFront) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () {
                Navigator.pop(context);
                isFront ? editFront(ImageSource.camera) : editBack(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Галерея'),
              onTap: () {
                Navigator.pop(context);
                isFront ? editFront(ImageSource.gallery) : editBack(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPreview({required File image, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: cardRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: image.existsSync()
              ? Image.file(image, fit: BoxFit.cover)
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
        ),
      ),
    );
  }

  Future<void> scanBarcode() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (scannedCode != null) {
      setState(() {
        barcodeController.text = scannedCode;
      });
    }
  }

  Future<void> saveCard() async {
    String? barcode = barcodeController.text.trim().isNotEmpty
        ? barcodeController.text.trim()
        : null;

    barcode ??= await BarcodeService.detectFromImages([front, back]);

    if (barcode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Не удалось распознать штрихкод. Введите вручную.')),
      );
      return;
    }

    widget.card
      ..title = titleController.text
      ..primaryBarcode = barcode
      ..frontImagePath = front.path
      ..backImagePath = back.path
      ..save();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать карту')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Название'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[а-яА-ЯёЁa-zA-Z0-9\s]')),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Лицевая сторона'),
          const SizedBox(height: 6),
          buildPreview(image: front, onTap: () => chooseSource(true)),
          const SizedBox(height: 10),
          const Text('Обратная сторона'),
          const SizedBox(height: 6),
          buildPreview(image: back, onTap: () => chooseSource(false)),
          const SizedBox(height: 10),
          TextField(
            controller: barcodeController,
            decoration: InputDecoration(
              labelText: 'Штрихкод',
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: scanBarcode,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: saveCard, child: const Text('Сохранить')),
        ],
      ),
    );
  }
}
