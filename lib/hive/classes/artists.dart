  import 'package:hive/hive.dart';

  part 'artists.g.dart';

  @HiveType(typeId: 1)
  class Artists extends HiveObject {
    Artists({
      required this.name,
      required this.id,
      required this.picture,
      this.favourite, // marked as nullable
      this.overview
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
    String? overview;

    @override
    String toString() {
      return '$name:$name';
    }
  }
