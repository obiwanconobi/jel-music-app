import 'dart:math';
import 'dart:ui';

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

  String returnSecondsToTimestampString(int totalSeconds){
    // Extract minutes and seconds
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;

    // Format the result as "mm:ss"
    String timestampString = "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    return timestampString;
  }

  String returnName(String input){
    if(input.isEmpty)return "";
    return input!.split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0])
        .join();
  }


  Color returnColor(){
    final random = Random();

    // Generate a random number between 1 and 7 (inclusive)
    int randomNumber = random.nextInt(7) + 1;
    switch(randomNumber) {
      case 1: {
        // statements;
        return const Color(0xFFd0d2ff);
      }


      case 2: {
        //statements;
        return const Color(0xFFfdd0ff);
      }

      case 3: {
        //statements;
        return const Color(0xFFd0fffd);
      }
      case 4: {
        //statements;
        return const Color(0xFF98ffcc);
      }
      case 5: {
        //statements;
        return const Color(0xFFf4c3d8);
      }

      case 6: {
        //statements;
        return const Color(0xFFc7c3f4);
      }
      case 7: {
        //statements;
        return const Color(0xFFc3f4c7);
      }

      default: {
        return const Color(0xFFc3f4c7);
        //statements;
      }
    }


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

  bool isMoreThanAnHourBefore(DateTime dateTime) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(dateTime);
    return difference > Duration(hours: 1);
  }
}