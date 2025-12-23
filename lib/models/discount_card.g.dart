// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiscountCardAdapter extends TypeAdapter<DiscountCard> {
  @override
  final int typeId = 0;

  @override
  DiscountCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiscountCard(
      primaryBarcode: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      frontImagePath: fields[3] as String,
      backImagePath: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DiscountCard obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.primaryBarcode)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.frontImagePath)
      ..writeByte(4)
      ..write(obj.backImagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscountCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
