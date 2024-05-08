  import 'package:hive/hive.dart';

  part 'log.g.dart';

  @HiveType(typeId: 4)
  class Log extends HiveObject {
    Log({
      required this.id,
      required this.logType,
      required this.logMessage,
      required this.logDateTime,
    });

    @HiveField(0)
    String id;

    @HiveField(1)
    String logType;

    @HiveField(2)
    String logMessage;

    @HiveField(3)
    DateTime logDateTime;

  }
