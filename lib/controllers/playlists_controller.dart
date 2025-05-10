import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/models/playlists.dart';

class PlaylistsController{

  var playlistsList = <Playlists>[];
  String serverType = "";


  late IHandler handler;

  clearList(){
    playlistsList.clear();
  }

  Future<List<Playlists>> onInit() async {
    serverType = GetStorage().read('ServerType') ?? "Jellyfin";
    handler = GetIt.instance<IHandler>(instanceName: serverType);
    try {
     // await artistHelper.openBox();
      clearList();
    
      playlistsList = await handler.returnPlaylists();
      return playlistsList;
    } catch (error) {
      // Handle errors if needed
       rethrow;
    }
  }

  Future<List<Playlists>> getPlaylists()async{
    try {
      // await artistHelper.openBox();
      clearList();

      playlistsList = await handler.returnPlaylists();
      return playlistsList;
    } catch (error) {
      // Handle errors if needed
      rethrow;
    }
  }

}