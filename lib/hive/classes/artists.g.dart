// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artists.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArtistsAdapter extends TypeAdapter<Artists> {
  @override
  final int typeId = 1;

  @override
  Artists read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Artists(
      name: fields[0] as String,
      id: fields[1] as String,
      picture: fields[2] as String,
      favourite: fields[3] as bool?,
      overview: fields[4] as String?,
      playCount: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Artists obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.picture)
      ..writeByte(3)
      ..write(obj.favourite)
      ..writeByte(4)
      ..write(obj.overview)
      ..writeByte(5)
      ..write(obj.playCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArtistsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
