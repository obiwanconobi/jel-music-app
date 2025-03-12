import 'package:jel_music/handlers/lrclib_handler.dart';
import 'package:jel_music/providers/music_controller_provider.dart';

class LyricsPageController{
  LrclibHandler handler = LrclibHandler();
  String artist = "";
  String track = "";
  Future<String> onInit() async {
    try {
      var value = await handler.getLyrics(artist,track);
     // return new Map<value["syncedLyrics"], "Synced">;
      return value["syncedLyrics"] ?? value["plainLyrics"];
    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }


}