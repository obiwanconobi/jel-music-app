import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jel_music/handlers/ihandler.dart';
import 'package:jel_music/models/playlists.dart';

class PlaylistsController{

  var playlistsList = <Playlists>[];
  String serverType = GetStorage().read('ServerType') ?? "Jellyfin";


  late IHandler handler;
  PlaylistsController(){
    if(serverType == "Roboto"){
      GetStorage().write('ServerType', "Jellyfin");
      serverType = "Jellyfin";
    }
    handler = GetIt.instance<IHandler>(instanceName: serverType);
  }


  clearList(){
    playlistsList.clear();
  }

  Future<List<Playlists>> onInit() async {
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