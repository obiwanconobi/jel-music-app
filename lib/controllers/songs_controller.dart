import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jel_music/models/songs.dart';
import 'package:get_storage/get_storage.dart';


class SongsController {
    var songs = <Songs>[];
    String? albumId;
    final int currentArtistIndex = 0;
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";

     Future<List<Songs>> onInit() async {
    try {
      songs = await fetchSongs(albumId!);
      return songs;
    } catch (error) {
      // Handle errors if needed
     
      rethrow; // Rethrow the error if necessary
    }
  }

   _getSongsData(String albumIdVal) async{
      try {
        var accessToken = GetStorage().read('accessToken');
        String albumId = albumIdVal;
        
          Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'X-MediaBrowser-Token': '$accessToken',
          'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
        };
      String url = "$baseServerUrl/Users/D8B7A1C3-8440-4C88-80A1-04F7119FAA7A/Items?recursive=true&excludeItemTypes=&includeItemTypes=&albumIds=$albumId&enableTotalRecordCount=true&enableImages=true";
      
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

  Future<List<Songs>> fetchSongs(String albumId) async{
    var songsRaw = await _getSongsData(albumId);

    List<Songs> songsList = [];

    for(var song in songsRaw["Items"]){
      String songId = song["Id"];
      int trackNumber = song["IndexNumber"] ?? 0;
      String length = _ticksToTimestampString(song["RunTimeTicks"]);
      var imgUrl = "$baseServerUrl/Items/$songId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      songsList.add(Songs(id: song["Id"], trackNumber: trackNumber, artistId: song["ArtistItems"][0]["Id"], title: song["Name"],artist: song["ArtistItems"][0]["Name"], albumPicture: imgUrl, album: song["Album"], albumId: song["AlbumId"], length: length, favourite: song["UserData"]["IsFavorite"]));
    }
    songsList.sort((a, b) => a.trackNumber!.compareTo(b.trackNumber ?? 0));
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
