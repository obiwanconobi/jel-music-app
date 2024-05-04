import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/models/playlists.dart';
import 'package:jel_music/models/songs.dart';
import 'package:jel_music/repos/jellyfin_repo.dart';

class PlaylistController{

  var playlistList = <Songs>[];
  String playlistId = "";
  late JellyfinHandler jellyfinHandler;
  PlaylistController(){
      jellyfinHandler = GetIt.instance<JellyfinHandler>();
  }


  clearList(){
    playlistList.clear();
  }

  Future<List<Songs>> onInit() async {
    try {
      clearList();
      playlistList = await jellyfinHandler.returnSongsFromPlaylist(playlistId);
      return playlistList;
    } catch (error) {
      // Handle errors if needed
       rethrow;
    }
  }

  Future<void> deleteSongFromPlaylist(String songId, String playlistId)async{
    await jellyfinHandler.deleteSongFromPlaylist(songId, playlistId);
  }

}