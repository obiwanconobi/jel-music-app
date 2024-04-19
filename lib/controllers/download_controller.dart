import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/controllers/music_controller.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:jel_music/models/songs.dart';

class DownloadController{

    SongsHelper songsHelper = SongsHelper();
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    var songs = <Songs>[];
  Future<List<Songs>> onInit() async {
    try {
     // songs = await fetchSongs(albumId!);
     songs = await _getSongsFromBox();
      return songs;
    } catch (error) {
      // Handle errors if needed
     
      rethrow; // Rethrow the error if necessary
    }
  }

  _getSongsFromBox()async{
      await songsHelper.openBox();
      var songsRaw =  await songsHelper.returnDownloadedSongs();
      List<Songs> songsList = [];
      for(var song in songsRaw){
             String songId = song.albumId;
             var imgUrl = "$baseServerUrl/Items/$songId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
        songsList.add(Songs(id: song.id, trackNumber: song.index, artistId: song.artistId, title: song.name,artist: song.artist, albumPicture: imgUrl, album: song.album, albumId: song.albumId, length: song.length, favourite: song.favourite, discNumber: song.discIndex, downloaded: song.downloaded));
      }
      return songsList;
  }

}