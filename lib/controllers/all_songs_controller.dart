import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/models/songs.dart' as Song;


class AllSongsController {
    var songs = <Song.Songs>[];
    String? artistId;
    bool? favouriteVal;
    final int currentArtistIndex = 0;
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    SongsHelper songsHelper = SongsHelper();


     Future<List<Song.Songs>> onInit() async {
    try {
      await songsHelper.openBox();
      songs = _getSongsFromBox(favouriteVal ?? false);
      return songs;
    } catch (error) {
      rethrow; // Rethrow the error if necessary
    }
  }

  

  List<Song.Songs> _getSongsFromBox(bool favourite){

      List<Songs> songsRaw = [];

      songsRaw = songsHelper.returnAllSongs();

      
      List<Song.Songs> songsList = [];
      for(var song in songsRaw){
        String albumId = song.albumId;
        var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
        //songsList.add(Songs(id: song.id, name: ))
        songsList.add(Song.Songs(id: song.id, trackNumber: song.index, title: song.name, album: song.album, artist: song.artist, artistId: song.artistId, albumPicture: imgUrl, favourite: song.favourite, length: song.length));
     //   songsList.add(Songs(index: song.index, id: song.id, name: song.name,artist: song.artist, year:song.year, albumId: imgUrl, artistId: song.artistId, album: song.album, length: song.length));
    
      }


      songsList.sort((a, b) => a.title!.compareTo(b.title!));
      return songsList;
  }

}
