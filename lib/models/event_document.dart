import 'package:hive/hive.dart';

import 'event_type.dart';

part 'event_document.g.dart';

/// Один документ, привязанный к событию: скан, QR-код, штрихкод или PDF.
@HiveType(typeId: 2)
class EventDocument extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String path;

  @HiveField(2)
  String type; // хранится как EventDocumentType.name

  @HiveField(3)
  String? title;

  @HiveField(4)
  String? code;

  EventDocument({
    required this.id,
    required this.path,
    required EventDocumentType type,
    this.title,
    this.code,
  }) : type = type.name;

  EventDocumentType get documentType => EventDocumentType.fromName(type);
}
