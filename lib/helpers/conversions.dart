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
}