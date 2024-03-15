// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'songs.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongsAdapter extends TypeAdapter<Songs> {
  @override
  final int typeId = 3;

  @override
  Songs read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Songs(
      name: fields[0] as String,
      id: fields[1] as String,
      artist: fields[2] as String,
      artistId: fields[3] as String,
      album: fields[4] as String,
      albumId: fields[5] as String,
      index: fields[6] as int,
      year: fields[7] as int,
      length: fields[8] as String,
      favourite: fields[9] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, Songs obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.artist)
      ..writeByte(3)
      ..write(obj.artistId)
      ..writeByte(4)
      ..write(obj.album)
      ..writeByte(5)
      ..write(obj.albumId)
      ..writeByte(6)
      ..write(obj.index)
      ..writeByte(7)
      ..write(obj.year)
      ..writeByte(8)
      ..write(obj.length)
      ..writeByte(9)
      ..write(obj.favourite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
