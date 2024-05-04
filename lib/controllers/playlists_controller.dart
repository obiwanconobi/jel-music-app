import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/models/playlists.dart';
import 'package:jel_music/repos/jellyfin_repo.dart';

class PlaylistsController{

  var playlistsList = <Playlists>[];

  late JellyfinHandler jellyfinHandler;
  PlaylistsController(){
      jellyfinHandler = GetIt.instance<JellyfinHandler>();
  }


  clearList(){
    playlistsList.clear();
  }

  Future<List<Playlists>> onInit() async {
    try {
     // await artistHelper.openBox();
      clearList();
    
      playlistsList = await jellyfinHandler.returnPlaylists();
      return playlistsList;
    } catch (error) {
      // Handle errors if needed
       rethrow;
    }
  }

}