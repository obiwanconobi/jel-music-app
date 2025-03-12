import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/hive/helpers/songs_hive_helper.dart';

class SongsListItemController{

  String baseServerUrl = "";
  late IHandler jellyfinHandler;
  String serverType = "";
  SongsHelper songsHelper = SongsHelper();



  onInit() async{

    try {
      baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
      serverType = GetStorage().read('ServerType') ?? "ERROR";
      jellyfinHandler = GetIt.instance<IHandler>(instanceName: serverType);
      // songs = await fetchSongs(albumId!);

    } catch (error) {
      // Handle errors if needed

      rethrow; // Rethrow the error if necessary
    }
  }

  toggleFavouriteSong(String itemId, bool current)async{
    try{
      await jellyfinHandler.updateFavouriteStatus(itemId, current);
    }catch(e){
      //print(e);
    }

  }

  Future<bool> addSongToPlaylist(String songId, String playlistId)async{
   return await jellyfinHandler.addSongToPlaylist(songId, playlistId);
  }
  favouriteSong(String songId, String artist, String title, bool current)async{
    await songsHelper.openBox();

    if(current){
      //unfavourite
      await toggleFavouriteSong(songId, false);
      await songsHelper.likeSong(artist, title, false);
      //updateSong(index, true);
    }else{
      //favourite
      await toggleFavouriteSong(songId, true);
      await songsHelper.likeSong(artist, title, true);
      //updateSong(index, false);
    }
  }



  returnPlaylists()async{
    var playlistsRaw =  await jellyfinHandler.returnPlaylists();
    return playlistsRaw;
  }
}