// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'albums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlbumsAdapter extends TypeAdapter<Albums> {
  @override
  final int typeId = 2;

  @override
  Albums read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Albums(
      name: fields[0] as String,
      id: fields[1] as String,
      picture: fields[2] as String,
      favourite: fields[3] as bool?,
      artistId: fields[4] as String?,
      artist: fields[5] as String?,
      year: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Albums obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.picture)
      ..writeByte(3)
      ..write(obj.favourite)
      ..writeByte(4)
      ..write(obj.artistId)
      ..writeByte(5)
      ..write(obj.artist)
      ..writeByte(6)
      ..write(obj.year);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlbumsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
