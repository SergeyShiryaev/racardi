import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:racardi/services/export_import_service.dart';

import '../models/discount_card.dart';
import '../widgets/settings_drawer.dart';
import 'add_card_screen.dart';
import 'edit_card_screen.dart';
import 'card_details_screen.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  State<CardListScreen> createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final TextEditingController searchController = TextEditingController();
  String query = '';

  static const double cardRatio = 1.586;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SettingsDrawer(),
      drawerEdgeDragWidth: 40,
      appBar: AppBar(
        title: const Text('Мои карты'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(20),
              child: TextField(
                controller: searchController,
                onChanged: (value) =>
                    setState(() => query = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Поиск по названию или штрихкоду',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddCardScreen()),
        ),
      ),

      /// 🔥 Слушаем Hive для автообновления
      body: ValueListenableBuilder(
        valueListenable: Hive.box<DiscountCard>('cards').listenable(),
        builder: (context, Box<DiscountCard> box, _) {
          final cards = box.values.where((card) {
            final text = '${card.title} ${card.primaryBarcode}'.toLowerCase();
            return text.contains(query);
          }).toList();

          if (cards.isEmpty) {
            return const Center(child: Text('Нет карт'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Dismissible(
                  key: ValueKey(card.key),
                  direction: DismissDirection.horizontal,

                  /// ───── УДАЛЕНИЕ (влево)
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Удалить карту?'),
                          content: Text(card.title),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Удалить'),
                            ),
                          ],
                        ),
                      );
                    }

                    /// ───── РЕДАКТИРОВАНИЕ (вправо)
                    if (direction == DismissDirection.startToEnd) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditCardScreen(card: card),
                        ),
                      );
                      return false;
                    }

                    return false;
                  },

                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      card.delete();
                    }
                  },

                  background: _swipeBackground(
                    icon: Icons.edit,
                    alignment: Alignment.centerLeft,
                    color: Colors.blueGrey,
                  ),
                  secondaryBackground: _swipeBackground(
                    icon: Icons.delete,
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                  ),

                  child: AspectRatio(
                    aspectRatio: cardRatio,
                    child: _CardTile(card: card),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _swipeBackground({
    required IconData icon,
    required Alignment alignment,
    required Color color,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 30),
    );
  }
}

class _CardTile extends StatelessWidget {
  final DiscountCard card;

  const _CardTile({required this.card});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 👆 ОДИНАРНЫЙ ТАП — ПРОСМОТР
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CardDetailsScreen(card: card),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// ФОН КАРТЫ
            card.frontImagePath.isNotEmpty &&
                    File(card.frontImagePath).existsSync()
                ? Image.file(
                    File(card.frontImagePath),
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/empty_front.png',
                    fit: BoxFit.cover,
                  ),

            /// НИЖНЯЯ ПАНЕЛЬ С ТЕКСТОМ
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 12, 48, 12),
                    color: Colors.black.withOpacity(0.45),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          card.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.primaryBarcode,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            /// ✏️ ИКОНКА РЕДАКТИРОВАНИЯ
            Positioned(
              right: 6,
              bottom: 6,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditCardScreen(card: card),
                      ),
                    );
                  },
                ),
              ),
            ),

            /// 📤 ИКОНКА ПОДЕЛИТЬСЯ
            Positioned(
              right: 46, // смещаем немного влево, чтобы не перекрывало edit
              bottom: 6,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () async {
                    try {
                      await ExportImportService.exportAndShareCard(card);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка отправки: $e')),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
