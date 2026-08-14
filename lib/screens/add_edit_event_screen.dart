import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../app_localizations.dart';
import '../models/card_event.dart';
import '../models/event_document.dart';
import '../models/event_type.dart';
import '../services/event_repository.dart';
import 'event_type_labels.dart';

class AddEditEventScreen extends StatefulWidget {
  final CardEvent? event;

  const AddEditEventScreen({super.key, this.event});

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _repository = EventRepository();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  late DateTime _date;
  late TimeOfDay _time;
  EventType _type = EventType.other;
  final List<EventDocument> _documents = [];

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    if (event != null) {
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _date = DateTime(event.startAt.year, event.startAt.month, event.startAt.day);
      _time = TimeOfDay(hour: event.startAt.hour, minute: event.startAt.minute);
      _type = event.eventType;
      _documents.addAll(event.documents);
    } else {
      final now = DateTime.now();
      _date = DateTime(now.year, now.month, now.day);
      _time = TimeOfDay(hour: now.hour, minute: now.minute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _addDocumentFromGallery() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    await _addDocumentFile(File(picked.path));
  }

  Future<void> _addDocumentFromCamera() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    await _addDocumentFile(File(picked.path));
  }

  Future<void> _addDocumentFile(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final eventsDir = Directory('${dir.path}/events');
    if (!await eventsDir.exists()) {
      await eventsDir.create(recursive: true);
    }
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final newPath = '${eventsDir.path}/doc_$id.jpg';
    final saved = await file.copy(newPath);

    setState(() {
      _documents.add(EventDocument(
        id: id,
        path: saved.path,
        type: EventDocumentType.image,
      ));
    });
  }

  void _removeDocument(EventDocument document) {
    setState(() => _documents.remove(document));
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final startAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );

    if (_isEditing) {
      final event = widget.event!;
      event.title = title;
      event.description = _descriptionController.text.trim();
      event.startAt = startAt;
      event.type = _type.name;
      event.documents
        ..clear()
        ..addAll(_documents);
      await _repository.save(event);
    } else {
      final now = DateTime.now();
      final event = CardEvent(
        id: now.microsecondsSinceEpoch.toString(),
        startAt: startAt,
        title: title,
        description: _descriptionController.text.trim(),
        documents: _documents,
        type: _type,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.save(event);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editEvent : l10n.addEvent),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: l10n.eventTitle),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.eventDate),
                  subtitle: Text(
                    '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                  ),
                  onTap: _pickDate,
                ),
              ),
              Expanded(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.eventTime),
                  subtitle: Text(
                    '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                  ),
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<EventType>(
            initialValue: _type,
            decoration: InputDecoration(labelText: l10n.eventType),
            items: EventType.values
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(eventTypeIcon(type), size: 20),
                          const SizedBox(width: 8),
                          Text(eventTypeLabel(l10n, type)),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: l10n.eventDescription),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.addDocument, style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined),
                    onPressed: _addDocumentFromGallery,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    onPressed: _addDocumentFromCamera,
                  ),
                ],
              ),
            ],
          ),
          if (_documents.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.noDocuments),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _documents.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final document = _documents[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(document.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _removeDocument(document),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
