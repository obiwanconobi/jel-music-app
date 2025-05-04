import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/models/songs.dart';

class PlaylistController{

  var playlistList = <ModelSongs>[];
  String playlistId = "";
  var serverType = GetStorage().read('ServerType');
  late IHandler handler;
  PlaylistController();


  clearList(){
    playlistList.clear();
  }

  Future<List<ModelSongs>> onInit() async {
    handler = GetIt.instance<IHandler>(instanceName: serverType);
    try {
      clearList();
      playlistList = await handler.returnSongsFromPlaylist(playlistId);
      return playlistList;
    } catch (error) {
      // Handle errors if needed
       rethrow;
    }
  }

  Future<List<ModelSongs>> getPlaylistData(String playlistId)async{
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