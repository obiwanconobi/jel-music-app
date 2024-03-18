import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:jel_music/hive/classes/albums.dart';
import 'package:http/http.dart' as http;

class AlbumsHelper{

  late Box<Albums> albumsBox;
  var accessToken = GetStorage().read('accessToken');
  var baseServerUrl = GetStorage().read('serverUrl');
  



  Future<void> openBox()async{
     await Hive.openBox<Albums>('albums');
     albumsBox = Hive.box('albums');
  }

  bool isFavourite(String artist, String title){
      return albumsBox.values.where((Albums) => Albums.artist == artist && Albums.name == title).first.favourite ?? false;
  }

  List<Albums> returnAlbums(bool favourite){
      return albumsBox.values.where((Albums) => Albums.favourite == favourite).toList();
  }

  List<Albums> returnAlbumsForArtist(String artist){
    //var testx = artistBox.values.where((Artists) => Artists.name == "Jeff Rosenstock");
      return albumsBox.values.where((Albums) => Albums.artist == artist).toList();
  }

  Albums? returnAlbum(String artist, String album){
    return albumsBox.values.where((Albums) => Albums.artist == artist && Albums.name == album).firstOrNull;
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
      try {
          Map<String, String> requestHeaders = {
          'Content-type': 'application/json',
          'X-MediaBrowser-Token': '$accessToken',
          'X-Emby-Authorization': 'MediaBrowser Client="Jellyfin Web",Device="Chrome",DeviceId="TW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEyMS4wLjAuMCBTYWZhcmkvNTM3LjM2fDE3MDc5Mzc2MDIyNTI1",Version="10.8.13"'
        };
      String url = "$baseServerUrl/Users/D8B7A1C3-8440-4C88-80A1-04F7119FAA7A/Items?recursive=true&includeItemTypes=MusicAlbum&videoTypes=&enableTotalRecordCount=true&enableImages=true&isFavorite=true";
      http.Response res = await http.get(Uri.parse(url), headers: requestHeaders);
      if (res.statusCode == 200) {
        return json.decode(res.body);
      }
    } catch (e) {
      rethrow;
    }
   }

  Future<List<Albums>> fetchAlbums() async{
    var albumsRaw = await _getAlbumData();

    List<Albums> albumsList = [];

    for(var album in albumsRaw["Items"]){
      String albumId = album["Id"];
      String artistname = album["AlbumArtist"];
      String artt = album["ArtistItems"][0]["Id"];

      String albumNamme = album["Name"];
      if(albumNamme == "California"){
        print("stop");
      }
      if(albumNamme == "Dude Ranch"){
        print("stop");
      }
      if(artistname.contains("link")){
        print('stop');
      }
      var imgUrl = "$baseServerUrl/Items/$albumId/Images/Primary?fillHeight=480&fillWidth=480&quality=96";
      try{
        albumsList.add(Albums(id: album["Id"], name: album["Name"],artist: album["AlbumArtist"], year: album["ProductionYear"].toString(), picture: imgUrl, favourite: album["UserData"]["IsFavorite"], artistId: album["ArtistItems"][0]["Id"] ?? ""));
      }catch(e){
        //log error
        print("error");
      }
      
    }

    return albumsList;
  }


}