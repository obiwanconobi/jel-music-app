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

  Duration parseTimeStamp(String timestamp) {
    //timestamp.replaceRange(0, 0, "");
    //timestamp.replaceRange(timestamp.length, timestamp.length, "")
    timestamp = timestamp.replaceAll('[', '');
    timestamp = timestamp.replaceAll(']', '');
    // Assuming timestamp format is "mm:ss.ms" or similar
    // You'll need to adjust this based on your actual timestamp format
    List<String> parts = timestamp.split(':');
    int minutes = int.parse(parts[0]);

    List<String> secondsParts = parts[1].split('.');
    int seconds = int.parse(secondsParts[0]);
    int milliseconds = secondsParts.length > 1 ? int.parse(secondsParts[1]) : 0;

    return Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: milliseconds
    );
  }

  Log returnLogFromLogModel(LogModel log){
    return Log(id: log.id!, logType: log.logType!, logMessage: log.logMessage!, logDateTime: log.logDateTime!);
  }

  LogModel returnLogModelFromLog(Log log){
   return LogModel(id: log.id, logType: log.logType, logMessage: log.logMessage, logDateTime: log.logDateTime);
  }

  codecCleanup(String codec){
      if(codec.startsWith('PCM'))return "wav";
      if(codec.startsWith('AAC'))return "m4a";
      if(codec.startsWith('ALAC'))return "m4a";
      if(codec.startsWith('FLAC'))return "flac";
      if(codec.startsWith('MP3'))return "mp3";
      
  }

  String returnSecondsFromTimeStamp(DateTime time){
    return "";
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
    return input.split(' ')
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
        return const Color(0xff9a9bc3);
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
        return const Color(0xffdfffe2);
      }

      default: {
        return const Color(0xffa3bfff);
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
    return difference > const Duration(hours: 1);
  }
}