import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:jel_music/helpers/apihelper.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:http/http.dart' as http;

class AlbumsHelper{

  late Box<Albums> albumsBox;
  var accessToken = GetStorage().read('accessToken');
  var baseServerUrl = GetStorage().read('serverUrl');
   ApiHelper apiHelper = ApiHelper();
  

  Future<void> closeBox()async{
   
  }

  Future<void> openBox()async{
     await Hive.openBox<Albums>('albums');
     albumsBox = Hive.box('albums');
  }

  bool isFavourite(String artist, String title){
    var ff = albumsBox.values.where((element) => element.artist == artist && element.name == title);
    var fff = albumsBox.values.where((element) => element.artist == artist);
      return albumsBox.values.where((element) => element.artist == artist && element.name == title).first.favourite ?? false;
  }

  List<Albums> returnAlbums(){
      return albumsBox.values.toList();
  }

  List<Albums> returnFavouriteAlbums(bool favourite){
      return albumsBox.values.where((albums) => albums.favourite == favourite).toList();
  }

  List<Albums> returnAlbumsForArtist(String artist){
    //var testx = artistBox.values.where((Artists) => Artists.name == "Jeff Rosenstock");
      return albumsBox.values.where((albums) => albums.artist == artist).toList();
  }

  Albums? returnAlbum(String artist, String album){
    return albumsBox.values.where((albums) => albums.artist!.toLowerCase() == artist.toLowerCase() && albums.name.toLowerCase() == album.toLowerCase()).firstOrNull;
  }

  updateAlbum(Albums album, int key){
    albumsBox.put(key,album);
  }

  addAlbumToBox(Albums album){
    albumsBox.add(album);
  }

  void clearAlbums(){
    albumsBox.clear();
  }

  void getAllAlbums()async{

      var albums = await fetchAlbums();

      for(var album in albums){
        albumsBox.put(album.id,album);
     }


  }


  
  getAlbumDataFavourite()async{
    return _getAlbumData();
  }

   _getAlbumData() async{
    var userId =  await GetStorage().read('userId');
       var requestHeaders = await apiHelper.returnJellyfinHeaders();
      String url = "$baseServerUrl/Users/$userId/Items?recursive=true&includeItemTypes=MusicAlbum&videoTypes=&enableTotalRecordCount=true&enableImages=true&isFavorite=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
   }

  Future<List<Albums>> fetchAlbums() async{
    var albumsRaw = await _getAlbumData();

    List<Albums> albumsList = [];

    for(var album in albumsRaw["Items"]){
      String albumId = album["Id"];
     
      var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      try{
        albumsList.add(Albums(id: album["Id"], name: album["Name"],artist: album["AlbumArtist"], year: album["ProductionYear"].toString(), picture: imgUrl, favourite: album["UserData"]["IsFavorite"], artistId: album["ArtistItems"][0]["Id"] ?? ""));
      }catch(e){
        //log error
      
      }
      
    }

    return albumsList;
  }


}