import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../models/discount_card.dart';

class CardDetailsScreen extends StatefulWidget {
  final DiscountCard card;
  const CardDetailsScreen({super.key, required this.card});

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen> {
  late final List<Widget> _views;
  late final PageController _pageController;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController()
      ..addListener(() {
        setState(() {
          _pageOffset = _pageController.page ?? 0.0;
        });
      });

    _views = [];

    // 1️⃣ Barcode
    final barcodeData = widget.card.primaryBarcode;
    if (barcodeData.isNotEmpty) {
      _views.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 1.586, // card proportions
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Card background (semi-transparent)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.white.withAlpha((0.95 * 255).round()),
                  ),
                ),

                // Centered barcode
                Center(
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: barcodeData,
                    drawText: true,
                    width: double.infinity,
                    height: 250, // fixed barcode height
                    style: const TextStyle(
                      fontSize: 28,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2️⃣ Front image
    if (widget.card.frontImagePath.isNotEmpty &&
        File(widget.card.frontImagePath).existsSync()) {
      _views.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Image.file(
            File(widget.card.frontImagePath),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // 3️⃣ Back image
    if (widget.card.backImagePath.isNotEmpty &&
        File(widget.card.backImagePath).existsSync()) {
      _views.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Image.file(
            File(widget.card.backImagePath),
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    // 4️⃣ Description
    if (widget.card.description.isNotEmpty) {
      _views.add(
        Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Text(
              widget.card.description,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    if (_views.isEmpty) {
      _views.add(const Center(child: Text('No data to display')));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasBackground = widget.card.frontImagePath.isNotEmpty &&
        File(widget.card.frontImagePath).existsSync();

    return Scaffold(
      appBar: AppBar(title: Text(widget.card.title)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 🖼 Background with parallax and clipped to avoid overscroll white stripe
          if (hasBackground)
            ClipRect(
              child: Transform.translate(
                offset: Offset(_pageOffset * 20, 0), // small parallax offset
                child: Image.file(
                  File(widget.card.frontImagePath),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(color: Theme.of(context).colorScheme.surface),

          /// ☁️ Frosted overlay + blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha((0.45 * 255).round()),
                    Colors.white.withAlpha((0.80 * 255).round()),
                  ],
                ),
              ),
            ),
          ),

          /// 📄 PageView with cards
          PageView.builder(
            controller: _pageController,
            itemCount: _views.length,
            physics: const ClampingScrollPhysics(), // disables overscroll
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  // Center card
                  child: AspectRatio(
                    aspectRatio: 1.586, // card proportions
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withAlpha((0.08 * 255).round()),
                            
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        color: Colors.white,
                        child: _views[index],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
