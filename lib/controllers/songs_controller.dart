import 'dart:convert';
import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/apihelper.dart';
import 'package:jel_music/helpers/mappers.dart';
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
    Mappers mappers = Mappers();
    ApiHelper apiHelper = ApiHelper();
    final int currentArtistIndex = 0;
    String baseServerUrl = "";
    late IHandler jellyfinHandler;
    String serverType = "";
  Future<List<Songs>> onInit() async{

    try {
      baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
      serverType = GetStorage().read('ServerType') ?? "ERROR";
      jellyfinHandler = GetIt.instance<IHandler>(instanceName: serverType);
     // songs = await fetchSongs(albumId!);
     songs = await _getSongsFromBox(artistId!, albumId!);
      return songs;
    } catch (error) {
      // Handle errors if needed
     
      rethrow; // Rethrow the error if necessary
    }
  }

  uploadArt(String albumId, XFile xfile)async{
    File file = File(xfile.path);
    await jellyfinHandler.uploadArt(albumId, file);
  }

  tryGetArt(String artist, String album)async{
    await jellyfinHandler.tryGetArt(artist, album);
  }

  toggleFavouriteSong(String itemId, bool current)async{
    await jellyfinHandler.updateFavouriteStatus(itemId, current);
  }

  toggleFavourite(String artist, String title, bool favourite)async{
    await albumHelper.openBox();
    Albums? album = albumHelper.returnAlbum(artist, title);
    album!.favourite = favourite;
    albumHelper.updateAlbum(album, album.key);

    if(serverType == "Jellyfin"){
      jellyfinHandler.updateFavouriteStatus(album.id, !favourite);
    }else if(serverType == "PanAudio"){
      jellyfinHandler.updateFavouriteAlbum(album.id, favourite);
    }


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
      return await mappers.convertHiveSongsToModelSongs(songsRaw);
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
