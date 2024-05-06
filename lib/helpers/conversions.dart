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