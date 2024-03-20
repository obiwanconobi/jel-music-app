import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:http/http.dart' as http;

class SongsHelper{

  late Box<Songs> songsBox;
  var accessToken = GetStorage().read('accessToken');
  var baseServerUrl = GetStorage().read('serverUrl');

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

  List<Songs> returnSongsFromAlbum(String artist, String album){
    return songsBox.values.where((Songs) => Songs.artist == artist && Songs.album == album).toList();
  }

  clearSongs(){
    songsBox.clear();
  }

  Future<void> openBox()async{
     await Hive.openBox<Songs>('songs');
     songsBox = Hive.box('songs');
  }

  closeBox()async{
    await Hive.close();
  }

  returnSongs()async{
    return songsBox.values.toList();
  }

  returnFavouriteSongs()async{
    return songsBox.values.where((Songs) => Songs.favourite == true).toList();
  }

  

   addSongsToBox()async{
    List<Songs> songsList = [];
    var songs = await _getSongsDataRaw();

    for(var song in songs["Items"]){
        try{
          songsList.add(Songs(id: song["Id"], name: song["Name"], artist: song["ArtistItems"][0]["Name"], artistId: song["ArtistItems"][0]["Id"], album: song["Album"], albumId: song["AlbumId"], index: song["IndexNumber"] ?? 0, year: song["ProductionYear"] ?? 0, length: _ticksToTimestampString(song["RunTimeTicks"] ?? 0), favourite: song["UserData"]["IsFavorite"]));
        }catch(e){
         
        }
     }
     for(var song in songsList){
        songsBox.add(song);
     }

  }

  _getSongsDataRaw() async{
    var userId = GetStorage().read('userId');
      try {
          Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'X-MediaBrowser-Token': '$accessToken',
          'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
        };
      String url = "$baseServerUrl/Users/$userId/Items?recursive=true&includeItemTypes=Audio&enableUserData=true&enableTotalRecordCount=true&enableImages=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
   }

}