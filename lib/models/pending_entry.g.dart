// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingEntryAdapter extends TypeAdapter<PendingEntry> {
  @override
  final int typeId = 0;

  @override
  PendingEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingEntry(
      id: fields[0] as String,
      category: fields[1] as String,
      type: fields[2] as String,
      value: fields[3] as String,
      timestamp: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PendingEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.value)
      ..writeByte(4)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
