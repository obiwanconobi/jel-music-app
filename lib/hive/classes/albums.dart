  import 'package:hive/hive.dart';

  part 'albums.g.dart';

  @HiveType(typeId: 2)
  class Albums extends HiveObject {
    Albums({
      required this.name,
      required this.id,
      required this.picture,
      required this.favourite,
      required this.artistId,
      required this.artist,
      required this.year,
    });

    @HiveField(0)
    String name;

    @HiveField(1)
    String id;

    @HiveField(2)
    String picture;

    @HiveField(3)
    bool? favourite; // marked as nullable

    @HiveField(4)
    String? artistId;

    @HiveField(5)
    String? artist;

    @HiveField(6)
    String? year;

    @override
    String toString() {
      return '$name:$name';
    }
  }
