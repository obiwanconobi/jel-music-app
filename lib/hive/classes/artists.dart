  import 'package:hive/hive.dart';

  part 'artists.g.dart';

  @HiveType(typeId: 1)
  class Artists extends HiveObject {
    Artists({
      required this.name,
      required this.id,
      required this.picture,
      this.favourite, // marked as nullable
    });

    @HiveField(0)
    String name;

    @HiveField(1)
    String id;

    @HiveField(2)
    String picture;

    @HiveField(3)
    bool? favourite; // marked as nullable

    @override
    String toString() {
      return '$name:$name';
    }
  }
