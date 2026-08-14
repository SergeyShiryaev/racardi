import 'package:hive/hive.dart';

import 'document.dart';
import 'event_document.dart';
import 'event_type.dart';

part 'card_event.g.dart';

/// Событие (билет в кино/театр, поездка и т.д.) со сканами документов.
@HiveType(typeId: 1)
class CardEvent extends HiveObject implements Document {
  @override
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startAt;

  @HiveField(2)
  DateTime? endAt;

  @HiveField(3)
  String title;

  @HiveField(4)
  String? description;

  @HiveField(5)
  List<EventDocument> documents;

  @HiveField(6)
  String type; // хранится как EventType.name

  @HiveField(7)
  bool reminderEnabled;

  @HiveField(8)
  DateTime? reminderAt;

  @HiveField(9)
  bool cancelled;

  @override
  @HiveField(10)
  DateTime createdAt;

  @override
  @HiveField(11)
  DateTime updatedAt;

  CardEvent({
    required this.id,
    required this.startAt,
    this.endAt,
    required this.title,
    this.description,
    List<EventDocument>? documents,
    EventType type = EventType.other,
    this.reminderEnabled = false,
    this.reminderAt,
    this.cancelled = false,
    required this.createdAt,
    required this.updatedAt,
  })  : documents = documents ?? [],
        type = type.name;

  EventType get eventType => EventType.fromName(type);

  bool get isPast => endAt != null
      ? endAt!.isBefore(DateTime.now())
      : startAt.isBefore(DateTime.now());

  @override
  String get searchableText => [
        title,
        description,
        ...documents.map((d) => d.title),
        ...documents.map((d) => d.code),
      ].whereType<String>().join(' ').toLowerCase();
}
