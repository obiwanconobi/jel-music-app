  import 'package:hive/hive.dart';

  part 'songs.g.dart';

  @HiveType(typeId: 3)
  class Songs extends HiveObject {
    Songs({
      required this.name,
      required this.id,
      required this.artist,
      required this.artistId,
      required this.album,
      required this.albumId,
      required this.index,
      required this.year,
      required this.length,
      this.favourite, // marked as nullable
      this.downloaded,
      this.discIndex
    });

    @HiveField(0)
    String name;

    @HiveField(1)
    String id;

    @HiveField(2)
    String artist;

    @HiveField(3)
    String artistId;

    @HiveField(4)
    String album;

    @HiveField(5)
    String albumId;

    @HiveField(6)
    int index;

    @HiveField(7)
    int year;

    @HiveField(8)
    String length;

    @HiveField(9)
    bool? favourite; // marked as nullable

    @HiveField(10)
    bool? downloaded;

    @HiveField(11)
    int? discIndex;
  
    @override
    String toString() {
      return '$name:$name';
    }
  }
