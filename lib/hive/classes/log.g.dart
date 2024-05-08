// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LogAdapter extends TypeAdapter<Log> {
  @override
  final int typeId = 4;

  @override
  Log read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Log(
      id: fields[0] as String,
      logType: fields[1] as String,
      logMessage: fields[2] as String,
      logDateTime: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Log obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.logType)
      ..writeByte(2)
      ..write(obj.logMessage)
      ..writeByte(3)
      ..write(obj.logDateTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
