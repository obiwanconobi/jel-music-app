import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/helpers/apihelper.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';
import 'package:get_storage/get_storage.dart';


class SongsController {
    var songs = <Songs>[];
    String? albumId;
    String? artistId;
    SongsHelper songsHelper = SongsHelper();
    AlbumsHelper albumHelper = AlbumsHelper();
    ApiHelper apiHelper = ApiHelper();
    final int currentArtistIndex = 0;
    String baseServerUrl = "";
    JellyfinHandler jellyfinHandler = GetIt.instance<JellyfinHandler>();
    String serverType = "";
  Future<List<Songs>> onInit() async{

    try {
      baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
      serverType = GetStorage().read('ServerType') ?? "ERROR";
     // songs = await fetchSongs(albumId!);
     songs = await _getSongsFromBox(artistId!, albumId!);
      return songs;
    } catch (error) {
      // Handle errors if needed
     
      rethrow; // Rethrow the error if necessary
    }
  }

  toggleFavouriteSong(String itemId, bool current)async{
    await jellyfinHandler.updateFavouriteStatus(itemId, current);
  }

  toggleFavourite(String artist, String title, bool favourite)async{
    await albumHelper.openBox();
    Albums? album = albumHelper.returnAlbum(artist, title);
    album!.favourite = favourite;
    albumHelper.updateAlbum(album, album.key);
    jellyfinHandler.updateFavouriteStatus(album.id, !favourite);
  }

  Future<bool> returnFavourite(String artist, String album)async{
    await albumHelper.openBox();
   // return albumHelper.isFavourite(artist, album);
   var albumFull = albumHelper.returnAlbum(artist, album);
    return albumFull?.favourite ?? false;
  }

 
  returnPlaylists()async{
      var playlistsRaw =  await jellyfinHandler.returnPlaylists();
      return playlistsRaw;
  }

  Future<void> addSongToPlaylist(String songId, String playlistId)async{
    await jellyfinHandler.addSongToPlaylist(songId, playlistId);
  }

  Future<List<Songs>> returnDownloaded()async{
    await songsHelper.openBox();
    return songsHelper.returnDownloadedSongs();
  }

  setDownloaded(String id)async{
    await songsHelper.openBox();
    await songsHelper.setDownloaded(id);
  }

  _getSongsFromBox(String artist, String album)async{
      await songsHelper.openBox();
      var songsRaw = songsHelper.returnSongsFromAlbum(artist, album);
      return await convertHiveSongsToModelSongs(songsRaw);
  }

  Future<List<Songs>> convertHiveSongsToModelSongs(dynamic songsRaw)async{
    List<Songs> songsList = [];
    for(var song in songsRaw){
      String songId = song.albumId;
      String imgUrl = "";
      if(serverType == "Jellyfin"){
        imgUrl = "$baseServerUrl/Items/$songId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      }else if (serverType == "PanAudio"){
         imgUrl = "$baseServerUrl/api/albumArt?albumId=${song.albumId}";
      }


      songsList.add(Songs(id: song.id, trackNumber: song.index, artistId: song.artistId, title: song.name,
          artist: song.artist, albumPicture: imgUrl, album: song.album, albumId: song.albumId, length: song.length,
          favourite: song.favourite, discNumber: song.discIndex, downloaded: song.downloaded, codec: song.codec,
          bitrate: song.bitrate, bitdepth: song.bitdepth, samplerate: song.samplerate
      ));
    }
    songsList.sort((a, b) {
      // First compare discNumber
      int discComparison = a.discNumber!.compareTo(b.discNumber ?? 0);

      // If discNumber is the same, then compare trackNumber
      if (discComparison == 0) {
        return a.trackNumber!.compareTo(b.trackNumber ?? 0);
      } else {
        return discComparison;
      }
    });

    return songsList;
  }

   _getSongsData(String albumIdVal) async{
      try {
        var accessToken = await GetStorage().read('accessToken');
        String albumId = albumIdVal;
        var userId = await GetStorage().read('userId');
           var requestHeaders = await apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/Users/$userId/Items?recursive=true&excludeItemTypes=&includeItemTypes=&albumIds=$albumId&enableTotalRecordCount=true&enableImages=true";
      
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
        try{
          String songId = song["Id"];
          int trackNumber = song["IndexNumber"] ?? 0;
          String length = _ticksToTimestampString(song["RunTimeTicks"] ?? 0);
          var imgUrl = "$baseServerUrl/Items/$songId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
          songsList.add(Songs(id: song["Id"], trackNumber: trackNumber, artistId: song["ArtistItems"][0]["Id"], title: song["Name"],artist: song["ArtistItems"][0]["Name"], albumPicture: imgUrl, album: song["Album"], albumId: song["AlbumId"], length: length, favourite: song["UserData"]["IsFavorite"]));
        }catch(e){
          //log error
        }
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
