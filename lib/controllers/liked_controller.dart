import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';
import 'package:get_storage/get_storage.dart';


class LikedController {
    var songs = <Songs>[];
  
    final int currentArtistIndex = 0;
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    SongsHelper  songsHelper = SongsHelper();
     Future<List<Songs>> onInit() async {
    try {
      songs = await fetchSongs();
      return songs;
    } catch (error) {
      // Handle errors if needed
     
      rethrow; // Rethrow the error if necessary
    }
  }

    _getFavouriteSongsFromBox()async{
      await songsHelper.openBox();
      return songsHelper.returnFavouriteSongs();
      }


   _getSongsData() async{
      try {
        var accessToken = GetStorage().read('accessToken');
        var userId = GetStorage().read('userId');
          Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'X-MediaBrowser-Token': '$accessToken',
          'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
        };
      String url = "$baseServerUrl/Users/$userId/Items?recursive=true&includeItemTypes=Audio&isFavorite=true&enableTotalRecordCount=true&enableImages=true";
      
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      //  var test = (result as List).map((e) => DailyModel.fromJson(e)).toList();
      //  _isLoading = false;
       // setState(() {});
      }
    } catch (e) {
      //log error
    }
   }

  Future<List<Songs>> fetchSongs() async{
    var songsRaw = await _getFavouriteSongsFromBox();

    List<Songs> songsList = [];
    for(var song in songsRaw){
      String songId = song.albumId;
   //   int trackNumber = song["Index"] ?? 0;
   //   String length = _ticksToTimestampString(song["RunTimeTicks"]);
      var imgUrl = "$baseServerUrl/Items/$songId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      try{
        songsList.add(Songs(id: song.id, trackNumber: song.index, artistId: song.artistId, title: song.name,artist: song.artist, albumPicture: imgUrl, album: song.album, albumId: song.albumId, length: song.length, favourite: song.favourite));
      }catch(e){
        
      }
    }
  //  songsList.sort((a, b) => a.trackNumber!.compareTo(b.trackNumber ?? 0));
    songsList.shuffle();
     return songsList;
  }


    String _ticksToTimestampString(int ticks) {
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
