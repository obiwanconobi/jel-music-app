import 'package:jel_music/hive/classes/albums.dart';
import 'package:jel_music/hive/helpers/albums_hive_helper.dart';
import 'package:jel_music/models/album.dart';
import 'package:get_storage/get_storage.dart';


class AllAlbumsController {
    var albums = <Album>[];
    String? artistId;
    bool? favouriteVal;
    final int currentArtistIndex = 0;
    String baseServerUrl = GetStorage().read('serverUrl') ?? "ERROR";
    AlbumsHelper albumHelper = AlbumsHelper();


     Future<List<Album>> onInit() async {
    try {
      await albumHelper.openBox();
      albums = _getAlbumsFromBox(favouriteVal ?? false);
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
