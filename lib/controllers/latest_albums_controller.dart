import 'package:get_it/get_it.dart';
import 'package:jel_music/handlers/jellyfin_handler.dart';
import 'package:jel_music/handlers/panaudio_handler.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/models/album.dart';
import 'package:get_storage/get_storage.dart';


class LatestAlbumsController {
    var albums = <Album>[];
    String? artistId;
    bool? favouriteVal;
    final int currentArtistIndex = 0;
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    AlbumsHelper albumHelper = AlbumsHelper();
    //JellyfinHandler jellyfinHandler = JellyfinHandler();
     var jellyfinHandler = GetIt.instance<JellyfinHandler>();
      var panaudioHandler = GetIt.instance<PanaudioHandler>();

     Future<List<Album>> onInit() async {
      var serverType = GetStorage().read('ServerType');
    try {
     // await albumHelper.openBox();
      if(serverType == "Jellyfin"){
        albums = await jellyfinHandler.returnLatestAlbums();
      }else if(serverType == "PanAudio"){
        albums = await panaudioHandler.returnLatestAlbums();
      }

      return albums;
    } catch (error) {
      rethrow; // Rethrow the error if necessary
    }
  }

  

  List<Album> _getAlbumsFromBox(bool favourite){

      List<Albums> albumsRaw = [];

      if(favourite == true){
        albumsRaw = albumHelper.returnFavouriteAlbums(true);
      }else{
        albumsRaw = albumHelper.returnAlbums();
      }

      
      List<Album> albumsList = [];
      for(var album in albumsRaw){
        String albumId = album.id;
        var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
        albumsList.add(Album(id: album.id, title: album.name,artist: album.artist, year: int.parse(album.year!), picture: imgUrl));
      }

      albumsList.sort((a, b) => a.title!.compareTo(b.title!));
      return albumsList;
  }

}
