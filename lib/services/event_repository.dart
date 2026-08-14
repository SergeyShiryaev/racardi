import 'dart:io';

import 'package:hive/hive.dart';

import '../models/card_event.dart';
import '../models/event_document.dart';

/// Инкапсулирует доступ к Hive box 'events' и работу с файлами документов.
class EventRepository {
  Box<CardEvent> get _box => Hive.box<CardEvent>('events');

  List<CardEvent> getAll() => _box.values.toList();

  CardEvent? getById(String id) {
    try {
      return _box.values.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(CardEvent event) async {
    event.updatedAt = DateTime.now();
    await _box.put(event.id, event);
  }

  Future<void> delete(String id) async {
    final event = getById(id);
    if (event == null) return;

    for (final document in List<EventDocument>.from(event.documents)) {
      await _deleteDocumentFile(document);
    }
    await _box.delete(id);
  }

  Future<void> addDocument(String eventId, EventDocument document) async {
    final event = getById(eventId);
    if (event == null) return;

    event.documents.add(document);
    await save(event);
  }

  Future<void> deleteDocument(String eventId, String documentId) async {
    final event = getById(eventId);
    if (event == null) return;

    final document = event.documents.firstWhere(
      (d) => d.id == documentId,
      orElse: () => throw StateError('Document not found: $documentId'),
    );

    await _deleteDocumentFile(document);
    event.documents.removeWhere((d) => d.id == documentId);
    await save(event);
  }

  Future<void> _deleteDocumentFile(EventDocument document) async {
    if (document.path.isEmpty) return;
    final file = File(document.path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
