// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_document.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventDocumentAdapter extends TypeAdapter<EventDocument> {
  @override
  final int typeId = 2;

  @override
  EventDocument read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventDocument(
      id: fields[0] as String,
      path: fields[1] as String,
      type: fields[2] as EventDocumentType,
      title: fields[3] as String?,
      code: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EventDocument obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.code);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventDocumentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
