import 'package:jel_music/hive/classes/log.dart';
import 'package:jel_music/models/log.dart';

class Conversions{

  int returnSecondsFromDuration(String duration){

      List<String> timeParts = duration.split(':');
      if (timeParts.length == 2) {
        int minutes = int.parse(timeParts[0]);
        int secondsFromMinutes = minutes * 60;
        int seconds = int.parse(timeParts[1]);
        return secondsFromMinutes + seconds;
      }
    return 0;
  }

  Log returnLogFromLogModel(LogModel log){
    return Log(id: log.id!, logType: log.logType!, logMessage: log.logMessage!, logDateTime: log.logDateTime!);
  }

  LogModel returnLogModelFromLog(Log log){
   return LogModel(id: log.id, logType: log.logType, logMessage: log.logMessage, logDateTime: log.logDateTime);
  }

  codecCleanup(String codec){
      if(codec.startsWith('PCM'))return "wav";
      if(codec.startsWith('ALAC'))return "m4a";
      if(codec.startsWith('FLAC'))return "flac";
      if(codec.startsWith('MP3'))return "mp3";
      
  }

  String returnTicksToTimestampString(int ticks) {
    // Ticks per second
      const int ticksPerSecond = 10000000;

      // Calculate the total seconds
      int totalSeconds = ticks ~/ ticksPerSecond;

      // Extract minutes and seconds
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;

      // Format the result as "mm:ss"
      String timestampString = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

      return timestampString;
    }
}