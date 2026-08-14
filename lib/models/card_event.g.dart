// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardEventAdapter extends TypeAdapter<CardEvent> {
  @override
  final int typeId = 1;

  @override
  CardEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardEvent(
      id: fields[0] as String,
      startAt: fields[1] as DateTime,
      endAt: fields[2] as DateTime?,
      title: fields[3] as String,
      description: fields[4] as String?,
      documents: (fields[5] as List?)?.cast<EventDocument>(),
      type: fields[6] as EventType,
      reminderEnabled: fields[7] as bool,
      reminderAt: fields[8] as DateTime?,
      cancelled: fields[9] as bool,
      createdAt: fields[10] as DateTime,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CardEvent obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startAt)
      ..writeByte(2)
      ..write(obj.endAt)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.documents)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.reminderEnabled)
      ..writeByte(8)
      ..write(obj.reminderAt)
      ..writeByte(9)
      ..write(obj.cancelled)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
