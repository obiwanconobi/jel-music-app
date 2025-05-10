import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/helpers/mappers.dart';
import 'package:jel_music/hive/classes/songs.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/models/songs.dart';


class AllSongsController {
    var songs = <ModelSongs>[];
    String? artistId;
    bool? favouriteVal;
    final int currentArtistIndex = 0;
    String baseServerUrl = "";
    SongsHelper songsHelper = SongsHelper();
    Mappers mappers = Mappers();
    late IHandler jellyfinHandler;

    Future<List<ModelSongs>> onInit() async {
      baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
      var serverType = GetStorage().read('ServerType') ?? "Jellyfin";
      jellyfinHandler = GetIt.instance<IHandler>(instanceName: serverType);

      try {
        await songsHelper.openBox();
        clearSongsList();
        songs = _getSongsFromBox(favouriteVal ?? false);
        return songs;
      } catch (error) {
        rethrow; // Rethrow the error if necessary
      }


  }

  clearSongsList(){
    songs.clear();
  }

  AllSongsController(){

  }
  
  orderByNameAsc(){
    songs.sort((a, b) => a.title!.compareTo(b.title!));
  }

  orderByNameDesc(){
    songs.sort((a, b) => b.title!.compareTo(a.title!));
  }

  shuffleOrder(){
    songs.shuffle();
  }

  toggleFavouriteSong(String itemId, bool current)async{
      await jellyfinHandler.updateFavouriteStatus(itemId, current);
  }

  List<ModelSongs> _getSongsFromBox(bool favourite){

      List<Songs> songsRaw = [];
      songsRaw = songsHelper.returnAllSongs();
      
      
      List<ModelSongs> songsList = [];
      for(var songRaw in songsRaw){
        var imgUrl = mappers.getImageUrl(songRaw.albumId);
        //songsList.add(Songs(id: song.id, name: ))
        songsList.add(ModelSongs(id: songRaw.id, trackNumber: songRaw.index, title: songRaw.name, album: songRaw.album, artist: songRaw.artist, artistId: songRaw.artistId, albumPicture: imgUrl, favourite: songRaw.favourite, length: songRaw.length, bitrate: songRaw.bitrate, bitdepth: songRaw.bitdepth, samplerate: songRaw.samplerate, codec: songRaw.codec));
     //   songsList.add(Songs(index: song.index, id: song.id, name: song.name,artist: song.artist, year:song.year, albumId: imgUrl, artistId: song.artistId, album: song.album, length: song.length));
    
      }

      songsList.shuffle();
    //  songsList.sort((a, b) => a.title!.compareTo(b.title!));
      return songsList;
  }

}
