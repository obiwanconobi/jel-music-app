import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/models/songs.dart';

class PlaylistController{

  var playlistList = <Songs>[];
  String playlistId = "";
  var serverType = GetStorage().read('ServerType');
  late IHandler handler;
  PlaylistController(){
      handler = GetIt.instance<IHandler>(instanceName: serverType);
  }


  clearList(){
    playlistList.clear();
  }

  Future<List<Songs>> onInit() async {
    try {
      clearList();
      playlistList = await handler.returnSongsFromPlaylist(playlistId);
      return playlistList;
    } catch (error) {
      // Handle errors if needed
       rethrow;
    }
  }

  Future<List<Songs>> getPlaylistData(String playlistId)async{
    try {
      clearList();
      playlistList = await handler.returnSongsFromPlaylist(playlistId);
      return playlistList;
    } catch (error) {
      // Handle errors if needed
      rethrow;
    }
  }

  Future<void> deleteSongFromPlaylist(String songId, String playlistId)async{
    await handler.deleteSongFromPlaylist(songId, playlistId);
  }

}